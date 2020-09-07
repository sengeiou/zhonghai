//
//  KDUserManager.h
//  kdweibo_common
//
//  Created by laijiandong on 12-8-22.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDUser.h"
#import "KDAuthToken.h"
#import "KDWeiboServicesContext.h"

@interface KDUserManager : NSObject {
 @private
    NSString *currentUserId_;
    NSString *currentUserCompanyDomain_;
    KDUser *currentUser_;
    
    KDAuthToken *accessToken_;
    
    NSMutableDictionary *userCache_;
    
    //当前登录用户，密码，邮件验证需要
    NSMutableDictionary *verifyCache_;
}

@property(nonatomic, retain) NSString *currentUserId;
@property(nonatomic, retain) NSString *currentUserCompanyDomain;
@property(nonatomic, retain) KDUser *currentUser;

@property(nonatomic, retain) KDAuthToken *accessToken;

@property(nonatomic, retain) NSMutableDictionary *verifyCache;

- (BOOL)isCurrentUserId:(NSString *)userId;
- (BOOL)isPublicUser;
- (BOOL)isSigned;
- (void)updateAuthorizationForServicesContext;

- (void)reset;
- (void)storeUserData;
- (void)cleanUserData;

- (void)addUser:(KDUser *)user;
- (KDUser *)userWithUserId:(NSString *)userId;
- (KDUser *)userWithUsername:(NSString *)username;
- (void)removeUser:(KDUser *)user;
- (void)removeUserWithId:(NSString *)userId;
- (void)updateCurrentUser :(KDServiceActionDidCompleteBlock)completeBlock;
- (void)wake;
@end
