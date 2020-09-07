//
//  KDUserDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDUserDAOImpl.h"
#import "KDUser.h"

@implementation KDUserDAOImpl

/**
 * 王松
 *
 *  @param rs
 *  @param flag 时候调用rs next
 *
 *  @return
 */
- (KDUser *)userWithResultSet:(FMResultSet *)rs shouldNext:(BOOL)flag{
    KDUser *user = nil;
    if ((flag && [rs next]) || !flag) {
        user = [[KDUser alloc] init];/// autorelease];
        
        int idx = 0;
        user.userId = [rs stringForColumnIndex:idx++];
        user.username = [rs stringForColumnIndex:idx++];
        user.screenName = [rs stringForColumnIndex:idx++];
        user.email = [rs stringForColumnIndex:idx++];
        user.profileImageUrl = [rs stringForColumnIndex:idx++];
        
        user.followersCount = [rs intForColumnIndex:idx++];
        user.friendsCount = [rs intForColumnIndex:idx++];
        
        user.summary = [rs stringForColumnIndex:idx++];
        user.statusesCount = [rs intForColumnIndex:idx++];
        user.favoritesCount = [rs intForColumnIndex:idx++];
        
        user.department = [rs stringForColumnIndex:idx++];
        user.jobTitle = [rs stringForColumnIndex:idx++];
        
        user.topicsCount = [rs intForColumnIndex:idx++];
        user.companyName = [rs stringForColumnIndex:idx++];
        
        user.isTeamUser = [rs boolForColumnIndex:idx++];
        user.isPublicUser = [rs boolForColumnIndex:idx++];
    }
    
    return user;
}

- (void)saveUser:(KDUser *)user database:(FMDatabase *)fmdb {
    if (user == nil) return;
    
    [self saveUsers:@[user] database:fmdb];
}

- (void)saveUserSimple:(KDUser *)user database:(FMDatabase *)fmdb {
    if (user == nil) return;
    
    [self saveUsersSimple:@[user] database:fmdb];
}

- (void)saveUsers:(NSArray *)users database:(FMDatabase *)fmdb {
    if (users == nil || [users count] == 0) return;
    NSString *sql = @"REPLACE INTO users(user_id, name, screen_name, email, profile_image_url,"
                     " followees, fans, description, statuses_count, favorites_count,"
                     " department, job, topic, company_name, is_team_user, is_public_user)"
                     " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    for (KDUser *u in users) {
        int idx = 1;
        
        [stmt bindString:u.userId atIndex:idx++];
        [stmt bindString:u.username atIndex:idx++];
        [stmt bindString:u.screenName atIndex:idx++];
        [stmt bindString:u.email atIndex:idx++];
        [stmt bindString:u.profileImageUrl atIndex:idx++];
        
        [stmt bindInt:(int)u.followersCount atIndex:idx++];
        [stmt bindInt:(int)u.friendsCount atIndex:idx++];
        [stmt bindString:u.summary atIndex:idx++];
        [stmt bindInt:(int)u.statusesCount atIndex:idx++];
        [stmt bindInt:(int)u.favoritesCount atIndex:idx++];
        
        [stmt bindString:u.department atIndex:idx++];
        [stmt bindString:u.jobTitle atIndex:idx++];
        [stmt bindInt:(int)u.topicsCount atIndex:idx++];
        [stmt bindString:u.companyName atIndex:idx++];
        
        [stmt bindBool:u.isTeamUser atIndex:idx++];
        [stmt bindBool:u.isPublicUser atIndex:idx++];
        
        // step
        if (![stmt step]) {
            DLog(@"Can not save user with id=%@", u.userId);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize
    [stmt close];
}

- (void)saveUsersSimple:(NSArray *)users database:(FMDatabase *)fmdb {
    if (users == nil || [users count] == 0) return;
    
    NSString *sql = @"REPLACE INTO users(user_id, name, screen_name, profile_image_url, is_team_user, is_public_user,company_name,department,job)"
                     " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    for (KDUser *u in users) {
        int idx = 1;
        
        [stmt bindString:u.userId atIndex:idx++];
        [stmt bindString:u.username atIndex:idx++];
        [stmt bindString:u.screenName atIndex:idx++];
        [stmt bindString:u.profileImageUrl atIndex:idx++];
        
        [stmt bindBool:u.isTeamUser atIndex:idx++];
        [stmt bindBool:u.isPublicUser atIndex:idx++];
        [stmt bindString:u.companyName atIndex:idx++];
        [stmt bindString:u.department atIndex:idx++];
        [stmt bindString:u.jobTitle atIndex:idx++];
        
        // step
        if (![stmt step]) {
            DLog(@"Can not save user with id=%@", u.userId);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize
    [stmt close];
}

- (KDUser *)queryUserWithId:(NSString *)userId database:(FMDatabase *)fmdb {
    if (userId == nil) return nil;
    
    NSString *sql = @"SELECT user_id, name, screen_name, email, profile_image_url, followees, fans,"
                     " description, statuses_count, favorites_count, department, job, topic, company_name, "
                     " is_team_user, is_public_user FROM users WHERE user_id=?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, userId];
    KDUser *user = [self userWithResultSet:rs shouldNext:YES];
    [rs close];
    
    return user;
}

- (KDUser *)queryUserWithName:(NSString *)name database:(FMDatabase *)fmdb {
    if (name == nil) return nil;
    
    NSString *sql = @"SELECT user_id, name, screen_name, email, profile_image_url, followees, fans,"
                     " description, statuses_count, favorites_count, department, job, topic, company_name,"
                     " is_team_user, is_public_user FROM users WHERE name=?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, name];
    KDUser *user = [self userWithResultSet:rs shouldNext:YES];
    [rs close];
    
    return user;
}

- (KDUser *)queryUserWithScreenName:(NSString *)screenName database:(FMDatabase *)fmdb {
    if (screenName == nil) return nil;
    
    NSString *sql = @"SELECT user_id, name, screen_name, email, profile_image_url, followees, fans,"
                     " description, statuses_count, favorites_count, department, job, topic, company_name,"
                     " is_team_user, is_public_user FROM users WHERE screen_name=?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, screenName];
    KDUser *user = [self userWithResultSet:rs shouldNext:YES];
    [rs close];
    
    return user;
}

- (NSArray *)queryUsersSimpleWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"SELECT user_id, name, screen_name, profile_image_url, is_team_user, is_public_user"
                     " FROM users ORDER by screen_name LIMIT ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, @(limit)];
    
    int idx;
    KDUser *user = nil;
    NSMutableArray *users = [NSMutableArray array];
    while ([rs next]) {
        user = [[KDUser alloc] init];
        
        idx = 0;
        user.userId = [rs stringForColumnIndex:idx++];
        user.username = [rs stringForColumnIndex:idx++];
        user.screenName = [rs stringForColumnIndex:idx++];
        user.profileImageUrl = [rs stringForColumnIndex:idx++];
        
        user.isTeamUser = [rs boolForColumnIndex:idx++];
        user.isPublicUser = [rs boolForColumnIndex:idx++];
        
        [users addObject:user];
//        [user release];
    }
    
    [rs close];
    
    return users;
}

- (BOOL)removeUserWithId:(NSString *)userId database:(FMDatabase *)fmdb {
    if (userId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM users WHERE user_id=?;", userId];
}

- (BOOL)removeAllUsersInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM users;"];
}

//for frequent contacts


- (void)saveFrequentContacts:(NSArray *)users withType:(NSInteger)type intoDatabase:(FMDatabase *)fmdb {
    if(!users || users.count == 0) return;
    
    [fmdb executeUpdate:@"DELETE FROM frequent_contacts"];
    
    NSString *sql = @"REPLACE INTO frequent_contacts VALUES(?, ?)";
    
    FMStatement *st = [fmdb preparedStatementWithSQL:sql];
    
    if(st) {
        BOOL success = YES;
        
        for(KDUser *user in users) {
            int idx = 1;
            
            [st bindString:user.userId atIndex:idx++];
            [st bindInt:(int)type atIndex:idx++];
            
            if(![st step]) {
                success = NO;
                NSLog(@"Failed to save frequent contacts");
            }
            
            [st reset];
        }
        
        if(success) {
            [self saveUsers:users database:fmdb];
        }
    }
    
    [st close];
}

- (NSArray *)queryFrequentcontactsWithType:(NSInteger)type from:(FMDatabase *)fmdb {
    NSString *query = [NSString stringWithFormat:@"SELECT U.user_id, U.name, U.screen_name, U.email, U.profile_image_url, U.followees, U.fans,"
                       "U.description, U.statuses_count, U.favorites_count, U.department, U.job, U.topic, U.company_name,"
                       "U.is_team_user, U.is_public_user FROM users U WHERE user_id IN (SELECT user_id FROM frequent_contacts WHERE type=%ld)", (long)type];
    
    FMResultSet *rs = [fmdb executeQuery:query];
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:10];
    
    while ([rs next]) {
        KDUser *user = [self userWithResultSet:rs shouldNext:NO];
        
        if(user)
            [users addObject:user];
    }
    
    [rs close];
    
    return users;
}

@end
