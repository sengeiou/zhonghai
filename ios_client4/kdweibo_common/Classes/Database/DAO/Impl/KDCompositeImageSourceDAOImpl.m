//
//  KDCompositeImageSourceDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCompositeImageSourceDAOImpl.h"
#import "KDCompositeImageSource.h"

@implementation KDCompositeImageSourceDAOImpl

- (KDCompositeImageSource *)_compositeImageSourceWithResultSet:(FMResultSet *)rs {
    KDImageSource *imageSource = nil;
    NSMutableArray *items = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        imageSource = [[KDImageSource alloc] init];
        
        idx = 0;
        imageSource.fileId = [rs stringForColumnIndex:idx++];
        imageSource.entityId = [rs stringForColumnIndex:idx++];
        imageSource.fileName = [rs stringForColumnIndex:idx++];
        imageSource.fileType = [rs stringForColumnIndex:idx++];
        imageSource.isUpload = [rs boolForColumnIndex:idx++];
        imageSource.thumbnail = [rs stringForColumnIndex:idx++];
        imageSource.middle = [rs stringForColumnIndex:idx++];
        imageSource.original = [rs stringForColumnIndex:idx++];
        imageSource.noRawUrl = [rs stringForColumnIndex:idx++];
        
        [items addObject:imageSource];
    }
    
    KDCompositeImageSource *compositeImageSource = nil;
    if ([items count] > 0) {
        compositeImageSource = [[KDCompositeImageSource alloc] initWithImageSources:items];// autorelease];
    }
    
    return compositeImageSource;
}

- (void)saveCompositeImageSource:(KDCompositeImageSource *)compositeImageSource
                        entityId:(NSString *)entityId
                        database:(FMDatabase *)fmdb {
    if (entityId == nil || compositeImageSource == nil || ![compositeImageSource hasImageSource]) return;
   
    NSString *sql = @"REPLACE INTO images_source(file_id,entity_id,file_name,file_type,is_upload,thumbnail, middle, original, noRawUrl) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDImageSource *item in compositeImageSource.imageSources) {
        idx = 1;
        [stmt bindString:item.fileId atIndex:idx++];
        [stmt bindString:entityId atIndex:idx++];
        [stmt bindString:item.fileName atIndex:idx++];
        [stmt bindString:item.fileType atIndex:idx++];
        [stmt bindBool:item.isUpload atIndex:idx++];
        [stmt bindString:item.thumbnail atIndex:idx++];
        [stmt bindString:item.middle atIndex:idx++];
        [stmt bindString:item.original atIndex:idx++];
        [stmt bindString:item.noRawUrl atIndex:idx++];
        
        // step
        if (![stmt step]) {
            DLog(@"Can not save composite image source with entity id=%@", entityId);
            DLog(@"item.filid = %@",item.fileId);
            DLog(@"item.thumbnail = %@",item.thumbnail);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize
    [stmt close];
}

- (KDCompositeImageSource *)queryCompositeImageSourceWithEntityId:(NSString *)entityId
                                                         database:(FMDatabase *)fmdb {
    if (entityId == nil) return nil;
    
    NSString *sql = @"SELECT file_id, entity_id, file_name,file_type, is_upload, thumbnail, middle, original, noRawUrl FROM images_source WHERE entity_id=?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, entityId];
    KDCompositeImageSource *compositeImageSource = [self _compositeImageSourceWithResultSet:rs];
    [rs close];
    
    return compositeImageSource;
}

- (BOOL)removeCompositeImageSourceWithEntityId:(NSString *)entityId database:(FMDatabase *)fmdb {
    if (entityId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM images_source WHERE entity_id=?;", entityId];
}

- (BOOL)removeCompositeImageSourceInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM images_source;"];
}

@end
