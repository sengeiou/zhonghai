//
//  KDUser.h
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDObject.h"
#import "KDAvatarProtocol.h"
#import "KDImageSourceProtocol.h"

@class KDStatus;
@class FMDatabase;

@interface KDUser : KDObject <KDAvatarDataSource, KDImageDataSource>

@property(nonatomic, retain) NSString *userId;
@property(nonatomic, retain) NSString *openId;   //原迅通的openId
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSString *screenName;
@property(nonatomic, retain) NSString *email;

@property(nonatomic, retain) NSString *domain;
@property(nonatomic, retain) NSString *companyName;
@property(nonatomic, retain) NSString *department;
@property(nonatomic, retain) NSString *jobTitle;
@property(nonatomic, retain) NSString *defaultNetworkType;

@property(nonatomic, assign) NSInteger gender;

@property(nonatomic, assign) BOOL geoEnabled;
@property(nonatomic, assign) BOOL verified;
@property(nonatomic, assign) BOOL isPublicUser;
@property(nonatomic, assign) BOOL isTeamUser;

@property(nonatomic, retain) NSString *province;
@property(nonatomic, retain) NSString *city;
@property(nonatomic, retain) NSString *location;

@property(nonatomic, retain) NSString *profileImageUrl;
@property(nonatomic, retain) NSString *url;

@property(nonatomic, retain) NSString *summary;

@property(nonatomic, assign) NSInteger statusesCount;
@property(nonatomic, assign) NSInteger followersCount;
@property(nonatomic, assign) NSInteger friendsCount;
@property(nonatomic, assign) NSInteger favoritesCount;
@property(nonatomic, assign) NSInteger topicsCount;

@property(nonatomic, assign) NSTimeInterval createdAt;

@property(nonatomic, retain) KDStatus *latestStatus; // the latest status posted by this user
@property(nonatomic, retain) NSString *wbNetworkId;

- (BOOL)isInNetwork;

- (BOOL)isDefaultAvatar;

- (BOOL)isCompany;//是否是企业工作圈

+ (KDUser *)userWithId:(NSString *)userId database:(FMDatabase *)fmdb;
+ (KDUser *)userWithName:(NSString *)username database:(FMDatabase *)fmdb;

+ (void)syncUserWithId:(NSString *)userId completionBlock:(void (^)(KDUser *))completionBlock;
+ (void)syncUserWithName:(NSString *)username completionBlock:(void (^)(KDUser *))completionBlock;

+ (BOOL)isCurrentSignedUserWithId:(NSString *)userId; // check the specificed user id is current signed user id

@end
