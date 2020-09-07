//
//  KDImageLoaderAdapter.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDAvatarProtocol.h"
#import "KDImageSourceProtocol.h"
#import "KDRequestDispatcher.h"
#import "KDRequestWrapper.h"
#import "KDCache.h"



typedef enum:NSUInteger {
    KDLoadImageTypeDefault = 0x00,
    KDLoadImageTypeGif
}KDLoadImageType;

typedef void (^KDImageLoaderCompletedBlock) (UIImage *);

@interface KDImageLoaderAdapter : NSObject <KDRequestWrapperDelegate> {
@private
    NSMutableDictionary *avatarLoaders_;
    NSMutableDictionary *imagesLoaders_;
}

- (UIImage *)avatarWithLoader:(id<KDAvatarLoader>)loader fromNetwork:(BOOL)fromNetwork;

// load the avatar as async mode
- (void)asyncLoadAvatarWithLoader:(id<KDAvatarLoader>)avatarLoader fromNetwork:(BOOL)fromNetwork
                   completedBlock:(KDImageLoaderCompletedBlock)block;

- (UIImage *)avatarWithCompositeLoader:(id<KDCompositeAvatarLoader>)loader atIndex:(NSUInteger)atIndex
                           fromNetwork:(BOOL)fromNetwork;

// load the avatar for composite loaders as async mode
- (void)asyncLoadAvatarWithCompositeLoader:(id<KDCompositeAvatarLoader>)loader atIndex:(NSUInteger)atIndex
                               fromNetwork:(BOOL)fromNetwork completedBlock:(KDImageLoaderCompletedBlock)block;


- (void)removeAvatarLoader:(id<KDAvatarLoader>)avatarLoader;
- (void)clearAllAvatarLoaders;

- (UIImage *)imageWithLoader:(id<KDImageSourceLoader>)imageSourceLoader forURL:(NSString *)URL
                   cacheType:(KDCacheImageType)cacheType fromNetwork:(BOOL)fromNetwork;

- (NSData *)imageDataWithLoader:(id<KDImageSourceLoader>)imageSourceLoader forURL:(NSString *)URL
                   cacheType:(KDCacheImageType)cacheType
                 fromNetwork:(BOOL)fromNetwork;


- (void)asyncLoadImageWithLoader:(id<KDImageSourceLoader>)imageSourceLoader forURL:(NSString *)URL
                       cacheType:(KDCacheImageType)cacheType
                       imageType:(KDLoadImageType)imageType
                     fromNetwork:(BOOL)fromNetwork
                  completedBlock:(KDImageLoaderCompletedBlock)block;

- (void)asyncLoadImageWithLoader:(id<KDImageSourceLoader>)imageSourceLoader forURL:(NSString *)URL
                       cacheType:(KDCacheImageType)cacheType fromNetwork:(BOOL)fromNetwork
                  completedBlock:(KDImageLoaderCompletedBlock)block;

- (void)removeImageSourceLoader:(id<KDImageSourceLoader>)loader cancelRequest:(BOOL)cancel;
- (void)clearAllImageSourceLoaders;
- (void)cancelRequestForLoader:(id<KDImageSourceLoader>)loader url:(NSString *)url;
- (BOOL)imageSourceDownLoadFinishedForLoader:(id<KDImageSourceLoader>)loader url:(NSString *)url;
@end
