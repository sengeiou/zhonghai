//
//  KDTodoDAO.h
//  kdweibo_common
//
//  Created by bird on 13-7-4.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@protocol KDTodoDAO   <NSObject>

@required

- (void)saveTodoList:(NSArray *)list database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;
- (NSArray *)queryTodoWithType:(NSString *)type database:(FMDatabase *)fmdb;
- (BOOL)removeTodoWithType:(NSString *)type database:(FMDatabase *)fmdb;
- (BOOL)removeTodoWithID:(NSString *)todoId database:(FMDatabase *)fmdb;
- (BOOL)removeTodoWithType:(NSString *)type byTime:(NSDate *)time database:(FMDatabase *)fmdb;
- (NSArray *)queryTodo_database:(FMDatabase *)fmdb;
- (BOOL)removeTodo_database:(FMDatabase *)fmdb;
@end