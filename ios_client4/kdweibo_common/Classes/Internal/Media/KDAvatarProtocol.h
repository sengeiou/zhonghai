//
//  KDAvatarProtocol.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDImageSize;

enum {
    KDAvatarTypeUser = 0x01,
    KDAvatarTypeGroup,
    KDAvatarTypeDMThumbnail,
    KDAvatarTypeDMThread
};

typedef NSUInteger KDAvatarType;

enum DmType {
    KdmTypeInbox = 1,
    KdmTypeThread,
    KdmTypeUnknow,
};
typedef enum DmType DmType;

////////////////////////////////////////////////////

#pragma mark -
#pragma mark single avatar data source

@protocol KDAvatarDataSource <NSObject>
@required

- (KDAvatarType)getAvatarType;
- (KDImageSize *)avatarScaleToSize;

- (NSString *)getAvatarLoadURL;
- (NSString *)getAvatarCacheKey;
- (void)removeAvatarCacheKey;

@end


////////////////////////////////////////////////////

#pragma mark -
#pragma mark composite avatar data source

@protocol KDCompositeAvatarDataSource <KDAvatarDataSource>
@required

- (NSString *)avatarLoadURLAtIndex:(NSUInteger)index;
- (NSString *)avatarCacheKeyAtIndex:(NSUInteger)index;

@end


////////////////////////////////////////////////////

#pragma mark -
#pragma mark single avatar loader

@protocol KDAvatarLoader <NSObject>
@required
- (id<KDAvatarDataSource>)getAvatarDataSource;

- (UIImage *)defaultAvatar;

@optional
- (void)avatarDidFinishLoad:(UIImage *)avatar forURL:(NSString *)URL succeed:(BOOL)succeed;

@end


////////////////////////////////////////////////////

#pragma mark -
#pragma mark composite avatar loader

@protocol KDCompositeAvatarLoader <KDAvatarLoader>
@required

- (id<KDCompositeAvatarDataSource>)compositeAvatarDataSource;

@end

