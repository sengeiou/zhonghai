//
//  BOSSetting.m
//  Public
//
//  Created by Gil on 12-4-27.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "BOSSetting.h"
#import "BOSFileManager.h"
#import "AlgorithmHelper.h"
#import "BOSConfig.h"
#import "NSDictionary+File.h"
#import "XTFileUtils.h"
#import "URL+MCloud.h"

#define kSettingFileName @"BOSSetting.archive"

#define kSettingCust3gNo @"cust3gNo"
#define kSettingCustomerName @"customerName"
#define kSettingUserName @"userName"
#define kSettingPassword @"password"
#define kSettingWelcome @"welcome"
#define kSettingxtopen @"xtOpen"
#define kSettingSecurity @"security"
#define kSettingLogoUpdateTimes @"logoUpdateTimes"
#define kSettingAccessToken @"accessToken"
#define kSettingParams @"params"
#define kSettingPublicKeys @"publicKeys"
#define kSettingHasFinishLogin @"hasFinishLogin"
#define kSettingAppDownloadURL @"appDownloadURL"
#define kSettingFeedBackUpdateTime @"feedBackUpdateTime"
#define kSettingURL @"url"
#define kSettingBindPhone @"bindPhoneFlag"
#define kSettingBindEmail @"bindEmailFlag"
#define kSettingShowAvatar @"showAvatarFlag"
#define kSettingAppConfigs @"appConfigs"
#define kSettingIsSound @"isSound"
#define kSettingIsVibrate @"isVibrate"
#define kSettingChatGroupAPPArr @"chatGroupAPPArr"


NSString * kBOSSettingParamChangedNotification = @"BOSSettingParamChangedNotification";

@implementation BOSSetting

static BOSSetting *m_instance = nil;
int kdIsHttpsOpen = -1;//判断https是否开启

+(BOSSetting *)sharedSetting
{
    @synchronized(self)
	{
		if(m_instance == nil)
		{
			m_instance=[[BOSSetting alloc] init];
		}
	}
	return m_instance;
}

+(BOSSetting *)getSetting
{
    return [self sharedSetting];
}

- (void)initProperties
{
    self.cust3gNo = [NSString string];;
    self.customerName = [NSString string];
    self.userName = [NSString string];
    self.password = [NSString string];
    self.welcome = [NSString string];
    self.xtOpen=[NSString string];
    self.logoUpdateTimes = [NSMutableDictionary dictionary];
    self.security = SecurityLevelNone;
    self.accessToken = [NSString string];
    
    self.params = [NSDictionary dictionary];
    self.publicKeys = [NSMutableDictionary dictionary];
    self.hasFinishLogin = NO;
    self.appDownloadURL = [NSString string];
    self.feedBackUpdateTime = [NSString string];
    self.url = [NSString string];
    
    self.bindPhoneFlag = 0;
    self.bindEmailFlag = 0;
    self.showAvatarFlag = 0;

    
    self.isSound = NO; //先屏蔽这两项，故初始设为no
    self.isVibrate = NO;
    
    self.appConfigs = [NSDictionary dictionary];
    self.chatGroupAPPArr = [[NSArray alloc] init];

    
}

- (id)init
{
	self = [super init];
    if (self) {
        if ([BOSFileManager fileExistAtXuntongPath:kSettingFileName]) {
    
            NSDictionary * settingData = [NSDictionary dictionaryWithArchivedFile:[[BOSFileManager xuntongPath] stringByAppendingPathComponent:kSettingFileName]];

            if (settingData != nil && [settingData isKindOfClass:[NSDictionary class]]) {
                self.cust3gNo = [self stringValueInSetting:settingData forKey:kSettingCust3gNo];
                self.customerName = [self stringValueInSetting:settingData forKey:kSettingCustomerName];
                self.xtOpen= [self stringValueInSetting:settingData forKey:kSettingxtopen];
                self.userName = [self stringValueInSetting:settingData forKey:kSettingUserName];
                self.password = [AlgorithmHelper des_Decrypt:[self stringValueInSetting:settingData forKey:kSettingPassword] key:self.userName];
                self.welcome = [self stringValueInSetting:settingData forKey:kSettingWelcome];
                
                self.security = [self intValueInSetting:settingData forKey:kSettingSecurity];
                self.logoUpdateTimes = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryValueInSetting:settingData forKey:kSettingLogoUpdateTimes]];
                self.accessToken = [self stringValueInSetting:settingData forKey:kSettingAccessToken];
                
                self.params = [self dictionaryValueInSetting:settingData forKey:kSettingParams];
                self.publicKeys = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryValueInSetting:settingData forKey:kSettingPublicKeys]];
                self.hasFinishLogin = [self boolValueInSetting:settingData forKey:kSettingHasFinishLogin];
                self.appDownloadURL = [self stringValueInSetting:settingData forKey:kSettingAppDownloadURL];
                self.feedBackUpdateTime = [self stringValueInSetting:settingData forKey:kSettingFeedBackUpdateTime];
                self.url = [self stringValueInSetting:settingData forKey:kSettingURL];
                self.bindPhoneFlag = [self intValueInSetting:settingData forKey:kSettingBindPhone];
                self.bindEmailFlag = [self intValueInSetting:settingData forKey:kSettingBindEmail];
                self.showAvatarFlag = [self intValueInSetting:settingData forKey:kSettingShowAvatar];
                self.appConfigs = [self dictionaryValueInSetting:settingData forKey:kSettingAppConfigs];
                self.isSound = [self boolValueInSetting:settingData forKey:kSettingIsSound];
                self.isVibrate = [self boolValueInSetting:settingData forKey:kSettingIsVibrate];
                self.chatGroupAPPArr = [self arrayValueInSetting:settingData forKey:kSettingChatGroupAPPArr];
                
            } else {
                [self initProperties];
            }
        }else {
            [self initProperties];
        }
    }
    
	return self;
}

-(void)dealloc
{
    //BOSRELEASE_cust3gNo);
    //BOSRELEASE_customerName);
    //BOSRELEASE_userName);
    //BOSRELEASE_password);
    //BOSRELEASE_welcome);
    //BOSRELEASE_logoUpdateTimes);
    //BOSRELEASE_accessToken);
    //BOSRELEASE_params);
    //BOSRELEASE_publicKeys);
    //BOSRELEASE_appDownloadURL);
    //BOSRELEASE_feedBackUpdateTime);
    //BOSRELEASE_url);
    //BOSRELEASE_appConfigs);
    //BOSRELEASE_extArray);
    //BOSRELEASE_chatGroupAPPArr);
    //[super dealloc];
}

#pragma mark - methods

-(BOOL)saveSetting
{
    if ([BOSConfig sharedConfig].bDemoLogin) {
        return NO;
    }
    NSMutableDictionary *settingData = [NSMutableDictionary dictionary];
    if (self.cust3gNo != nil) {
        [settingData setObject:self.cust3gNo forKey:kSettingCust3gNo];
    }
    if (self.customerName != nil) {
        [settingData setObject:self.customerName forKey:kSettingCustomerName];
    }
    if (self.userName != nil) {
        [settingData setObject:self.userName forKey:kSettingUserName];
    }
    if (self.password != nil) {
        NSString *key = self.userName == nil ? @"" : self.userName;
        NSString *p = [AlgorithmHelper des_Encrypt:self.password key:key];
        if (p != nil) {
            [settingData setObject:p forKey:kSettingPassword];
        }
    }
    if (self.welcome != nil) {
        [settingData setObject:self.welcome forKey:kSettingWelcome];
    }
    
    [settingData setObject:[NSNumber numberWithInt:self.security] forKey:kSettingSecurity];
    if (self.logoUpdateTimes != nil) {
        [settingData setObject:self.logoUpdateTimes forKey:kSettingLogoUpdateTimes];
    }
    if (self.accessToken != nil) {
        [settingData setObject:self.accessToken forKey:kSettingAccessToken];
    }
    
    if (self.params != nil) {
        [settingData setObject:self.params forKey:kSettingParams];
    }
    if (self.xtOpen != nil) {
        [settingData setObject:self.xtOpen forKey:kSettingxtopen];
    }
    if (self.publicKeys != nil) {
        [settingData setObject:self.publicKeys forKey:kSettingPublicKeys];
    }
    [settingData setObject:[NSNumber numberWithBool:self.hasFinishLogin] forKey:kSettingHasFinishLogin];
    if (self.appDownloadURL != nil) {
        [settingData setObject:self.appDownloadURL forKey:kSettingAppDownloadURL];
    }
    if (self.feedBackUpdateTime != nil) {
        [settingData setObject:self.feedBackUpdateTime forKey:kSettingFeedBackUpdateTime];
    }
    if (self.url != nil) {
        [settingData setObject:self.url forKey:kSettingURL];
    }
    
    [settingData setObject:[NSNumber numberWithInt:self.bindPhoneFlag] forKey:kSettingBindPhone];
    [settingData setObject:[NSNumber numberWithInt:self.bindEmailFlag] forKey:kSettingBindEmail];
    [settingData setObject:[NSNumber numberWithInt:self.showAvatarFlag] forKey:kSettingShowAvatar];
    
    if (self.appConfigs != nil) {
        [settingData setObject:self.appConfigs forKey:kSettingAppConfigs];
    }
    
    [settingData setObject:[NSNumber numberWithBool:self.isSound] forKey:kSettingIsSound];
    [settingData setObject:[NSNumber numberWithBool:self.isVibrate] forKey:kSettingIsVibrate];
    
    if (self.chatGroupAPPArr) {
        [settingData setObject:self.chatGroupAPPArr forKey:kSettingChatGroupAPPArr];
    }
    
    return [settingData writeToArchivedFile:[[BOSFileManager xuntongPath] stringByAppendingPathComponent:kSettingFileName]];
}

-(void)clearSetting
{
    [self initProperties];
    [self saveSetting];
}

-(void)cleanUpAccount
{
	/*
	   不删除当前企业的公钥
	   [self.publicKeys removeObjectForKey:self.cust3gNo];
	   self.cust3gNo = [NSString string];
	   self.customerName = [NSString string];
	 */

	/*
	   不删除当前登录者的用户名
	   self.userName = [NSString string];
	 */
    
    self.password = [NSString string];
    
    self.accessToken = [NSString string];
    if([self supportNotMobile]){
        self.params = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"supportNotMobile", nil];
    }else{
        self.params = [NSDictionary dictionary];
    }
    self.feedBackUpdateTime = [NSString string];
    self.url = [NSString string];
    
    self.bindPhoneFlag = 0;
    self.bindEmailFlag = 0;
    self.showAvatarFlag = 0;
    
    [self saveSetting];
}

- (void)setParams:(NSDictionary *)params
{
    if (_params != params) {
        
//        [_params release];
        _params = params ;//retain];
        if(_extArray)
        {
//            [_extArray release];
            _extArray = nil;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kBOSSettingParamChangedNotification object:nil userInfo:params];
    }
}

-(NSString *)url
{
    if([BOSSetting isHTTPSOpen])
        return [BOSSetting getHttpsUrl:_url];
    return _url;
}

- (BOOL)isIntergrationMode
{
    if (self.params) {
        id invitation = self.params[@"isIntergrationMode"];
        if (invitation != [NSNull null] && [invitation intValue] == 0 && ![invitation isEqualToString:@"null"]) {
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)isNetworkOrgTreeInfo
{
//    if (self.params) {
//        id isNetworkOrgTreeInfo = self.params[@"isNetworkOrgTreeInfo"];
//        if (isNetworkOrgTreeInfo != [NSNull null] && [isNetworkOrgTreeInfo intValue] == 0 && ![isNetworkOrgTreeInfo isEqualToString:@"null"]) {
//            return ;
//        }
//    }
    
    return YES;
}

- (NSString *)hasInvitePermission
{
//    if (self.params) {
        id invitation = self.params[@"invitation"];
//        if (invitation != [NSNull null] && [invitation intValue] == 0 && ![invitation isEqualToString:@"null"]) {
            return invitation;
//        }
//    }
    
//    return YES;
}
- (BOOL)isInviteApprove
{
    
    if (self.params) {
        id invitation = self.params[@"isInviteApprove"];
        if (invitation != [NSNull null] && [invitation intValue] == 0 && ![invitation isEqualToString:@"null"]) {
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)bossTalkShowId
{
    if (self.params) {
        id bossTalkShowId = self.params[@"bosstalkshow"];
        if (bossTalkShowId != [NSNull null] && ((NSString *)bossTalkShowId).length > 0 && ![(NSString *)bossTalkShowId isEqualToString:@"null"]) {
            return bossTalkShowId;
        }
    }
    
    return nil;
}

- (NSString *)bossTalkName
{
    if (self.params) {
        id bossTalkShowName = self.params[@"bosstalkName"];
        if (bossTalkShowName != [NSNull null] && ((NSString *)bossTalkShowName).length > 0 && ![(NSString *)bossTalkShowName isEqualToString:@"null"]) {
            return bossTalkShowName;
        }
    }
    
    return ASLocalizedString(@"BOSSetting_Speak");
}

- (BOOL)supportNotMobile
{
    if (self.params) {
        id supportNotMobile = self.params[@"supportNotMobile"];
        if (supportNotMobile != [NSNull null] && [supportNotMobile integerValue] == 1 && ![supportNotMobile isEqualToString:@"null"]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)funcswitch {
    if (self.params) {
        id funcswitch = self.params[@"funcswitch"];
        if (funcswitch != [NSNull null] && ((NSString *)funcswitch).length > 0 && ![(NSString *)funcswitch isEqualToString:@"null"]) {
            return funcswitch;
        }
    }
 
    return nil;
}

- (ContactStyle)contactStyle
{
    ContactStyle style = ContactStyleShowAll;
    
    if (self.params) {
        id contactStyle = self.params[@"contactStyle"];
        if (contactStyle != [NSNull null] && ((NSString *)contactStyle).length > 0) {
            // A = ContactStyleShowAll , B = ContactStyleShowRecently
            if ([contactStyle isEqualToString:@"B"]) {
                style = ContactStyleShowRecently;
            }
        }
    }
    
    return style;
}

- (NSString *)groupManageAppId
{
    NSString *appId = self.appConfigs[@"groupManageAppID"];
    if (appId.length > 0) {
        return appId;
    }
    return @"";
}

- (NSString *)mySignAppId
{
    NSString *appId = self.appConfigs[@"mySignAppID"];
    if (appId.length > 0) {
        return appId;
    }
    return @"";
}
- (BOOL)mySignEnable
{
    id mySignEnable = self.params[@"mySignEnable"];
    if (mySignEnable != [NSNull null] && [mySignEnable intValue] == 1) {
        return YES;
    }
    return NO;
}
- (NSString *)assistantPubAccId
{
    NSString *pubAccId = self.appConfigs[@"assistantPubAccID"];
    if (pubAccId.length > 0) {
        return pubAccId;
    }
    return @"";
}

- (BOOL)autowifiEnable
{
    if (self.params) {
        id invitation = self.params[@"autowifiEnable"];
        if (invitation != [NSNull null] && [invitation integerValue] == 1 && ![invitation isEqualToString:@"null"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)photoSigninEnable
{
    return YES;
    //    if (self.params) {
    //        id invitation = self.params[@"photoSigninEnable"];
    //        if (invitation != [NSNull null] && [invitation integerValue] == 1 && ![invitation isEqualToString:@"null"]) {
    //            return YES;
    //        }
    //    }
    //    return NO;
}

- (BOOL)freeCallEnable
{
    if (self.params) {
        id invitation = self.params[@"freeCallEnable"];
        if (invitation != [NSNull null] && [invitation integerValue] == 1 && ![invitation isEqualToString:@"null"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isWPSControlOpen
{
    if (self.params)
    {
        id result = self.params[@"wpsOpenMode"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result length] == 0)
            return NO;
        
        return [result boolValue];
    }
    
    return NO;
}

- (BOOL)fileShareEnable
{
    if (self.params) {
        id invitation = self.params[@"fileShareEnable"];
        if (invitation != [NSNull null] && ![invitation isEqualToString:@"null"] && [invitation integerValue] == 1) {
            return YES;
        }
    }
    return NO;
}
//判断指定文件格式是否允许下载
- (BOOL)allowFileDownload:(NSString *)ext
{
    //图片默认支持
    if([XTFileUtils isPhotoExt:ext])
        return YES;
    
    if (self.params)
    {
        id result = self.params[@"appAllowedDownloadFileExt"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result length] == 0)
            return YES;
        if(!_extArray)
            _extArray = [result componentsSeparatedByString:@","];// retain];
        
        for (NSString *str in _extArray)
        {
            if([str isEqualToString:ext])
                return YES;
        }
        return NO;
    }
    
    return YES;
}
//A.wang 判断是否在线打开
- (BOOL)allowOpenOnline
{
    if (self.params)
    {
        id result = self.params[@"isPreview"];
        if (result != [NSNull null] && result && ![result isEqualToString:@"null"] && [result integerValue] == 1)
            return YES;
       
        return NO;
    }
    return NO;
}
//A.wang 判断是否是在线打开的格式
- (BOOL)openOnlineExt:(NSString *)ext
{
    if(_extArray)
    {
        _extArray = nil;
    }
    if(!_extArray)
        _extArray = [@"doc,docx,pdf,xlsx,ppt,xls,pptx,txt" componentsSeparatedByString:@","];
    
    for (NSString *str in _extArray)
    {
        if([str isEqualToString:ext])
            return YES;
    }
    
    return NO;
}


- (NSString *)attachViewUrlWithId:(NSString *)fileId
{
    if (self.params)
    {
        id result = self.params[@"attachViewUrl"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] ||[result length] == 0)
            return nil;
        
        return [NSString stringWithFormat:@"%@%@",result,fileId];
    }
    
    return nil;
}


- (BOOL)allowMsgInnerMobileShare
{
    if (self.params)
    {
        id result = self.params[@"limitMobileShare"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result length] == 0)
            return YES;
        
        result = [result substringToIndex:1];
        if([result integerValue] == 0 || [result integerValue] == 2)
            return YES;
        else
            return NO;
    }
    
    return YES;
}

- (BOOL)allowMsgOuterMobileShare
{
    if (self.params)
    {
        id result = self.params[@"limitMobileShare"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result length] == 0)
            return YES;
        
        result = [result substringToIndex:1];
        if([result integerValue] == 0 || [result integerValue] == 3)
            return YES;
        else
            return NO;
    }
    
    return YES;
}


- (NSInteger)canCancelMessage
{
    if (self.params)
    {
        id result = self.params[@"canCancelMsgMin"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result length] == 0)
            return -1;
        return [result intValue];
    }
    return -1;
}

- (BOOL)openGesturePassword
{
    if (self.params)
    {
        id result = self.params[@"openGesturePassword"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result isEqualToString:@"0"])
            return NO;
        else if([result isEqualToString:@"1"])
            return YES;
    }
    
    return NO;
}

- (BOOL)openWaterMark:(WaterMarkType)type;
{
    if (self.params)
    {
        id result = self.params[@"openWaterMark"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result isEqualToString:@"0"])
            return NO;
        else if([result isEqualToString:@"1"])
            return YES;
            
        
        //010三位分别对应会话、通讯录、公共号和轻应用
        NSInteger num = [result integerValue]/type;
        return (num%2 == 1);
    }
    
    return NO;
}


- (NSString *)openWorkWithID
{
    if (self.params)
    {
        id result = self.params[@"importantAppID"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result isEqualToString:@"0"])
            return nil;
        
        return result;
    }
    
    return nil;
}

- (NSString *)msgMenuAppId
{
    if (self.params)
    {
        id result = self.params[@"CustomButtonAppID"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result isEqualToString:@""])
            return nil;
        
        return result;
    }
    
    return nil;
}

- (BOOL)showPersonCount
{
    if (self.params)
    {
        id result = self.params[@"isShowPersonCount"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result isEqualToString:@"0"])
            return NO;
        
        return YES;
    }
    
    return NO;
}

- (NSString *)copyright
{
    if (self.params)
    {
        id result = self.params[@"copyright"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result isEqualToString:@""])
            return nil;
        
        return result;
    }
    
    return nil;
}

#pragma mark - get value

- (int)intValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key
{
    id value = [settingData objectForKey:key];
    if (value == [NSNull null] || ![value isKindOfClass:[NSNumber class]]) {
        return 0;
    }
    return [value intValue];
}

- (BOOL)boolValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key
{
    id value = [settingData objectForKey:key];
    if (value == [NSNull null] || ![value isKindOfClass:[NSNumber class]]) {
        return NO;
    }
    return [value boolValue];
}

- (NSString *)stringValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key
{
    id value = [settingData objectForKey:key];
    if (value == [NSNull null] || ![value isKindOfClass:[NSString class]]) {
        return [NSString string];
    }
    return value;
}

- (NSDictionary *)dictionaryValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key
{
    id value = [settingData objectForKey:key];
    if (value == [NSNull null] || ![value isKindOfClass:[NSDictionary class]]) {
        return [NSDictionary dictionary];
    }
    return value;
}

- (NSArray *)arrayValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key
{
    id value = [settingData objectForKey:key];
    if (value == [NSNull null] || ![value isKindOfClass:[NSArray class]]) {
        return [NSArray array];
    }
    return value;
}

-(NSString *)vendorID
{
    if (self.params)
    {
        id result = self.params[@"vendorid"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result isEqualToString:@"0"])
            return nil;
        
        return result;
    }
    
    return nil;
}

-(NSString *)signKey
{
    if (self.params)
    {
        id result = self.params[@"signkey"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"] || [result isEqualToString:@"0"])
            return nil;
        
        return result;
    }
    
    return nil;
}

- (NSString *)getAppstoreurl
{
    if (self.params)
    {
        id result = self.params[@"appstoreurl"];
        if (result == [NSNull null]|| !result || [result isEqualToString:@"null"])
            return nil;
        
        return result;
    }
    
    return nil;
}
- (BOOL)longConnEnable
{
    if (self.params) {
        id invitation = self.params[@"longConnEnable"];
        if (invitation != [NSNull null] && ![invitation isEqualToString:@"null"] && [invitation integerValue] == 1) {
            return YES;
        }
    }
    return NO;
}

- (void)setLongConnEnable:(BOOL)longConnEnable {
    if (self.params) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
        [params setObject:longConnEnable ? @"1" : @"0" forKey:@"longConnEnable"];
        self.params = params;
    }
}
+ (BOOL)isHTTPSOpen
{
    if(kdIsHttpsOpen == -1)
    {
        if([MCLOUD_IP_FOR_PUBACC rangeOfString:@"https://"].location == 0)
        {
            kdIsHttpsOpen = 1;
        }
        
//        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"kdweibo_conf" ofType:@"plist"];
//        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//        NSString *wbHost = [data objectForKey:@"kdweibo.pref.serverBaseURL"];
//        if([wbHost rangeOfString:@"https://"].location == 0)
//        {
//            kdIsHttpsOpen = 1;
//        }
    }
    return kdIsHttpsOpen==1;
}

+ (NSString *)getHttpsUrl:(NSString *)url
{
    NSString *resultUrl = [url copy];
    if([url rangeOfString:@"http://"].location == 0)
    {
        resultUrl = [url stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    }
    
    NSURL *uri = [NSURL URLWithString:resultUrl];
    NSNumber *port = [uri port];
    if(port)
        resultUrl = [resultUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@":%@",port] withString:@""];
    
    return resultUrl;
}

- (BOOL)sendSmsEnable
{
    if (self.params) {
        id sendSmsEnable = self.params[@"sendSmsEnable"];
        if (sendSmsEnable != [NSNull null] && ![sendSmsEnable isEqualToString:@"null"] && [sendSmsEnable integerValue] == 1) {
            return YES;
        }else
            return NO;
    }
    return NO;
}

- (BOOL)useWKWebView
{
    if (self.params) {
        id useWKWebView = self.params[@"useWKWebView"];
        if (useWKWebView == nil || [useWKWebView isEqualToString:@"null"] || [useWKWebView integerValue] == 1) {
            return YES;
        }else
            return NO;
    }
    return YES;
}


- (BOOL)classifiedDisplay
{
    if (self.params) {
        id isAppShowMode = self.params[@"ClassifiedDisplay"];
        if (isAppShowMode == nil || [isAppShowMode isEqualToString:@"null"] || [isAppShowMode integerValue] == 0) {
            return NO;
        }else
            return YES;
    }
    return YES;
}
@end
