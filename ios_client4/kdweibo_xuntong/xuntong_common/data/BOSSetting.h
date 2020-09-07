//
//  BOSSetting.h
//  Public
//
//  Created by Gil on 12-4-27.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 应用程序数据存储类，具体的应用可继承此类增加特有的属性
 */

#import <Foundation/Foundation.h>
#import "AuthDataModel.h"

extern NSString * kBOSSettingParamChangedNotification;

enum {
	// 通讯录A方案，显示所有联系人，默认
    ContactStyleShowAll      = 0,
	// 通讯录B方案，显示最近联系人
    ContactStyleShowRecently = 1
}; typedef NSUInteger ContactStyle;


enum {
    WaterMarkTypeConversation = 100,
    WaterMarkTypeContact = 10,
    WaterMarkTypPublicAndLightApp = 1
}; typedef NSUInteger WaterMarkType;

//需要保存的数据
@interface BOSSetting : NSObject {
    @private
    NSArray *_extArray;
}

//客户3g号
@property (nonatomic,copy) NSString *cust3gNo;
//客户名称
@property (nonatomic,copy) NSString *customerName;
//用户名,文本框中输入的用户名
@property (nonatomic,copy) NSString *userName;
//密码，写入时加密，取出时已解密
@property (nonatomic,copy) NSString *password;
//欢迎语
@property (nonatomic,copy) NSString *welcome;
//客户的安全策略等级，默认为0，安全等级越高该数值越大
@property (nonatomic,assign) SecurityLevel security;
//各个企业logo的最后更新时间，以cust3gNo为key，lastUpdateTime为value
@property (nonatomic,retain) NSMutableDictionary *logoUpdateTimes;
//业务系统Token
@property (nonatomic,copy) NSString *accessToken;
//检测是否开通讯通
@property (nonatomic,copy) NSString *xtOpen;


//since 3.0
//应用参数
@property (nonatomic,retain) NSDictionary *params;
//RSA加密的公钥
@property (nonatomic,retain) NSMutableDictionary *publicKeys;
//曾经使用过帐号登录
@property (nonatomic,assign) BOOL hasFinishLogin;
//应用的下载地址
@property (nonatomic,copy) NSString *appDownloadURL;
//意见反馈的更新时间
@property (nonatomic,copy) NSString *feedBackUpdateTime;

//登录URL
@property (nonatomic,copy) NSString *url;

@property (nonatomic, assign) int bindPhoneFlag;        //0:未绑定  1:已绑定
@property (nonatomic, assign) int bindEmailFlag;        //0:未绑定  1:已绑定
@property (nonatomic, assign) int showAvatarFlag;       //0:未提示  1:已提示

@property (nonatomic,retain) NSDictionary *appConfigs;

//推送开启声音否
@property (nonatomic, assign) BOOL isSound;
//推送开启振动否
@property (nonatomic, assign) BOOL isVibrate;

//聊天加号菜单轻应用
@property (nonatomic, retain) NSArray *chatGroupAPPArr;

/*
 @desc 获取BOSSetting单例对象 (deprecated);
 deprecated since 3.0
 使用< +(BOSSetting *)sharedSetting >方法替代
 @return BOSSetting;
 */
+(BOSSetting *)getSetting __attribute__((deprecated));
+(BOSSetting *)sharedSetting;

/*
 @desc 保存配置文件;
 @return 是否成功;
 */
-(BOOL)saveSetting;

/*
 @desc 清除所有配置信息并保存;
 @return void;
 */
-(void)clearSetting;

/*
 @desc 清除登录配置信息并保存;
 @return void;
 */
-(void)cleanUpAccount;

//是否具有邀请权限 0.管理员可以 1.全部可以 2.全部不可以
- (NSString *)hasInvitePermission;
//老板开讲公共号ID
- (NSString *)bossTalkShowId;
//领导开讲公共号名称
- (NSString *)bossTalkName;
//是否支持非手机号码登录
- (BOOL)supportNotMobile;
//判断是否启用网络通讯录，NO:不支持启用网络通讯录;YES：支持启用网络通讯录
- (BOOL)isNetworkOrgTreeInfo;

- (NSString *)funcswitch;

//是否开通EPR集成服务
- (BOOL)isIntergrationMode;
//邀请是否需要管理员审核
- (BOOL)isInviteApprove;
//通讯录AB方案风格
- (ContactStyle)contactStyle;

//组织管理轻应用ID
- (NSString *)groupManageAppId;
//我的签到轻应用ID
- (NSString *)mySignAppId;
//我的签到轻应用是否启用
- (BOOL)mySignEnable;
//管理员助手公共号ID
- (NSString *)assistantPubAccId;

- (BOOL)autowifiEnable;
- (BOOL)photoSigninEnable;
- (BOOL)freeCallEnable;


//office文档权限
//office文档管控是否开启
- (BOOL)isWPSControlOpen;
- (BOOL)fileShareEnable;

//允许下载的文件格式
- (BOOL)allowFileDownload:(NSString *)ext;
//在线打开文件的地址
- (NSString *)attachViewUrlWithId:(NSString *)fileId;
//A.wang 判断是否在线打开
- (BOOL)allowOpenOnline;
//A.wang 判断是否是在线打开的格式
- (BOOL)openOnlineExt:(NSString *)ext;

//该参数控制微博文字是否可复制/对话消息中文字是否可复制/对话消息中文字是否可分享到其他
- (BOOL)allowMsgInnerMobileShare;
- (BOOL)allowMsgOuterMobileShare;

//消息是否可撤回 -1为不可撤回，0为可以，大于0则根据所得时间进行计算（min为单位）
- (NSInteger)canCancelMessage;

//打开是否强制开启手势密码 0为不强制，1为强制
- (BOOL)openGesturePassword;

//聊天是否开启水印 0 不启用，1为启用
- (BOOL)openWaterMark:(WaterMarkType)type;

//是否显示组织架构总人数 0 不显示，1为显示
- (BOOL)showPersonCount;

//聊天是否开启工作台
- (NSString *)openWorkWithID;


//消息转发轻应用支持的appid
- (NSString *)msgMenuAppId;

-(NSString *)vendorID;
-(NSString *)signKey;

//云端轻应用
-(NSString *)getAppstoreurl;

// 是否激活了长连接
- (BOOL)longConnEnable;
//- (BOOL)groupSignInEnable;
- (void)setLongConnEnable:(BOOL)longConnEnable;

+ (BOOL)isHTTPSOpen;
+ (NSString *)getHttpsUrl:(NSString *)url;

// 金格授权码
- (NSString *)copyright;

//平台是否支持发送短信(1：开启，0：不开启，默认不开启)
- (BOOL)sendSmsEnable;


//是否使用wkwebview(1/nil：开启，0：不开启，默认开启)
- (BOOL)useWKWebView;

// 是否显示分类模式及是否显示分类按钮
- (BOOL)classifiedDisplay;
@end
