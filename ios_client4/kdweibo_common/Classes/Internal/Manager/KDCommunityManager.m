//
//  KDCommunityManager.m
//  kdweibo_common
//
//  Created by laijiandong on 12-8-21.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "Kdcommon.h"
#import "KDCommunityManager.h"

#import "KDManagerContext.h"
#import "KDWeiboServicesContext.h"
#import "KDDBManager.h"


#define KD_CM_PROP_JOINED_COMMUNITIES_KEY   @"kd.cm.joinedCommunities"
#define KD_CM_PROP_JOINED_COMPANIES_KEY   @"kd.cm.joinedCompanies"

@implementation KDCommunityManager

@synthesize currentCommunity=currentCommunity_;
@synthesize joinedCommunities=joinedCommunities_;

- (id)init {
    self = [super init];
    if(self){
        // retrieve joined communities from cache
        [self retrieveCommunities];
    }
    
    return self;
}

- (void)retrieveCommunities {
    KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    NSData *data = [userDefaultsAdapter objectForKey:KD_CM_PROP_JOINED_COMMUNITIES_KEY];
    if(data != nil) {
        self.joinedCommunities = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    NSData *companyData = [userDefaultsAdapter objectForKey:KD_CM_PROP_JOINED_COMPANIES_KEY];
    if(companyData != nil) {
        self.joinedCommpanies = [NSKeyedUnarchiver unarchiveObjectWithData:companyData];
    }
}

- (void)storeCommunities {
    if(joinedCommunities_ != nil){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:joinedCommunities_];
        if(data != nil){
            KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
            [userDefaultsAdapter storeObject:data forKey:KD_CM_PROP_JOINED_COMMUNITIES_KEY];
        }
    }
}

- (void)cleanCommunities {
    KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    [userDefaultsAdapter removeObjectForKey:KD_CM_PROP_JOINED_COMMUNITIES_KEY];
}

- (void)updateWithCommunities:(NSArray *)communities currentDomain:(NSString *)currentDomain {
    if(communities != nil && [communities count] > 0){
        self.joinedCommunities = communities;
        
        [self updateCurrentCommunityWithDomain:currentDomain];
    }
}

- (void)updateCurrentCommunityWithDomain:(NSString *)currentDomain {
    NSUInteger count = (joinedCommunities_ != nil) ? [joinedCommunities_ count] : 0;
    if(count > 0){
        KDCommunity *currentCommunity = nil;
        
        // if current signed user not in a public domain and joined communities more than one
        // filter the current community by user's company community
        if(currentDomain != nil && count > 1){
            for(KDCommunity *community in joinedCommunities_){
                if([community.subDomainName isEqualToString:currentDomain]){
                    currentCommunity = community;
                    break;
                }
            }
        }
        
        // If current user is an public user, make the first community as current community
        if(currentCommunity == nil){
            currentCommunity = [joinedCommunities_ objectAtIndex:0x00];
        }
        
        self.currentCommunity = currentCommunity;
    }
}

- (BOOL)isCompanyDomain {
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    
    BOOL isCompany = NO;
    if(userManager.currentUserCompanyDomain != nil
       && [userManager.currentUserCompanyDomain isEqualToString:currentCommunity_.subDomainName]){
        isCompany = YES;
    }
    
    if(userManager.currentUser.isPublicUser || !isCompany) {
        return NO;
    }else {
        return YES;
    }
    
}

- (BOOL)isTeamDomain {
    return (self.currentCommunity.communityType == KDCommunityTypeTeam);
}

- (void)updateCommunityDomainForServicesContext {
    NSString *domain = _currentCompany.wbNetworkId;
    if (!Test_Environment) {
        domain = currentCommunity_.subDomainName;
    }
    [[[KDWeiboServicesContext defaultContext] getKDWeiboServices] setCurrentCommunityDomain:domain];
}

// If the comunity is nil, then connect to current community.
// otherwise connect to specificed community
- (void)connectToCommunity:(KDCommunity *)community {
    KDCommunity *target = community;
    if(target == nil){
        if(currentCommunity_ != nil){
            target = currentCommunity_;
        
        }else {
            // about public user, only pick first community as target
            if(joinedCommunities_ != nil && [joinedCommunities_ count] > 0){
                target = [joinedCommunities_ objectAtIndex:0x00];
            }
        }
        
    }else {
        for(KDCommunity *item in joinedCommunities_){
            if([item.communityId isEqualToString:target.communityId]){
                target = item;
                break;
            }
        }
    }
    
    if(target != nil){
        self.currentCommunity = target;
        
        // update domain for requests
        [self updateCommunityDomainForServicesContext];
        
        // open database for current community
        [[KDDBManager sharedDBManager] tryConnectToCommunity:currentCommunity_.communityId];
    }
}

- (BOOL)isDefaultCommunity {
    KDUser *currentUser = [[[KDManagerContext globalManagerContext] userManager] currentUser];
    return [self.currentCommunity.subDomainName isEqualToString:currentUser.domain];
}

- (KDCommunity *)communityByDomainName:(NSString *)domain {
    KDCommunity *result = nil;
    if (domain.length >0) {
        //
        for (KDCommunity *community in self.joinedCommunities) {
            if ([community.subDomainName isEqualToString:domain]) {
                result = community;
                break;
            }
        }
    }
    return result;
}

- (NSString *)defaultCommunityName {
    NSString *result = nil;
    NSString *defaultDomainName = [[[KDManagerContext globalManagerContext] userManager] currentUser].domain;
    result = [self communityByDomainName:defaultDomainName].name;
    return result;
    
}

- (void)storeCompanies
{
    if(_joinedCommpanies != nil){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_joinedCommpanies];
        if(data != nil){
            KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
            [userDefaultsAdapter storeObject:data forKey:KD_CM_PROP_JOINED_COMPANIES_KEY];
        }
    }

}
- (void)cleanCompanies
{
    KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    [userDefaultsAdapter removeObjectForKey:KD_CM_PROP_JOINED_COMPANIES_KEY];
}

- (void)updateWithCompanies:(NSArray *)communities currentDomain:(NSString *)currentDomain
{
    if(communities != nil && [communities count] > 0){
        self.joinedCommpanies = communities;
        
        [self updateCurrentCompanyWithDomain:currentDomain];
    }
}
- (void)updateCurrentCompanyWithDomain:(NSString *)currentDomain
{
    NSUInteger count = (_joinedCommpanies != nil) ? [_joinedCommpanies count] : 0;
    if(count > 0){
        CompanyDataModel *currentCommunity = nil;
        
        // if current signed user not in a public domain and joined communities more than one
        // filter the current community by user's company community
        if(currentDomain != nil && count >= 1){
            for(CompanyDataModel *community in _joinedCommpanies){
                if([community.eid isEqualToString:currentDomain]){
                    currentCommunity = community;
                    break;
                }
            }
        }
        
        // If current user is an public user, make the first community as current community
        if(currentCommunity == nil){
            currentCommunity = [_joinedCommpanies objectAtIndex:0x00];
        }
        
        self.currentCompany = currentCommunity;
        [self updateCommunityDomainForServicesContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:kKDCommunityDidChangedNotification object:self userInfo:nil];
    }

}
- (void)updateCurrentCommunitiesWBUnreadWithUnread: (KDUnread *)unread{
    NSDictionary *communities = [unread communityNotices];

    NSArray *joinedCompany = [[KDManagerContext globalManagerContext] communityManager].joinedCommpanies;
    [communities enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        for (CompanyDataModel *model in joinedCompany) {
            if ([model.wbNetworkId isEqual:key]) {
                model.wbUnreadCount = ((NSNumber *)obj).integerValue;
            }
            if ([model.wbNetworkId isEqualToString:[[KDManagerContext globalManagerContext] communityManager].currentCompany.wbNetworkId]) {
                model.wbUnreadCount = unread.inboxTotal;
            }
        }
    }];
}

- (void)updateCurrentCommunitiesUnreadWithUnread : (KDXTUnread *)unread{
    NSDictionary *dict = unread.unreadDictionary;

    NSArray *joinedCompany = [self joinedCommpanies];
    
    NSArray *userIds = [dict allKeys];
    
    for (NSString *userId in userIds) {
        for (CompanyDataModel *model in joinedCompany) {
            if ([userId isEqual:model.user.userId]) {
                NSNumber *count = ((NSDictionary *)dict[userId])[@"unreadCount"];
                model.unreadCount = count.integerValue;
            }
        }
    }
}

- (void)connectToCompany:(CompanyDataModel *)company
{
    CompanyDataModel *target = company;
    if(target == nil){
        if(currentCompany_ != nil){
            target = currentCompany_;
            
        }else {
            // about public user, only pick first community as target
            if(_joinedCommpanies != nil && [_joinedCommpanies count] > 0){
                target = [_joinedCommpanies objectAtIndex:0x00];
            }
        }
        
    }else {
        for(CompanyDataModel *item in self.joinedCommpanies){
            if([item.eid isEqualToString:target.eid]){
                target = item;
                break;
            }
        }
    }
    
    if(target != nil){
        self.currentCompany = target;
         [self updateCommunityDomainForServicesContext];
        [[KDDBManager sharedDBManager] tryConnectToCommunity:target.eid];
        [[NSNotificationCenter defaultCenter] postNotificationName:kKDCommunityDidChangedNotification object:self userInfo:nil];
    }
    
    if (!Test_Environment) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"communityId = %@", target.wbNetworkId];
        KDCommunity *community = [[joinedCommunities_ filteredArrayUsingPredicate:predicate] firstObject];
        if (community) {
            [self connectToCommunity:community];
        }
    }
}
           
- (CompanyDataModel *)companyByDomainName:(NSString *)domain {
    CompanyDataModel *result = nil;
    if (domain.length >0) {
        //
        for (CompanyDataModel *community in self.joinedCommpanies) {
            if ([community.eid isEqualToString:domain]) {
                result = community;
                break;
            }
        }
    }
    return result;
}

- (NSArray *)joinedUserIds
{
    NSMutableArray *result = [NSMutableArray array];
    for (CompanyDataModel *model in _joinedCommpanies) {
        if (model.user.userId) {
            [result addObject:model.user.userId];
        }
    }
    return result;
}

- (BOOL)isJoinedCompany:(NSString *)eid {
    __block BOOL isJoied = NO;
    [_joinedCommpanies enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop) {
        if ([[(CompanyDataModel *)obj eid] isEqualToString:eid]) {
              *stop = YES;
            isJoied = YES;
        }
      
    }];
    return isJoied;
}

- (void)reset {
    [self cleanCommunities];
    [self cleanCompanies];
    
    currentCompany_ = nil;
    currentCommunity_ = nil;
    joinedCommunities_ = nil;
    _joinedCommpanies = nil;
    
    //KD_RELEASE_SAFELY(currentCommunity_);
    //KD_RELEASE_SAFELY(joinedCommunities_);
    //KD_RELEASE_SAFELY(_joinedCommpanies);
    //KD_RELEASE_SAFELY(currentCompany_);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(currentCommunity_);
    //KD_RELEASE_SAFELY(joinedCommunities_);
    //KD_RELEASE_SAFELY(_joinedCommpanies);
    //KD_RELEASE_SAFELY(currentCompany_);
    //[super dealloc];
}

@end
