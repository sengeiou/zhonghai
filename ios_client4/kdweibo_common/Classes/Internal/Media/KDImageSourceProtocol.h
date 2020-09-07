//
//  KDImageSourceProtocol.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-24.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDImageSize.h"

@class KDRequestProgressMonitor;
@class KDImageSource;

// This protocol use to load the normal image

@protocol KDImageDataSource <NSObject>
@required

- (BOOL)hasImageSource;
- (BOOL)hasManyImageSource;
- (BOOL)isTimeLineDataSource;
- (KDImageSource *)getTimeLineImageSourceAtIndex:(NSInteger)index;

- (NSString *)thumbnailImageURL;
- (NSArray *)thumbnailImageURLs;

- (NSString *)middleImageURL;
- (NSArray *)middleImageURLs;

- (NSString *)bigImageURL;
- (NSArray *)bigImageURLs;

- (NSString *)cacheKeyForImageSourceURL:(NSString *)imageSourceURL;

- (NSArray *)noRawURLs;
@end



@protocol KDImageSourceLoader <NSObject>

@required
- (id<KDImageDataSource>) getImageDataSource;
- (UIImage *) defaultPlaceholderImage;
- (KDImageSize *) optimalImageSize;

@optional
- (void) imageSourceLoaderDidFinishLoad:(UIImage *)image cacheKey:(NSString *)cacheKey succeed:(BOOL)succeed;
- (void) imageSourceLoaderWithCacheKey:(NSString *)cacheKey progressMonitor:(KDRequestProgressMonitor *)progressMonitor;

- (void) imageDataSourceLoaderDidFinishLoad:(NSData *)data cacheKey:(NSString *)cacheKey succeed:(BOOL)succeed;
- (void) imageDataSourceLoaderWithCacheKey:(NSString *)cacheKey progressMonitor:(KDRequestProgressMonitor *)progressMonitor;

@end
