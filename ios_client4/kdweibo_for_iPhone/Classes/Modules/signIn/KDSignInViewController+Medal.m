//
//  KDSignInViewController+Medal.m
//  kdweibo
//
//  Created by shifking on 16/3/26.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController+Medal.h"
#import "KDSigninMedalModel.h"
#import "KDCommonHintView.h"
#import <objc/runtime.h>
#import "KDWebViewController.h"
#import "KDImageSourceConfig.h"
#import "SDWebImageManager.h"
@interface KDSignInViewController()
@property (strong , nonatomic) KDCommonHintView *medalHintView;
@property (strong , nonatomic) KDSigninMedalModel *signinMedal;
@end


@implementation KDSignInViewController (Medal)

- (BOOL)showMedalListAlertWithModel:(KDSigninMedalModel *)medalModel {
    BOOL result = NO;
    self.signinMedal = medalModel;
    if (medalModel == nil || [medalModel isKindOfClass:NSNull.class] || medalModel.alertEnable == NO) {
        return result;
    }
    
    //设置弹窗左右button
    NSString *leftButton = ASLocalizedString(@"知道啦");
    NSString *rightButton = ASLocalizedString(@"去看看");
    if (medalModel.leftBtnText && ![medalModel.leftBtnText isKindOfClass:[NSNull class]] && medalModel.leftBtnText.length > 0) {
        leftButton = medalModel.leftBtnText;
    }
    if (medalModel.rightBtnText && ![medalModel.rightBtnText isKindOfClass:[NSNull class]] && medalModel.rightBtnText.length > 0) {
        rightButton = medalModel.rightBtnText;
    }
    
    //初始化弹窗
    if (medalModel.alertType == 1) {
        //积分弹窗
        result = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:medalModel.title message:medalModel.content delegate:self cancelButtonTitle:leftButton otherButtonTitles:rightButton, nil];
        alert.tag = KDSigninMedalAlertTag;
        [alert show];
    }
    else if (medalModel.alertType == 2) {
        //勋章弹窗
        result = YES;
        __weak KDSignInViewController *weak_self = self;
        self.medalHintView = [[KDCommonHintView alloc] init];
        self.medalHintView.showCloseButton = YES;
        [self.medalHintView setupTitle:medalModel.title image:nil contentText:medalModel.content];
        [self.medalHintView setLeftButtonString:leftButton];
        [self.medalHintView setRightButtonString:rightButton];
        
        self.medalHintView.buttonClickBlock = ^(NSInteger index , NSString *title) {
            [weak_self clickAlertButtonWithIndex:index];
        };
        [self.medalHintView show];
        if (medalModel.picUrl && medalModel.picUrl.length > 0) {
            [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:medalModel.picUrl] options:SDWebImageRetryFailed | SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
                [self.medalHintView setHeaderImage:image];
            }];
        }
    }
    
    if (result == YES) {
//        [KDEventAnalysis event:event_signin_medal_showtimes];
    }
    
    return result;
}

- (void)clickAlertButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        //左边按钮
//        [KDEventAnalysis event:event_signin_medal_clickleftbutton];
    }
    else if (index == 1){
        //右边按钮,跳转webview
//        [KDEventAnalysis event:event_signin_medal_clickrightbutton];
        NSString *appId = self.signinMedal.appId;
        NSString *sourcePath = self.signinMedal.detailAddress;
        KDWebViewController *webVC ;
        if (!appId || appId.length <= 0) {
            if (sourcePath && ![sourcePath isKindOfClass:NSNull.class] && sourcePath.length > 0) {
                sourcePath = [sourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                webVC = [[KDWebViewController alloc] initWithUrlString:sourcePath];
            }
        }
        else {
            webVC = [[KDWebViewController alloc] initWithUrlString:sourcePath appId:appId];
        }
        
        if (webVC) {
            webVC.hidesBottomBarWhenPushed = YES;
            webVC.isBlueNav = YES;
            if (appId.length > 0) {
                __weak KDSignInViewController *weak_self = self;
                __weak KDWebViewController *weak_web = webVC;
                webVC.getLightAppBlock = ^() {
                        [weak_self.navigationController pushViewController:weak_web animated:YES];
                };
            }
        }
    }
}



#pragma mark - setter & getter
- (void)setMedalHintView:(KDCommonHintView *)medalHintView {
    objc_setAssociatedObject(self, @selector(medalHintView), medalHintView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KDCommonHintView *)medalHintView {
    return objc_getAssociatedObject(self, @selector(medalHintView));
}

- (void)setSigninMedal:(KDSigninMedalModel *)signinMedal {
    objc_setAssociatedObject(self, @selector(signinMedal), signinMedal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KDSigninMedalModel *)signinMedal {
    return objc_getAssociatedObject(self, @selector(signinMedal));
}
@end
