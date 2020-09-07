//
//  KDImageSize.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDImageSize : NSObject {
 @private
    CGSize size_;
}

@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;

- (id)initWithSize:(CGSize)size;
- (id)initWithWidth:(CGFloat)width height:(CGFloat)height;
+ (KDImageSize *)imageSize:(CGSize)size;
+ (KDImageSize *)imageSizeWithWidth:(CGFloat)width height:(CGFloat)height;

+ (KDImageSize *)defaultUserAvatarSize;
+ (KDImageSize *)defaultUserProfileImageSize;
+ (KDImageSize *)defaultGroupAvatarSize;
+ (KDImageSize *)defaultPreviewImageSize;
+ (KDImageSize *)defaultOriginViewImageSize;
+ (KDImageSize *)defaultMiddleImageSize;
+ (KDImageSize *)defaultThumbnailImageSize;
+ (KDImageSize *)defaultDMThreadAvatarSize;
+ (KDImageSize *)defaultMapRenderImageSize;
+ (KDImageSize *)defaultGifImageSize;
+ (KDImageSize *)defaultCommunityImageSize;
@end
