//
//  KDCommunity.h
//  kdweibo_common
//
//  Created by laijiandong on 12-8-21.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDAvatarProtocol.h"
#import "KDObject.h"

enum {
    KDCommunityTypeUndefined = 0x00, // generally speaking, this issue can not happens
    KDCommunityTypeCompany = 0x01,
    KDCommunityTypeCommunity,
    KDCommunityTypeTeam
};

typedef NSUInteger KDCommunityType;

@interface KDCommunity : KDObject <NSCoding, KDAvatarDataSource>{
 @private
    NSString *communityId_;
    NSString *name_;
    NSString *subDomainName_;
    NSString *url_;
    NSString *logoURL_;
    NSString *parentId_;
    NSString *inviter_;
    NSString *code_;
    
    BOOL     isAdmin_;
    BOOL     isApply_;
    BOOL     isAllowInto_;
    KDCommunityType communityType_;
}

@property(nonatomic, retain) NSString *communityId;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *subDomainName;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NSString *logoURL;
@property(nonatomic, retain) NSString *parentId;
@property(nonatomic, retain) NSString *inviter;
@property(nonatomic, retain) NSString *code;
@property(nonatomic, assign) BOOL      isAdmin;
@property(nonatomic, assign) BOOL      isApply;
@property(nonatomic, assign) BOOL      isAllowInto;
@property(nonatomic, assign) KDCommunityType communityType;
//排序
@property(nonatomic, assign) NSInteger unreadNum;

+ (KDCommunityType)convertCommunityTypeFromString:(NSString *)string;
- (BOOL)isCompany;
- (BOOL)isTeam;
@end
