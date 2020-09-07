//
//  KDBaseDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseDAOImpl.h"

@implementation KDBaseDAOImpl

- (KDDBManager *)dbManager {
    return [KDDBManager sharedDBManager];
}

- (NSUInteger)queryCount:(NSString *)sql database:(FMDatabase *)fmdb {
    if (sql == nil) return 0;
    
    FMResultSet *rs = [fmdb executeQuery:sql];
    
    NSUInteger count = 0;
    if ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    
    [rs close]; // close result set
    
    return count;
}

@end
