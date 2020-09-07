//
//  XTLoginService.m
//  kdweibo
//
//  Created by bird on 14-4-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTLoginService.h"
#import "AlgorithmHelper.h"
#import "BOSSetting.h"
#import "UserDataModel.h"
#import "BOSConfig.h"
#import "MCloudClient.h"
#import "LoginDataModel.h"
#import "XTSetting.h"
#import "ContactLoginDataModel.h"
#import "ContactClient.h"
#import "T9.h"
#import "XTInitializationManager.h"
#import "KDMainUserDataModel.h"
#import "KDWeiboLoginService.h"
#import "KDDBManager.h"
#import "KDParamFetchManager.h"

@interface XTLoginService()
@property (nonatomic, retain) XTOpenSystemClient *openClient;
@property (nonatomic, retain) MCloudClient *clientCloud;
@property (nonatomic, copy) XTLoginFinishedBlock block;
@property (nonatomic, retain) NSString *eId;
@property (nonatomic, retain) UserDataModel *user;
@property (nonatomic, retain) EMPServerClient *clientServer;
@property (nonatomic, retain) AuthDeviceUnauthorizedDataModel *authDeviceUnauthorizedDataModel;
@property (nonatomic, retain) ContactClient *t9UpdateClient;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) XTOpenSystemClient *openTeamClient;

@end
@implementation XTLoginService

static XTLoginService *_XTLoginService = NULL;

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_t9UpdateClient);
    //KD_RELEASE_SAFELY(_authDeviceUnauthorizedDataModel);
    //KD_RELEASE_SAFELY(_clientServer);
    //KD_RELEASE_SAFELY(_eId);
    //KD_RELEASE_SAFELY(_openClient);
    //KD_RELEASE_SAFELY(_clientCloud);
    //KD_RELEASE_SAFELY(_token);
    //KD_RELEASE_SAFELY(_openTeamClient);
    //[super dealloc];
}
+ (void)xtLoginInEId:(NSString *)eid finishBlock:(XTLoginFinishedBlock)block
{
    if(KD_IS_BLANK_STR(eid)){
        return;
    }
    XTLoginService *service = [[XTLoginService alloc] init] ;//autorelease];
    service.block = block;
    service.eId  = eid;
    
    [service login];
    
    _XTLoginService = service;// retain];
}

+ (void)xtLoginInToken:(NSString *)token finishBlock:(XTLoginFinishedBlock)block {
    if (KD_IS_BLANK_STR(token)) {
        return;
    }
    
    XTLoginService *service = [[XTLoginService alloc] init];// autorelease];
    service.block = block;
    service.token  = token;
    
    [service loginTeamAccount];
    
    _XTLoginService = service;// retain];
}

- (void)loginTeamAccount {
    self.openTeamClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getTeamTokenDidReceived:result:)];// autorelease];
    NSString *password = [AlgorithmHelper des_Encrypt:[BOSSetting sharedSetting].password key:[BOSSetting sharedSetting].userName];
    [self.openTeamClient loginWithCust3gNo:[BOSConfig sharedConfig].mainUser.eid userName:[BOSConfig sharedConfig].mainUser.wbUserId password:password appClientId:XuntongAppClientId deviceId:[UIDevice uniqueDeviceIdentifier] deviceType:[[UIDevice currentDevice] model] token:self.token];
}

- (void)getTeamTokenDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result {
    
    if (client.hasError || !result.success || ![result isKindOfClass:[BOSResultDataModel class]]) {
        
        if (_block) {
            _block(false);
        }
        
//        [_XTLoginService release];
        _XTLoginService = NULL;
        
        return;
    }
    
    self.openTeamClient = nil;
    
    UserDataModel *user = [[UserDataModel alloc] initWithDictionary:result.data];// autorelease];
    if (user.status != 3) {
        user.status = 3;
    }
    user.phone = user.bindedPhone;
    user.email = user.bindedEmail;
    
    self.user =  user;
    [BOSConfig sharedConfig].user = user;
    [[BOSConfig sharedConfig] saveConfig];
    
    self.eId = user.eid;
    
    KDAuthToken *token = [[KDAuthToken alloc] initWithKey:user.oauthToken secret:user.oauthTokenSecret];
    if (Test_Environment) {
        KDWeiboLoginFinishedBlock block = ^(BOOL success, NSString *error)
        {
            if (success) {
                
                //先清空数据库，团队账号
                [[KDDBManager sharedDBManager] deleteCurrentCompanyDataBase];
                [[KDDBManager sharedDBManager] tryConnectToCommunity:user.eid];
                
                KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
                KDUser *currentUser = userManager.currentUser;
                userManager.currentUser = nil;
                userManager.currentUser = currentUser;
            }
            
            [BOSConfig sharedConfig].user = user;
            
            [BOSSetting sharedSetting].cust3gNo = user.eid;
            
            [[XTDataBaseDao sharedDatabaseDaoInstance] setOpenId:user.openId eId:user.eid];
            
            PersonSimpleDataModel *currentPerson = [[PersonSimpleDataModel alloc] init];
            currentPerson.personId = _user.userId;
            currentPerson.personName = _user.name;
            currentPerson.isAdmin = _user.isAdmin;
            currentPerson.photoUrl = _user.photoUrl;
            if (_user.status == 1) {
                currentPerson.status = 3;
            }else{
                currentPerson.status = _user.status;
            }
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:currentPerson];
            
            [[XTSetting sharedSetting] setOpenId:user.openId eId:user.eid];
        };
        
        [KDWeiboLoginService signInToken:token finishBlock:block];
        
    }
    
    [self auth];
}

- (void)login
{
    self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getTokenDidReceived:result:)];// autorelease];
	NSString *password = [AlgorithmHelper des_Encrypt:[BOSSetting sharedSetting].password key:[BOSSetting sharedSetting].userName];
	[self.openClient loginWithCust3gNo:_eId userName:[BOSSetting sharedSetting].userName password:password appClientId:XuntongAppClientId deviceId:[UIDevice uniqueDeviceIdentifier] deviceType:[[UIDevice currentDevice] model] token:@""];
}
- (void)getTokenDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result {
    
	if (client.hasError || !result.success || ![result isKindOfClass:[BOSResultDataModel class]]) {
        
        if (_block) {
            _block(false);
        }
        
//        [_XTLoginService release];
        _XTLoginService = NULL;
        
		return;
	}
    
    self.openClient = nil;
    
    UserDataModel *user = [[UserDataModel alloc] initWithDictionary:result.data];// autorelease];
    user.phone = user.bindedPhone;
    user.email = user.bindedEmail;
    
    self.user =  user;
    
    // 为切换团队账号，保存一份主账号的信息
    KDMainUserDataModel *mainUser = [[KDMainUserDataModel alloc] initWithDictionary:result.data];
    mainUser.phone = mainUser.bindedPhone;
    mainUser.email = mainUser.bindedEmail;
    
    // 主账号归档操作
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *arch = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [arch encodeObject:mainUser forKey:@"mainUser"];
    [arch finishEncoding];
    [data writeToFile:[[BOSFileManager xuntongPath] stringByAppendingPathComponent:@"mainUser.archiver"] atomically:YES];
    
    KDAuthToken *token = [[KDAuthToken alloc] initWithKey:user.oauthToken secret:user.oauthTokenSecret];
    
    if (user.language != nil && user.language.length > 0 ) {
        if ([user.language hasPrefix:@"zh-Hans"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
        } else if ([user.language hasPrefix:@"zh-TW"] || [user.language hasPrefix:@"zh-HK"] || [user.language hasPrefix:@"zh-Hant"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
        } else if ([user.language hasPrefix:@"en"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:AppLanguage];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
        }
    }
    if (Test_Environment) {
        KDWeiboLoginFinishedBlock block = ^(BOOL success, NSString *error)
        {
            if (success) {
                //先清空数据库，团队账号
                [[KDDBManager sharedDBManager] deleteCurrentCompanyDataBase];
                [[KDDBManager sharedDBManager] tryConnectToCommunity:user.eid];
                
                KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
                KDUser *currentUser = userManager.currentUser;
                userManager.currentUser = nil;
                userManager.currentUser = currentUser;
            }
            
            [BOSConfig sharedConfig].user = user;
            
            [BOSSetting sharedSetting].cust3gNo = user.eid;
            
            [[XTDataBaseDao sharedDatabaseDaoInstance] setOpenId:user.openId eId:user.eid];
            
            [[XTSetting sharedSetting] setOpenId:user.openId eId:user.eid];
            
            PersonSimpleDataModel *currentPerson = [[PersonSimpleDataModel alloc] init];
            currentPerson.personId = _user.userId;
            currentPerson.personName = _user.name;
            currentPerson.isAdmin = _user.isAdmin;
            currentPerson.photoUrl = _user.photoUrl;
            currentPerson.wbUserId = _user.wbUserId;
            if (_user.status == 1) {
                currentPerson.status = 3;
            }else{
                currentPerson.status = _user.status;
            }
            currentPerson.oid = _user.oId;
            currentPerson.orgId = _user.orgId;
            currentPerson.partnerType = _user.partnerType;
            
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:currentPerson];
        };
        
        [KDWeiboLoginService signInToken:token finishBlock:block];
        
    }
    
    [self auth];
}


- (void)auth {
    
    self.clientCloud = [[MCloudClient alloc] initWithTarget:self action:@selector(authDidReceived:result:)];/// autorelease];
	[_clientCloud authWithCust3gNo:_eId userName:[BOSSetting sharedSetting].userName];
}

-(void)authDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    if ([client connectedHostError] || client.hasError || ![result isKindOfClass:[BOSResultDataModel class]]) {
        
        if (_block) {
            _block(false);
        }
        
        self.user = nil;
        
//        [_XTLoginService release];
        _XTLoginService = NULL;
        
		return;
    }
    
    self.clientCloud = nil;
    
    
    if (result.success) {
     
        [BOSConfig sharedConfig].user = _user;
        
        [BOSSetting sharedSetting].cust3gNo = _user.eid;
        
        [[XTDataBaseDao sharedDatabaseDaoInstance] setOpenId:_user.openId eId:_user.eid];
        [[XTSetting sharedSetting] setOpenId:_user.openId eId:_user.eid];
        
        
        AuthDataModel *authDM = [[AuthDataModel alloc] initWithDictionary:result.data];// autorelease];
        
        //记录需要保存的配置
        BOSSetting *bosSetting = [BOSSetting sharedSetting];
        bosSetting.customerName = [BOSConfig sharedConfig].user.companyName;
        bosSetting.params = authDM.params;
        bosSetting.url = authDM.url;
        bosSetting.xtOpen = authDM.xtOpen;
        
        [bosSetting saveSetting];
        
        //记录无需保存的配置(现在也需要保存)
        BOSConfig *bosConfig = [BOSConfig sharedConfig];    
        bosConfig.currentUser = nil;
        bosConfig.loginUser = authDM.loginUser;
        bosConfig.appId = authDM.appId;
        bosConfig.instanceName = authDM.instanceName;
        [bosConfig updateConfig4Param];
        [bosConfig saveConfig];
        
        [BOSConnect setUAWithAppId:authDM.appId name:authDM.instanceName];
        
        [self startFetchParam];
        [self acccess];
    }
    else
    {
        if (result.errorCode == MCloudDeviceUnauthorizedError) {
            AuthDeviceUnauthorizedDataModel *authDeviceUnauthorizedDM = [[AuthDeviceUnauthorizedDataModel alloc] initWithDictionary:result.data] ;//autorelease];
            //到EMP Server鉴权
            self.authDeviceUnauthorizedDataModel = authDeviceUnauthorizedDM;
            
            //鉴权成功，判断licence策略
            if (authDeviceUnauthorizedDM.licencePolicy == LicenceBaseOnApplyPolicy) {
                //提示用户申请授权
                
                if (_block) {
                    _block(false);
                }
                
//                [_XTLoginService release];
                _XTLoginService = NULL;
            }
            else {
                //调用绑定接口
                [self bindLicence:@""];
            }
        }
        else
        {
            if (_block) {
                _block(false);
            }
            
//            [_XTLoginService release];
            _XTLoginService = NULL;
        }
    }
    
 
}
- (void)acccess
{
    NSString *languageKey = [[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage];
    self.clientServer = [[EMPServerClient alloc] initWithTarget:self action:@selector(loginDidReceived:result:)] ;//autorelease];
    [_clientServer authTokenWithToken:[BOSConfig sharedConfig].user.token
                          appClientId:XuntongAppClientId
                             deviceId:[UIDevice uniqueDeviceIdentifier]
                          deviceToken:[BOSConfig sharedConfig].deviceToken
                              langKey:languageKey];
}
-(void)loginDidReceived:(EMPServerClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || ![result isKindOfClass:[BOSResultDataModel class]] || !result.success) {
        if (_block) {
            _block(false);
        }
        
//        [_XTLoginService release];
        _XTLoginService = NULL;
        
        return;
    }

    self.clientServer = nil;
    
    LoginDataModel *loginDM = [[LoginDataModel alloc] initWithDictionary:result.data] ;//autorelease];
    
    BOSSetting *setting = [BOSSetting sharedSetting];
    setting.accessToken = loginDM.accessToken;
    
    setting.hasFinishLogin = YES;
    [setting saveSetting];
    
    BOSConfig *bosConfig = [BOSConfig sharedConfig];
    bosConfig.ssoToken = loginDM.ssoToken;
    bosConfig.loginToken = loginDM.loginToken;
    bosConfig.homePage = loginDM.homePage;
    [bosConfig saveConfig];
    
    ContactLoginDataModel *contactLoginDM = [[ContactLoginDataModel alloc] initWithDictionary:result.data];// autorelease];
    [ContactConfig sharedConfig].publicAccountList = contactLoginDM.extraData.pubAccount;
    [[ContactConfig sharedConfig] saveConfig];
    
    [XTSetting sharedSetting].cloudpassport = [contactLoginDM extraData].cloudpassport;
    [XTSetting sharedSetting].grammarId = [contactLoginDM extraData].grammarId;
    [XTSetting sharedSetting].orgTree = [contactLoginDM extraData].orgTree;
    [[XTSetting sharedSetting] saveSetting];
    
    [[XTInitializationManager sharedInitializationManager] startInitializeCompletionBlock:nil failedBlock:nil];
    
    if (_block) {
        _block(true);
    }
    
//    [_XTLoginService release];
    _XTLoginService = NULL;
    
}
-(void)bindLicence:(NSString *)validateToken
{
    self.clientCloud = [[MCloudClient alloc] initWithTarget:self action:@selector(bindLicenceDidReceived:result:)];// autorelease];
    [_clientCloud bindLicenceWithCust3gNo:_eId userName:_authDeviceUnauthorizedDataModel.loginUser opToken:_authDeviceUnauthorizedDataModel.opToken validateToken:validateToken];
}
-(void)bindLicenceDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || ![result isKindOfClass:[BOSResultDataModel class]] || !result.success){

        if (_block) {
            _block(false);
        }
        
//        [_XTLoginService release];
        _XTLoginService = NULL;
        
        return;
    }
    
    //绑定Licence成功，重新进行认证
    [self auth];
}

- (void)startFetchParam {
    [[KDParamFetchManager sharedParamFetchManager] startParamFetchCompletionBlock:^(BOOL success) {
        if (success) {
            //
        }
    }];
}

@end
