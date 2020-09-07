//
//  MFClient.m
//  MobileFamily
//
//  Created by kingdee eas on 13-5-15.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//
#define GETLIST @"/ecLite/convers/pubacct/publicAccountList.action"
#define GETORDER @"/ecLite/convers/pubacct/subscribePublicAccount.action"
#define GETPUBLICACCOUNT @"/ecLite/convers/pubacct/publicAccountInfo.action"
#define GETPUBLICACCOUNTS @"/ecLite/convers/pubacct/publicAccountsInfo.action"


//获取应用的接口  0为应用中心   1为推荐应用
#define KD_App_Action_Acquire @"/appRecommendXT2.action"
#define KD_App_Type_All  @"0"
#define KD_App_Type_Recommend @"1"
//搜索应用的接口
#define KD_App_Action_Search @"/appsXT2.action"

// 微信社区帐号信息
#define sdkAccount @"/sdkAccount.action"


#import "AppsClient.h"
#import "UIDevice+Additions.h"
#import "BOSSetting.h"
#import "BOSConfig.h"

@implementation AppsClient

- (NSDictionary *)wfHeader {
	NSString *openToken = [BOSConfig sharedConfig].user.token;
	if (!openToken) {
		openToken = @"";
	}
	return [NSDictionary dictionaryWithObject:openToken forKey:@"openToken"];
}

- (void)getApps {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
	[params setObject:[[BOSSetting sharedSetting] cust3gNo] forKey:@"mID"];
	[params setObject:@"10200" forKey:@"appClientId"];
	[params setObject:@"102" forKey:@"appId"];
	[params setObject:[[BOSSetting sharedSetting] userName] forKey:@"userName"];
	[params setObject:[UIDevice uniqueDeviceIdentifier] forKey:@"deviceId"];
	[params setObject:[[BOSConfig sharedConfig] instanceName] forKey:@"instanceName"];
	[params setObject:@"1" forKey:@"platform"];
	[super post:@"/portal/appsXT.action" body:params header:[self wfHeader]];
}

- (void)getHotApps:(NSString *)type {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
	[params setObject:[[BOSSetting sharedSetting] cust3gNo] forKey:@"mID"];
	[params setObject:@"10200" forKey:@"appClientId"];
	[params setObject:@"102" forKey:@"appId"];
	[params setObject:[[BOSSetting sharedSetting] userName] forKey:@"userName"];
	[params setObject:[UIDevice uniqueDeviceIdentifier] forKey:@"deviceId"];
	[params setObject:[[BOSConfig sharedConfig] instanceName] forKey:@"instanceName"];
	[params setObject:@"1" forKey:@"platform"];
	[params setObject:type forKey:@"type"];
	[super post:@"/portal/hotApps.action" body:params header:[self wfHeader]];
}

- (void)getPublicList {
	NSString *url = [NSString stringWithFormat:@"%@", [BOSSetting sharedSetting].url];
	[self setBaseUrlString:url];
	[super post:GETLIST body:nil header:[self wfHeader]];
}

- (void)getPublicListWithPublicIds:(NSArray *)publicIds {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:publicIds forKey:@"ids"];
    
	NSString *url = [NSString stringWithFormat:@"%@", [BOSSetting sharedSetting].url];
    
	[self setBaseUrlString:url];
	[super post:GETPUBLICACCOUNTS body:params header:[self wfHeader]];
}

- (void)attention:(NSString *)ID withdata:(NSString *)data {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
	[params setObject:[super checkNullOrNil:ID] forKey:@"id"];
	[params setObject:[NSString stringWithFormat:@"%d", data.intValue] forKey:@"data"];
	NSString *url = [NSString stringWithFormat:@"%@", [BOSSetting sharedSetting].url];
	[self setBaseUrlString:url];
	[super post:GETORDER body:params header:[self wfHeader]];
}

- (void)getPublicAccount:(NSString *)ID {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	[params setObject:[super checkNullOrNil:ID] forKey:@"id"];
	NSString *url = [NSString stringWithFormat:@"%@", [BOSSetting sharedSetting].url];
	[self setBaseUrlString:url];
	[super post:GETPUBLICACCOUNT body:params header:[self wfHeader]];
}

#pragma mark -
#pragma Apps Request Methods
/**
 *  获取推荐应用列表数据
 */
- (void)getRecommendApps {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
	[params setObject:KD_App_Type_Recommend forKey:@"type"];
	[params setObject:[super checkNullOrNil:[BOSSetting sharedSetting].cust3gNo] forKey:@"mID"];
	[params setObject:[super checkNullOrNil:[BOSSetting sharedSetting].userName] forKey:@"userName"];
	[super post:KD_App_Action_Acquire body:params];
}

/**
 *  获取应用中心的应用数据
 */
- (void)getAllApps {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
	[params setObject:KD_App_Type_All forKey:@"type"];
	[params setObject:[super checkNullOrNil:[BOSSetting sharedSetting].cust3gNo] forKey:@"mID"];
	[params setObject:[super checkNullOrNil:[BOSSetting sharedSetting].userName] forKey:@"userName"];
	[super post:KD_App_Action_Acquire body:params];
}

/**
 *  搜索应用
 *
 *  @param string 搜索的关键字
 *
 */
- (void)searchAppsWithKey:(NSString *)key {
	if (key == nil || [key length] == 0) {
		return;
	}
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
	[params setObject:[super checkNullOrNil:[BOSSetting sharedSetting].cust3gNo] forKey:@"mID"];
	[params setObject:[super checkNullOrNil:[BOSSetting sharedSetting].userName] forKey:@"userName"];
	[params setObject:[super checkNullOrNil:key] forKey:@"key"];
	[super post:KD_App_Action_Search body:params];
}


-(void)postOneApp:(KDAppDataModel *)app {
    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    
    //openId
    [myDic setObject:[BOSConfig sharedConfig].user.userId forKey:@"personId"];
    
    //type & appIds
    if (app.appType == KDAppTypeLight)
    {
        [myDic setObject:[NSString stringWithFormat:@"%@", app.appID] forKey:@"appIds"];
    }
    else if (app.appType == KDAppTypePublic)
    {
        [myDic setObject:[NSString stringWithFormat:@"%@", app.pid] forKey:@"appIds"];
    }
    else if (app.appType == KDAppTypeNativeKingdee)
    {
        [myDic setObject:[NSString stringWithFormat:@"%@", app.appID] forKey:@"appIds"];
    }else if(app.appType == KDAppTypeNativeThirdPart){
        [myDic setObject:[NSString stringWithFormat:@"%@", app.appID] forKey:@"appIds"];
    }
    else if (app.appType == KDAppTypeSpecial)
    {
        [myDic setObject:[NSString stringWithFormat:@"%@", app.appID] forKey:@"appIds"];
    }
    
    //deviceID
    [myDic setObject:[UIDevice uniqueDeviceIdentifier] forKey:@"deviceId"];
    
    [super post:@"/addAppToUser.action" body:myDic];
}

-(void)postCloudApp:(KDAppDataModel *)app {
    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    
    //openId
    [myDic setObject:[BOSConfig sharedConfig].user.userId forKey:@"personId"];
    
    //type & appIds
    if (app.appType == KDAppTypeLight)
    {
        [myDic setObject:[NSString stringWithFormat:@"%@", app.appID] forKey:@"appIds"];
    }
    else if (app.appType == KDAppTypePublic)
    {
        [myDic setObject:[NSString stringWithFormat:@"%@", app.pid] forKey:@"appIds"];
    }
    else if (app.appType == KDAppTypeNativeKingdee)
    {
        [myDic setObject:[NSString stringWithFormat:@"%@", app.appID] forKey:@"appIds"];
    }else if(app.appType == KDAppTypeNativeThirdPart){
        [myDic setObject:[NSString stringWithFormat:@"%@", app.appID] forKey:@"appIds"];
    }
    else if (app.appType == KDAppTypeSpecial)
    {
        [myDic setObject:[NSString stringWithFormat:@"%@", app.appID] forKey:@"appIds"];
    }
    
    //deviceID
    [myDic setObject:[UIDevice uniqueDeviceIdentifier] forKey:@"deviceId"];
    
    //新参数
    [myDic setObject:app.appID forKey:@"appId"];
    [myDic setObject:app.appName forKey:@"appName"];
    [myDic setObject:app.appLogo forKey:@"appIcoUri"];
    [myDic setObject:app.downloadURL forKey:@"appAdress"];
    [myDic setObject:[BOSSetting sharedSetting].cust3gNo forKey:@"f3gNo"];
    [myDic setObject:app.appSecret forKey:@"appSecret"];
    [super post:@"/addYunAppToUser.action" body:myDic];
}

-(void)postAllLocalApps:(NSString *)apps {
    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    
    //openId
    [myDic setObject:[BOSConfig sharedConfig].user.userId forKey:@"personId"];
    
    //type & appIds
    [myDic setObject:apps forKey:@"appIds"];
    
    //deviceID
    [myDic setObject:[UIDevice uniqueDeviceIdentifier] forKey:@"deviceId"];
    
    [super post:@"/addAppToUser.action" body:myDic];
}

-(void)deleteOneApp:(KDAppDataModel *)app {
    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    
    //openId
    [myDic setObject:[BOSConfig sharedConfig].user.userId forKey:@"personId"];
    
    //type & appIds
    if (app.appClientID != nil) {
        NSInteger appIdFromappClientId = [app.appClientID integerValue] / 100;
        [myDic setObject:[NSString stringWithFormat:@"%zi", appIdFromappClientId] forKey:@"appIds"];
    }
    
    if (app.pid != nil) {
        [myDic setObject:[NSString stringWithFormat:@"%@", app.pid] forKey:@"appIds"];
    }
    
    //deviceID
    [myDic setObject:[UIDevice uniqueDeviceIdentifier] forKey:@"deviceId"];
    
    if(app.appType == KDAppTypeYunApp)
        [myDic setObject:@"1" forKey:@"isyunapp"];
        
    
    [super post:@"/delAppFromUser.action" body:myDic];
}

-(void)deleteFromNSUserDefaultWithApps:(NSString *)apps {
    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    
    //openId
    [myDic setObject:[BOSConfig sharedConfig].user.userId forKey:@"personId"];
    
    //type & appIds
    [myDic setObject:apps forKey:@"appIds"];
    
    //deviceID
    [myDic setObject:[UIDevice uniqueDeviceIdentifier] forKey:@"deviceId"];
    
    [super post:@"/delAppFromUser.action" body:myDic];
}

-(void)queryAppList {
    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    
    //openId
    [myDic setObject:[BOSConfig sharedConfig].user.userId forKey:@"personId"];
    
    //mId
    [myDic setObject:[BOSConfig sharedConfig].user.eid forKey:@"mID"];
    
    [super post:@"/queryUserAppList.action" body:myDic];
    
}
-(void)makeNoteWhenAppClickedWithMid:(NSString *)mid Appid:(NSString *)appid PersonId:(NSString *)personId
{
    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    
    //mId
    [myDic setObject:[BOSConfig sharedConfig].user.eid forKey:@"mid"];
    
    //personId
    [myDic setObject:[BOSConfig sharedConfig].user.userId forKey:@"personid"];
    
    //appId
    [myDic setObject:appid forKey:@"appid"];
    
    [super post:@"3gol/operateAppLog.action" body:myDic];
}

-(void)queryQrcodeInfo:(NSString *)url
{
    [self setBaseUrlString:@""];
    [super get:url];
}

- (void)getBuluoAccountWithEid:(NSString *)eid Oid:(NSString *)oid {
    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    [myDic setObject:safeString(eid) forKey:@"eid"];
    [myDic setObject:safeString(oid) forKey:@"oid"];
    
    [super post:sdkAccount body:myDic];
}

-(void)sortAppListWithAppIds:(NSArray *)appIds
{
    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    
    //mId
    [myDic setObject:[BOSConfig sharedConfig].user.eid forKey:@"mID"];
    
    //personId
    [myDic setObject:[BOSConfig sharedConfig].user.userId forKey:@"personId"];
    
    //appId
    [myDic setObject:appIds forKey:@"sortAppIds"];
    
    [super post:@"/sortUserAppAction.action" body:myDic];
}

@end
