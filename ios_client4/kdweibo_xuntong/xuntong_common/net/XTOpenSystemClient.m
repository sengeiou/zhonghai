//
//  XTOpenSystemClient.m
//  EMPNativeContainer
//
//  Created by mark on 14-2-15.
//  Copyright (c) 2014年 Kingdee.com. All rights reserved.
//

#import "XTOpenSystemClient.h"
#import "BOSConfig.h"
#import "JSON.h"
#import "NSData+Base64.h"
#import "AlgorithmHelper.h"
#import "BOSSetting.h"
#import "BOSConfig.h"

@implementation XTOpenSystemClient

-(NSDictionary *)header
{
    return @{@"appkey":@"eHVudG9uZw",@"signature":@"Ld3dK-9E7r7HKQMZ9j7m1QOp5zCYqjWKH4xupXTaFMDl2UlJzdeQVYsWhb37scAVK-NCC6wW1A9aOYYNjzoQt-yGvup5xmOBR1SsSp690FN8aX4gUwCpxiarbesQ7Z7m9UL1fi7QUWSPBvFuD4twJNi75dOAZW287UWQHijsSqo",@"update_code":@"1"};
}

-(NSDictionary *)depHeader
{
    return @{@"appkey":@"eHVudG9uZw",@"signature":@"Ld3dK-9E7r7HKQMZ9j7m1QOp5zCYqjWKH4xupXTaFMDl2UlJzdeQVYsWhb37scAVK-NCC6wW1A9aOYYNjzoQt-yGvup5xmOBR1SsSp690FN8aX4gUwCpxiarbesQ7Z7m9UL1fi7QUWSPBvFuD4twJNi75dOAZW287UWQHijsSqo",@"update_code":@"1"};
}
- (id)initWithTarget:(id)target action:(SEL)action {
	self = [super initWithTarget:target action:action];
	if (self) {
		[super setBaseUrlString:[_baseUrlString_ stringByReplacingOccurrencesOfString:@"3gol" withString:@""]];
	}
	return self;
}


- (void)loginWithCust3gNo:(NSString *)cust3gNo
                 userName:(NSString *)userName
                 password:(NSString *)password
              appClientId:(NSString *)appClientId
                 deviceId:(NSString *)deviceId
               deviceType:(NSString *)deviceType
                    token:(NSString *)token {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];

	[params setObject:[super checkNullOrNil:cust3gNo] forKey:@"eid"];
	[params setObject:[super checkNullOrNil:userName] forKey:@"userName"];
	[params setObject:[super checkNullOrNil:password] forKey:@"password"];
	[params setObject:[super checkNullOrNil:appClientId] forKey:@"appClientId"];
	[params setObject:[super checkNullOrNil:deviceId] forKey:@"deviceId"];
	[params setObject:[super checkNullOrNil:deviceType] forKey:@"deviceType"];
    [params setObject:[super checkNullOrNil:token] forKey:@"token"];
    
    NSString *languageKey = [[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage];
    if (languageKey) {
       if ([languageKey hasPrefix:@"en"]) {
            languageKey = @"en";
        }else{
            languageKey = @"zh";
        }
    }
    [params setObject:[super checkNullOrNil:languageKey] forKey:@"langKey"];
//A.wang 登录加入header
	[super post:OPENURL_LOGIN body:params header:[self header]];
}

- (void)phoneCheckWithPhone:(NSString *)phone {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:phone] forKey:@"userName"];
//	[super post:OPENURL_PHONECHECK body:params];
    if([phone containsString:@"\\"]){
        NSArray *array = [phone componentsSeparatedByString:@"\\"];
        phone = array[1];
    }
    if([phone containsString:@"@"]){
        NSArray *array = [phone componentsSeparatedByString:@"@"];
        phone = array[0];
    }
    [params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
    //引用新接口
    [super post:OPENURL_PHONECHECK_NEW body:params header:[self header]];
}

- (void)getCodeWithPhone:(NSString *)phone {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
	[super post:OPENURL_GETCODE body:params];
}

- (void)smsGetCodeWithPhone:(NSString *)phone {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
	[super post:OPENURL_SMSGETCODE body:params];
}

- (void)smsValiCheckCodeWithPhone:(NSString *)phone token:(NSString *)token {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
	[params setObject:[super checkNullOrNil:token] forKey:@"token"];
	[super post:OPENURL_SMSVALICHECKCODE body:params];
}

- (void)activeWithPhone:(NSString *)phone checkCode:(NSString *)checkCode {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
	[params setObject:[super checkNullOrNil:checkCode] forKey:@"checkCode"];
	[super post:OPENURL_ACTIVE body:params];
}

- (void)changepwdWithPhone:(NSString *)phone checkCode:(NSString *)checkCode password:(NSString *)password passwordack:(NSString *)passwordack {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
	[params setObject:[super checkNullOrNil:checkCode] forKey:@"checkCode"];
	[params setObject:[super checkNullOrNil:password] forKey:@"password"];
	[params setObject:[super checkNullOrNil:passwordack] forKey:@"passwordack"];
	[super post:OPENURL_CHANGEPWD body:params];
}

- (void)createCompanyWithEId:(NSString *)eId phone:(NSString *)phone name:(NSString *)name {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:eId] forKey:@"eid"];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
	[params setObject:[super checkNullOrNil:name] forKey:@"name"];
	[super post:OPENURL_CREATECOMPANY body:params];
}

- (void)inviteWithEId:(NSString *)eId eName:(NSString *)eName persons:(NSArray *)persons name:(NSString *)name URL:(NSString *)url {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:eId] forKey:@"eid"];
    [params setObject:[super checkNullOrNil:eName] forKey:@"eName"];
    [params setObject:[super checkNullOrNil:name] forKey:@"name"];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.openId] forKey:@"openid"];
    [params setObject:[super checkNullOrNil:url] forKey:@"inviteUrl"];
    
    NSString *p = [persons JSONFragment];
    if (persons) {
        [params setObject:p forKey:@"invite"];
    }
    [super post:OPENURL_PHONE_INVITE body:params];
}

- (void)phoneInviteWithEId:(NSString *)eId eName:(NSString *)eName persons:(NSArray *)persons name:(NSString *)name openId:(NSString *)openId URL:(NSString *)url {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:eId] forKey:@"eid"];
	[params setObject:[super checkNullOrNil:eName] forKey:@"eName"];
	[params setObject:[super checkNullOrNil:name] forKey:@"name"];
//	[params setObject:[super checkNullOrNil:openId] forKey:@"openid"];
//	[params setObject:[super checkNullOrNil:url] forKey:@"inviteUrl"];

//	NSString *p = [persons JSONFragment];
	if (persons) {
		[params setObject:persons forKey:@"invite"];
	}
	[super post:OPENURL_INVITE body:params];
}

- (void)updatePersonWithToken:(NSString *)token name:(NSString *)name {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:token] forKey:@"token"];
	[params setObject:[super checkNullOrNil:name] forKey:@"name"];
	[super post:OPENURL_UPDATEPERSON body:params];
}

- (void)elistWithToken:(NSString *)token {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:token] forKey:@"token"];
	[super post:OPENURL_ELIST body:params];
}

- (void)fetchCodeWithPhone:(NSString *)phone openId:(NSString *)openId {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
	[params setObject:[super checkNullOrNil:openId] forKey:@"openId"];
	[super post:OPENURL_FETCHCODE body:params];
}

/*
   "openaccess/user/phonebind/verifyCodeAndBind"
   "openaccess/user/phoneupdate/updatePhoneAccount"
   两个接口合并成后者

   UI改动较多，故暂只在请求处修改
 */
- (void)verifyCodeWithPhone:(NSString *)phone checkCode:(NSString *)checkCode openId:(NSString *)openId {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
	[params setObject:[super checkNullOrNil:openId] forKey:@"openId"];
	[params setObject:[super checkNullOrNil:checkCode] forKey:@"checkCode"];
	[params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];


	// [super post:OPENURL_VERIFYCODE body:params];
	[super post:OPENURL_UPDATEPHONEACCOUNT body:params];
}

- (void)updatePhoneAccountWithOpenId:(NSString *)openId
                               phone:(NSString *)phone
                           checkCode:(NSString *)checkCode {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
	[params setObject:[super checkNullOrNil:openId] forKey:@"openId"];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];
	[params setObject:[super checkNullOrNil:checkCode] forKey:@"checkCode"];
	[super post:OPENURL_UPDATEPHONEACCOUNT body:params];
}

- (void)getPhoneByOpenId:(NSString *)openId {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:openId] forKey:@"openId"];
	[params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
	[super post:OPENURL_GETPHONE body:params];
}

- (void)bindEmail:(NSString *)email secrect:(NSString *)pwd openId:(NSString *)openId {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:openId] forKey:@"openId"];
	[params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
	[params setObject:[super checkNullOrNil:email] forKey:@"email"];
	[params setObject:[super checkNullOrNil:pwd] forKey:@"password"];
	[super post:OPENURL_BINDEMAIL body:params];
}

#pragma mark - open auth

- (void)getPubAccTokenWithOpenToken:(NSString *)openToken
                           pubAccId:(NSString *)pubAccId
                           deviceId:(NSString *)deviceId
                             menuId:(NSString *)menuId
                             openId:(NSString *)openId {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:openToken] forKey:@"opentoken"];
	[params setObject:[super checkNullOrNil:pubAccId] forKey:@"pubaccid"];
	[params setObject:[super checkNullOrNil:deviceId] forKey:@"deviceid"];
	[params setObject:[super checkNullOrNil:menuId] forKey:@"menuid"];
	[params setObject:[super checkNullOrNil:openId] forKey:@"openid"];
	[super post:OPENAUTHURL_GETPUBACCTOKEN body:params];
}

- (void)getNewOAuthTokenWithOpenToken:(NSString *)openToken
                                  eid:(NSString *)eid
                                appId:(NSString *)appId {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:eid] forKey:@"eid"];
	[params setObject:[super checkNullOrNil:appId] forKey:@"appid"];
	[super post:OPENAUTHURL_GETPUBACCTOKEN2 body:params header:[NSDictionary dictionaryWithObject:openToken forKey:@"openToken"]];
}

- (void)getPersonByEid:(NSString *)eid
             andOpenId:(NSString *)openId
                 token:(NSString *)token {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:eid] forKey:@"eid"];
	[params setObject:[super checkNullOrNil:openId] forKey:@"openId"];
	[params setObject:[super checkNullOrNil:token] forKey:@"token"];
	[super post:OPENURL_GET_PERSON_BYEID_OID body:params];
}

- (void)getPersonsByOids:(NSString *)oids
                   token:(NSString *)token {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:oids] forKey:@"oids"];
	[params setObject:[super checkNullOrNil:token] forKey:@"token"];
	[super post:OPENURL_GET_PERSONS_BY_OIDS body:params];
}

- (void)getOrgByOrgID:(NSString *)orgId {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:orgId] forKey:@"orgId"];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.eid] forKey:@"eid"];
    [super post:OPENURL_GetOrgByOrgID body:params header:[self header]];
}

- (void)getPersonsByPhones:(NSString *)phones eid:(NSString *)eid token:(NSString *)token {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:phones] forKey:@"phone"];
    [params setObject:[super checkNullOrNil:eid] forKey:@"eid"];
    [params setObject:[super checkNullOrNil:token] forKey:@"token"];
    [super post:OPENURL_getPersonByPhones body:params];
}
//A.wang js桥createGroupByPhone
- (void)getPersonsByCounts:(NSArray *)counts eid:(NSString *)eid token:(NSString *)token {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableString *result = [NSMutableString stringWithString:@""];
    BOOL first = YES;
    for (int i = 0; i < counts.count; i++) {
        if (first) {
            first = NO;
        } else {
            [result appendString:@","];
        }
        [result appendString:counts[i]];
    }
    [params setObject:result forKey:@"counts"];
    [params setObject:[super checkNullOrNil:eid] forKey:@"eid"];
    [params setObject:[super checkNullOrNil:token] forKey:@"token"];
    [super post:OPENURL_getPersonByCounts body:params header:[self depHeader]];
}
//A.wang 获取设备列表
- (void)getGrantDevices:(NSString *)username {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:username] forKey:@"account"];
    [super post:OPENURL_getDeviceLists body:params header:[self depHeader]];
}
//A.wang 删除设备列表
- (void)deleteGrantDevice:(NSString *)username deviceId:(NSString *)deviceId{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:username] forKey:@"account"];
    [params setObject:[super checkNullOrNil:deviceId] forKey:@"deviceId"];
    [super post:OPENURL_deleteDevice body:params header:[self depHeader]];
}


//A.wang 获取邮箱验证码
- (void)sendEmail:(NSString *)username officePhone:(NSString *)officePhone{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:username] forKey:@"account"];
    if(![[super checkNullOrNil:officePhone] isEqualToString:@""]){
        [params setObject:[super checkNullOrNil:officePhone] forKey:@"phone"];
        
    }
    [super post:OPENURL_SendEmail body:params header:[self depHeader]];
}
//A.wang 验证验证码
- (void)verifyCheckCode:(NSString *)username verifyCode:(NSString *)verifyCode officePhone:(NSString *)officePhone{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:username] forKey:@"account"];
    if(![[super checkNullOrNil:officePhone] isEqualToString:@""]){
        [params setObject:[super checkNullOrNil:officePhone] forKey:@"phone"];
        
    }
    [params setObject:[super checkNullOrNil:verifyCode] forKey:@"verifyCode"];
    [super post:OPENURL_verifyCheckCode body:params header:[self depHeader]];
}

//A.wang 设备唤醒时间
- (void)awakeDevice:(NSString *)username openId:(NSString *)openId  eid:(NSString *)eid{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:openId] forKey:@"openId"];
    [params setObject:[super checkNullOrNil:eid] forKey:@"eid"];
     [params setObject:[super checkNullOrNil:username] forKey:@"account"];
    [super post:OPENURL_awakeDevice body:params header:[self depHeader]];
}


- (void)getPhotoUrlByOid:(NSString *)oid {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:oid] forKey:@"oid"];
	[super post:OPENURL_GET_PHOTOURL_BY_OID body:params];
}

//获取公司组织
- (void)getOrgByEid:(NSString *)eid {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:eid] forKey:@"eid"];
	[super post:OPENURL_GETORGBYEID body:params];
}

// 人员挪部门
- (void)moveOrgWithEid:(NSString *)eid
                 nonce:(NSString *)nonce
              longName:(NSString *)longName
                openId:(NSString *)openId {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:eid] forKey:@"eid"];
	[params setObject:[super checkNullOrNil:nonce] forKey:@"nonce"];

	// 方式一 返回400 格式错误
//    NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
//    [dictData setObject:[super checkNullOrNil:eid] forKey:@"eid"];
//    [dictData setObject:[super checkNullOrNil:longName] forKey:@"longName"];
//    [dictData setObject:@[@{@"openId":openId}] forKey:@"array"];
//    [params setObject:dictData forKey:@"data"];
//
	// 方式二 成功
	NSString *strCompound = [NSString stringWithFormat:@"{\"array\":[{\"openId\":\"%@\"}],\"eid\":\"%@\",\"longName\":\"%@\"}", openId, eid, longName];
	[params setObject:strCompound forKey:@"data"];

	NSLog(@"%@", params);

	[super post:OPENURL_PERSON_MOVE_ORG body:params];
}

- (void)checkIsAdmin:(NSString *)openId
                 eid:(NSString *)eid
               token:(NSString *)token {
	NSString *theOpenId = [super checkNullOrNil:openId];
	NSString *theEid = [super checkNullOrNil:eid];
	NSString *theToken = [super checkNullOrNil:token];
	NSDictionary *params = @{ @"method":@"isadmin", @"openid":theOpenId, @"eid":theEid, @"token":theToken };
	[super post:OPENURL_ADMIN_VALUE body:params];
}

- (void)getCompanyConfiguration:(NSString *)eid token:(NSString *)token {
	NSString *theEid = [super checkNullOrNil:eid];
	NSString *theToken = [super checkNullOrNil:token];
	NSDictionary *params = @{ @"method":@"getParam", @"eid":theEid, @"token":theToken };
	[super post:OPENURL_ADMIN_VALUE body:params];
}

- (void)joinToDefaultCompany:(NSString *)phone {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[super checkNullOrNil:phone] forKey:@"phone"];

	[super post:OPENURL_PERSON_JOIN_COMPANY body:params];
}

- (void)getAppConfig {
	[super post:OPENURL_GETAPPCONFIG];
}


-(void)sendAdminMessageForNotOrganization{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[[[[KDManagerContext globalManagerContext]communityManager]currentCompany]eid] forKey:@"eid"];
	[params setObject:@"1" forKey:@"type"];
    [params setObject:[super checkNullOrNil:[[[BOSConfig sharedConfig] currentUser] personName]] forKey:@"userName"];
	[super post:OPENURL_SEND_ADMIN_MESSAGE body:params];
}

//组织架构
- (void)orgTreeInfoWithOrgId:(NSString *)orgId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.eid] forKey:@"eid"];
    [params setObject:[super checkNullOrNil:orgId] forKey:@"orgId"];
    [params setObject:@"0" forKey:@"begin"];
    [params setObject:@"0" forKey:@"count"];
    [super post:OPENURL_GETORGCASVIRPERSONS body:params header:[self header]];
}



- (void)getHeaderByNetworkAndUserIdWithNetWorkId:(NSString *)networkId userId:(NSString *)userId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.eid] forKey:@"eid"];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    [super post:OPENURL_getHeaderByNetworkAndUserId body:params header:[self header]];
}

- (void)getPersonsCasvirByIds:(NSArray *)personIds
{
    NSString *ids = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:personIds options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    [params setObject:[super checkNullOrNil:ids] forKey:@"ids"];
    [super post:OPENURL_GETPERSONSCASVIRBYIDS body:params header:[self header]];
}

- (void)savePersonAttributeWithAttributeId:(NSString *)attributeId value:(NSString *)value {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    [params setObject:[super checkNullOrNil:attributeId] forKey:@"id"];
    [params setObject:[super checkNullOrNil:value] forKey:@"value"];
    
    [super post:OPENURL_savePersonAttribute body:params header:[self header]];
}

//保存我的个人联系人信息
- (void)saveMyContacts:(NSArray *)contacts {
    
    NSString *contactsStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:contacts options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    if (contacts) {
        [params setObject:contactsStr forKey:@"contact"];
    }
    [super post:OPENURL_SAVEMYCONTACTS body:params header:[self header]];
}

#pragma mark - multi voice session
- (void)joinSessionWithGroupId:(NSString *)groupid PersonId:(NSString *)personid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.eid] forKey:@"eid"];
    [params setObject:[super checkNullOrNil:groupid] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:personid] forKey:@"personId"];
    [super post:OPENURL_joinSession body:params header:[self header]];
}

- (void)quitSessionWithGroupId:(NSString *)groupid PersonId:(NSString *)personid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    [params setObject:[super checkNullOrNil:groupid] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:personid] forKey:@"personId"];
    [super post:OPENURL_quitSession body:params header:[self header]];
}

- (void)getSessionPersonsWithGroupId:(NSString *)groupid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:groupid] forKey:@"groupId"];
    [super post:OPENURL_getSessionPersons body:params header:[self header]];
}

- (void)getUidByPersonIdWithPersonIds:(NSString *)personids
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    [params setObject:[super checkNullOrNil:personids] forKey:@"personIds"];   //先把数组用JSON转成string
    [super post:OPENURL_getUidByPersonId body:params header:[self header]];
}

- (void)getPersonIdByUidWithUids:(NSString *)uids;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    [params setObject:[super checkNullOrNil:uids] forKey:@"uids"];   //先把数组用JSON转成string
    [super post:OPENURL_getPersonIdByUid body:params header:[self header]];
}

-(void)changeLanguage:(NSString *)key
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:[BOSSetting sharedSetting].userName] forKey:@"userName"];
    [params setObject:[super checkNullOrNil:key] forKey:@"langKey"];
    [super post:OPENURL_CHANGELANGUAGE body:params];
}

//保存phone1\phone2\email\birthday
- (void)saveOfficeWithName:(NSString *)name AndValue:(NSString *)value
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    [params setObject:value forKey:name];
    [super post:OPENURL_SAVEOFFICEPROPERTIES body:params header:[self header]];
}


-(void)getYunAppSecrect:(NSString *)appId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //[params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.token] forKey:@"token"];
    [params setObject:appId forKey:@"appid"];
    [super setBaseUrlString:[[BOSSetting sharedSetting] getAppstoreurl]];
    [super post:@"/lightapp-store/rest/getAppSecret" body:params header:[self header]];
}

- (void)getAdminEid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:[BOSConfig sharedConfig].user.wbNetworkId] forKey:@"eid"];
    [super post:OPENURL_getAdminByEid body:params header:[self header]];
}

// 通过旧密码修改密码接口
- (void)changePasswordWithAccount:(NSString *)strAccount
                      oldPassword:(NSString *)strOldPassword
                      newPassword:(NSString *)strNewPassword
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:strAccount] forKey:@"account"];
    [params setObject:[super checkNullOrNil:strOldPassword] forKey:@"oldPassword"];
    [params setObject:[super checkNullOrNil:strNewPassword] forKey:@"newPassword"];
    [super post:OPENURL_CHANGE_PASSWORD_WITH_OLD_PASSWORD body:params header:[self header]];
    
}

@end
