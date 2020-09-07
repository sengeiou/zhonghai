//
//  KDBaseInvitationViewController.h
//  kdweibo
//
//  Created by AlanWong on 14-7-23.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef  NS_ENUM(NSInteger, KDVerificationType) {
    KDVerificationTypeNone = 0, //24小时内免验证
    KDVerificationTypeShould    //需要管理员审核
};
@interface KDBaseInvitationViewController : UIViewController
@property (nonatomic,assign) KDVerificationType type;
@property (nonatomic,strong) MBProgressHUD * hud;
@property (nonatomic,assign) BOOL canShare;


- (void)getUrlFailed;
- (void)showHud:(BOOL)animated;
- (void)hideHud:(BOOL)animated;
- (void)setButtonEnable:(BOOL)isEnable buttonCount:(NSUInteger)count;
- (void)getInvitationURLWithCompleteBlock:(KDServiceActionDidCompleteBlock)completionBlock source:(NSString *)type;

@end
