//
//  KDGestureViewController.h
//  DynamicCode
//
//  Created by 曾昭英 on 13-11-28.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PPLockView.h"
#import "KDLockControl.h"
#import "GestureDescView.h"
#define kAllowFailCount 5

#define kNotificationName_lockShowup @"lockShowup"

typedef enum
{
    LockType_setting,   //设置
    LockType_confirm,   //确认设置
}LockType;

@interface KDGestureSettingViewController : UIViewController <PPLockViewDelegate> {
    PPLockView *_lockView;
}

@property (nonatomic) LockType lockType;
@property (nonatomic) BOOL isReset; // 是否是从新设置密码

@property (nonatomic,strong) UIView *lockViewContainer;
@property (nonatomic,strong) GestureDescView *descV;
@property (nonatomic,strong) UILabel *promptL;

@property (nonatomic,assign) BOOL isHideBackBtn;

@end
