//
//  URL+MCloud.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 MCloud 服务相关接口URL，不需要暴露此文件
 */

//MCloud Server URL
//ping mcloud.kingdee.com = 118.194.40.37
#define KD_WEBSOCKET    @"ws:"

#define MCLOUD_IP @"xttest.msbu.kingdee.com"   //正式
#define MCLOUD_DOMAIN @"xttest.msbu.kingdee.com"

#define MCLOUD_IP_FOR_PUBACC [NSString stringWithFormat:@"http://%@/",MCLOUD_IP]
#define MCLOUD_IP_URL [NSString stringWithFormat:@"http://%@/3gol",MCLOUD_IP]
#define MCLOUD_DOMAIN_URL [NSString stringWithFormat:@"http://%@/3gol",MCLOUD_DOMAIN]
#ifndef MCLOUD_DEFAULT_URL
    #define MCLOUD_DEFAULT_URL MCLOUD_IP_URL
#endif

#define FEEDBACK_IP_URL [NSString stringWithFormat:@"http://%@:6899/xuntong",MCLOUD_IP]
#define FEEDBACK_DOMAIN_URL [NSString stringWithFormat:@"http://%@:6899/xuntong",MCLOUD_DOMAIN]

//MCloud Actions
//认证
#define MCLOUDURL_AUTH @"/auth.action"
//Licence绑定（开放licence管理模式）
#define MCLOUDURL_BINDLICENCE @"/bindLicence.action"
//设备用户的绑定策略提交
#define MCLOUDURL_BINDUSERDEVICE @"/bindUserDevice.action"
//获取云端指令
#define MCLOUDURL_INSTRUCTIONS @"/instructions.action"
//版本检测
#define MCLOUDURL_CHECKVERSION @"/checkVersion.action"
//搜索企业列表
#define MCLOUDURL_CUSTOMERSEARCH @"/customerSearch.action"
//签署TOS
#define MCLOUDURL_SIGNTOS @"/signtos.action"
//获取TOS信息
#define MCLOUDURL_TOS(clientID) [NSString stringWithFormat:@"/tos/%@.html",clientID]
//设备licence申请
#define MCLOUDURL_DEVICELICENCEAPPLY @"/deviceLicenceApply.action"
//客户logo请求
#define MCLOUDURL_CUSTOMERLOGODOWNLOAD @"/customerLogoDownload.action"
//获取参数
#define MCLOUDURL_APPPARAMS @"/appParamsXT.action"
//since 3.0
//获取企业公钥
#define MCLOUDURL_CUSTOMERPUBLICKEY @"/customerPublicKey.action"
//获取演示帐号
#define MCLOUDURL_DEMOACCOUNT @"/demoAccount.action"
//应用信息
#define MCLOUDURL_APPINFO @"/appInfo.action"
//应用推荐列表
#define MCLOUDURL_APPRECOMMENDATIONS @"/appRecommendations.action"
#define MCLOUDURL_EVALUATION @"/checkSurvey.action"
#define MCLOUDURL_REGISTER @"/register.action"
#define XT_APP_Recommend @"/appRecommendXT.action"
#define XT_APP_Tab @"/appTabXT2.action"

//获取轻应用信息
#define MCLOUDURL_GETLIGHTAPPURL @"/getLightAppURL.action"
#define MCLOUDURL_GETLIGHTAPPPARAMURL @"/GetLightAppsParamURL.action"
#define MCLOUDURL_GETDEFINELIGHTAPPSURL @"/GetDefineLightAppsURL.action"










