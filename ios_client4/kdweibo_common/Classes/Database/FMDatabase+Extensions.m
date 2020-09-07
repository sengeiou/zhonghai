//
//  FMDatabase+Extensions.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "FMDatabase+Extensions.h"

@implementation FMDatabase (Extensions)

- (FMStatement *)preparedStatementWithSQL:(NSString *)sql {
    if ([self sqliteHandle] == NULL) {
        return nil;
    }
    
    int rc = 0;
    sqlite3_stmt *pStmt = NULL;
    
    int numberOfRetries = 0;
    BOOL retry = NO;
    
    if (pStmt == NULL) {
        do {
            retry = NO;
            rc = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &pStmt, 0);
            if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
                retry = YES;
                usleep(20);
                
                if (_busyRetryTimeout && (numberOfRetries++ > _busyRetryTimeout)) {
                    NSLog(@"%s:%d Database busy (%@)", __FUNCTION__, __LINE__, [self databasePath]);
                    NSLog(@"Database busy");
                    sqlite3_finalize(pStmt);
                    pStmt = NULL;
                    
                    return nil;
                }
                
            } else if (SQLITE_OK != rc) {
                if (_logsErrors) {
                    NSLog(@"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                    NSLog(@"DB Query: %@", sql);
                    NSLog(@"DB Path: %@", _databasePath);
#ifndef NS_BLOCK_ASSERTIONS
                    if (_crashOnErrors) {
                        abort();
                        NSAssert2(false, @"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                    }
#endif
                }
                
                sqlite3_finalize(pStmt);
                pStmt = NULL;
                
                return nil;
            }
            
        } while (retry);
    }
    
    FMStatement *stmt = nil;
    if (pStmt != NULL) {
        stmt = [[FMStatement alloc] init];// autorelease];
        stmt.statement = pStmt;
    }
    
    return stmt;
}

@end
