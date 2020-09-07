//
//  KDUser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDUser.h"

#import "KDManagerContext.h"
#import "KDWeiboDAOManager.h"
#import "KDCache.h"

#import "KDDatabaseHelper.h"

@implementation KDUser

@synthesize userId =userId_;
@synthesize openId = openId_;
@synthesize username=username_;
@synthesize screenName=screenName_;
@synthesize email=email_;

@synthesize domain=domain_;
@synthesize companyName=companyName_;
@synthesize department=department_;
@synthesize jobTitle=jobTitle_;
@synthesize defaultNetworkType = defaultNetworkType_;

@synthesize gender=gender_;

@synthesize geoEnabled=geoEnabled_;
@synthesize verified=verified_;
@synthesize isPublicUser=isPublicUser_;
@synthesize isTeamUser=isTeamUser_;

@synthesize province=province_;
@synthesize city=city_;
@synthesize location=location_;

@synthesize profileImageUrl=profileImageUrl_;
@synthesize url=url_;

@synthesize summary=summary_;

@synthesize statusesCount=statusesCount_;
@synthesize followersCount=followersCount_;
@synthesize friendsCount=friendsCount_;
@synthesize favoritesCount=favoritesCount_;
@synthesize topicsCount=topicsCount_;

@synthesize createdAt=createdAt_;

@synthesize latestStatus=latestStatus_;

@synthesize wbNetworkId = wbNetworkId_;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (BOOL)isInNetwork {
    if(defaultNetworkType_ == nil || defaultNetworkType_.length == 0 || [defaultNetworkType_ isEqualToString:@"VIRTUAL"]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isCompany
{
    NSLog(@"%@",defaultNetworkType_);
    
    if(defaultNetworkType_ == nil || defaultNetworkType_.length == 0 || [defaultNetworkType_ isEqualToString:@"VIRTUAL"]) {
        return NO;
    }
    
    if ([defaultNetworkType_ isEqualToString:@"COMPANY"])
    {
        return YES;
    }
    
    return NO;
}


- (BOOL)isDefaultAvatar {
    if([profileImageUrl_ rangeOfString:@"id=null"].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

+ (KDUser*)userWithId:(NSString *)userId database:(FMDatabase *)fmdb {
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    KDUser *user = [userManager userWithUserId:userId];
    if(user == nil){
        // retrieve user by user id
        id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
        user = [userDAO queryUserWithId:userId database:fmdb];
        
        if(user != nil){
            [userManager addUser:user];
        }
    }
    
    return user;
}

+ (KDUser *)userWithName:(NSString *)username database:(FMDatabase *)fmdb {
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    KDUser *user = [userManager userWithUsername:username];
    if(user == nil){
        // retrieve user by username
        id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
        user = [userDAO queryUserWithName:username database:fmdb];
        
        if(user != nil){
            [userManager addUser:user];
        }
    }
    
    return user;
}

+ (void)syncUserWithId:(NSString *)userId completionBlock:(void (^)(KDUser *))completionBlock {
    // query user from memory cache
        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
                        id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                        KDUser *cachedObj = [userDAO queryUserWithId:userId database:fmdb];
                        return cachedObj;
            
                    } completionBlock:^(id results){
                        if (completionBlock != nil) {
                            completionBlock(results);
                       }
                   }];
 
}

+ (void)syncUserWithName:(NSString *)username completionBlock:(void (^)(KDUser *))completionBlock {
    // query user from memory cache
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    KDUser *user = [userManager userWithUsername:username];
    if (user == nil) {
        // query user from local database
        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
            id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
            KDUser *cachedObj = [userDAO queryUserWithName:username database:fmdb];
            
            return cachedObj;
            
        } completionBlock:^(id results){
            if (completionBlock != nil) {
                completionBlock(results);
            }
        }];
        
    } else {
        if (completionBlock != nil) {
            completionBlock(user);
        }
    }
}

+ (BOOL)isCurrentSignedUserWithId:(NSString *)userId {
    return [[KDManagerContext globalManagerContext].userManager isCurrentUserId:userId];
}


///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDAvatarDataSource protocol methods

- (KDAvatarType)getAvatarType {
    return KDAvatarTypeUser;
}

- (KDImageSize *)avatarScaleToSize {
    return [KDImageSize defaultUserAvatarSize];
}

- (NSString *)getAvatarLoadURL {
    return profileImageUrl_;
}

- (NSString *)getAvatarCacheKey {
    NSString *cacheKey = [super propertyForKey:kKDAvatarPropertyCacheKey];
    if(cacheKey == nil){
        NSString *loadURL = [self getAvatarLoadURL];
        cacheKey = [KDCache cacheKeyForURL:loadURL];
        if(cacheKey != nil){
            [super setProperty:cacheKey forKey:kKDAvatarPropertyCacheKey];
        }
    }
    
    return cacheKey;
}

- (void)removeAvatarCacheKey {
    [super setProperty:nil forKey:kKDAvatarPropertyCacheKey];
}


///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDImageDataSource protocol methods

- (BOOL)hasImageSource {
    return (profileImageUrl_ != nil && [profileImageUrl_ length] > 1) ? YES : NO;
}

- (BOOL)hasManyImageSource {
    return NO;
}
- (BOOL)isTimeLineDataSource
{
    return NO;
}
- (KDImageSource *)getTimeLineImageSourceAtIndex:(NSInteger)index
{
    return nil;
}
- (NSString *)thumbnailImageURL {
    return [self middleImageURL];
}

- (NSArray *)thumbnailImageURLs {
    return [self middleImageURLs];
}

- (NSString *)middleImageURL {
    return [self hasImageSource] ? profileImageUrl_ : nil;
}

- (NSArray *)middleImageURLs {
    return [self hasImageSource] ? @[profileImageUrl_] : nil;
}

- (NSString *)bigImageURL {
    return [self middleImageURL];
}

- (NSArray *)bigImageURLs {
    return [self middleImageURLs];
}

- (NSArray *)noRawURLs
{
    return [self middleImageURLs];
}
- (NSString *)cacheKeyForImageSourceURL:(NSString *)imageSourceURL {
    return [self getAvatarCacheKey];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(userId_);
    //KD_RELEASE_SAFELY(openId_);
    //KD_RELEASE_SAFELY(username_);
    //KD_RELEASE_SAFELY(screenName_);
    //KD_RELEASE_SAFELY(email_);
    
    //KD_RELEASE_SAFELY(domain_);
    //KD_RELEASE_SAFELY(companyName_);
    //KD_RELEASE_SAFELY(department_);
    //KD_RELEASE_SAFELY(jobTitle_);
    //KD_RELEASE_SAFELY(defaultNetworkType_);
    
    //KD_RELEASE_SAFELY(province_);
    //KD_RELEASE_SAFELY(city_);
    //KD_RELEASE_SAFELY(location_);
    
    //KD_RELEASE_SAFELY(profileImageUrl_);
    //KD_RELEASE_SAFELY(url_);
    
    //KD_RELEASE_SAFELY(summary_);
    
    //KD_RELEASE_SAFELY(latestStatus_);
    
    //[super dealloc];
}

@end
