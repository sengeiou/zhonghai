//
//  KDPhoneBindingDisplayViewController.h
//  kdweibo
//
//  Created by DarrenZheng on 14-6-26.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

/*
  服务于【修改手机号】功能，点击手机号进入的第一个页面
*/

#import <UIKit/UIKit.h>
#import "KDPwdConfirmViewController.h"

@interface KDPhoneBindingDisplayViewController : UIViewController

@property (nonatomic, assign) id<KDLoginPwdConfirmDelegate> delegate;

@end
