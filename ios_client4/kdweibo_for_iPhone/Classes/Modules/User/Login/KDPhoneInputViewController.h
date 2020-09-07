//
//  KDPhoneInputViewController.h
//  kdweibo
//
//  Created by bird on 14-4-21.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDPwdConfirmViewController.h"

typedef NS_ENUM(NSInteger, KDPhoneInputType) {
    KDPhoneInputTypeUndefine = 0,
    KDPhoneInputTypeRegister,
    KDPhoneInputTypeFindPwd,
    KDPhoneInputTypeBind,
    KDPhoneInputTypeUpdatePhoneAccount
};

@interface KDPhoneInputViewController : UIViewController

@property (nonatomic, assign) KDPhoneInputType type;
@property (nonatomic, assign) id<KDLoginPwdConfirmDelegate> delegate;
@end
