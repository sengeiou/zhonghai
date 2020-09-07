//
//  KDSigninRecordDAOImpl.m
//  kdweibo_common
//
//  Created by 王松 on 13-8-25.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDSigninRecordDAOImpl.h"
#import "KDDBManager.h"
#import "KDSignInRecord.h"
#import "NSDate+Additions.h"
@implementation KDSigninRecordDAOImpl

- (void)saveRecord:(KDSignInRecord *)record withDate:(NSDate *)date database:(FMDatabase *)fmdb
{
    if (!record) {
        return;
    }
    [self saveRecords:@[record] withDate:date database:fmdb rollback:NULL];
}
- (void)saveRecords:(NSArray *)record withDate:(NSDate *)date database:(FMDatabase *)fmdb rollback:(BOOL *)rollback
{
    if (!record||[record count] <1) {
        return;
    }
    NSString *sql = @"REPLACE INTO signin_record(singinId, featurename, content, status, singinTime, latitude, longitude, mbShare,recordType,photoIds,cachesUrl, inComany, clockInType, ssid, bssid, managerOid,manualType,org_latitude,org_longitude,address)"
    " VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?,?);";
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    NSTimeInterval time = 0;
    for (KDSignInRecord *s in record) {
        //如果signinId 为空，以时间和'KD'前缀来作为iD
        if (KD_IS_BLANK_STR(s.singinId)) {
            s.singinId = [NSString stringWithFormat:@"%@%f%lu",@"KD",[date timeIntervalSince1970],(unsigned long)[s hash]];
        }
        int idx = 1;
        [stmt bindString:s.singinId atIndex:idx++];
        [stmt bindString:s.featurename atIndex:idx++];
        [stmt bindString:s.content atIndex:idx++];
        [stmt bindInt:(int)s.status atIndex:idx++];
        if (s.singinTime) {
            time = [s.singinTime timeIntervalSince1970];
        }else{
            time = [date timeIntervalSince1970];
        }
        [stmt bindDouble:time atIndex:idx++];
        [stmt bindFloat:s.latitude atIndex:idx++];
        [stmt bindFloat:s.longitude atIndex:idx++];
        [stmt bindString:s.mbShare atIndex:idx++];
        [stmt bindInt:s.recordType atIndex:idx++];
        [stmt bindString:(s.photoIds && ![s.photoIds isKindOfClass:[NSNull class]] ? s.photoIds : @"") atIndex:idx++];
        
        [stmt bindString:(s.cachesUrl && s.cachesUrl.length>0)?s.cachesUrl : @"" atIndex:idx++];
        [stmt bindInt:(int)s.inCompany atIndex:idx++];
        [stmt bindString:(s.clockInType && s.clockInType.length>0) ? s.clockInType : @"" atIndex:idx++];
        [stmt bindString:(s.ssid && s.ssid.length>0)?s.ssid:@"" atIndex:idx++];
        [stmt bindString:(s.bssid&&s.bssid.length>0)?s.bssid : @"" atIndex:idx++];
        [stmt bindString:(s.managerOId && s.managerOId.length>0)?s.managerOId:@"" atIndex:idx++];
        [stmt bindInt:s.manualType atIndex:idx++];
        [stmt bindFloat:s.org_latitude atIndex:idx++];
        [stmt bindFloat:s.org_longitude atIndex:idx++];
        [stmt bindString:(s.address && s.address.length>0)? s.address:@"" atIndex:idx++];
        
        // step
        if (![stmt step]) {
            if (rollback) {
                *rollback = YES;
            }
            // rollback
            DLog(@"Can not save singIn with id=%@", s.singinId);
            
            break;
        }
        // reset parameters
        [stmt reset];
    }
    
    // finalize
    [stmt close];
    
    if (![self removeRecordlastDay:fmdb withDate:date]) {
        DLog(@"clean the expired record failed ");
    }
}

- (BOOL)removeRecordlastDay:(FMDatabase *)fmdb withDate:(NSDate *)date{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    NSTimeInterval todayTime = [today timeIntervalSince1970];
    NSString *sql = @"DELETE FROM signin_record WHERE  singinTime < ? and status != -1;";
    return [fmdb executeUpdate:sql, @(todayTime)];
}

- (void)updateRecordCounts:(NSArray *)counts database:(FMDatabase *)fmdb
{
    
}

- (NSArray *)queryRecordsWithLimit:(NSUInteger)limit withDate:(NSDate *)date database:(FMDatabase *)fmdb
{
    NSString *sql = @"SELECT singinId, featurename, content, status, singinTime, latitude, longitude, mbShare,recordType,photoIds,cachesUrl, inComany, clockInType, ssid, bssid, managerOid,manualType,org_latitude,org_longitude,address"
    " FROM signin_record WHERE singinTime >= ? AND featurename != '' ORDER BY singinTime DESC;";
    FMResultSet *rs = nil;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    NSTimeInterval todayTime = [today timeIntervalSince1970];
    rs = [fmdb executeQuery:sql, @(todayTime)];
    
    KDSignInRecord *record = nil;
    NSMutableArray *records = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        record = [[KDSignInRecord alloc] init];
        idx = 0;
        record.singinId = [rs stringForColumnIndex:idx++];
        record.featurename = [rs stringForColumnIndex:idx++];
        record.content = [rs stringForColumnIndex:idx++];
        record.status = [rs intForColumnIndex:idx++];
        record.singinTime = [rs dateForColumnIndex:idx++];
        record.latitude = [rs doubleForColumnIndex:idx++];
        record.longitude = [rs doubleForColumnIndex:idx++];
        record.mbShare = [rs stringForColumnIndex:idx++];
        record.recordType = [rs intForColumnIndex:idx++];
        record.photoIds = [rs stringForColumnIndex:idx ++];
        
        record.cachesUrl = [rs stringForColumnIndex:idx++];
        record.inCompany = [rs intForColumnIndex:idx++];
        record.clockInType = [rs stringForColumnIndex:idx++];
        record.ssid = [rs stringForColumnIndex:idx++];
        record.bssid = [rs stringForColumnIndex:idx++];
        record.managerOId = [rs stringForColumnIndex:idx++];
        record.manualType = [rs intForColumnIndex:idx++];
        record.org_latitude = [rs doubleForColumnIndex:idx++];
        record.org_longitude = [rs doubleForColumnIndex:idx++];
        record.address = [rs stringForColumnIndex:idx++];
        [records addObject:record];
    }
    
    [rs close];
    
    return records;
}

- (BOOL)removeRecordWithId:(NSString *)signId database:(FMDatabase *)fmdb
{
    if (signId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM signin_record WHERE singinId=?;", signId];
    
}

- (BOOL)removeAllRecordsInDatabase:(FMDatabase *)fmdb
{
    return NO;
}

- (NSMutableArray *)queryFailuredSignInRecordsWithLimit:(NSUInteger)limit withDate:(NSDate *)date database:(FMDatabase *)fmdb
{
    NSString *sql = @"SELECT singinId, featurename, content, status, singinTime, latitude, longitude, mbShare,recordType,photoIds,cachesUrl, inComany, clockInType, ssid, bssid, managerOid,manualType,org_latitude,org_longitude,address"
    " FROM signin_record WHERE singinTime >= ? AND featurename != '' AND status = -1 ORDER BY singinTime DESC;";
    FMResultSet *rs = nil;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    NSTimeInterval todayTime = [today timeIntervalSince1970];
    rs = [fmdb executeQuery:sql, @(todayTime)];
    
    KDSignInRecord *record = nil;
    NSMutableArray *records = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        record = [[KDSignInRecord alloc] init];
        idx = 0;
        record.singinId = [rs stringForColumnIndex:idx++];
        record.featurename = [rs stringForColumnIndex:idx++];
        record.content = [rs stringForColumnIndex:idx++];
        record.status = [rs intForColumnIndex:idx++];
        record.singinTime = [rs dateForColumnIndex:idx++];
        record.latitude = [rs doubleForColumnIndex:idx++];
        record.longitude = [rs doubleForColumnIndex:idx++];
        record.mbShare = [rs stringForColumnIndex:idx++];
        record.recordType = [rs intForColumnIndex:idx++];
        record.photoIds = [rs stringForColumnIndex:idx ++];
        
        record.cachesUrl = [rs stringForColumnIndex:idx++];
        record.inCompany = [rs intForColumnIndex:idx++];
        record.clockInType = [rs stringForColumnIndex:idx++];
        record.ssid = [rs stringForColumnIndex:idx++];
        record.bssid = [rs stringForColumnIndex:idx++];
        record.managerOId = [rs stringForColumnIndex:idx++];
        record.manualType = [rs intForColumnIndex:idx++];
        record.org_latitude = [rs doubleForColumnIndex:idx++];
        record.org_longitude = [rs doubleForColumnIndex:idx++];
        record.address = [rs stringForColumnIndex:idx++];
        [records addObject:record];
    }
    
    [rs close];
    
    return records;
}

@end
