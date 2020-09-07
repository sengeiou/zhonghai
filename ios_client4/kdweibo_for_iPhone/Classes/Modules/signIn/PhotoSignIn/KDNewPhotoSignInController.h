//
//  KDNewPhotoSignInController.h
//  kdweibo
//
//  Created by lichao_liu on 15/3/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSignInRootViewController.h"

typedef NS_ENUM(NSInteger, KDPhotoSignInType) {
    KDPhotoSignInType_NoSignInPoint,
    KDPhotoSignInType_OfficeWork,
    KDPhotoSignInType_FieldPersonnel
};

typedef void(^BlockChangeSignInType)(KDPhotoSignInType type);

@interface KDNewPhotoSignInController : KDSignInRootViewController

@property (nonatomic, strong) NSString *cacheImagePath;
@property (nonatomic, strong) NSString *assetImageUrl;

@end
