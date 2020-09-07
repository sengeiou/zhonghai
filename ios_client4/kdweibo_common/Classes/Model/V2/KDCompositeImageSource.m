//
//  KDCompositeImageSource.m
//  kdweibo_common
//
//  Created by laijiandong on 12-9-28.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDCompositeImageSource.h"
#import "KDCache.h"

@implementation KDCompositeImageSource

@synthesize entity=entity_;
@synthesize imageSources=imageSources_;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (id)initWithImageSources:(NSArray *)imageSources {
    self = [super init];
    if (self) {
        imageSources_ = imageSources;// retain];
    }
    
    return self;
}

// 1 - thumbnail, 2 - middle, 3 - original, 
- (NSArray *)_imageSourceURLsWithType:(NSUInteger)type {
    NSMutableArray *items = nil;
    if ([self hasImageSource]) {
        items = [NSMutableArray array];
        
        NSString *url = nil;
        for (KDImageSource *item in imageSources_) {
            url = nil;
            
            if (0x01 == type) {
                url = item.thumbnail;
            
            } else if(0x02 == type) {
                url = item.middle;
                
            } else if(0x03 == type){
                url = item.original;
            }
            
            if (url != nil) {
                [items addObject:url];
            }
        }
    }
    
    return items;
}

- (NSArray *)thumbnailURLs {
    return [self _imageSourceURLsWithType:0x01];
}

- (NSArray *)middleURLs {
    return [self _imageSourceURLsWithType:0x02];
}

- (NSArray *)originalURLs {
    return [self _imageSourceURLsWithType:0x03];
}

- (NSString *)firstThumbnailURL {
    return ([self hasImageSource]) ? [self firstImageSource].thumbnail : nil;
}

- (NSString *)firstMiddleURL {
    return ([self hasImageSource]) ? [self firstImageSource].middle : nil;
}

- (NSString *)firstOriginalURL {
    return ([self hasImageSource]) ? [self firstImageSource].original : nil;
}

- (KDImageSource *)firstImageSource {
    KDImageSource *temp = nil;
    if ([self hasImageSource]) {
        temp = [imageSources_ objectAtIndex:0x00];
    }
    
    return temp;
}

- (KDImageSource *)lastImageSource {
    KDImageSource *temp = nil;
    if ([self hasImageSource]) {
        temp = [imageSources_ lastObject];
    }
    
    return temp;
}

- (void)insertImageSource:(KDImageSource *)imageSource atIndex:(NSInteger)index {
    NSMutableArray *array = nil;
    if (self.imageSources) {
        array = [NSMutableArray arrayWithArray:self.imageSources];
    }else {
        array = [NSMutableArray array];
    }
    [array insertObject:imageSource atIndex:0];
    self.imageSources = array;
}
/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDImageDataSource methods

- (BOOL)hasImageSource {
    return (imageSources_ != nil && [imageSources_ count] > 0);
}

- (BOOL)hasManyImageSource {
    return (imageSources_ != nil && [imageSources_ count] > 0x01);
}
- (BOOL)isTimeLineDataSource
{
    return YES;
}
- (KDImageSource *)getTimeLineImageSourceAtIndex:(NSInteger)index
{
    if ([self isTimeLineDataSource]) {
        if (index < [imageSources_ count]) {
            KDImageSource *source = [imageSources_ objectAtIndex:index];
            return source;
        }
    }
    return nil;
}
- (NSString *)thumbnailImageURL {
    KDImageSource *temp = [self firstImageSource];
    return (temp != nil) ? temp.thumbnail : nil;
}

- (NSArray *)thumbnailImageURLs {
    NSMutableArray *items = nil;
    if ([self hasImageSource]) {
        items = [NSMutableArray arrayWithCapacity:[imageSources_ count]];
        for (KDImageSource *imageSource in imageSources_) {
            if (imageSource.thumbnail != nil) {
                [items addObject:imageSource.thumbnail];
            }
        }
    }
    
    return items;
}

- (NSString *)middleImageURL {
    KDImageSource *temp = [self firstImageSource];
    return (temp != nil) ? temp.middle : nil;
}

- (NSArray *)middleImageURLs {
    NSMutableArray *items = nil;
    if ([self hasImageSource]) {
        items = [NSMutableArray arrayWithCapacity:[imageSources_ count]];
        for (KDImageSource *imageSource in imageSources_) {
            if (imageSource.middle != nil) {
                [items addObject:imageSource.middle];
            }
        }
    }
    
    return items;
}

- (NSString *)bigImageURL {
    KDImageSource *temp = [self firstImageSource];
    return (temp != nil) ? temp.original : nil;
}

- (NSArray *)bigImageURLs {
    NSMutableArray *items = nil;
    if ([self hasImageSource]) {
        items = [NSMutableArray arrayWithCapacity:[imageSources_ count]];
        for (KDImageSource *imageSource in imageSources_) {
            if (imageSource.original != nil) {
                [items addObject:imageSource.original];
            }
        }
    }
    
    return items;
}
- (NSArray *)noRawURLs
{
    NSMutableArray *items = nil;
    if ([self hasImageSource]) {
        items = [NSMutableArray arrayWithCapacity:[imageSources_ count]];
        for (KDImageSource *imageSource in imageSources_) {
            if (imageSource.noRawUrl != nil) {
                [items addObject:imageSource.noRawUrl];
            }
        }
    }
    
    return items;
}

- (NSString *)cacheKeyForImageSourceURL:(NSString *)imageSourceURL {
    if(imageSourceURL == nil) return nil;
    
    NSString *cacheKey = [super propertyForKey:imageSourceURL];
    if(cacheKey == nil){
        cacheKey = [KDCache cacheKeyForURL:imageSourceURL];
        if(cacheKey != nil){
            [super setProperty:cacheKey forKey:imageSourceURL];
        }
    }
    
    return cacheKey;
}

- (NSString *)fileIds {
    NSString *fileIds = nil;
    NSMutableArray *fileIdArray = [NSMutableArray array];
    for (KDImageSource *source in self.imageSources) {
        [fileIdArray addObject:source.fileId];
    }
    if ([fileIdArray count] >0) {
        fileIds = [fileIdArray componentsJoinedByString:@","];

    }
    return fileIds;
}

- (void)dealloc {
    entity_ = nil;
    //KD_RELEASE_SAFELY(imageSources_);
    
    //[super dealloc];
}

@end
