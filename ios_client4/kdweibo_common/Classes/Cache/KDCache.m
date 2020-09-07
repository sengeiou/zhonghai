//
//  KDCache.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-12.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "KDCache.h"

#import "NSString+Additions.h"
#import "UIImage+Additions.h"


static NSString * const kKDDefaultCacheName = @"kdweibo";

@interface KDCache ()

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableDictionary *imageCache;

@end


@implementation KDCache

@synthesize name=name_;
@synthesize imageCache=imageCache_;

- (id)init {
    self = [super init];
    if(self){
        name_ = nil;
        
        disableMemoryCache_ = YES; // disable memory cache
        if(!disableMemoryCache_){
            imageCache_ = [[NSMutableDictionary alloc] init];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return self;
}

- (id)initWithName:(NSString *)name {
    self = [self init];
    if(self){
        name_ = name;//[name retain];
    }
    
    return self;
}

+ (id)sharedCache {
    static KDCache *sharedCache_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache_ = [[KDCache alloc] initWithName:kKDDefaultCacheName];
    });
    
    return sharedCache_;
}

+ (NSString *)cacheKeyForURL:(NSString *)URL {
    return [URL MD5DigestKey];
}

/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (UIImage *)retrieveImageFromDiskWithPath:(NSString *)path {
    if(path == nil) return nil;
    
    UIImage *image = nil;
    
    BOOL isDir = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
        if(!isDir){
            image = [UIImage imageWithContentsOfFile:path];
        }
    }
    
    return image;
}
- (NSData *)retrieveImageDataFromDiskWithPath:(NSString *)path {
    
    if(path == nil) return nil;
    
    NSData *data = nil;
    
    BOOL isDir = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
        if(!isDir){
            data = [NSData dataWithContentsOfFile:path];
        }
    }
    
    return data;
}
// load the image from local file system as async mode
- (void)_asyncLoadImageWithPath:(NSString *)path completedBlock:(KDCacheLoadedImageBlock)block {
    if (path == nil) {
        if (block != nil) {
            block(nil);
            return;
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            if (block != nil) {
                block(image);
            }
        });
    });
}

- (BOOL)existsFilePathOnDisk:(NSString *)path {
    if(path == nil) return NO;
    
    BOOL exists = NO;
    BOOL isDir = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
        if(!isDir){
            exists = YES;
        }
    }
    
    return exists;
}

- (void)_asyncWriteData:(NSData *)data toPath:(NSString *)path finishedBlock:(void (^)(BOOL))block {
    if (data == nil || path == nil) {
        if (block != nil) {
            block(NO);
        }
        
        return;
    }
    
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            BOOL success = [data writeToFile:path atomically:NO];
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                if (block != nil) {
                    block(success);
                }
            });
        });
    
    } else {
        BOOL success = [data writeToFile:path atomically:NO];
        if (block != nil) {
            block(success);
        }
    }
}

//只创建link
- (void)_translatefile:(NSString *)source toPath:(NSString *)destination  {
    if (source == nil || destination == nil||![[NSFileManager defaultManager] fileExistsAtPath:source]) {
          return;
    }
       
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            //[fileManager moveItemAtPath:source toPath:destination error:NULL];
           BOOL success = [fileManager linkItemAtPath:source toPath:destination error:NULL];
            if (!success) {
                DLog(@"create link not success...");
            }
//            [fileManager release];
        });
        
    } else {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager linkItemAtPath:source toPath:destination error:NULL];
//        [fileManager release];
    }
}

- (void)translateImageSources:(KDCompositeImageSource *)source ToImageSource:(KDCompositeImageSource *)destination {
    for (KDImageSource *is1 in source.imageSources) {
        for (KDImageSource *is2 in destination.imageSources) {
            if ([is1.fileId isEqualToString:is2.fileId]) {
                [self _translatefile:[KDCacheUtlities imageFullPathForCacheKey:[KDCache cacheKeyForURL:is1.thumbnail] imageType:KDCacheImageTypeThumbnail] toPath:[KDCacheUtlities imageFullPathForCacheKey:[KDCache cacheKeyForURL:is2.thumbnail] imageType:KDCacheImageTypeThumbnail]];
                [self _translatefile:[KDCacheUtlities imageFullPathForCacheKey:[KDCache cacheKeyForURL:is1.original] imageType:KDCacheImageTypeOrigin] toPath:[KDCacheUtlities imageFullPathForCacheKey:[KDCache cacheKeyForURL:is2.original] imageType:KDCacheImageTypeOrigin]];
                [self _translatefile:[KDCacheUtlities imageFullPathForCacheKey:[KDCache cacheKeyForURL:is1.original] imageType:KDCacheImageTypeThumbnail] toPath:[KDCacheUtlities imageFullPathForCacheKey:[KDCache cacheKeyForURL:is2.middle] imageType:KDCacheImageTypeMiddle]];
            }
        }
    }
    
}
/////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark common methods

- (void)removeCachedImageForKey:(id)key {
    if (key != nil) {
        [imageCache_ removeObjectForKey:key];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Avatar methods

- (UIImage *)avatarForCacheKey:(NSString *)cacheKey fromDisk:(BOOL)fromDisk {
    UIImage *image = nil;
    
    if(!disableMemoryCache_){
        image = [imageCache_ objectForKey:cacheKey];
    }
    
    if(image == nil && fromDisk){
        NSString *path = [KDCacheUtlities avatarFullPathForCacheKey:cacheKey];
        image = [self retrieveImageFromDiskWithPath:path];
        
        if(!disableMemoryCache_ && image != nil){
            [imageCache_ setObject:image forKey:cacheKey];
        }
    }
    
    return image;
}

- (UIImage *)avatarForURL:(NSString *)URL fromDisk:(BOOL)fromDisk {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    return [self avatarForCacheKey:cacheKey fromDisk:fromDisk];
}

- (void)avatarForCacheKey:(NSString *)cacheKey fromDisk:(BOOL)fromDisk completedBlock:(KDCacheLoadedImageBlock)block {
    UIImage *image = nil;
    if(!disableMemoryCache_){
        image = [imageCache_ objectForKey:cacheKey];
    }
    
    BOOL callback = NO;
    if (image != nil) {
        callback = YES;
        
    } else {
        if (fromDisk) {
            NSString *path = [KDCacheUtlities avatarFullPathForCacheKey:cacheKey];
            [self _asyncLoadImageWithPath:path completedBlock:^(UIImage *loadedImage) {
                // save the avatar into memory cache if need
                if(!disableMemoryCache_ && loadedImage != nil){
                    [imageCache_ setObject:loadedImage forKey:cacheKey];
                }
                
                if (block != nil) {
                    block(loadedImage);
                }
            }];
        
        } else {
            callback = YES;
        }
    }
    
    if (callback && block != nil) {
        block(image);
    }
}

- (void)avatarForURL:(NSString *)URL fromDisk:(BOOL)fromDisk completedBlock:(KDCacheLoadedImageBlock)block {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    [self avatarForCacheKey:cacheKey fromDisk:fromDisk completedBlock:block];
}

- (void)storeAvatarWithImage:(UIImage *)image forCacheKey:(NSString *)cacheKey writeToDisk:(BOOL)writeToDisk {
    if (image == nil || cacheKey == nil) return;
    
    if(!disableMemoryCache_){
        // save to memory cache
        [imageCache_ setObject:image forKey:cacheKey];
    }
    
    if (writeToDisk) {
        NSData *data = [image asJPEGDataWithQuality:kKDJPEGThumbnailQuality];
        NSString *path = [KDCacheUtlities avatarFullPathForCacheKey:cacheKey];
        
        [self _asyncWriteData:data toPath:path finishedBlock:nil];
    }
}

- (void)storeAvatarWithImage:(UIImage *)image forURL:(NSString *)URL writeToDisk:(BOOL)writeToDisk {
    [self storeAvatarWithImage:image forCacheKey:[KDCache cacheKeyForURL:URL] writeToDisk:writeToDisk];
}

- (void)storeAvatarWithData:(NSData *)data forCacheKey:(NSString *)cacheKey writeToDisk:(BOOL)writeToDisk {
    if(data == nil || cacheKey == nil) return;
    
    if(!disableMemoryCache_){
        // save to memory cache
        UIImage *image = [UIImage imageWithData:data];
        if(image != nil) {
            [imageCache_ setObject:image forKey:cacheKey];
        }
    }
    
    if (writeToDisk) {
        NSString *path = [KDCacheUtlities avatarFullPathForCacheKey:cacheKey];
        [self _asyncWriteData:data toPath:path finishedBlock:nil];
    }
}

- (void)storeAvatarWithData:(NSData *)data forURL:(NSString *)URL writeToDisk:(BOOL)writeToDisk {
    return [self storeAvatarWithData:data forCacheKey:[KDCache cacheKeyForURL:URL] writeToDisk:writeToDisk];
}

- (BOOL)hasAvatarOnDiskForCacheKey:(NSString *)cacheKey {
    if(cacheKey == nil) return NO;
    
    NSString *path = [KDCacheUtlities avatarFullPathForCacheKey:cacheKey];
    return [self existsFilePathOnDisk:path];
}

- (BOOL)hasAvatarOnDiskForURL:(NSString *)URL {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    return [self hasAvatarOnDiskForCacheKey:cacheKey];
}

- (BOOL)moveAvartarWithCacheKey:(NSString *)cacheKey srcPath:(NSString *)srcPath {
    if(cacheKey == nil) return NO;
    
    BOOL succeed = NO;
    BOOL sourceIsAvailable = [self existsFilePathOnDisk:srcPath];
    if(sourceIsAvailable){
        NSError *error = nil;
        NSString *path = [KDCacheUtlities avatarFullPathForCacheKey:cacheKey];
        succeed = [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:path error:&error];
        
        if(error != nil){
            DLog(@"Can not move avrtar from:%@ to:%@ error:%@", srcPath, path, error);
        }
    }
    
    return succeed;
}

- (BOOL)moveAvartarWithURL:(NSString *)URL srcPath:(NSString *)srcPath {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    return [self moveAvartarWithCacheKey:cacheKey srcPath:srcPath];
}

//////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark load image from disk

- (UIImage *)imageForCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType {
    if(cacheKey == nil) return nil;
    
    NSString *path = [KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:imageType];
    return [self retrieveImageFromDiskWithPath:path];
}

- (UIImage *)imageForURL:(NSString *)URL imageType:(KDCacheImageType)imageType {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    return [self imageForCacheKey:cacheKey imageType:imageType];
}
- (NSData *)imageDataForCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType
{
    if (cacheKey == nil)    return nil;
    
    NSString *path = [KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:imageType];
    
    return [self retrieveImageDataFromDiskWithPath:path];
    
}
- (NSData *)imageDataForURL:(NSString *)URL imageType:(KDCacheImageType)imageType {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    return [self imageDataForCacheKey:cacheKey imageType:imageType];
}
- (void)imageForCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType completedBlock:(KDCacheLoadedImageBlock)block {
    if (cacheKey == nil) {
        if (block != nil) {
            block(nil);
        }
    }
    
    NSString *path = [KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:imageType];
    [self _asyncLoadImageWithPath:path completedBlock:block];
}

- (void)imageForURL:(NSString *)URL imageType:(KDCacheImageType)imageType completedBlock:(KDCacheLoadedImageBlock)block {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    [self imageForCacheKey:cacheKey imageType:imageType completedBlock:block];
}

- (void)storeImage:(UIImage *)image forCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType{
    if(image == nil || cacheKey == nil) return;
    
    NSData *data = [image asJPEGDataWithQuality:kKDJPEGPreviewImageQuality];
    NSString *path = [KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:imageType];
    
    [self _asyncWriteData:data toPath:path finishedBlock:nil];
}
- (void)storeImage:(UIImage *)image forCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType finishedBlock:(void (^)(BOOL))block {
    if(image == nil || cacheKey == nil) return;
    
    NSData *data = [image asJPEGDataWithQuality:kKDJPEGPreviewImageQuality];
    NSString *path = [KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:imageType];
    
    [self _asyncWriteData:data toPath:path finishedBlock:block];
}
- (void)storeImage:(UIImage *)image forURL:(NSString *)URL imageType:(KDCacheImageType)imageType {
    [self storeImage:image forCacheKey:[KDCache cacheKeyForURL:URL] imageType:imageType];
}
- (void)storeImage:(UIImage *)image forURL:(NSString *)URL imageType:(KDCacheImageType)imageType finishedBlock:(void (^)(BOOL))block {
    [self storeImage:image forCacheKey:[KDCache cacheKeyForURL:URL]  imageType:imageType finishedBlock:block];
}
- (void)storeImageData:(NSData *)data forCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType {
    if(data == nil || cacheKey == nil) return;
    
    NSString *path = [KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:imageType];
    [self _asyncWriteData:data toPath:path finishedBlock:nil];
}

- (void)storeImageData:(NSData *)data forURL:(NSString *)URL imageType:(KDCacheImageType)imageType {
    [self storeImageData:data forCacheKey:[KDCache cacheKeyForURL:URL] imageType:imageType];
}

- (void)storeVideo:(NSString *)srcPath forFileId:(NSString *)fileId
{
    NSString *path = [[KDCacheUtlities defaultVideoStorePath] stringByAppendingPathComponent:[fileId stringByAppendingString:@".mp4"]];
    [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:path error:nil];
}

- (BOOL)hasImageForCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType {
    if(cacheKey == nil) return NO;
    
    NSString *path = [KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:imageType];
    return [self existsFilePathOnDisk:path];
}

- (BOOL)hasImageForURL:(NSString *)URL imageType:(KDCacheImageType)imageType {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    return [self hasImageForCacheKey:cacheKey imageType:imageType];
}



- (BOOL)moveImageWithCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType srcPath:(NSString *)srcPath  {
    if(cacheKey == nil) return NO;
    
    BOOL succeed = NO;
    BOOL sourceIsAvailable = [self existsFilePathOnDisk:srcPath];
    if(sourceIsAvailable){
        NSString *path = [KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:imageType];
        succeed = [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:path error:NULL];
    }
    
    return succeed;
}
- (BOOL)copyImageWithCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType srcPath:(NSString *)srcPath  {
    if(cacheKey == nil) return NO;
    
    BOOL succeed = NO;
    BOOL sourceIsAvailable = [self existsFilePathOnDisk:srcPath];
    if(sourceIsAvailable){
        NSString *path = [KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:imageType];

        succeed = [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:path error:NULL];
    }
    
    return succeed;
}

- (BOOL)linkImageWithCacheKey:(NSString *)cacheKey  imageType:(KDCacheImageType)imageType srcPath:(NSString *)srcPath  {
    if(cacheKey == nil) return NO;
    
    BOOL succeed = NO;
    BOOL sourceIsAvailable = [self existsFilePathOnDisk:srcPath];
    if(sourceIsAvailable){
        NSString *path = [KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:imageType];
        succeed = [[NSFileManager defaultManager] linkItemAtPath:srcPath toPath:path error:NULL];
    }
    
    return succeed;
}

- (BOOL)moveImageWithURL:(NSString *)URL imageType:(KDCacheImageType)imageType srcPath:(NSString *)srcPath {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    return [self moveImageWithCacheKey:cacheKey imageType:imageType srcPath:srcPath ];
}

- (BOOL)copyImageWithURL:(NSString *)URL imageType:(KDCacheImageType)imageType srcPath:(NSString *)srcPath  {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    return [self copyImageWithCacheKey:cacheKey imageType:imageType srcPath:srcPath ];
}

- (BOOL)linkImageWithURL:(NSString *)URL  imageType:(KDCacheImageType)imageType srcPath:(NSString *)srcPath  {
    NSString *cacheKey = [KDCache cacheKeyForURL:URL];
    return [self linkImageWithCacheKey:cacheKey imageType:imageType srcPath:srcPath];
}

//
-(BOOL)linkImageFromURL:(NSString *)sourceURL sourceType:(KDCacheImageType)sourceType toURL:(NSString *)toURL type:(KDCacheImageType)type {
    NSString *sourceKey = [KDCache cacheKeyForURL:sourceURL];
    if (!sourceKey) {
        return NO;
    }
    NSString *toKey = [KDCache cacheKeyForURL:toURL];
    if (!toKey) {
        return NO;
    }
    NSString *sourcePath = [KDCacheUtlities imageFullPathForCacheKey:sourceKey imageType:sourceType];
    if (![self existsFilePathOnDisk:sourcePath]) {
        return NO;
    }
    
    NSString *toPath = [KDCacheUtlities imageFullPathForCacheKey:toKey imageType:type];
    return [[NSFileManager defaultManager] linkItemAtPath:sourcePath toPath:toPath error:NULL];
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark images from resource bundle

- (UIImage *)bundleImageWithName:(NSString *)imageName cache:(BOOL)cache {
    UIImage *image = [imageCache_ objectForKey:imageName];
    if (image == nil) {
        image = [UIImage imageNamed:imageName];
        if (image != nil && !disableMemoryCache_ && cache) {
            [imageCache_ setObject:image forKey:imageName];
        }
    }
    
    return image;
}

- (UIImage *)bundleImageWithName:(NSString *)imageName leftCapAnchor:(float)left topCapAnchor:(float)top cache:(BOOL)cache {
    UIImage *image = [imageCache_ objectForKey:imageName];
    if (image == nil) {
        image = [UIImage imageNamed:imageName];
        image = [image stretchableImageWithLeftCapWidth:image.size.width*left topCapHeight:image.size.height*top];
        
        if (image != nil && !disableMemoryCache_ && cache) {
            [imageCache_ setObject:image forKey:imageName];
        }
    }
    
    return image;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Application did receive memory warning

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    [imageCache_ removeAllObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    //KD_RELEASE_SAFELY(name_);
    //KD_RELEASE_SAFELY(imageCache_);
    
    //[super dealloc];
}

@end
