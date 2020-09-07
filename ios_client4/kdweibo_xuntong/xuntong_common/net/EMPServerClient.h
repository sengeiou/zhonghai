//
//  EMPServerClient.h
//  Public
//
//  Created by Gil on 12-4-27.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 EMPServer上的公共接口，包括：登录、注销、验证密码、职员查询等。
 使用时需生成一个EMPServerClient的对象，传入target和action
 其中action命名有规则：
    例如调用login接口时，action最好为(loginDidReceived:result:)
    而对应的方法为：-(void)loginDidReceived:(EMPServerClient *)client result:(id)result;
    其中，client中包含errorCode和errorMessage；成功时result为id或者BOSResultDataModel对象，否则为nil
*/

#import "BOSConnect.h"

typedef enum _EMPRequestMethodType{
    EMPRequestPostMethod,
    EMPRequestGetMethod
}EMPRequestMethodType;

@interface EMPServerClient : BOSConnect

/**
 *  验证Token
 *
 *  @param token       Open Token
 *  @param appClientId 客户端ID
 *  @param deviceId    设备号
 *  @param deviceToken 推送Token
 */
- (void)authTokenWithToken:(NSString *)token
               appClientId:(NSString *)appClientId
                  deviceId:(NSString *)deviceId
               deviceToken:(NSString *)deviceToken
                   langKey:(NSString *)langKey;

- (void)registerDeviceTokenWithToken:(NSString *)token
                         appClientId:(NSString *)appClientId
                            deviceId:(NSString *)deviceId
                         deviceToken:(NSString *)deviceToken;

/**
 *  注销
 *
 *  @param token Open Token
 */
-(void)logoutWithToken:(NSString *)token;

@end
