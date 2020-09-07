//
//  KDUnreadManager.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-8-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDUnreadManager.h"

#import "KDcommunity.h"
#import "KDManagerContext.h"
#import "KDWeiboServicesContext.h"
#import "KDRequestDispatcher.h"
#import "KDSession.h"
#import "CompanyDataModel.h"
#import "KDWeiboLoginService.h"


////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDMockUnreadListener class

@implementation KDMockUnreadListener

@synthesize listener=listener_;

- (id)initWithListener:(id<KDUnreadListener>)listener {
    self = [super init];
    if(self){
        listener_ = listener;
    }
    
    return self;
}

+ (KDMockUnreadListener *)mockUnreadListenerWithListener:(id<KDUnreadListener>)listener {
    return [[KDMockUnreadListener alloc] initWithListener:listener];// autorelease];
}

- (void)dealloc {
    listener_ = nil;
    
    //[super dealloc];
}

@end

@implementation KDXTMockUnreadListener

@synthesize listener=listener_;

- (id)initWithListener:(id<KDUnreadListener>)listener {
    self = [super init];
    if(self){
        listener_ = listener;
    }
    
    return self;
}

+ (KDXTMockUnreadListener *)mockUnreadListenerWithListener:(id<KDUnreadListener>)listener {
    return [[KDXTMockUnreadListener alloc] initWithListener:listener];// autorelease];
}

- (void)dealloc {
    listener_ = nil;
    
    //[super dealloc];
}

@end


////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDUnreadManager class

@interface KDUnreadManager ()

@property(nonatomic, retain) KDUnread *unread;
@property(nonatomic, retain) KDXTUnread *xtUnread;
@end

@implementation KDUnreadManager

@synthesize unread = unread_;
@synthesize xtUnread = xtUnread_;
- (id)init {
    self = [super init];
    if(self){
        interval_ = 60.0; // repeat interval is 60 seconds
        loading_ = NO;
        listeners_ = [[NSMutableArray alloc] init];
        xtListeners_ = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadCompany:) name:@"xtUnreadCount" object:nil];
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (BOOL)isExistListener:(id<KDUnreadListener>)listener atIndex:(NSUInteger *)index {
    if(listener == nil) return NO;
    
    BOOL found = NO;
    NSUInteger p = 0;
    for(KDMockUnreadListener * item in listeners_){
        if(item.listener == listener){
            found = YES;
            
            if(index != NULL){
                *index = p;
            }
            
            break;
        }
        
        p++;
    }
    
    return found;
}

- (BOOL)isExistXTListener:(id<KDUnreadListener>)listener atIndex:(NSUInteger *)index {
    if(listener == nil) return NO;
    
    BOOL found = NO;
    NSUInteger p = 0;
    for(KDXTMockUnreadListener * item in xtListeners_){
        if(item.listener == listener){
            found = YES;
            
            if(index != NULL){
                *index = p;
            }
            
            break;
        }
        
        p++;
    }
    
    return found;
}
- (void)addXTUnreadListener:(id<KDUnreadListener>)listener{
    if(listener != nil){
        if(![self isExistXTListener:listener atIndex:NULL]){
            [xtListeners_ addObject:[KDXTMockUnreadListener mockUnreadListenerWithListener:listener]];
        }
    }
}
- (void)removeXTUnreadListener:(id<KDUnreadListener>)listener{

    if(listener != nil){
        NSUInteger index = NSNotFound;
        if([self isExistXTListener:listener atIndex:&index]){
            [xtListeners_ removeObjectAtIndex:index];
        }
    }
}

- (void)addUnreadListener:(id<KDUnreadListener>)listener {
    if(listener != nil){
        if(![self isExistListener:listener atIndex:NULL]){
            [listeners_ addObject:[KDMockUnreadListener mockUnreadListenerWithListener:listener]];
        }
    }
}

- (void)removeUnreadListener:(id<KDUnreadListener>)listener {
    if(listener != nil){
        NSUInteger index = NSNotFound;
        if([self isExistListener:listener atIndex:&index]){
            [listeners_ removeObjectAtIndex:index];
        }
    }
}

// notify the listeners the unread count may be did change
- (void)notify {
    if([listeners_ count] > 0){
        for(KDMockUnreadListener *item in listeners_){
            
            if([item.listener respondsToSelector:@selector(unreadManager:unReadType:)]){
                
                [item.listener unreadManager:self unReadType:KDUnreadTypeWeibo];
                
                
            }
        }
    }
}

- (void)notifyXT {
    if([xtListeners_ count] > 0){
        
        for(KDXTMockUnreadListener *item in xtListeners_){
            
            if([item.listener respondsToSelector:@selector(unreadManager:unReadType:)]){
                
                [item.listener unreadManager:self unReadType:KDUnreadTypeXuntong];
                
                
            }
        }
    }
}
- (void)getUnreadCount {
    if(loading_) return; // if get unread request is going now, return directly
    loading_ = YES;
    
    NSString *communityId = [KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId;

    KDQuery *query = [KDQuery queryWithName:@"includ_group" value:@"true"];
    [query setParameter:@"include_dm" booleanValue:false];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil && [self isCurrenCommunity:request]) {
            KDUnread *unread = results;
            unread.communityId = communityId;
            
            self.unread = unread;
            
            [self unreadCompanyFromWeibo];
            
            [self notify];
            [self changeApplicationBadgeValue];
        }else {
            
        }
        
        loading_ = NO;
        
        if ([response statusCode] == 403) {
//            NSString *userName = [[[KDManagerContext globalManagerContext] userManager].verifyCache objectNotNSNullForKey:@"userName"];
//            NSString *password = [[[KDManagerContext globalManagerContext] userManager].verifyCache objectNotNSNullForKey:@"password"];
//            [KDWeiboLoginService signInUser:userName password:password finishBlock:nil];
            [self stop];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDUnreadManager_alter_msg")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
            alert.tag = 0x123;
            [alert show];
//            [alert release];
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:unread" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}
//
//- (void)getXTUnreadCount{
//    if (self.needUpdateClient == nil) {
//        self.needUpdateClient = [[ContactClient alloc]initWithTarget:self action:@selector(checkUpdateDidReceived:result:)];
//    }
//    //    [self.needUpdateClient checkNeedUpdateWithUpdatetime:[XTSetting sharedSetting].updateTime pubUpdateTime:@"" pubAccount:[XTSetting sharedSetting].pubAccountsUpdateTimeDict];
//    [self.needUpdateClient unreadCountWithUserIds:[[KDManagerContext globalManagerContext].communityManager joinedUserIds] updatetime:[XTSetting sharedSetting].updateTime];
//}
//
//
//- (void)checkUpdateDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
//{
//    if (result == nil) {
//        return;
//    }
//    if (![result isKindOfClass:[BOSResultDataModel class]]) {
//        return;
//    }
//    
//    if (result.success && [result.data isKindOfClass:[NSDictionary class]])
//    {
//        NSDictionary *data = (NSDictionary *)result.data;
//        
//        id currentData = data[[BOSConfig sharedConfig].user.userId];
//        if (currentData && [currentData isKindOfClass:[NSDictionary class]]) {
//            BOOL flag = [currentData[@"flag"] boolValue];
//            if (flag) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"needUpdate" object:nil];
//            }
//        }
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"xtUnreadCount" object:self userInfo:data];
//        
//        //        NeedUpdateDataModel *needDM = [[NeedUpdateDataModel alloc] initWithDictionary:result.data];
//        //        [ContactConfig sharedConfig].needUpdateDataModel = needDM;
//        //        if (needDM.flag) {
//        //            [[NSNotificationCenter defaultCenter] postNotificationName:@"needUpdate" object:nil];
//        //        }
//        //        if (needDM.pubAccount != nil) {
//        //            [[NSNotificationCenter defaultCenter] postNotificationName:@"pubNeedUpdate" object:needDM.pubAccount];
//        //            [self reloadUnreadCount];
//        //        }
//    }
//}

/**
 *  判断是否是当前社区
 *  根据请求的url中subDomainName与当前社区的subDomainName对比，相同即为同一社区
 *  例 http://kdweibo.com/snsapi/kingdee.com/statuses/unread.json?source=Dkt6PaDq630NJD3R
 *  @param request
 *
 *  @return
 */
- (BOOL)isCurrenCommunity:(KDRequestWrapper *)request
{
    NSString *subDomainName = [KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId;
    
    NSString *url = request.url;
   
    return [url rangeOfString:[NSString stringWithFormat:@"/%@/statuses/v4/unread.json", subDomainName]].location != NSNotFound;
}


- (void)invalidateRepeatTimer {
    if(repeatTimer_ != nil){
        [repeatTimer_ invalidate];
        repeatTimer_ = nil;
    }
}

- (void)startRepeatTimer {
    if(repeatTimer_ == nil){
        repeatTimer_ = [NSTimer scheduledTimerWithTimeInterval:interval_ target:self selector:@selector(repeatTimerFire:)
                                                      userInfo:nil repeats:YES];
    }
}

- (void)repeatTimerFire:(NSTimer *)timer {
    [self getUnreadCount];
//    [self getXTUnreadCount];
}

- (void)start:(BOOL)delay {
    if(!loading_ && !delay){
        // start request immediately
        [self getUnreadCount];
//        [self getXTUnreadCount];
    }
    
    [self startRepeatTimer];
}

- (void)stop {
    // invalid repeat timer
    [self invalidateRepeatTimer];
    
    
    [self changeApplicationBadgeValue];
    // stop unread request
   
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (void)reset {
    [unread_ reset];
    [self notify];
}

- (NSInteger)timelineBadgeValue {
    NSInteger value = 0;
    KDTLStatusType timelineType = [[KDSession globalSession] timelineType];
        if(KDTLStatusTypePublic == timelineType){
        value = unread_.publicStatuses;
        
    }else if(KDTLStatusTypeFriends == timelineType){
        value = unread_.friendsStatuses;
    }
    
    return value;
}

- (NSInteger)messageBadgeValue {
    NSInteger totoal = 0;
    if(unread_ != nil){
        totoal = unread_.inboxTotal + unread_.directMessages;
    }
    
    return totoal;
}

- (void)didChangeTimelineBadgeValue:(BOOL)reset {
    if([unread_ canChangeUnreadBadgeValue]){
        KDTLStatusType timelineType = [[KDSession globalSession] timelineType];
        if(KDTLStatusTypePublic == timelineType && reset){
            unread_.publicStatuses = 0;
            
        }else if(KDTLStatusTypeFriends == timelineType && reset){
            unread_.friendsStatuses = 0;
        }
        
        [self notify];
    }
}

- (void)didChangePublicTimelineBadge:(BOOL)rest {
    if ([unread_ canChangeUnreadBadgeValue]) {
        unread_.publicStatuses = 0;
        [self notify];
    }
}

- (void)didChangeFriendTimelineBadge:(BOOL)rest {
    if ([unread_ canChangeUnreadBadgeValue]) {
        unread_.friendsStatuses = 0;
        [self notify];
    }
}
- (void)didChangeMessageBadgeValue:(BOOL)resetMentions resetComments:(BOOL)resetComments resetDM:(BOOL)resetDM {
    if([unread_ canChangeUnreadBadgeValue]){
        if(resetMentions) {
            unread_.mentions = 0;
            
            if(unread_.lastVisitType == KDUnReadLastVisitTypeMention) {
                unread_.lastVisitType = KDUnReadLastVisitTypeNone;
                unread_.lastVisitorName = nil;
            }
        }
        
        if(resetComments) {
            unread_.comments = 0;
            
            if(unread_.lastVisitType == KDUnReadLastVisitTypeComment) {
                unread_.lastVisitType = KDUnReadLastVisitTypeNone;
                unread_.lastVisitorName = nil;
            }
        }
        
        if(resetDM) {
            unread_.directMessages = 0;
            
            if(unread_.lastVisitType == KDUnReadLastVisitTypeDirectMessage) {
                unread_.lastVisitType = KDUnReadLastVisitTypeNone;
                unread_.lastVisitorName = nil;
            }
        }
        
        [self notify];
        [self changeApplicationBadgeValue];
    }
}

- (void)didChangeDMBadgeValue:(NSInteger)badgeValue {
    if([unread_ canChangeUnreadBadgeValue]){
        
        unread_.directMessages = badgeValue;
        
        [self didChangeMessageBadgeValue:NO resetComments:NO resetDM:NO];
    }
}
- (void)didChangeUndoBadgeValue:(NSInteger)badgeValue
{
    if([unread_ canChangeUnreadBadgeValue]){
        
        unread_.undoTotal = badgeValue;
        
        [self didChangeMessageBadgeValue:NO resetComments:NO resetDM:NO];
    }

}
- (void)didChangeInvitedBadgeValue:(NSInteger)badgeValue
{
    if ([unread_ canChangeUnreadBadgeValue]) {
        unread_.inviteTotal = badgeValue;
        
        [self didChangeMessageBadgeValue:NO resetComments:NO resetDM:NO];
    }
}
- (void)didChangeInboxBadgeValue:(NSInteger)badgeValue
{
    if([unread_ canChangeUnreadBadgeValue]){

        unread_.inboxTotal = badgeValue;
        
        [self didChangeMessageBadgeValue:YES resetComments:YES resetDM:NO];
    }
}

- (void)didChangeGroupsBadgeValue:(BOOL)reset groupId:(NSString *)groupId {
    if([unread_ canChangeUnreadBadgeValue]){
        if(reset){
            [unread_ resetUnreadWithGroupId:groupId];
        }
        
        [self notify];
    }
}

- (void)didChangeAllGroupsUnread:(BOOL)reset {
    if([unread_ canChangeUnreadBadgeValue]){
        if(reset){
            [unread_ resetAllGroupUnreadCount];
        }
        
        [self notify];
    }

}
- (void)changeFollowersBadgeValue:(BOOL)reset {
    if([unread_ canChangeUnreadBadgeValue]){
        if(reset){
            unread_.followers = 0;
        }
        
        [self notify];
    }
}

- (void)decreaseNewFunctionsNum {
    if ([unread_ canChangeUnreadBadgeValue]) {
        if (unread_.functions >0) {
            -- unread_.functions;
            [self notify];
        }
    }
}

- (void)changeApplicationBadgeValue {
   /*
    NSArray *joinedCommunity = [[KDManagerContext globalManagerContext] communityManager].joinedCommunities;
    
    NSInteger count = 0;
    for (KDCommunity *community in joinedCommunity) {
        if (![community.communityId isEqualToString:[[KDManagerContext globalManagerContext] communityManager].currentCommunity.communityId]) {
            count += community.unreadNum;
        }
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [self messageBadgeValue] + count;
    */
}

- (void)changeLeftListBadge
{
    
}

- (void)unreadCompanyFromWeibo
{
    [[[KDManagerContext globalManagerContext]communityManager] updateCurrentCommunitiesWBUnreadWithUnread:unread_];

}

- (void)unreadCompany:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    self.xtUnread = [[KDXTUnread alloc]init];//autorelease];
    [xtUnread_ setUnreadDictionary:dict];
    
    [[[KDManagerContext globalManagerContext]communityManager]updateCurrentCommunitiesUnreadWithUnread:xtUnread_];

    [self notifyXT];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0x123) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"user_logout" object:nil];
    }
}

- (void)dealloc {
    [self invalidateRepeatTimer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"xtUnreadCount" object:nil];
    xtUnread_ = nil;
    unread_ = nil;
    listeners_ = nil;
    //KD_RELEASE_SAFELY(xtUnread_);
    //KD_RELEASE_SAFELY(unread_);
    //KD_RELEASE_SAFELY(listeners_);
    
    //[super dealloc];
}

@end
