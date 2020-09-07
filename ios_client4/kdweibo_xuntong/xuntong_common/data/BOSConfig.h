//
//  BOSConfig.h
//  EMPNativeContainer
//
//  Created by Gil on 12-11-9.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOSSetting.h"
#import "UserDataModel.h"
#import "KDMainUserDataModel.h"

#define BOS_CONFIG [BOSConfig sharedConfig]

//since 3.0
//程序运行期的数据
@interface BOSConfig : NSObject {
    
}
//push deviceToken
@property (nonatomic,copy) NSString *deviceToken;
//应用支持的方向，从info文件中获取
@property (nonatomic,retain) NSArray *supportedOrientations;

//应用公用参数，是否自动登录(从params中获取)
@property (nonatomic,assign) BOOL bAutoLogin;
//应用公用参数，是否启用安全策略，即加密传输(从params中获取)
@property (nonatomic,assign) BOOL bSecurity;

//DES加密的密钥
@property (nonatomic,copy) NSString *secretKey;
//是否为Demo按钮进入
@property (nonatomic,assign) BOOL bDemoLogin;

//-----------------------------------------//
//需要持久化的
//云服务平台Token
@property (nonatomic,copy) NSString *loginToken;
//门户单点登录Token
@property (nonatomic,copy) NSString *ssoToken;
//启动页面
@property (nonatomic,copy) NSString *homePage;
//经过mCloud处理过后的用户名
@property (nonatomic,copy) NSString *loginUser;
//应用ID和实例名
@property (nonatomic,assign) int appId;
@property (nonatomic,copy) NSString *instanceName;

//当前登录者信息
@property (nonatomic, retain) UserDataModel *user;
@property (nonatomic, retain) PersonSimpleDataModel *currentUser;

@property (nonatomic,assign) BOOL isLoginWithOpenAccount;

@property (nonatomic, retain) KDMainUserDataModel *mainUser;

/*
 @desc 获取BOSConfig单例对象;
 @return BOSConfig;
 */
+(BOSConfig *)sharedConfig;

/*
 @desc 更新本地参数(如bAutoLogin、bSecurity等);
 @return void;
 */
-(void)updateConfig4Param;

/*
 @desc 清除配置;
 @return void;
 */
-(void)clearConfig;
-(BOOL)saveConfig;

@property (retain, nonatomic) NSString *tokenFromShare;         // 部落传来的do token （临时存储）
@property (retain, nonatomic) NSString *tokenSecretFromShare;   // 部落传来的do token secret （临时存储）
@property (retain, nonatomic) NSString *shareToken;             // 服务器换来的share token （临时存储）
@property (retain, nonatomic) NSString *shareTokenSecret;       // 服务器换来的share token secret （临时存储）
@property (retain, nonatomic) NSString *networkIdFromShare;     // 部落传来的networkId （临时存储）
@end
