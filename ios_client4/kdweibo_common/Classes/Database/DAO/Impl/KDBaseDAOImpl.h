//
//  KDBaseDAOImpl.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDCommon.h"
#import "KDDBManager.h"

#import "FMDatabase+Extensions.h"
#import "FMStatement+Extensions.h"

@interface KDBaseDAOImpl : NSObject

- (KDDBManager *)dbManager;

// Query the result set count with specificed SQL
- (NSUInteger)queryCount:(NSString *)sql database:(FMDatabase *)fmdb;

@end
