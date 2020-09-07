//
//  KDStatusDataProvider.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-1.
//
//

#import "KDStatusDataProvider.h"
#import "KDStatusCounts.h"

@implementation KDStatusDataProvider
@synthesize dataSet = dataSet_;

@synthesize viewController = viewController_;


//
- (id)init {
    self = [super init];
    if(self != nil) {
        self.dataSet = [[[KDStatusDataset alloc] init] autorelease];
    }
    return self;
}
- (id)initWithViewController:(KDStatusBaseViewController *)viewController {
    self = [self init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}

- (void)loadCachedStatus {
    [viewController_ setFirstInLoadingState];
    [viewController_ shouldShowBlankHolderView:YES];
    [KDStatusDataset cachedStatusesWithType:self
     .type completionBlock:^(NSArray *array)  {
       
         [self.dataSet mergeStatuses:array atHead:YES limit:-1];
          [self.viewController reloadTableView];
         [self loadLatestStatus];
     }];
    
}

- (NSString *)getIdsFromStatues:(NSArray *)statuses{
    NSMutableString * ids = nil;
    NSInteger count = [statuses count];
    if (count > 0) {
        ids = [NSMutableString string];
        NSUInteger idx = 0;
        for(KDStatus *status in statuses){
            [ids appendString:status.statusId];
            if(idx != (count - 1)){
                [ids appendString:@","];
            }
            
            idx++;
        }
    }
    return ids;
}

- (void)shouldShowFooterView:(BOOL)isShould {
    
    viewController_.haveFootView = isShould;
}

- (void)showNodataTipsView{
    BOOL shouldShow = NO;
    if(!self.dataSet || [self.dataSet count] <= 0) {
        shouldShow = YES;
    }
    [viewController_ shouldShowNoDataTipsView:shouldShow];
}


- (void)updateForwardAndcommentCount:(NSArray*)statues completionBlock:(statuesCountUpdatingCompletionBlock)block {
    if (statues == nil ||[statues count] == 0) {
        if (block != nil) {
            block();
        }
        return;
    }
    
    NSString *ids = [self getIdsFromStatues:statues];
    if (ids.length > 0) {
        KDQuery *query = [KDQuery queryWithName:@"ids" value:ids];
        
        __block KDStatusDataProvider *msp = [self retain];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            if (results != nil) {
                NSArray *objs = results;
                NSUInteger count = [objs count];
                if (count > 0) {
                    KDStatus *status = nil;
                    NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
                    for (KDStatusCounts *sc in objs) {
                        status = [msp.dataSet statusById:sc.statusId];
                        if (status != nil) {
                            if (status.forwardsCount != sc.forwardsCount || status.commentsCount != sc.commentsCount||status.likedCount !=sc.likedCount) {
                                status.forwardsCount = sc.forwardsCount;
                                status.commentsCount = sc.commentsCount;
                                status.likedCount = sc.likedCount;
                                
                                [items addObject:sc];
                            }
                        }
                    }
                    
                    [msp saveStatusCount:items];
                }
            }
            
            if (block != nil) {
                block();
            }
            
            // release current statuses provider
            [msp release];
        };
        
        [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:counts" query:query
                                     configBlock:nil completionBlock:completionBlock];
    }
}


- (void)loadLatestStatus {

    NSLog(@"loadLatestStatus");
    __block KDStatusDataProvider *msp = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        NSArray *statuses = nil;
        NSUInteger count = 0;
        BOOL succeed = NO;
        if ([response isValidResponse]) {
            succeed = YES;
            statuses = results;
            count = [statuses count];
            [msp.dataSet mergeStatuses:statuses atHead:YES limit:msp.statueslimits];
            [msp saveStatus:statuses];
            
            if (count > 0) {
                
                [msp updateUnread];
            }
            [msp updateForwardAndcommentCount:[msp.dataSet allStatuses] completionBlock:nil];
            [msp.viewController showPrompView:count];
            [msp.viewController reloadTableView];
            [msp showNodataTipsView];
        }
        else {
            if (![response isCancelled]) {
                [msp.viewController displayError:[[response  responseDiagnosis] networkErrorMessage]];
            }else {
                NSLog(@"cancled");
            }
           
        }
        [msp.viewController finishRefreshed:succeed];
        msp.viewController.haveFootView = ([msp.dataSet count] >= 20);
        [msp release];
    };
    [self loadStatus:[self latestStatusQuery] completionBlock:completionBlock];
    
}

- (void)loadEarlierStatus {
    if ([dataSet_ count] == 0) {
        return;
    }

    __block KDStatusDataProvider *msp = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        NSArray *statuses = nil;
        NSInteger count = 0;
        if ([response isValidResponse]) {
            
            statuses = results;
            count = [statuses count];
            msp.viewController.haveFootView = (count >0);
        }
        else {
            if (![response isCancelled]) {
                [msp.viewController displayError:[[response responseDiagnosis]  networkErrorMessage] ];
            }
        }
        [msp.dataSet mergeStatuses:statuses atHead:NO limit:20];
        [msp saveStatus:statuses];
        [msp.viewController finishLoadMore];
        [msp updateForwardAndcommentCount:statuses completionBlock:^() {
            
            [msp.viewController reloadTableView];
        }];
        
        [msp release];
    };
    
    
    [self loadStatus:[self earlierStatusQuery] completionBlock:completionBlock];
}

- (void)loadStatus:(KDQuery *)query completionBlock:(KDServiceActionDidCompleteBlock)block {
    [KDServiceActionInvoker invokeWithSender:self actionPath:self.actionPath query:query
                                 configBlock:nil completionBlock:block];
}

- (void)saveStatus:(NSArray *)statuses {
    if (statuses == nil || [statuses count] == 0) {
        return;
    }
    SEL selector = self.statuesSavingSelector;
    if (selector == nil) {
        return ;
    }
    [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback) {
        id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
        
        NSMethodSignature *methodSignature = [[statusDAO class] instanceMethodSignatureForSelector:selector];
        NSArray *theStatues = statuses;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:statusDAO];
        //设置target
        [invocation setSelector:selector];
        [invocation setArgument:&theStatues atIndex:2];
        [invocation setArgument:&fmdb atIndex:3];
        [invocation setArgument:&rollback atIndex:4];
        [invocation retainArguments];
        [invocation invoke];
        return nil;
        
    } completionBlock:nil];
}

- (void)saveStatusCount:(NSArray *)statuesCount {
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
        
        //[statusDAO updateCommentMeStatusCounts:items database:fmdb];
        SEL selector = self.countingSavingSelector;
        if (selector) {
            NSMethodSignature *methodSignature = [[statusDAO class] instanceMethodSignatureForSelector:selector];
            NSArray *theStatuesCount = statuesCount;
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setTarget:statusDAO];
            //设置target
            [invocation setSelector:selector];
            [invocation setArgument:&theStatuesCount atIndex:2];
            [invocation setArgument:&fmdb atIndex:3];
            [invocation retainArguments];
            [invocation invoke];
        }
        
    }completionBlock:nil];
    
}

- (void)cancleAllNetworkRequest {
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

// override
- (void)loadImageSourceInTableView:(UITableView *)tableView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be overrided by %@",NSStringFromSelector(_cmd),self] userInfo:nil];
}
// override
- (CGFloat)calculateStatusContentHeight:(KDStatus *)status {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be overrided by %@",NSStringFromSelector(_cmd),self] userInfo:nil];
}


- (KDQuery *)latestStatusQuery {
  KDQuery *query = [KDQuery query];
    [query setParameter:@"count" stringValue:[NSString stringWithFormat:@"%d",self.statueslimits]];
    if([dataSet_ count]>0) {
        KDStatus *status = [dataSet_ firstStatus];
        [query setParameter:@"since_id" stringValue:status.statusId];
    }
    return query;
}

- (KDQuery *)earlierStatusQuery {
    KDQuery *query = [KDQuery query];
    [query setParameter:@"count" stringValue:[NSString stringWithFormat:@"%d",self.statueslimits]];
    if([dataSet_ count]>0) {
     KDStatus *status = [dataSet_ lastStatus];
     [query  setParameter:@"max_id" stringValue:status.statusId];
    }
    return query;
}
//override
- (KDTLStatusType)type {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be overrided by %@",NSStringFromSelector(_cmd),self] userInfo:nil];
}
//override
- (NSString *)actionPath {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be overrided by %@",NSStringFromSelector(_cmd),self] userInfo:nil];
}
//override
- (SEL)statuesSavingSelector {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be overrided by %@",NSStringFromSelector(_cmd),self] userInfo:nil];
}
//override
- (SEL)countingSavingSelector {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be overrided by %@",NSStringFromSelector(_cmd),self] userInfo:nil];
}
//override
- (BOOL)showAccurateGroupName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be overrided by %@",NSStringFromSelector(_cmd),self] userInfo:nil];
}
//override
- (NSInteger)statueslimits {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be overrided by %@",NSStringFromSelector(_cmd),self] userInfo:nil];
}
//override
- (void)updateUnread {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be overrided by %@",NSStringFromSelector(_cmd),self] userInfo:nil];
}

- (void)dealloc {
    KD_RELEASE_SAFELY(dataSet_);
    [super dealloc];
}
@end
