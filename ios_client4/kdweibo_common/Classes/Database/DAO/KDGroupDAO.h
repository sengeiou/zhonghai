//
//  KDGroupDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDGroup;

@protocol KDGroupDAO <NSObject>
@required

- (void)saveGroups:(NSArray *)groups database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;
- (KDGroup *)queryGroupWithId:(NSString *)groupId database:(FMDatabase *)fmdb;
- (NSArray *)queryGroupsWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb;
- (BOOL)removeAllGroupsInDatabase:(FMDatabase *)fmdb;

@end