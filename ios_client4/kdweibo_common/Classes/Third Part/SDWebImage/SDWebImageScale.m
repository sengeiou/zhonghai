//
//  SDWebImageScale.m
//  kdweibo_common
//
//  Created by bird on 14-5-12.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "SDWebImageScale.h"

@implementation SDWebImageScale
+ (CGSize)sizeForScaleOption:(SDWebImageScaleOptions)option
{
    CGSize size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    switch (option) {
        case SDWebImageScaleAvatar:
            size = [self isHighResolutionDevice]?CGSizeMake(34.f*2, 34.f*2):CGSizeMake(34.f, 34.f);
            break;
        case SDWebImageScaleThumbnail:
            size = [self isHighResolutionDevice]?CGSizeMake(200.f, 200.f):CGSizeMake(100.f, 100.f);
            break;
        case SDWebImageScaleMiddle:
            size = [self isHighResolutionDevice]?CGSizeMake(480.0, 360.0):CGSizeMake(240.f, 180.f);
            break;
        case SDWebImageScalePreView:
            size = [self isHighResolutionDevice]?CGSizeMake([UIScreen mainScreen].bounds.size.width*2, [UIScreen mainScreen].bounds.size.height*2):
            CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        default:
            break;
    }
    return size;
}

+ (BOOL)isHighResolutionDevice {
	return ([UIScreen mainScreen].scale + 0.01) > 2.0;
}
@end
