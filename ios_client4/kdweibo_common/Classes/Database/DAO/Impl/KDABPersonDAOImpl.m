//
//  KDABPersonDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDABPersonDAOImpl.h"
#import "KDDBManager.h"

@implementation KDABPersonDAOImpl

////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Persistence

#define KD_AB_PERSON_DIVIDER_SYMBOL    @"<,>"

- (NSString *)personCompositeValueToString:(NSArray *)compositeValue {
    if (compositeValue == nil || [compositeValue count] < 1) return nil;
    
    return [compositeValue componentsJoinedByString:KD_AB_PERSON_DIVIDER_SYMBOL];
}

- (NSArray *)personCompositeValueFromString:(NSString *)string {
    if (string == nil || [string length] < 1) return nil;
    return [string componentsSeparatedByString:KD_AB_PERSON_DIVIDER_SYMBOL];
}

- (void)saveABPersons:(NSArray *)persons type:(KDABPersonType)type
                clear:(BOOL)clear database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    if (persons == nil || [persons count] < 1) return;
    
    if (clear) {
        // remove all cached persons for specificed type before any updates
        if (![self removeAllABPersonsWithType:type database:fmdb]) {
            DLog(@"Can not remove the address book persons with specificed type=%d before save action.", type);
        }
    }
    
    NSString *sql = @"REPLACE INTO ab_persons(pid, user_id, name, job_title, department, emails, "
                     " phones, mobiles, profile_image_url, network_id, favorited, type, sorting_time)"
                     " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    NSInteger time = [[NSDate date] timeIntervalSince1970];
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    for (KDABPerson *p in persons) {
        int idx = 1;
        
        [stmt bindString:p.pId atIndex:idx++];
        [stmt bindString:p.userId atIndex:idx++];
        [stmt bindString:p.name atIndex:idx++];
        [stmt bindString:p.jobTitle atIndex:idx++];
        [stmt bindString:p.department atIndex:idx++];
        
        [stmt bindString:[self personCompositeValueToString:p.emails] atIndex:idx++];
        [stmt bindString:[self personCompositeValueToString:p.phones] atIndex:idx++];
        [stmt bindString:[self personCompositeValueToString:p.mobiles] atIndex:idx++];
        
        [stmt bindString:p.profileImageURL atIndex:idx++];
        [stmt bindString:p.networkId atIndex:idx++];
        
        [stmt bindBool:p.favorited atIndex:idx++];
        [stmt bindInt:type atIndex:idx++];
        
        [stmt bindInt:(int)time-- atIndex:idx++];
        
        // step
        if (![stmt step]) {
            *rollback = YES; // rollback
            DLog(@"Can not save ab person with id=%@", p.pId);
            
            break;
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize
    [stmt close];
}

- (BOOL)updateABPersonFavoritedState:(KDABPerson *)person database:(FMDatabase *)fmdb {
    if (person == nil || person.pId == nil) return NO;
    
    NSNumber *favorited = @(person.favorited ? 1 : 0);
    return [fmdb executeUpdate:@"UPDATE ab_persons SET favorited = ? WHERE pid = ?;", favorited, person.pId];
}

- (NSArray *)queryABPersonsByType:(KDABPersonType)type limit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"SELECT pid, user_id, name, job_title, department, emails, phones, mobiles, profile_image_url,"
                     " network_id, favorited, type FROM ab_persons WHERE type=? ORDER BY sorting_time DESC limit ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, @(type), @(limit)];
    
    KDABPerson *p = nil;
    NSMutableArray *persons = [NSMutableArray array];
    
    while ([rs next]) {
        int idx = 0;
        p = [[KDABPerson alloc] initWithType:type];
        
        p.pId = [rs stringForColumnIndex:idx++];
        p.userId = [rs stringForColumnIndex:idx++];
        p.name = [rs stringForColumnIndex:idx++];
        p.jobTitle = [rs stringForColumnIndex:idx++];
        p.department = [rs stringForColumnIndex:idx++];
        
        p.emails = [self personCompositeValueFromString:[rs stringForColumnIndex:idx++]];
        p.phones = [self personCompositeValueFromString:[rs stringForColumnIndex:idx++]];
        p.mobiles = [self personCompositeValueFromString:[rs stringForColumnIndex:idx++]];
        
        p.profileImageURL = [rs stringForColumnIndex:idx++];
        p.networkId = [rs stringForColumnIndex:idx++];
        
        p.favorited = [rs boolForColumnIndex:idx++];
        p.type = [rs intForColumnIndex:idx++];
        
        [persons addObject:p];
    }
    
    [rs close];
    
    return persons;
}

- (NSArray *)queryABPersonsByUserId:(NSString *)userId database:(FMDatabase *)fmdb {
    NSString *sql = @"SELECT pid, user_id, name, job_title, department, emails, phones, mobiles, profile_image_url,"
    " network_id, favorited, type FROM ab_persons WHERE user_id=? ORDER BY sorting_time;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, userId];
    
    KDABPerson *p = nil;
    NSMutableArray *persons = [NSMutableArray array];
    
    while ([rs next]) {
        int idx = 0;
        p = [[KDABPerson alloc] init];
        
        p.pId = [rs stringForColumnIndex:idx++];
        p.userId = [rs stringForColumnIndex:idx++];
        p.name = [rs stringForColumnIndex:idx++];
        p.jobTitle = [rs stringForColumnIndex:idx++];
        p.department = [rs stringForColumnIndex:idx++];
        
        p.emails = [self personCompositeValueFromString:[rs stringForColumnIndex:idx++]];
        p.phones = [self personCompositeValueFromString:[rs stringForColumnIndex:idx++]];
        p.mobiles = [self personCompositeValueFromString:[rs stringForColumnIndex:idx++]];
        
        p.profileImageURL = [rs stringForColumnIndex:idx++];
        p.networkId = [rs stringForColumnIndex:idx++];
        
        p.favorited = [rs boolForColumnIndex:idx++];
        p.type = [rs intForColumnIndex:idx++];
        
        [persons addObject:p];
    }
    
    [rs close];
    
    return persons;

}

// each type of person in address book only keep latest 20. (except favoried persons)
- (BOOL)cleanExpiredABPersonsByType:(KDABPersonType)type database:(FMDatabase *)fmdb {
    NSString *sql = @"DELETE FROM ab_persons WHERE type = ? AND sorting_time < (SELECT MIN(temp.sorting_time)"
                     " FROM (SELECT sorting_time FROM ab_persons WHERE type = ? ORDER BY sorting_time DESC LIMIT 20) AS temp);";
    
    return [fmdb executeUpdate:sql, @(type), @(type)];
}

- (BOOL)removeAllABPersonsWithType:(KDABPersonType)type database:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM ab_persons WHERE type = ?;", @(type)];
}

- (BOOL)removeABPerson:(KDABPerson *)person type:(KDABPersonType)type database:(FMDatabase *)fmdb {
    if (person == nil || person.pId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM ab_persons WHERE pid = ? AND type = ?;", person.pId, @(type)];
}

@end
