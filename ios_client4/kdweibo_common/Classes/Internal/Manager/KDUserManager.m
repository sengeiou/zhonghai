//
//  KDUserManager.m
//  kdweibo_common
//
//  Created by laijiandong on 12-8-22.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDUserManager.h"

#import "KDXAuthAuthorization.h"
#import "KDWeiboServicesContext.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"

#define KD_UM_PROP_ACCOUNT_SETTINGS                 @"kd.um.accountSettings"

#define KD_UM_PROP_SIGNED_USER_ID_KEY               @"kd.um.signedUserId"
#define KD_UM_PROP_SIGNED_USER_COMPANY_DOMAIN_KEY   @"kd.um.signedUserCompanyDomain"
#define KD_UM_PROP_SIGNED_USER_ACCESS_TOKEN_KEY     @"kd.um.signedUserAccessToken"
#define KD_UM_PROP_SIGNED_USER_VERIFY_USER_KEY      @"kd.um.signedUserInfoCache"

@interface KDUserManager ()

@property(nonatomic, retain) NSMutableDictionary *userCache;

@end

@implementation KDUserManager

@synthesize currentUserId=currentUserId_;
@synthesize currentUserCompanyDomain=currentUserCompanyDomain_;
@synthesize currentUser=currentUser_;

@synthesize accessToken=accessToken_;

@synthesize userCache=userCache_;

@synthesize verifyCache=verifyCache_;

- (id)init {
    self = [super init];
    if(self){
        userCache_ = [[NSMutableDictionary alloc] init];
        
        // retrieve user info
        [self retrieveUserData];
        
        // register did receive memory warning notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////

- (void)retrieveUserData {
    KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    NSData *data = [userDefaultsAdapter objectForKey:KD_UM_PROP_ACCOUNT_SETTINGS];
    if(data != nil){
        NSDictionary *userData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if(userData != nil){
            self.currentUserId = [userData objectForKey:KD_UM_PROP_SIGNED_USER_ID_KEY];
            self.currentUserCompanyDomain = [userData objectForKey:KD_UM_PROP_SIGNED_USER_COMPANY_DOMAIN_KEY];
            self.accessToken = [userData objectForKey:KD_UM_PROP_SIGNED_USER_ACCESS_TOKEN_KEY];
            self.verifyCache = [userData objectForKey:KD_UM_PROP_SIGNED_USER_VERIFY_USER_KEY];
        }
    }
}

- (void)updateCurrentUser :(KDServiceActionDidCompleteBlock)completeBlock
{
    NSString *userId = self.currentUserId;
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:userId];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            self.currentUser = results;
            if(completeBlock)
                completeBlock(results,request,response);
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:show" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

-(void)wake{
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            NSLog(@"123");
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:wake" query:nil
                                 configBlock:nil completionBlock:completionBlock];
}

- (KDUser *)currentUser{
    if(currentUser_ == nil) {
        currentUser_ = [self userWithUserId:self.currentUserId];
        if (currentUser_ == nil) {
//            [KDUser syncUserWithId:self.currentUserId completionBlock:^(KDUser * user) {
//                currentUser_ = [user retain];
//                [self addUser:currentUser_];
            //}];
            
           [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
                id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                return [userDAO queryUserWithId:self.currentUserId database:fmdb];
           }completionBlock:^(id results){
               currentUser_ = results;//.// retain];
           }];
        }
    
    }
    return currentUser_;
}
- (void)setCurrentUser:(KDUser *)currentUser {
    DLog(@"setCurrentuser...");
    if(currentUser_ != currentUser) {
//         [currentUser_ release];
        currentUser_ = currentUser;// retain];
        [self addUser:currentUser_];
        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
            id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
            [userDAO saveUser:currentUser_ database:fmdb];
            return nil;
            
        } completionBlock:nil];

    }
}

- (void)storeUserData {
    NSMutableDictionary *userData = [NSMutableDictionary dictionaryWithCapacity:0x03];
    
    if(currentUserId_ != nil){
        [userData setObject:currentUserId_ forKey:KD_UM_PROP_SIGNED_USER_ID_KEY];
    }
    
    if(currentUserCompanyDomain_ != nil){
        [userData setObject:currentUserCompanyDomain_ forKey:KD_UM_PROP_SIGNED_USER_COMPANY_DOMAIN_KEY];
    }
    
    if(accessToken_ != nil){
        [userData setObject:accessToken_ forKey:KD_UM_PROP_SIGNED_USER_ACCESS_TOKEN_KEY];
    }
    
    if (verifyCache_ != nil) {
        [userData setObject:verifyCache_ forKey:KD_UM_PROP_SIGNED_USER_VERIFY_USER_KEY];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userData];
    if(data != nil){
        KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
        [userDefaultsAdapter storeObject:data forKey:KD_UM_PROP_ACCOUNT_SETTINGS];
    }
}

- (void)cleanUserData {
    KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    [userDefaultsAdapter removeObjectForKey:KD_UM_PROP_ACCOUNT_SETTINGS];
}


////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark public methods

// check user is same as current user
- (BOOL)isCurrentUserId:(NSString *)userId {
    if(userId == nil || currentUserId_ == nil) return NO;
    
    return [currentUserId_ isEqualToString:userId];
}

- (BOOL)isPublicUser {
    return (!currentUserCompanyDomain_ || [currentUserCompanyDomain_ isEqualToString:@""]) ? YES : NO;
}

- (BOOL)isSigned {
    return (accessToken_ != nil && [accessToken_ isValid]) ? YES : NO;
}

- (void)updateAuthorizationForServicesContext {
    KDXAuthAuthorization *xAuthorization = [[KDXAuthAuthorization alloc] init];
    xAuthorization.accessToken = accessToken_;
    
    [[[KDWeiboServicesContext defaultContext] getKDWeiboServices] updateAuthorization:xAuthorization];
//    [xAuthorization release];
}


////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark user cahce methods

// cache user
- (void)addUser:(KDUser *)user {
    if(user != nil && user.userId != nil){
        [userCache_ setObject:user forKey:user.userId];
    }
}

// retrieve user from cache by user id
- (KDUser *)userWithUserId:(NSString *)userId {
    KDUser *target = nil;
    if(userId != nil){
        target = [userCache_ objectForKey:userId];
    }
    
    return target;
}

// retrieve user from cache by username
- (KDUser *)userWithUsername:(NSString *)username {
    KDUser *target = nil;
    if(username != nil && [userCache_ count] > 0){
        NSArray *keys = [userCache_ allKeys];
        KDUser *user = nil;
        for(NSArray *key in keys){
            user = [userCache_ objectForKey:key];
            if([user.username isEqualToString:username]){
                target = user;
                break;
            }
        }
    }
    
    return target;
}

// remove user from cache
- (void)removeUser:(KDUser *)user {
    if(user != nil){
        [self removeUserWithId:user.userId];
    }
}

// remove user from cache by user id
- (void)removeUserWithId:(NSString *)userId {
    if(userId != nil){
        [userCache_ removeObjectForKey:userId];
    }
}


//////////////////////////////////////////////////////////////////////////////////////

- (void)reset {
    //KD_RELEASE_SAFELY(currentUserId_);
    //KD_RELEASE_SAFELY(currentUserCompanyDomain_);
    //KD_RELEASE_SAFELY(currentUser_);
    
    //KD_RELEASE_SAFELY(accessToken_);
    
    [userCache_ removeAllObjects];
}


//////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Application did receive memory warning

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    [userCache_ removeAllObjects];
}

- (void)dealloc {
    // remove did receive memory warning notification
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
    //KD_RELEASE_SAFELY(verifyCache_);
    
    //KD_RELEASE_SAFELY(currentUserId_);
    //KD_RELEASE_SAFELY(currentUserCompanyDomain_);
    //KD_RELEASE_SAFELY(currentUser_);
    
    //KD_RELEASE_SAFELY(accessToken_);
    
    //KD_RELEASE_SAFELY(userCache_);
    
    //[super dealloc];
}

@end
