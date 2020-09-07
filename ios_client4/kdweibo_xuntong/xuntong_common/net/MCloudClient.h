//
//  MCloudClient.h
//  Public
//
//  Created by Gil on 12-4-27.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 MCloud上的所有公共接口，包括：认证、绑定、licence申请等，但是不包括业务独有的接口，比如通讯录的部分接口。
 使用时需生成一个MCloudClient的对象，传入target和action。
 其中action命名有规则：
    例如调用auth接口时，action最好为(authDidReceived:result:)
    而对应的方法为：-(void)authDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result;
    其中，client中包含errorCode和errorMessage；成功时result为BOSResultDataModel对象，否则为nil
 */

#import "BOSConnect.h"

typedef enum _BindUserDevicePolicy{
    BindUserDevicePolicyRemove = 0,//不绑定或者解除绑定
    BindUserDevicePolicyUser = 1,//绑定用户：此设备上只能有【当前用户】使用
    BindUserDevicePolicyDevice = 2,//绑定设备：【当前用户】只能使用此设备
    BindUserDevicePolicyAll = 3 //绑定用户+绑定设备：此设备上只能有【当前用户】使用，并且【当前用户】只能使用此设备
}BindUserDevicePolicy;

@interface MCloudClient : BOSConnect

/**
 *	@brief	类方法，判断是否是使用域名来连接mCloud
 *
 *	@return	布尔值
 */
+ (BOOL)connectedByDomain;

/**
 *	@brief	mcloud地址
 *
 *	@return	NSString
 */
+ (NSString *)mcloudBaseUrl;

/**
 *	@brief	判断在终端可联网的环境下是否存在连接mCloud错误
 *
 *	@return	布尔值
 */
- (BOOL)connectedHostError;

/**
 *	@brief	判断是否是使用IP来连接mCloud
 *
 *	@return	布尔值
 */
- (BOOL)connectedByIP;

/**
 *	@brief	判断是否是使用域名来连接mCloud
 *
 *	@return	布尔值
 */
- (BOOL)connectedByDomain;

- (void)getAppParamsWithCust3gNo:(NSString *)cust3gNo;
/*
 @desc 认证
 @param cust3gNo; -- 企业3g号
 @param userName; -- 用户名(原始用户名，未经mCloud处理的)
 @return void;
 */
-(void)authWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName;

/*
 @desc Licence绑定（开放licence管理模式）
 @param cust3gNo; -- 企业3g号
 @param userName; -- 用户名
 @param opToken; -- 操作令牌,auth接口返回
 @param validateToken; -- 验证令牌, EMP的validate接口返回
 @return void;
 */
-(void)bindLicenceWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName opToken:(NSString *)opToken validateToken:(NSString *)validateToken;

/*
 @desc 设备用户的绑定策略提交
 @param cust3gNo; -- 企业3g号
 @param userName; -- 用户名
 @param policy; -- 绑定策略，见BindUserDevicePolicy
 @return void;
 */
-(void)bindUserDeviceWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName policy:(BindUserDevicePolicy)policy;

/*
 @desc 获取云端指令
 @param cust3gNo; -- 企业3g号
 @param userName; -- 用户名
 @return void;
 */
-(void)instructionsWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName;

/*
 @desc 版本检测
 @return void;
 */
-(void)checkVersion;

/*
 @desc 搜索企业
 @param word; -- 关键字
 @return void;
 */
-(void)customerSearchWithWord:(NSString *)word;

/*
 @desc 签署TOS
 @param cust3gNo; -- 企业3g号
 @param userName; -- 用户名
 @return void;
 */
-(void)signtosWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName;

/*
 @desc 设备licence申请
 @param cust3gNo; -- 企业3g号
 @param userName; -- 用户名
 @param memo; -- 备注，给管理员的留言
 @return void;
 */
-(void)deviceLicenceApplyWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName memo:(NSString *)memo;

/*
 @desc 客户logo请求
 @param cust3gNo; -- 企业3g号
 @param lastUpdateTime; -- 最后更新时间
 @return void;
 */
-(void)customerLogoDownloadWithCust3gNo:(NSString *)cust3gNo lastUpdateTime:(NSString *)lastUpdateTime;

/*
 @desc 获取企业公钥
 @param cust3gNo; -- 企业3g号
 @return void;
 */
-(void)customerPublicKeyWithCust3gNo:(NSString *)cust3gNo;

/*
 @desc 获取演示帐号
 @return void;
 */
-(void)demoAccount;

/*
 @desc 获取应用信息
 @return void;
 */
-(void)appInfo;

/*
 @desc 获取应用推荐列表
 @return void;
 */
-(void)appRecommendationsWithType:(int)type begin:(int)begin count:(int)count;

/*
 @desc 获取应用推荐列表(新版云之家4.0接口）
 @return void;
 */
-(void)appRecommendWithType:(int)type cust3g:(NSString *)cust3gNo userName:(NSString *)userName searchKey:(NSString*)searchKey;

/*
 @desc 默认应用
 @return void;
 */
-(void)appDefaultCust3g:(NSString *)cust3gNo userName:(NSString *)userName;

/*
 @desc 产品评价
 @return void;
 */
-(void)evaluationswithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName;

- (void)registerWithCustName:(NSString *)custName phone:(NSString *)phone name:(NSString *)name;

//- (void)getLightAppURLWithMid:(NSString *)mid appid:(NSString *)appid openToken:(NSString *)openToken urlParam:(NSString *)urlParam;
- (void)getLightAppURLWithMid:(NSString *)mid appid:(NSString *)appid openToken:(NSString *)openToken groupId:(NSString *)groupId userId:(NSString *)userId msgId:(NSString *)msgId urlParam:(NSString *)urlParam todoStatus:(NSString *)todoStatus;

- (void)getYunAppURLWithMid:(NSString *)mid appid:(NSString *)appid openToken:(NSString *)openToken urlParam:(NSString *)urlParam;

- (void)getLightAppParamWithMid:(NSString *)mid appids:(NSString *)appids openToken:(NSString *)openToken urlParam:(NSString *)urlParam;

- (void)getDefineLightAppsWithMid:(NSString *)mid appids:(NSString *)appids openToken:(NSString *)openToken urlParam:(NSString *)urlParam;
@end
