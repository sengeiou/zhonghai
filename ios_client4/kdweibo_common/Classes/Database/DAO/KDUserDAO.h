//
//  KDUserDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDUser;

@protocol KDUserDAO <NSObject>
@required

- (void)saveUser:(KDUser *)user database:(FMDatabase *)fmdb;
- (void)saveUserSimple:(KDUser *)user database:(FMDatabase *)fmdb; // just update name, screen name and profile image url
- (void)saveUsers:(NSArray *)users database:(FMDatabase *)fmdb;
- (void)saveUsersSimple:(NSArray *)users database:(FMDatabase *)fmdb;

- (KDUser *)queryUserWithId:(NSString *)userId database:(FMDatabase *)fmdb;
- (KDUser *)queryUserWithName:(NSString *)name database:(FMDatabase *)fmdb;
- (KDUser *)queryUserWithScreenName:(NSString *)screenName database:(FMDatabase *)fmdb;

// just return the basic info about user (id, name, screen name, profile image url, is_team_user, is_public_user)
- (NSArray *)queryUsersSimpleWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb;

- (BOOL)removeUserWithId:(NSString *)userId database:(FMDatabase *)fmdb;
- (BOOL)removeAllUsersInDatabase:(FMDatabase *)fmdb;

//for frequent contacts
- (void)saveFrequentContacts:(NSArray *)users withType:(NSInteger)type intoDatabase:(FMDatabase *)fmdb;
- (NSArray *)queryFrequentcontactsWithType:(NSInteger)type from:(FMDatabase *)fmdb;
@end
