//
//  KDDBManager.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface KDDBManager : NSObject

@property(nonatomic, retain, readonly) FMDatabaseQueue *fmdbQueue; // fmdb queue

+ (KDDBManager *)sharedDBManager; // default shared database manager,

- (BOOL)tryConnectToCommunity:(NSString *)communityId;
- (BOOL)isConnectingWithCommunity:(NSString *)communityId;
- (void)close;
- (void)deleteCurrentCompanyDataBase;
@end
