//
//  KDCacheUtlities.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-14.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCacheUtlities.h"

#import "KDUtility.h"

NSString * const kKDCacheImageTypeMiddleSuffix = @"_t";
NSString * const kKDCacheImageTypePreviewSuffix = @"_p";
NSString * const kKDCacheImageTypeOriginSuffix = @"_o";
NSString * const kKDCacheImageTypePreviewBlurSuffix = @"_pb";

static NSString * defaultImageStorePath_ = nil;
static NSString * defaultAvatarStorePath_ = nil;
static NSString * defaultVideoStorePath_ = nil;

@implementation KDCacheUtlities

- (id) init {
    self = [super init];
    if(self){
        
    }
    
    return self;
}

+ (NSString *)defaultImageStorePath {
    if(defaultImageStorePath_ == nil){
        defaultImageStorePath_ = [[KDUtility defaultUtility] searchDirectory:KDPicturesPreviewDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];// retain];
    }
    
    return defaultImageStorePath_;
}

+ (NSString *)defaultAvatarStorePath {
    if(defaultAvatarStorePath_ == nil){
        defaultAvatarStorePath_ = [[KDUtility defaultUtility] searchDirectory:KDPicturesAvatarDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];// retain];
    }
    
    return defaultAvatarStorePath_;
}

+ (NSString *)defaultVideoStorePath
{
    if (!defaultVideoStorePath_) {
        defaultVideoStorePath_ = [[KDUtility defaultUtility] searchDirectory:KDVideosDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES] ;//retain];
    }
    return defaultVideoStorePath_;  
}

// Generally speaking, There are must less than 20000 items in one directory on logic file system.
// If the amount of items more than 20000, The commands like "ls" will be slow. So defined up to 5000 may be good enough.
static const NSUInteger kKDMaxNumberOfItemsInOneDirectory = 5000;

+ (NSString *)cachePathSuffixForCacheKey:(NSString *)cacheKey {
    if(cacheKey == nil) return nil;
    
    NSUInteger hash = [cacheKey hash];
    NSUInteger value = hash / kKDMaxNumberOfItemsInOneDirectory;
    NSUInteger firstLevel = (value > kKDMaxNumberOfItemsInOneDirectory) ? (value % kKDMaxNumberOfItemsInOneDirectory) : value;
    NSUInteger secondLevel = hash % kKDMaxNumberOfItemsInOneDirectory;
    
    return [NSString stringWithFormat:@"%lu/%lu", (unsigned long)firstLevel, (unsigned long)secondLevel];
}

+ (BOOL)createParentPathForPathIfNeed:(NSString *)path {
    BOOL succeed = NO;
    
    NSString *parentPath = [path stringByDeletingLastPathComponent];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:parentPath]){
        NSError *error = nil;
        succeed = [fm createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:&error];
        if(!succeed && error != nil){
            DLog(@"Can not create parent path:%@ with error:%@", parentPath, error);
        }
    }
    
    return succeed;
}

+ (NSString *)avatarFullPathForCacheKey:(NSString *)cacheKey {
    NSString *prefix = [KDCacheUtlities defaultAvatarStorePath];
    NSString *suffix = [KDCacheUtlities cachePathSuffixForCacheKey:cacheKey];
    
    NSString *filename = [cacheKey stringByAppendingString:[KDCacheUtlities filenameWithHighResolutionExtension]];
    suffix = [suffix stringByAppendingPathComponent:filename];
    
    NSString *path = [prefix stringByAppendingPathComponent:suffix];
    
    // create parent path before return
    [KDCacheUtlities createParentPathForPathIfNeed:path];
    
    return path;
}

+ (NSString *)imageFullPathForCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType {
    if (!cacheKey) {
        return nil;
    }
    NSString *prefix = [KDCacheUtlities defaultImageStorePath];
    NSString *suffix = [KDCacheUtlities cachePathSuffixForCacheKey:cacheKey];
    
    NSString *filename = cacheKey;
    switch (imageType) {
        case KDCacheImageTypeMiddle:
            filename = [filename stringByAppendingString:kKDCacheImageTypeMiddleSuffix];
            break;
            
        case KDCacheImageTypePreview:
            filename = [filename stringByAppendingString:kKDCacheImageTypePreviewSuffix];
            break;
            
        case KDCacheImageTypePreviewBlur:
            filename = [filename stringByAppendingString:kKDCacheImageTypePreviewBlurSuffix];
            break;
            
        case KDCacheImageTypeOrigin:
            filename = [filename stringByAppendingString:kKDCacheImageTypeOriginSuffix];
            break;
            
        default:
            break;
    }
    
    suffix = [suffix stringByAppendingPathComponent:filename];
    
    // path format: <store path>/[0-5000]/[0-5000]/filename
    NSString *path = [prefix stringByAppendingPathComponent:suffix];
    
    // create parent path before return
    [KDCacheUtlities createParentPathForPathIfNeed:path];
    
    return path;
}

+ (NSString *)videoPathForCacheKey:(NSString *)cacheKey {
    NSString *prefix = [KDCacheUtlities defaultVideoStorePath];
    NSString *suffix = [KDCacheUtlities cachePathSuffixForCacheKey:cacheKey];
    
    NSString *filename = [cacheKey stringByAppendingString:[KDCacheUtlities filenameWithHighResolutionExtension]];
    suffix = [suffix stringByAppendingPathComponent:filename];
    
    NSString *path = [prefix stringByAppendingPathComponent:suffix];
    
    // create parent path before return
    [KDCacheUtlities createParentPathForPathIfNeed:path];
    
    return path;
}

+ (NSString *)filenameWithHighResolutionExtension {
    // Beucase UIImage object use @2x as an high resolution image
    // So, if an UIImage object initialization with @2x in the filename. 
    // Then the image size to RAW(W, H) -> NOW (0.5 * W, 0.5 *H)
    
    static NSString *imageNameExtension = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageNameExtension = (([UIScreen mainScreen].scale + 0.01) > 2.0) ? @"@2x" : @"";
//        [imageNameExtension retain];
    });
    
    return imageNameExtension;
}

+ (void)asyncCalculateFoldersSize:(NSArray *)paths
                   cancelledBlock:(BOOL (^) (void))cancelledBlock
                    finishedBlock:(void (^) (KDUInt64 totalSize, NSUInteger count))finishedBlock {
    
    if (paths != nil && [paths count] > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            KDUInt64 total = 0;
            NSUInteger totalCount = 0;
            
            NSFileManager *fm = [[NSFileManager alloc] init];
            BOOL isDir = NO;
            BOOL exists = NO;
            BOOL cancelled = NO;
            
            for (NSString *path in paths) {
                exists = [fm fileExistsAtPath:path isDirectory:&isDir];
                if (exists) {
                    if (isDir) {
                        // recursive retrieve items in current folder
                        NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:path];
                        while([enumerator nextObject]){
                            totalCount++;
                            // just every 100 items to check does it cancelled 
                            if ((totalCount % 100 == 0) && cancelledBlock != nil) {
                                // stop the enumeration if cancelled
                                if (cancelledBlock()) {
                                    cancelled = YES;
                                    break;
                                }
                            }
                            
                            if(NSFileTypeRegular == [[enumerator fileAttributes] fileType]){
                                total += [[enumerator fileAttributes] fileSize];
                            }
                        }
                        
                    } else {
                        totalCount += 1;
                        
                        NSDictionary *attributes = [fm attributesOfItemAtPath:path error:NULL];
                        total = [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
                    }
                }
                
                // break outer loop
                if (cancelled) {
                    break;
                }
            }
            
//            [fm release];
            
            if (finishedBlock != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    finishedBlock(total, totalCount);
                });
            }
        });
        
    }
}

+ (void)asyncCalculateFolderSize:(NSString *)path
                  cancelledBlock:(BOOL (^) (void))cancelledBlock
                   finishedBlock:(void (^) (KDUInt64 totalSize, NSUInteger count))finishedBlock {
    
    if (path != nil && [path length] > 0) {
        [KDCacheUtlities asyncCalculateFoldersSize:@[path] cancelledBlock:cancelledBlock finishedBlock:finishedBlock];
    }
}

+ (void)asyncRemovePath:(NSString *)path finishedBlock:(void (^) (BOOL success, NSError *error))finishedBlock {
    if (path != nil && [path length] > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSFileManager *fm = [[NSFileManager alloc] init];
            
            NSError *error = nil;
            BOOL success = NO;
            if ([fm fileExistsAtPath:path]) {
                success = [fm removeItemAtPath:path error:&error];
            }
            
//            [fm release];
            
            if (finishedBlock != nil) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    finishedBlock(success, error);
                });
            }
        });
    }
}

- (void)dealloc {
    //[super dealloc];
}

@end
