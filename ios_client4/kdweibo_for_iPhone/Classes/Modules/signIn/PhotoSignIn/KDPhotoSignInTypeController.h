//
//  KDPhotoSignInTypeController.h
//  kdweibo
//
//  Created by lichao_liu on 15/3/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDNewPhotoSignInController.h"
@interface KDPhotoSignInTypeController : UIViewController
@property (nonatomic, assign) KDPhotoSignInType signInType;
@property (nonatomic, copy) BlockChangeSignInType changeSignInTypeBlock;
@end
