//
//  KDDatabaseHelper.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-20.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDDatabaseHelper.h"
#import "KDDBManager.h"

@implementation KDDatabaseHelper

+ (void)asyncInDatabase:(id (^)(FMDatabase *))executionBlock
               completionBlock:(void (^)(id results))completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        __block id results = nil;
        [[KDDBManager sharedDBManager].fmdbQueue inDatabase:^(FMDatabase *fmdb){
            results = executionBlock(fmdb);
        }];
        
        if (completionBlock != nil) {
            // execute the block as sync mode to make the results object can not be release
            // before completion block did finish.
            // current sub thread will be block.
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                completionBlock(results);
            });
        }
    });
}

+ (void)inDatabase:(id (^)(FMDatabase *))executionBlock
            completionBlock:(void (^)(id results))completionBlock {
    
    __block id results = nil;
    [[KDDBManager sharedDBManager].fmdbQueue inDatabase:^(FMDatabase *fmdb){
        results = executionBlock(fmdb);
    }];
    
    if (completionBlock != nil) {
        completionBlock(results);
    }
}

+ (void)asyncInTransaction:(id (^)(FMDatabase *db, BOOL *rollback))executionBlock
           completionBlock:(void (^)(id results))completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        __block id results = nil;
        [[KDDBManager sharedDBManager].fmdbQueue inTransaction:^(FMDatabase *fmdb, BOOL *rollback){
            results = executionBlock(fmdb, rollback);
        }];
        
        if (completionBlock != nil) {
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                completionBlock(results);
            });
        }
    });
}

+ (void)inTransaction:(id (^)(FMDatabase *db, BOOL *rollback))executionBlock
                  completionBlock:(void (^)(id results))completionBlock {
    
    __block id results = nil;
    [[KDDBManager sharedDBManager].fmdbQueue inTransaction:^(FMDatabase *fmdb, BOOL *rollback){
        results = executionBlock(fmdb, rollback);
    }];
    
    if (completionBlock != nil) {
        completionBlock(results);
    }
}

+ (void)asyncInDeferredTransaction:(id (^)(FMDatabase *db, BOOL *rollback))executionBlock
                          completionBlock:(void (^)(id results))completionBlock {
  
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        __block id results = nil;
        [[KDDBManager sharedDBManager].fmdbQueue inDeferredTransaction:^(FMDatabase *fmdb, BOOL *rollback){
            results = executionBlock(fmdb, rollback);
        }];
        
        if (completionBlock != nil) {
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                completionBlock(results);
            });
        }
    });
}

+ (void)inDeferredTransaction:(id (^)(FMDatabase *db, BOOL *rollback))executionBlock
                         completionBlock:(void (^)(id results))completionBlock {
    
    __block id results = nil;
    [[KDDBManager sharedDBManager].fmdbQueue inDeferredTransaction:^(FMDatabase *fmdb, BOOL *rollback){
        results = executionBlock(fmdb, rollback);
    }];
    
    if (completionBlock != nil) {
        completionBlock(results);
    }
}

@end
