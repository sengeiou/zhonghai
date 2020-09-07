//
//  AuthDataModel.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 MCloud认证接口数据模型
 */

#import "BOSBaseDataModel.h"

//客户的安全策略等级
typedef enum _SecurityLevel{
    SecurityLevelNone = 0
}SecurityLevel;

//licence策略
typedef enum _LicencePolicy{
    LicenceOpenPolicy = 1,//开放licence
    LicenceBaseOnApplyPolicy = 2 //基于申请的licence
}LicencePolicy;

//TOS签署标示
typedef enum _TOSType{
    TOSSigned = 0,//协议已签署
    TOSUnsigned = 1,//协议未签署
    TOSChanged = 2//协议已变更
}TOSType;

@interface AuthDataModel : BOSBaseDataModel{
    NSString *_welcome_;
    NSString *_url_;
    SecurityLevel _security_;
    NSString *_customerName_;	
    NSString *_authToken_;
    
    NSDictionary *_params_;
    int _appId_;
    NSString *_loginUser_;
    NSString *_instanceName_;
}
/*欢迎语。可能是企业定义的，也可能是金蝶
 设定的广告推广用语。在EMP容器的闪屏中使用*/
@property (nonatomic,copy) NSString *welcome;
//EMP Server URL路径
@property (nonatomic,copy) NSString *url;
//客户的安全策略等级，默认为0，安全等级越高该数值越大
@property (nonatomic,assign) SecurityLevel security;
/*(可选，默认空字符串)客户名称（在单点登录时候）*/
@property (nonatomic,copy) NSString *customerName;
/*mCloud通过企业公钥加密的认证串，EMP容器在向EMPServer发送业务请求带上该认证串，EMPServer在解析业务消息时，通过私钥解码出该串，做相关的验证*/
@property (nonatomic,copy) NSString *authToken;
//since 3.0
/*(可选，默认为null) 应用参数，不同的应用返回不同的参数，以key/value的形式返回*/
@property (nonatomic,retain) NSDictionary *params;
/*应用ID.支持一个客户端连接不同的应用连接器*/
@property (nonatomic,assign) int appId;
/*用户名,支持多实例登录*/
@property (nonatomic,copy) NSString *loginUser;
/*应用实例名,支持多实例登录*/
@property (nonatomic,copy) NSString *instanceName;
/*检测企业是否开通讯通*/
@property (nonatomic,copy) NSString *xtOpen;
@end

//当认证失败消息为：版本过低时，返回此对象
@interface AuthVersionLowDataModel : BOSBaseDataModel{
    NSString *_iosURL_;
}
//(ios版) iTunes AppStore上的url
@property (nonatomic,copy) NSString *iosURL;
@end

//当认证失败消息为：设备未授权时，返回此对象
@interface AuthDeviceUnauthorizedDataModel : BOSBaseDataModel{
    NSString *_url_;
    LicencePolicy _licencePolicy_;
    NSString *_opToken_;
    NSString *_authTime_;
    NSString *_loginUser_;
}
//EMP容器通过该属性，在提交licence申请前向EMP Server验证账号密码的有效性
@property (nonatomic,copy) NSString *url;
//licence策略
@property (nonatomic,assign) LicencePolicy licencePolicy;
//DES(timestamp) 在提交licence绑定时，必须带上该token
@property (nonatomic,copy) NSString *opToken;
//用于EMP的validate.action接口
@property (nonatomic,copy) NSString *authTime;
/*用户名,支持多实例登录*/
@property (nonatomic,copy) NSString *loginUser;
@end

//当认证失败消息为：TOS使用的服务条款未签署或许需要再签署时，返回此对象
@interface  AuthTOSDataModel  : BOSBaseDataModel{
    TOSType _tosTag_;
}
//协议签署标示
@property (nonatomic,assign) TOSType tosTag;
@end
