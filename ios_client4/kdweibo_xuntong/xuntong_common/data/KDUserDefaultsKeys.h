//
//  KDUserDefaultsKeys.h
//  kdweibo
//
//  Created by DarrenZheng on 15/1/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#ifndef kdweibo_KDUserDefaultsKeys_h
#define kdweibo_KDUserDefaultsKeys_h

// 标记H5引导只出现一次flag 金蝶圈
static const NSString* kMarkH5GuideOnceFlagKingdee = @"kMarkH5GuideOnceFlagKingdee";
// 标记H5引导只出现一次flag 非金蝶
static const NSString* kMarkH5GuideOnceFlag = @"kMarkH5GuideOnceFlag";

// Timeline广告栏数据 (KDModalTimelineAdvert)
#define kModalTimelineAdvert @"kModalTimelineAdvert"

// Timeline可信设备横幅
#define kTimelineTrustDeviceBanner @"kTimelineTrustDeviceBanner"

// 系统相册最近一张照片，用来判断是否有照片更新
#define kMostRecentPhoto @"kMostRecentPhoto"

// 聊天加号面板加号上的红点
#define kChatPlusMenuRedFlag @"kChatPlusMenuRedFlag"

// 无痕蒙层
#define kChatNotraceMask @"kChatNotraceMask"

//订阅消息是否全量获取过的标识
#define kAllPubicAcccountsFetch @"kAllPubicAcccountsFetch"

// 通讯录广告
#define kContactAdFlag @"kContactAdFlag"

//我界面红点
#define kMeViewTabbarClick @"kMeViewTabbarClick"

//个人设置页面生日AlterTipView
#define kPersonalSettingBirthdayTipView @"kPersonalSettingBirthdayTipView"

//个人界面 ,个人设置红点引导
#define kPersonalSettingGuideClick @"kPersonalSettingGuideClick"

//消息撤回提示标志
#define kChatWithdrawFlag @"kChatWithdrawFlag"

//管理员指南界面红点
#define kAdminGuideClick @"kAdminGuideClick"

//新手指南界面红点
#define kNewUserGuideClick @"kNewUserGuideClick"

//个人详情界面 管理红点
#define kPersonalManageGuideClick @"kPersonalManageGuideClick"

//工作汇报
#define KWorkGroupFlag @"KWorkGroupFlag"

//聊天加号面板多人会话new 图标 审批
#define KChatPlusMenuNewFlagapproval @"KChatPlusMenuNewFlagapproval"

// 截图上传要求每天提示一次，该标志记录最后显示的日期
#define kScreenshotLastViewDate @"kScreenshotLastViewDate"

// mark timeline入口的呼吸灯
#define kMarkTimelineGuide @"kMarkTimelineGuide"

// mark 代办入口的呼吸灯
#define kMarkTodoGuide @"kMarkTodoGuide"

// mark 标记过，比如双击过，或者进入标记列表有新数据
static NSString * kMarkUsed = @"kMarkUsed";
// ----------------【蒙层】----------------
// 应用蒙层
#define kApplicationMaskView @"kApplicationMaskView"

//人数少于7人时，提示用户邀请同事的蒙层
#define kInviteMaskView @"kInviteMaskView"

//已经点击了添加同事的广告
#define kAddColleagueView @"kAddColleagueView"


//-----------------【应用】---------------

//应用列表是否已经获取
#define kAppListDidRequest @"kAppListDidRequest"

//-----------------【聊天室】---------------

//是否提示用户外部群组发文件提示
#define KDShouldShowExtenalFileAlertView [NSString stringWithFormat:@"%@_ShouldShowExtenalFileAlertView",[BOSConfig sharedConfig].user.openId]

//是否用户第一次进入聊天界面
#define kDUserFirstTimeIntoChatRoom [NSString stringWithFormat:@"%@_userFirstTimeIntoChatRoom",[BOSConfig sharedConfig].user.openId]

//用户是否刚刚切换到该圈
#define kUserJustChangeToNetwork [NSString stringWithFormat:@"%@_userJustChangeToNetwork",[BOSConfig sharedConfig].user.eid]
//标注是否清除了多余的签到提醒本地通知
#define kIsCleanRedundantSignInReminNotification @"kIsCleanRedundantSignInReminNotification"

////-----------------【组织架构】---------------
#define kShouldShowAlterDepartmentTipsView [NSString stringWithFormat:@"%@_%@_ShouldShowAlterDepartmentTipsView",[BOSConfig sharedConfig].user.eid, [BOSConfig sharedConfig].user.openId]

#define kShouldShowMeViewTipsView [NSString stringWithFormat:@"%@_%@_kShouldShowMeViewTipsView",[BOSConfig sharedConfig].user.eid, [BOSConfig sharedConfig].user.openId]

// 我的
#define kShouldShowMeViewMyTeamRedDot @"kShouldShowMeViewMyTeamRedDot"

#define kCompanyOpenedAppShouldSlideToTop @"kCompanyOpenedAppShouldSlideToTop"
#define kOrgCreateTipView @"kOrgCreateTipView" // 创建组织架构的tip view控制（按圈）
#define kDepartmentSettingTipView  @"kDepartmentSettingTipView" // 部门设置 的tip view控制（按圈）
#define kNotFirstLoadShowAddPerson @"kNotFirstLoadShowAddPerson" // 部门下面的添加成员
#define kSettingBossOrManagerTipView @"kSettingBossOrManagerTipView" // 设置老板或者最高负责人
#define kNotFirstLoadShowAdmin  @"kNotFirstLoadShowAdmin" //组织架构 -> 设置 ->
#define kModifyDepartmentTipView @"kModifyDepartmentTipView" //修改部门

#define kCompanysShouldShowChangeNameTips [NSString stringWithFormat:@"%@_%@_kCompanysShouldShowChangeNameTips",[BOSConfig sharedConfig].user.eid, [BOSConfig sharedConfig].user.openId]

// 企业已开通应用tips
#define kShouldShowOpenedAppTipsView [NSString stringWithFormat:@"%@_%@_kShouldShowOpenedAppTipsView",[BOSConfig sharedConfig].user.eid, [BOSConfig sharedConfig].user.openId]

// 推荐用用tips
#define kShouldShowRecommendAppTipsView [NSString stringWithFormat:@"%@_%@_kShouldShowRecommendAppTipsView",[BOSConfig sharedConfig].user.eid, [BOSConfig sharedConfig].user.openId]

// 开通更多企业应用 呼吸灯
#define kEnterpriseMoreAppIndicator [NSString stringWithFormat:@"%@_%@_kEnterpriseMoreAppIndicator",[BOSConfig sharedConfig].user.eid, [BOSConfig sharedConfig].user.openId]

// 为本企业开通应用 呼吸灯
#define kAppDetailIndicator [NSString stringWithFormat:@"%@_%@_kAppDetailIndicator",[BOSConfig sharedConfig].user.eid, [BOSConfig sharedConfig].user.openId]

// 删除应用提示
#define kAppEditTips @"kAppEditTips"



#endif
