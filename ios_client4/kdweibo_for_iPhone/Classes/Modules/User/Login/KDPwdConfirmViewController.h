//
//  KDPwdConfirmViewController.h
//  kdweibo
//
//  Created by bird on 14-4-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDInputView.h"

typedef NS_ENUM(NSInteger, KDPwdInputType) {
    KDPwdInputTypeUndefine = 0,
    KDPwdInputTypePwdConfirm,
    KDPwdInputTypePwdSetting
};

typedef NS_ENUM(NSInteger, KDPWDSupportType) {
    KDPWDSupportTypeNormal = 0,
    KDPWDSupportTypeSetting,
};

typedef NS_ENUM(NSInteger, KDPWDNotPhoneType) {
    KDPWDNotPhoneElse = 20410,
    KDPWDNotPhonePhone = 20411,
    KDPWDNotPhoneEmail = 20412
};

@protocol KDLoginPwdConfirmDelegate <NSObject>

- (void)authViewConfirmPwd;
@end

@interface KDPwdConfirmViewController : UIViewController
@property (nonatomic, assign)id<KDLoginPwdConfirmDelegate> delegate;
@property (nonatomic, assign)KDPwdInputType pwdType;
@property (nonatomic, assign)KDPWDNotPhoneType pwdSupportType;
@property (nonatomic, assign) BOOL isRegister;
@property (nonatomic, assign) BOOL hasProtocolRegulation; //是否有用户协议守则
@property (nonatomic, assign) BOOL isHideSMSVerify; //是否关闭短信验证密码
@end
