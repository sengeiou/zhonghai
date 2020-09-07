//
//  SDWebImageManager+MJ.m
//  FingerNews
//
//  Created by mj on 13-9-23.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "SDWebImageManager+MJ.h"

@implementation SDWebImageManager (MJ)
+ (void)downloadWithURL:(NSURL *)url
{
    // cmp不能为空
    [[self sharedManager] downloadWithURL:url options:SDWebImageLowPriority|SDWebImageRetryFailed imageScale:SDWebImageScalePreView progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
        
    }];
}
+ (void)downloadWithURL:(NSURL *)url withImageScale:(SDWebImageScaleOptions)option
{
    // cmp不能为空
    [[self sharedManager] downloadWithURL:url options:SDWebImageLowPriority|SDWebImageRetryFailed imageScale:option progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
        
    }];
}
@end
