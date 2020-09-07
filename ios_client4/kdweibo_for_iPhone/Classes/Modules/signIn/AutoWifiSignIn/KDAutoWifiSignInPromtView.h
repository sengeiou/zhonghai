//
//  KDAutoWifiSignInPromtView.h
//  kdweibo
//
//  Created by lichao_liu on 1/12/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KDAutoWifiSignInPromtViewType) {
    KDAutoWifiSignInPromtViewType_showlink,
    KDAutoWifiSignInPromtViewType_signInSuccess,
    KDPromtViewAdminSignInSuccess,                   //管理员外勤签到成功
    KDPromtViewCustomSignInSuccess,                 //普通员工外勤签到成功
    KDPromtViewSignInPointSetSuccess,            //签到点设置成功
    KDPromtViewNotificationAdminSuccess,                //成功通知管理员
    KDPromtViewAddOrUpdateSignInPointSource,      //设置签到点成功  由签到点列表页面进入
    KDPromtViewAddWifiLinkFromNone,//从无到有关联wifi
    
};
typedef void (^KDAutoWifiSignInPromtViewBlock)(BOOL isLinkOperation);
@interface KDAutoWifiSignInPromtView : UIView
@property (nonatomic, assign) KDAutoWifiSignInPromtViewType type;
@property(nonatomic,copy)KDAutoWifiSignInPromtViewBlock block;

//- (void)setBlock:(KDAutoWifiSignInPromtViewBlock)block
//            ssid:(NSString *)ssid
//       promtType:(KDAutoWifiSignInPromtViewType)type;
//
//- (void)setBlock:(KDAutoWifiSignInPromtViewBlock)block promtType:(KDAutoWifiSignInPromtViewType)type;
@end
