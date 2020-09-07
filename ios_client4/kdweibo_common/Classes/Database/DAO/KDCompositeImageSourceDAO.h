//
//  KDCompositeImageSourceDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDCompositeImageSource;

@protocol KDCompositeImageSourceDAO <NSObject>
@required

- (void)saveCompositeImageSource:(KDCompositeImageSource *)compositeImageSource
                        entityId:(NSString *)entityId database:(FMDatabase *)fmdb;
- (KDCompositeImageSource *)queryCompositeImageSourceWithEntityId:(NSString *)entityId database:(FMDatabase *)fmdb;

- (BOOL)removeCompositeImageSourceWithEntityId:(NSString *)entityId database:(FMDatabase *)fmdb;
- (BOOL)removeCompositeImageSourceInDatabase:(FMDatabase *)fmdb;

@end
