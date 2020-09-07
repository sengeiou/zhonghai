//
//  KDExtendStatusDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-5.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDExtendStatus;

@protocol KDExtendStatusDAO <NSObject>
@required

- (void)saveExtendStatus:(KDExtendStatus *)status database:(FMDatabase *)fmdb;
- (KDExtendStatus *)queryExtendStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb;

- (BOOL)removeExtendStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb;
- (BOOL)removeAllExtendStatusesInDatabase:(FMDatabase *)fmdb;

@end
