//
//  KDCommunityManager.h
//  kdweibo_common
//
//  Created by laijiandong on 12-8-21.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDcommunity.h"

#import "CompanyDataModel.h"

@class KDUnread;
@class KDXTUnread;

@interface KDCommunityManager : NSObject {
 @private
    KDCommunity *currentCommunity_;
    CompanyDataModel *currentCompany_;
    NSArray *joinedCommunities_;
}

@property(nonatomic, retain) KDCommunity *currentCommunity;
@property(nonatomic, retain) NSArray *joinedCommunities;
- (void)storeCommunities;
- (void)cleanCommunities;
- (void)updateWithCommunities:(NSArray *)communities currentDomain:(NSString *)currentDomain;
- (void)updateCurrentCommunityWithDomain:(NSString *)currentDomain;
- (BOOL)isCompanyDomain;
- (BOOL)isTeamDomain;
- (void)connectToCommunity:(KDCommunity *)community;

@property(nonatomic, retain) CompanyDataModel *currentCompany;
@property(nonatomic, retain) NSArray *joinedCommpanies;

- (void)storeCompanies;
- (void)cleanCompanies;

- (void)updateWithCompanies:(NSArray *)communities currentDomain:(NSString *)currentDomain;
- (void)updateCurrentCompanyWithDomain:(NSString *)currentDomain;
- (void)connectToCompany:(CompanyDataModel *)community;
- (CompanyDataModel *)companyByDomainName:(NSString *)domain;

//返回当前公司所有openuserid
- (NSArray *)joinedUserIds;


//是否在默认的网络
- (BOOL)isDefaultCommunity;

- (NSString *)defaultCommunityName;

- (KDCommunity *)communityByDomainName:(NSString *)domain;

- (void)reset;

- (BOOL)isJoinedCompany:(NSString *)eid;

- (void)updateCurrentCommunitiesWBUnreadWithUnread : (KDUnread *)unreadDictionary;

- (void)updateCurrentCommunitiesUnreadWithUnread : (KDXTUnread *)unreadDictionary;

@end
