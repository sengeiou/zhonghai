//
//  KDLoggedInUser.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-7.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDLoggedInUser.h"
#import "KDWeiboServicesContext.h"

#define KD_LOGGED_IN_USERS_CACHE_KEY  @"loggedInUsers"


@implementation KDLoggedInUser

@synthesize identifier=identifier_;
@synthesize loggedInTime=loggedInTime_;
@synthesize avatarURL = avatarURL_;
@synthesize isPhone = isPhone_;

- (id) init {
    self = [super init];
    if(self){
        identifier_ = nil;
        loggedInTime_= 0;
    }
    
    return self;
}

- (id)initWithIdentifier:(NSString *)identifier loggedInTime:(NSUInteger)time andAvatarURL:(NSString *)url {
    self = [self init];
    if(self) {
        identifier_ = identifier ;//；／／retain];
        loggedInTime_ = time;
        avatarURL_ = [url copy];
    }
    
    return self;
}

- (id)initWithIdentifier:(NSString *)identifier loggedInTime:(NSUInteger)time {
    self = [self init];
    if(self) {
        identifier_ = identifier;//；／／ retain];
        loggedInTime_ = time;
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if(self){
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.loggedInTime = [aDecoder decodeIntegerForKey:@"loggedInTime"];
        self.avatarURL = [aDecoder decodeObjectForKey:@"avatarURL"];
        self.isPhone = [aDecoder decodeBoolForKey:@"isPhone"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if(identifier_ != nil){
        [aCoder encodeObject:identifier_ forKey:@"identifier"];
    }

    [aCoder encodeBool:isPhone_ forKey:@"isPhone"];
    [aCoder encodeInteger:loggedInTime_ forKey:@"loggedInTime"];
    [aCoder encodeObject:avatarURL_ forKey:@"avatarURL"];
}

+ (id) loggedInUserWithIdentifier:(NSString *)identifier loggedInTime:(NSUInteger)time {
    return [[KDLoggedInUser alloc] initWithIdentifier:identifier loggedInTime:time];// autorelease];
}

- (NSString *) format {
    return [NSString stringWithFormat:@"{%@,%lu,%@,%d}", identifier_, (unsigned long)loggedInTime_, avatarURL_ ? avatarURL_ : @"",isPhone_];
}

+ (id) parse:(NSString *)str {
    if (str == nil || [str length] < 0x03) return nil;
    
    NSUInteger len = [str length];
    if('{' != [str characterAtIndex:0x00] && '}' != [str characterAtIndex:len - 1]) return nil;
    
    NSString *target = [str substringWithRange:NSMakeRange(1, len - 2)];
    NSArray *items = [target componentsSeparatedByString:@","];
    if(items == nil || [items count] < 0x02) return nil;
    
    KDLoggedInUser *user = [[KDLoggedInUser alloc] initWithIdentifier:[items objectAtIndex:0x00]
                                                         loggedInTime:[[items objectAtIndex:0x01] integerValue]];
    
    if(items.count > 2) {
        user.avatarURL = [items objectAtIndex:0x02];
    }
    if(items.count > 3) {
        user.isPhone = [[items objectAtIndex:0x03] boolValue];
    }
    
    return user;// autorelease];
}
+ (NSMutableArray *) getLoggedInUsersIsPhone:(BOOL)isPhone
{
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:
                        @"isPhone_=%d",isPhone];
    
    NSArray *allUser = [self retrieveLoggedInUsers];
    allUser = [allUser filteredArrayUsingPredicate:pre];
    return [NSMutableArray arrayWithArray:allUser];

}
+ (NSMutableArray *) retrieveLoggedInUsers {
    NSMutableArray *users = nil;
    
    KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    NSString *body = [userDefaultAdapter stringForKey:KD_LOGGED_IN_USERS_CACHE_KEY];
    
    if(body != nil){
        users = [NSMutableArray array];
        
        NSArray *items = [body componentsSeparatedByString:@";"];
        if(items != nil){
            KDLoggedInUser *user = nil;
            for(NSString *item in items){
                user = [KDLoggedInUser parse:item];
                if(user != nil) {
                    [users addObject:user];
                }
            }
        }
    }
    
    return users;
}
+ (void) storeLoggedInUsers:(NSMutableArray *)users isIphone:(BOOL)isPhone
{
    
    KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    
    if(users != nil && [users count] > 0) {
        // sort by last logged in time
        [users sortUsingComparator:^(id obj1, id obj2){
            NSInteger diff = ((KDLoggedInUser *)obj1).loggedInTime - ((KDLoggedInUser *)obj2).loggedInTime;
            
            return (diff > 0) ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        // generate cache string
        NSMutableString *str = [NSMutableString string];
        
               NSPredicate *pre = [NSPredicate predicateWithFormat:
                            @"isPhone_=%d",!isPhone];
        
        NSArray *allUser = [self retrieveLoggedInUsers];
        allUser = [allUser filteredArrayUsingPredicate:pre];
        [users addObjectsFromArray:allUser];
        
        NSUInteger boundary = [users count] - 1;
        NSInteger idx = 0;

        for(KDLoggedInUser *user in users){
            [str appendString:[user format]];
            if(idx++ != boundary){
                [str appendString:@";"];
            }
        }
        
        [userDefaultAdapter storeObject:str forKey:KD_LOGGED_IN_USERS_CACHE_KEY];
        
    }else {
        [userDefaultAdapter removeObjectForKey:KD_LOGGED_IN_USERS_CACHE_KEY];
    }
}


+ (void) storeLoggedInUsers:(NSMutableArray *)users {
    KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    
    if(users != nil && [users count] > 0) {
        // sort by last logged in time
        [users sortUsingComparator:^(id obj1, id obj2){
            NSInteger diff = ((KDLoggedInUser *)obj1).loggedInTime - ((KDLoggedInUser *)obj2).loggedInTime;
            
            return (diff > 0) ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        // generate cache string
        NSMutableString *str = [NSMutableString string];
        
        NSUInteger boundary = [users count] - 1;
        NSInteger idx = 0;
        for(KDLoggedInUser *user in users){
            [str appendString:[user format]];
            if(idx++ != boundary){
                [str appendString:@";"];
            }
        }
        [userDefaultAdapter storeObject:str forKey:KD_LOGGED_IN_USERS_CACHE_KEY];
    
    }else {
        [userDefaultAdapter removeObjectForKey:KD_LOGGED_IN_USERS_CACHE_KEY];
    }
}
+ (void)updateUser:(NSString *)name url:(NSString *)url{
    
    NSMutableArray *allUser = [self retrieveLoggedInUsers];
    for (KDLoggedInUser *user in allUser) {
        if ([user.identifier isEqualToString:name]) {
            user.avatarURL = url;
        }
    }
    
    [self storeLoggedInUsers:allUser];
}
- (void) dealloc {
    //KD_RELEASE_SAFELY(identifier_);
    
    //[super dealloc];
}

@end
