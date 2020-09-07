//
//  KDApplicationDAO.h
//  kdweibo_common
//
//  Created by shen kuikui on 14-1-9.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@protocol KDApplicationDAO <NSObject>
@required

- (NSArray *)queryAllApplicationsFromDB:(FMDatabase *)db;

- (void)saveApplications:(NSArray *)applications database:(FMDatabase *)db;

@end
