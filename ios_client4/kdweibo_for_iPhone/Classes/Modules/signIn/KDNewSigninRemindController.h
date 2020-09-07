//
//  KDNewSigninRemindController.h
//  kdweibo
//
//  Created by lichao_liu on 9/8/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSignInRemind.h"
#import "KDSignInRootViewController.h"

typedef  NS_ENUM(NSInteger, KDSignInRemindOperateType) {
    KDSignInRemindOperateType_add,
    KDSignInRemindOperateType_update,
    KDSignInRemindOperateType_delete
};

@interface KDNewSigninRemindController : KDSignInRootViewController

@property (nonatomic, strong) KDSignInRemind *signInRemind;

@end
