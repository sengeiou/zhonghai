//
//  KDCacheUtlities.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-14.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDCommon.h"

typedef enum:NSUInteger {
    KDCacheImageTypeNormal = 0x00,
    
    KDCacheImageTypeThumbnail,
    KDCacheImageTypeMiddle,
    KDCacheImageTypePreview,
    KDCacheImageTypeOrigin,
    KDCacheImageTypePreviewBlur,
    
    KDCacheImageTypeAvatar,
    KDCacheImageTypeVideo
}KDCacheImageType;


extern NSString * const kKDCacheImageTypeMiddleSuffix;
extern NSString * const kKDCacheImageTypePreviewSuffix;
extern NSString * const kKDCacheImageTypePreviewBlurSuffix;


@interface KDCacheUtlities : NSObject {
@private
    
}

+ (NSString *)defaultImageStorePath;
+ (NSString *)defaultAvatarStorePath;
+ (NSString *)defaultVideoStorePath;

+ (NSString *)cachePathSuffixForCacheKey:(NSString *)cacheKey;

+ (NSString *)avatarFullPathForCacheKey:(NSString *)cacheKey;
+ (NSString *)imageFullPathForCacheKey:(NSString *)cacheKey imageType:(KDCacheImageType)imageType;
+ (NSString *)videoPathForCacheKey:(NSString *)cacheKey;

+ (NSString *)filenameWithHighResolutionExtension;


// calculate the size of specified folder[s](recursive) in asynchronous mode,
// and the cancelled block use to control workflow, The enumeration will break if return YES.
// and the finished block call on main queue to report results at final

+ (void)asyncCalculateFoldersSize:(NSArray *)paths
                   cancelledBlock:(BOOL (^) (void))cancelledBlock
                    finishedBlock:(void (^) (KDUInt64 totalSize, NSUInteger count))finishedBlock;

+ (void)asyncCalculateFolderSize:(NSString *)path
                  cancelledBlock:(BOOL (^) (void))cancelledBlock
                   finishedBlock:(void (^) (KDUInt64 totalSize, NSUInteger count))finishedBlock;

// remove the specificed path as asynchronous, and the finished block call on main queue
+ (void)asyncRemovePath:(NSString *)path
          finishedBlock:(void (^) (BOOL success, NSError *error))finishedBlock;

@end
