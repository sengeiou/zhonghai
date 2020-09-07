//
//  KDCache.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-12.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDCacheUtlities.h"

#import "KDCompositeImageSource.h"
typedef void (^KDCacheLoadedImageBlock)(UIImage *);

@interface KDCache : NSObject {
@private 
    NSString *name_;
    NSMutableDictionary *imageCache_;
    
    BOOL disableMemoryCache_;
}

- (id)initWithName:(NSString *)name;

+ (id)sharedCache;
+ (NSString *)cacheKeyForURL:(NSString *)URL;

- (void)removeCachedImageForKey:(id)key;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Avatar methods

- (UIImage *)avatarForCacheKey:(NSString *)cacheKey fromDisk:(BOOL)fromDisk;
- (UIImage *)avatarForURL:(NSString *)URL fromDisk:(BOOL)fromDisk;

// load the avatar from cache or disk as async mode for specificed cache key
- (void)avatarForCacheKey:(NSString *)cacheKey fromDisk:(BOOL)fromDisk completedBlock:(KDCacheLoadedImageBlock)block;

// load the avatar from cache or disk as async mode for specificed url
- (void)avatarForURL:(NSString *)URL fromDisk:(BOOL)fromDisk completedBlock:(KDCacheLoadedImageBlock)block;

- (void)storeAvatarWithImage:(UIImage *)image forCacheKey:(NSString *)cacheKey writeToDisk:(BOOL)writeToDisk;
- (void)storeAvatarWithImage:(UIImage *)image forURL:(NSString *)URL writeToDisk:(BOOL)writeToDisk;
- (void)storeAvatarWithData:(NSData *)data forCacheKey:(NSString *)cacheKey writeToDisk:(BOOL)writeToDisk;
- (void)storeAvatarWithData:(NSData *)data forURL:(NSString *)URL writeToDisk:(BOOL)writeToDisk;

- (BOOL)hasAvatarOnDiskForCacheKey:(NSString *)cacheKey;
- (BOOL)hasAvatarOnDiskForURL:(NSString *)URL;

- (BOOL)moveAvartarWithCacheKey:(NSString *)cacheKey srcPath:(NSString *)srcPath;
- (BOOL)moveAvartarWithURL:(NSString *)URL srcPath:(NSString *)srcPath;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Normal image methods

- (UIImage *)imageForCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType;
- (UIImage *)imageForURL:(NSString *)URL imageType:(KDCacheImageType)imageType;
- (NSData *)imageDataForCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType;
- (NSData *)imageDataForURL:(NSString *)URL imageType:(KDCacheImageType)imageType;
// load the image from cache or disk as async mode for specificed cache key
- (void)imageForCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType
          completedBlock:(KDCacheLoadedImageBlock)block;

// load the image from cache or disk as async mode for specificed url
- (void)imageForURL:(NSString *)URL imageType:(KDCacheImageType)imageType
     completedBlock:(KDCacheLoadedImageBlock)block;

- (void)storeImage:(UIImage *)image forCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType;
- (void)storeImage:(UIImage *)image forURL:(NSString *)URL imageType:(KDCacheImageType)imageType;
- (void)storeImage:(UIImage *)image forURL:(NSString *)URL imageType:(KDCacheImageType)imageType finishedBlock:(void (^)(BOOL))block;

- (void)storeImageData:(NSData *)data forCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType;
- (void)storeImageData:(NSData *)data forURL:(NSString *)URL imageType:(KDCacheImageType)imageType;

- (BOOL)hasImageForCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType;
- (BOOL)hasImageForURL:(NSString *)URL imageType:(KDCacheImageType)imageType;


//- (BOOL)moveImageWithCacheKey:(NSString *)cacheKey srcPath:(NSString *)srcPath imageType:(KDCacheImageType)imageType;
//- (BOOL)linkImageWithCacheKey:(NSString *)cacheKey srcPath:(NSString *)srcPath imageType:(KDCacheImageType)imageType;
//- (BOOL)copyImageWithCacheKey:(NSString *)cacheKey srcPath:(NSString *)srcPath imageType:(KDCacheImageType)imageType;


- (BOOL)moveImageWithURL:(NSString *)URL imageType:(KDCacheImageType)imageType srcPath:(NSString *)srcPath;
- (BOOL)copyImageWithURL:(NSString *)URL imageType:(KDCacheImageType)imageType srcPath:(NSString *)srcPath;
- (BOOL)linkImageWithURL:(NSString *)URL  imageType:(KDCacheImageType)imageType srcPath:(NSString *)srcPath ;

- (void)translateImageSources:(KDCompositeImageSource *)source ToImageSource:(KDCompositeImageSource *)destination;

//将一个网络URL的Image 链接到另一个网络URL
-(BOOL)linkImageFromURL:(NSString *)sourceURL sourceType:(KDCacheImageType)sourceType toURL:(NSString *)toURL type:(KDCacheImageType)type;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)storeVideo:(NSString *)srcPath forFileId:(NSString *)fileId;

#pragma mark -
#pragma mark bundle image methods

- (UIImage *)bundleImageWithName:(NSString *)imageName cache:(BOOL)cache;

// left:[0.0, 1.0]  top:[0.0, 1.0]
- (UIImage *)bundleImageWithName:(NSString *)imageName leftCapAnchor:(float)left topCapAnchor:(float)top cache:(BOOL)cache;

@end
