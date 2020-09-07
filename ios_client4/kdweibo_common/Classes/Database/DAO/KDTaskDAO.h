//
//  KDTaskDAO.h
//  kdweibo_common
//
//  Created by Tan yingqi on 13-7-5.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@class KDTask;

@protocol KDTaskDAO <NSObject>
@required
- (void)saveTasks:(NSArray *)tasks database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;

@end