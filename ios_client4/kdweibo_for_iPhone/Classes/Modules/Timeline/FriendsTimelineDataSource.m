//
//  FriendsTimelineDataSource.m
//  TwitterFon
//
//  Created by kaz on 12/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "FriendsTimelineDataSource.h"
#import "FriendsTimelineController.h"
#import "KDWeiboAppDelegate.h"

#import "ProfileViewController.h"
#import "KDStatusDetailViewController.h"

#import "RefreshTableFootView.h"
#import "KDErrorDisplayView.h"
#import "KDStatusContentView.h"

#import "KDStatusCounts.h"

#import "KDWeiboServicesContext.h"
#import "KDRequestDispatcher.h"
#import "KDDatabaseHelper.h"
#import "KDStatusLayouter.h"
#import "KDStatusCell.h"

@interface FriendsTimelineDataSource()

@property(nonatomic, assign)NSInteger pageIndex;
@end

@implementation FriendsTimelineDataSource

@synthesize controller = controller_;
@synthesize reloading = reloading_;
@synthesize dataset=dataset_;

@synthesize pageIndex = pageIndex_;

@synthesize timelineType = timelineType_;

- (id)initWithController:(UIViewController*)aController type:(KDTLStatusType)type {
    self = [super init];
    if(self) {
        controller_ = (FriendsTimelineController*)aController;
        reloading_ = NO;
        pageIndex_ = 1;
        dataset_ = [[KDStatusDataset alloc] init];
        timelineType_ = type;
    }
    
    return self;
}

- (void)restore {
    [controller_ initRefreshTableView];
    [controller_ shouldShowBlankHolderView:YES];
    //去本地微博
    if([dataset_ count] > 0)
    {
        [self getTimeline:YES];
        return;
    }
    
    [self asyncLoadCachedStatusWithCompletionBlock:^(void) {
        [controller finishRefreshed:NO];
        [controller_ reloadTableView];
        
        [self getTimeline:YES];
    }];
    
}

- (void)showNodataTipsView {
    //[self.dataset removeAllStatuses];
    [controller_ showTipsOrNot];
}

- (void)asyncLoadCachedStatusWithCompletionBlock:(void (^)(void))completionBlock {
    if (![self isHotCommentsTimeline]) {
        [KDStatusDataset cachedStatusesWithType:self.timelineType
                                completionBlock:^(NSArray *statuses){
                                    
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                        if (statuses != nil && [statuses count] > 0) {
                                            [statuses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop) {
                                                //zgbin:去除缓存cell了
                                                //                                                [KDStatusLayouter  statusLayouter:obj constrainedWidth:self.controller.view.bounds.size.width - 16];
                                                //zgbin:end
                                                
                                            }];
                                            
                                            [dataset_ mergeStatuses:statuses atHead:YES limit:-1];
                                        }
                                        
                                        if (completionBlock != nil) {
                                            dispatch_sync(dispatch_get_main_queue(), ^(void){
                                                completionBlock();
                                                
                                            });
                                        }
                                    });
                                    
                                    
                                }];
    }else {
        if (completionBlock != nil) {
            completionBlock();
        }
    }
    
    
}


- (BOOL)isHotCommentsTimeline {
    KDTLStatusType timelineType = self.timelineType;
    return (KDTLStatusTypeHotComment == timelineType) ? YES : NO;
}

///////////////////////////////////////////////////////////////////////////


- (void)_handleTimelineStatuses:(NSArray *)statuses isLoadLatest:(BOOL)isLoadLatest
          isHotCommentsTimeline:(BOOL)isHotCommentsTimeline {
    
    if(!isHotCommentsTimeline && isLoadLatest){
        [[KDManagerContext globalManagerContext].unreadManager didChangeTimelineBadgeValue:YES];
    }
    
    NSUInteger count = [statuses count];
    if (count > 0) {
        // if the data source is hot comments, clear the cached data source
        if (isLoadLatest && isHotCommentsTimeline) {
            [dataset_ removeAllStatuses];
            [self.controller removeAllCellCache];
        }
        
        // combine statuses into main timeline
        [dataset_ mergeStatuses:statuses atHead:isLoadLatest limit:-1];
        [controller_ reloadTableView];
        
        if (isLoadLatest) {
            
            [controller_ showPrompView:count];
            
        } else {
            // load the fowards and comments count
            [self getTimelineIDS:statuses];
        }
        
        if (!isHotCommentsTimeline) {
            // save the statuses into database
            [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
                id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
                [statusDAO saveStatuses:statuses database:fmdb rollback:rollback];
                
                return nil;
                
            } completionBlock:nil];
        }
        
    }
}

- (KDQuery *)_buildRequestQuery:(BOOL)isLoadLatest isHotCommentsTimeline:(BOOL)isHotCommentsTimeline {
    NSInteger count = 20;
    KDQuery *query = [KDQuery query];
    
    if(isHotCommentsTimeline){
        NSInteger pageCursor = isLoadLatest ? 1 : (pageIndex_ + 1);
        
        [[query setParameter:@"count" intValue:(int)count]
         setParameter:@"page" intValue:(int)pageCursor];
    }else {
        NSString *sinceId = nil;
        NSString *maxId = nil;
        
        NSString *oldSinceId = nil;
        
        if(isLoadLatest){
            count = 50;
            if([[dataset_ allStatuses] count] > 0){
                //KDStatus *sts = [dataset_ statusAtIndex:0];
                KDStatus *sts = [dataset_ sinceStatus];
                sinceId = sts.statusId;
                oldSinceId = sts.statusId;
            }
            
        }else {
            NSUInteger statusesCount = [[dataset_ allStatuses] count];
            if(statusesCount > 0){
                //KDStatus *sts = [dataset_ statusAtIndex:statusesCount - 1];
                KDStatus *sts = [dataset_ maxStatus];
                maxId = sts.statusId;
            }
        }
        
        [query setParameter:@"count" intValue:(int)count];
        if(sinceId != nil){
            [query setParameter:@"since_id" stringValue:sinceId];
        }
        
        if(maxId != nil){
            [query setParameter:@"max_id" stringValue:maxId];
        }
        if(oldSinceId != nil){
            [query setParameter:@"oldsince_id" stringValue:oldSinceId];
        }
    }
    return query;
}


- (void)getTimeline:(BOOL)isLatest {
    if (reloading_) {
        return;
    }
    
    [KDServiceActionInvoker cancelInvokersWithSender:self];// 将之前的请求取消，特别是获取回复数和转发数的请求，因为比较慢。
    reloading_ = YES;
    if (isLatest) {
        [controller_ initRefreshTableView];
    }
    BOOL isHotCommentsTimeline = [self isHotCommentsTimeline];
    KDQuery *query = [self _buildRequestQuery:isLatest isHotCommentsTimeline:isHotCommentsTimeline];
    
    __block FriendsTimelineDataSource *ds = self;// retain];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        BOOL successful = NO;
        NSInteger count = 0;
        ds->reloading_ = NO;
        if ([response isValidResponse]) {
            successful = YES;
            if (results != nil) {
                count = [(NSArray *)results count];
                NSMutableArray *statusArray = [[NSMutableArray alloc]init];
                [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop) {
                    //新增的微博
                    if ([obj isKindOfClass:[KDStatus class]]) {
                        //zgbin:去除cell的缓存
                        //                         KDLayouter * layouter =   [KDStatusLayouter  statusLayouter:obj constrainedWidth:ds.controller.view.bounds.size.width - 16];
                        //                         KDLayouterView * layouterView = [layouter view];
                        //                         KDStatusCell * cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];// autorelease];
                        //                         [cell addSubview:layouterView];
                        //                         cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        //                         layouterView.layouter = layouter;
                        //                         [ds.controller.cellCache setObject:cell forKey:[(KDStatus *)obj statusId] cost:1];
                        //zgbin:end
                        [statusArray addObject:obj];
                        //
                    }else
                    {
                        //根据服务器返回的微博id删除本地数据
                        [dataset_ removeStatusesById:obj];
                    }
                    
                }];
                [ds _handleTimelineStatuses:statusArray isLoadLatest:isLatest isHotCommentsTimeline:isHotCommentsTimeline];
                
                if(isHotCommentsTimeline){
                    ds.pageIndex = isLatest ? 1 : (ds.pageIndex + 1);
                }
            }
            if (isLatest ){
                // load the fowards and comments count
                [ds getTimelineIDS:[ds.dataset allStatuses]];
                ds.controller.hasFooterView = ([ds.dataset count] >= 20);
                
            }else {
                ds.controller.hasFooterView = (count > 0);
            }
            
        }
        else {
            if (![response isCancelled]) {
                if ([response statusCode] == 401) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kKDTokenExpiredNotification object:nil userInfo:nil];
                    
                }else if([response statusCode] == 403) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[response.responseDiagnosis networkErrorMessage] delegate:nil cancelButtonTitle:ASLocalizedString(@"FriendsTimelineDataSource_tips_1")otherButtonTitles:nil];
                    [alert show];
                    //                    [alert release];
                }else {
                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                                  inView:ds.controller.view.window];
                }
            }else {
                DLog(@"cancel.....");
            }
        }
        
        [ds showNodataTipsView];
        if (isLatest) {
            [ds.controller finishRefreshed:successful];
            
        } else {
            [ds.controller finishLoadMore];
        }
        
        // release the data source
        //        [ds release];
    };
    
    NSString *actionPath = nil;
    if(self.timelineType == KDTLStatusTypePublic){
        actionPath = @"/statuses/:publicTimeline";
        
    }else if(self.timelineType == KDTLStatusTypeFriends){
        actionPath = @"/statuses/:friendsTimeline";
        
    }else if(isHotCommentsTimeline){
        actionPath = @"/statuses/:hotComments";
    }else if(self.timelineType == KDTLStatusTypeBulletin) {
        actionPath = @"/statuses/:bulletins";
    }
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)loadLatestStatus {
    [self getTimeline:YES];
}
- (void)loadEarlierStatus {
    [self getTimeline:NO];
}

- (BOOL)hasStatuses {
    return [dataset_ count] > 0;
}


//获取评论和转发数
- (void)getTimelineIDS:(NSArray *)statuses {
    NSUInteger count = (statuses != nil) ? [statuses count] : 0;
    if(count < 0x01) return;
    
    NSMutableString *IDs = [NSMutableString string];
    NSUInteger idx = 0;
    for(KDStatus *item in statuses){
        [IDs appendString:item.statusId];
        if(idx++ != (count - 1)){
            [IDs appendString:@","];
        }
    }
    
    KDQuery *query = [KDQuery queryWithName:@"ids" value:IDs];
    __block FriendsTimelineDataSource *ds = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            NSArray *objs = results;
            
            NSUInteger count = [objs count];
            if (count > 0) {
                NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
                NSInteger likedChangeCount = 0;
                KDStatus *status = nil;
                for (KDStatusCounts *sc in objs) {
                    status = [ds.dataset statusById:sc.statusId];
                    
                    if (status != nil) {
                        //zgbin:sc和status模型加字段microBlogComments、likeUserInfos
                        if(status.forwardsCount != sc.forwardsCount || status.commentsCount != sc.commentsCount
                           ||status.likedCount !=sc.likedCount || ![status.microBlogComments isEqual:sc.microBlogComments] || ![status.likeUserInfos isEqual:sc.likeUserInfos]){
                            status.forwardsCount = sc.forwardsCount;
                            status.commentsCount = sc.commentsCount;
                            status.likedCount = sc.likedCount;
                            status.microBlogComments = sc.microBlogComments;
                            status.likeUserInfos = sc.likeUserInfos;
                            
                            [items addObject:status];
                        }
                        //zgbin:end
                        
                        if (status.liked != sc.liked) {
                            likedChangeCount ++;
                            status.liked = sc.liked;
                            // update status liked
                            [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                                id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
                                [statusDAO updateLiked:sc.liked statusId:sc.statusId database:fmdb];
                                return nil;
                            } completionBlock:nil];
                        }
                    }
                }
                
                //zgbin:由于新加字段microBlogComments、likeUserInfos的影响，让控制器一定刷新
                [ds.controller reloadTableView];
                //                if (items.count > 0 || likedChangeCount > 0) {
                //                    [ds.controller reloadTableView];
                //                }
                //zgbin:end
                
                if ([items count] > 0) {
                    if (![ds isHotCommentsTimeline]) {
                        // update status counts
                        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                            id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
                            [statusDAO updateStatusCounts:items database:fmdb];
                            
                            return nil;
                            
                        } completionBlock:nil];
                    }
                }
            }
        }
        
        // release the data source
        //        [ds release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self  actionPath:@"/statuses/:counts" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)cancelAllGetRequests {
    // for now, Just cancel get timeline and get forward / comment counts requets if exists
    //[[KDRequestDispatcher globalRequestDispatcher] cancelRequestsForReceiveTypeWithDelegate:self];
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (void)reloadTableViewDataSource {
    [self getTimeline:YES];
}

- (void)dealloc {
    [self cancelAllGetRequests];
    //KD_RELEASE_SAFELY(dataset_);
    //[super dealloc];
}

@end

