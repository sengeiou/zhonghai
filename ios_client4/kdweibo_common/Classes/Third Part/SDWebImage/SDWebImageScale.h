//
//  SDWebImageScale.h
//  kdweibo_common
//
//  Created by bird on 14-5-12.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SDWebImageScaleOptions)
{
    SDWebImageScaleNone             = 0,
    SDWebImageScaleAvatar,
    SDWebImageScaleThumbnail,
    SDWebImageScaleMiddle,
    SDWebImageScalePreView
};

@interface SDWebImageScale : NSObject

+ (CGSize)sizeForScaleOption:(SDWebImageScaleOptions)option;
@end
