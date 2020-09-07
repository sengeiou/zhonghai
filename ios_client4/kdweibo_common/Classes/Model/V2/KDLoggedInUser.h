//
//  KDLoggedInUser.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-7.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDLoggedInUser : NSObject <NSCoding> {
@private
    NSString *identifier_;
    NSUInteger loggedInTime_;
    BOOL isPhone_;
}

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, assign) NSUInteger loggedInTime;
@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, assign) BOOL isPhone;

- (id) initWithIdentifier:(NSString *)identifier loggedInTime:(NSUInteger)time;
- (id) initWithIdentifier:(NSString *)identifier loggedInTime:(NSUInteger)time andAvatarURL:(NSString *)url;
+ (id) loggedInUserWithIdentifier:(NSString *)identifier loggedInTime:(NSUInteger)time;

+ (NSMutableArray *) retrieveLoggedInUsers;
+ (NSMutableArray *) getLoggedInUsersIsPhone:(BOOL)isPhone;

+ (void) storeLoggedInUsers:(NSMutableArray *)users;
+ (void) storeLoggedInUsers:(NSMutableArray *)users isIphone:(BOOL)isPhone;

+ (void)updateUser:(NSString *)name url:(NSString *)url;
@end
