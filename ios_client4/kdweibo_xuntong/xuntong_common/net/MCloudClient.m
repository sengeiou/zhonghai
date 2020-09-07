//
//  MCloudClient.m
//  Public
//
//  Created by Gil on 12-4-27.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "MCloudClient.h"
#import "URL+MCloud.h"

@implementation MCloudClient

static NSString *mcloudBaseUrlString = nil;

+ (BOOL)connectedByDomain
{
    return [mcloudBaseUrlString isEqualToString:MCLOUD_DOMAIN_URL];
}

+ (NSString *)mcloudBaseUrl
{
    return mcloudBaseUrlString == nil ? MCLOUD_DEFAULT_URL : mcloudBaseUrlString;
}

- (BOOL)connectedByIP
{
    return ![self connectedByDomain];
}

- (BOOL)connectedByDomain
{
    return [mcloudBaseUrlString isEqualToString:MCLOUD_DOMAIN_URL];
}

- (BOOL)connectedHostError
{
    if (self.errorCode == 0) {
        return NO;
    }
    
    if (self.errorCode == ASIConnectionFailureErrorType || self.errorCode == ASIRequestTimedOutErrorType) {
        if ([[KDReachabilityManager sharedManager] isReachable]) {
            return YES;
        }
    }
    
    return NO;
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    BOSConnectFlags connectFlags = {BOSConnect4DirectURL,BOSConnectNotEncryption,BOSConnectResponseAllowCompressed,BOSConnectRequestBodyNotCompressed,NO};
    self = [super initWithTarget:target action:action connectionFlags:connectFlags];
    if (self) {
        //用来输入测试地址
        NSString *xturl = [[NSUserDefaults standardUserDefaults] objectForKey:@"xt_preference_ip"];
        if ([xturl length]>0) {
            mcloudBaseUrlString = [[NSString alloc] initWithFormat:@"http://%@/3gol",xturl];
        }
        if (mcloudBaseUrlString == nil) {
            [super setBaseUrlString:MCLOUD_DEFAULT_URL];
        } else {
            [super setBaseUrlString:mcloudBaseUrlString];
        }
    }
    return self;
}

- (void)performWithErrorCode:(int)errorCode objcet:(id)object
{
    if (mcloudBaseUrlString == nil) {
    
        if ([[KDReachabilityManager sharedManager]isReachable]) {
            
            if (errorCode == ASIConnectionFailureErrorType || errorCode == ASIRequestTimedOutErrorType) {
                mcloudBaseUrlString = [MCLOUD_DOMAIN_URL copy];
            } else {
                mcloudBaseUrlString = [MCLOUD_IP_URL copy];
            }
            
        }
    }
    
    [super performWithErrorCode:errorCode objcet:object];
}

#pragma mark - since 2.0
- (void)getAppParamsWithCust3gNo:(NSString *)cust3gNo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"mID"];
    [params setObject:[super checkNullOrNil:[UIDevice uniqueDeviceIdentifier]] forKey:@"deviceId"];
    [super post:MCLOUDURL_APPPARAMS body:params header:nil];
}
-(void)authWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"cust3gNo"];
    [params setObject:[super checkNullOrNil:userName] forKey:@"userName"];
    [params setObject:[super checkNullOrNil:[UIDevice uniqueDeviceIdentifier]] forKey:@"deviceId"];
    [super post:MCLOUDURL_AUTH body:params header:nil];
}

-(void)bindLicenceWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName opToken:(NSString *)opToken validateToken:(NSString *)validateToken
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"cust3gNo"];
    [params setObject:[super checkNullOrNil:[UIDevice uniqueDeviceIdentifier]] forKey:@"deviceId"];
    [params setObject:[super checkNullOrNil:userName] forKey:@"userName"];
    [params setObject:[super checkNullOrNil:opToken] forKey:@"opToken"];
    NSString *token = [super checkNullOrNil:validateToken];
    if (token.length > 0) {
        [params setObject:[super checkNullOrNil:validateToken] forKey:@"validateToken"];
    }
    [super post:MCLOUDURL_BINDLICENCE body:params];
}

-(void)bindUserDeviceWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName policy:(BindUserDevicePolicy)policy
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"cust3gNo"];
    [params setObject:[super checkNullOrNil:[UIDevice uniqueDeviceIdentifier]] forKey:@"deviceId"];
    [params setObject:[super checkNullOrNil:userName] forKey:@"userName"];
    if (policy > 3) {
        policy = BindUserDevicePolicyRemove;
    }
    [params setObject:[NSString stringWithFormat:@"%d",policy] forKey:@"policy"];
    [super post:MCLOUDURL_BINDUSERDEVICE body:params];
}

-(void)instructionsWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"cust3gNo"];
    [params setObject:[super checkNullOrNil:[UIDevice uniqueDeviceIdentifier]] forKey:@"deviceId"];
    [params setObject:[super checkNullOrNil:userName] forKey:@"userName"];
    [super post:MCLOUDURL_INSTRUCTIONS body:params];
}

-(void)checkVersion
{
    [super post:MCLOUDURL_CHECKVERSION];
}

-(void)customerSearchWithWord:(NSString *)word
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:word] forKey:@"word"];
    [super post:MCLOUDURL_CUSTOMERSEARCH body:params];
}

-(void)signtosWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"cust3gNo"];
    [params setObject:[super checkNullOrNil:userName] forKey:@"userName"];
    [super post:MCLOUDURL_SIGNTOS body:params];
}

-(void)deviceLicenceApplyWithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName memo:(NSString *)memo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"cust3gNo"];
    [params setObject:[super checkNullOrNil:userName] forKey:@"userName"];
    [params setObject:[super checkNullOrNil:[UIDevice uniqueDeviceIdentifier]] forKey:@"deviceId"];
    [params setObject:[super checkNullOrNil:memo] forKey:@"memo"];
    [super post:MCLOUDURL_DEVICELICENCEAPPLY body:params];
}

-(void)customerLogoDownloadWithCust3gNo:(NSString *)cust3gNo lastUpdateTime:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"cust3gNo"];
    [params setObject:[super checkNullOrNil:lastUpdateTime] forKey:@"lastUpdateTime"];
    [super post:MCLOUDURL_CUSTOMERLOGODOWNLOAD body:params];
}

#pragma mark - since 3.0

-(void)customerPublicKeyWithCust3gNo:(NSString *)cust3gNo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"cust3gNo"];
    [super post:MCLOUDURL_CUSTOMERPUBLICKEY body:params];
}

-(void)demoAccount
{
    [super post:MCLOUDURL_DEMOACCOUNT];
}

-(void)appInfo
{
    [super post:MCLOUDURL_APPINFO body:nil];
}

-(void)appRecommendationsWithType:(int)type begin:(int)begin count:(int)count
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[NSString stringWithFormat:@"%d",type] forKey:@"type"];
    [params setObject:[NSString stringWithFormat:@"%d",begin] forKey:@"begin"];
    [params setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [super post:MCLOUDURL_APPRECOMMENDATIONS body:params];
}

-(void)appRecommendWithType:(int)type cust3g:(NSString *)cust3gNo userName:(NSString *)userName searchKey:(NSString *)searchKey
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[NSString stringWithFormat:@"%d",type] forKey:@"type"];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"mID"];
    [params setObject:[super checkNullOrNil:userName] forKey:@"userName"];
    [params setObject:[super checkNullOrNil:searchKey] forKey:@"key"];
    [super post:XT_APP_Recommend body:params];
}

-(void)appDefaultCust3g:(NSString *)cust3gNo userName:(NSString *)userName
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"mID"];
    [params setObject:[super checkNullOrNil:userName] forKey:@"userName"];
    
    [super post:XT_APP_Tab body:params];
}

-(void)evaluationswithCust3gNo:(NSString *)cust3gNo userName:(NSString *)userName
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:cust3gNo] forKey:@"cust3gNo"];
    [params setObject:[super checkNullOrNil:userName] forKey:@"userName"];
    [params setObject:[super checkNullOrNil:[UIDevice uniqueDeviceIdentifier]] forKey:@"deviceId"];
    [super post:MCLOUDURL_EVALUATION body:params header:nil timeout:5];
}

- (void)registerWithCustName:(NSString *)custName phone:(NSString *)phone name:(NSString *)name
{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
	[params setObject:[super checkNullOrNil:custName] forKey:@"custName"];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
	[params setObject:[super checkNullOrNil:name] forKey:@"name"];
	[super post:MCLOUDURL_REGISTER body:params header:nil];
}

- (void)getLightAppURLWithMid:(NSString *)mid appid:(NSString *)appid openToken:(NSString *)openToken groupId:(NSString *)groupId userId:(NSString *)userId msgId:(NSString *)msgId urlParam:(NSString *)urlParam todoStatus:(NSString *)todoStatus
{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
	[params setObject:[super checkNullOrNil:mid] forKey:@"mid"];
	[params setObject:[super checkNullOrNil:appid] forKey:@"appid"];
	[params setObject:[super checkNullOrNil:openToken] forKey:@"openToken"];
    if (groupId.length > 0) {
        [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    }
    if (userId.length > 0) {
        [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    }
    if (msgId.length > 0) {
        [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
    }
    if (todoStatus.length > 0) {
        [params setObject:[super checkNullOrNil:todoStatus] forKey:@"todoStatus"];
    }
	[params setObject:[super checkNullOrNil:urlParam] forKey:@"urlParam"];
	[super post:MCLOUDURL_GETLIGHTAPPURL body:params header:nil];
}

- (void)getYunAppURLWithMid:(NSString *)mid appid:(NSString *)appid openToken:(NSString *)openToken urlParam:(NSString *)urlParam
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:mid] forKey:@"mid"];
    [params setObject:[super checkNullOrNil:appid] forKey:@"appid"];
    [params setObject:[super checkNullOrNil:openToken] forKey:@"openToken"];
    [params setObject:[super checkNullOrNil:urlParam] forKey:@"urlParam"];
    [params setObject:[NSString stringWithFormat:@"%zi",KDAppTypeYunApp] forKey:@"type"];
    [super post:MCLOUDURL_GETLIGHTAPPURL body:params header:nil];
}

- (void)getLightAppParamWithMid:(NSString *)mid appids:(NSString *)appids openToken:(NSString *)openToken urlParam:(NSString *)urlParam
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:mid] forKey:@"mid"];
    [params setObject:[super checkNullOrNil:appids] forKey:@"appids"];
    [params setObject:[super checkNullOrNil:openToken] forKey:@"openToken"];
    [params setObject:[super checkNullOrNil:urlParam] forKey:@"urlParam"];
    [params setObject:[BOSConfig sharedConfig].currentUser.personId forKey:@"personId"];
    [super post:MCLOUDURL_GETLIGHTAPPPARAMURL body:params header:nil];
}

- (void)getDefineLightAppsWithMid:(NSString *)mid appids:(NSString *)appids openToken:(NSString *)openToken urlParam:(NSString *)urlParam {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:mid] forKey:@"mid"];
    [params setObject:[super checkNullOrNil:appids] forKey:@"appids"];
    [params setObject:[super checkNullOrNil:openToken] forKey:@"openToken"];
    [params setObject:[super checkNullOrNil:urlParam] forKey:@"urlParam"];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.userId] forKey:@"personId"];
    [super post:MCLOUDURL_GETDEFINELIGHTAPPSURL body:params header:nil];
}

@end
