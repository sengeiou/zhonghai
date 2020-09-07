//
//  KDCompositeImageSource.h
//  kdweibo_common
//
//  Created by laijiandong on 12-9-28.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDObject.h"
#import "KDImageSourceProtocol.h"
#import "KDImageSource.h"

@interface KDCompositeImageSource : KDObject <KDImageDataSource> {
 @private
//    id entity_; // weak reference
    NSArray *imageSources_;
}

@property(nonatomic, assign) id entity; 
@property(nonatomic, retain) NSArray *imageSources;

- (id)initWithImageSources:(NSArray *)imageSources;

- (NSArray *)thumbnailURLs;
- (NSArray *)middleURLs;
- (NSArray *)originalURLs;

- (NSArray *)noRawURLs;

- (NSString *)firstThumbnailURL;
- (NSString *)firstMiddleURL;
- (NSString *)firstOriginalURL;

- (KDImageSource *)firstImageSource;
- (KDImageSource *)lastImageSource;

- (NSString *)fileIds;

- (void)insertImageSource:(KDImageSource *)imageSource atIndex:(NSInteger)index;

@end
