//
//  KDCodeConfirmViewController.h
//  kdweibo
//
//  Created by bird on 14-4-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDPwdConfirmViewController.h"

@interface KDCodeConfirmViewController : UIViewController

@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, assign) BOOL shouldResetTimer;
@property (nonatomic, assign) id<KDLoginPwdConfirmDelegate> delegate;
@property (nonatomic, assign) int fromType;  //0:注册，找回      1:绑定 2:更新号码   3 手机验证  4 邮箱验证A.wang
@property (nonatomic, assign) BOOL isRegister;
@property (nonatomic, assign) BOOL isSendAllCode;  //是否邮箱手机号都发送验证码
@end
