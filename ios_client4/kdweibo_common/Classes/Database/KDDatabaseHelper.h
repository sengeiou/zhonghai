//
//  KDDatabaseHelper.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-20.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"

@interface KDDatabaseHelper : NSObject

// Start execute path in the global queue, and execute the execution block on fmdatabase queue,
// Then execute the completion block on main queue.
//
// Because the fmdatabase queue is sync queue, so it will block current execution path,
+ (void)asyncInDatabase:(id (^)(FMDatabase *))executionBlock
        completionBlock:(void (^)(id results))completionBlock;

// execute the execution block on fmdatabase queue
// and the completion block execute on caller thread context (may be main thread on sub thread, it's depends on caller)
+ (void)inDatabase:(id (^)(FMDatabase *))executionBlock
          completionBlock:(void (^)(id results))completionBlock;


////////////////////////////////////////////////////////////////////////

+ (void)asyncInTransaction:(id (^)(FMDatabase *db, BOOL *rollback))executionBlock
           completionBlock:(void (^)(id results))completionBlock;

+ (void)inTransaction:(id (^)(FMDatabase *db, BOOL *rollback))executionBlock
      completionBlock:(void (^)(id results))completionBlock;


////////////////////////////////////////////////////////////////////////

+ (void)asyncInDeferredTransaction:(id (^)(FMDatabase *db, BOOL *rollback))executionBlock
                   completionBlock:(void (^)(id results))completionBlock;

+ (void)inDeferredTransaction:(id (^)(FMDatabase *db, BOOL *rollback))executionBlock
              completionBlock:(void (^)(id results))completionBlock;

@end
