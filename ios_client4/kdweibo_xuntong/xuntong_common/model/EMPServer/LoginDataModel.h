//
//  LoginDataModel.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 登录接口数据模型
 */

#import "BOSBaseDataModel.h"

@interface LoginDataModel : BOSBaseDataModel{
    NSString *_ssoToken_;
    NSString *_accessToken_;
    NSString *_loginToken_;
    NSString *_homePage_;
}

/*
 (可选)门户单点令牌
 后续跳转至其他应用时需要使用此值
 */
@property (nonatomic,copy) NSString *ssoToken;

/*
 (可选)访问令牌
 后续访问业务接口时必须将其放在HttpHeader中(key=”accessToken”,value=值).
 用于解决session失效问题。
 */
@property (nonatomic,copy) NSString *accessToken;

/*
 (可选)云平台令牌
 表示客户端已成功登录EAS-3G，此令牌用于客户端请求Cloud平台数据。
 */
@property (nonatomic,copy) NSString *loginToken;

/*
 (可选)成功登录后,应用的首页URL(只适用于web版本移动应用).
 当不是web版本移动应用或者未配置首页时,不返回其属性
 */
@property (nonatomic,copy) NSString *homePage;

@end
