//
//  XTOpenSystemClient.h
//  EMPNativeContainer
//
//  Created by mark on 14-2-15.
//  Copyright (c) 2014年 Kingdee.com. All rights reserved.
//

#import "MCloudClient.h"


#define OPENURL_GETCHANGEDADDRESS @"openaccess/contacts/getChangedAddress"

#define OPENURL_LOGIN               @"openaccess/user/login"

#define OPENURL_PHONECHECK          @"openaccess/user/phonecheck"
#define OPENURL_PHONECHECK_NEW       @"openaccess/user/phonecheck_new"
#define OPENURL_GETCODE             @"openaccess/user/phonegetcode"
#define OPENURL_ACTIVE              @"openaccess/user/phoneactive"
#define OPENURL_CHANGEPWD           @"openaccess/user/phonechangepwd"
#define OPENURL_CREATECOMPANY       @"openaccess/user/phonecreatecompany"
#define OPENURL_INVITE              @"openaccess/user/phoneinvite"

#define OPENURL_FETCHCODE           @"openaccess/user/phonebind/fetchcode"
#define OPENURL_VERIFYCODE          @"openaccess/user/phonebind/verifyCodeAndBind"
#define OPENURL_UPDATEPHONEACCOUNT  @"openaccess/user/phoneupdate/updatePhoneAccount"


#define OPENURL_UPDATEPERSON        @"openaccess/user/phoneupdateperson"
#define OPENURL_ELIST               @"openaccess/user/elist"
#define OPENURL_GETPHONE            @"openaccess/user/getPhoneByOpenId"
#define OPENURL_BINDEMAIL           @"openaccess/user/bindemail"

#define OPENAUTHURL_GETPUBACCTOKEN  @"openauth/getpubacctoken"
#define OPENAUTHURL_GETPUBACCTOKEN2 @"openauth2/api/createcontext"

#define OPENURL_GET_PERSON_BYEID_OID    @"openaccess/user/getPersonByEidAndOpenIdForMobile"
#define OPENURL_GET_PERSONS_BY_OIDS     @"openaccess/user/getPersonsByOids"
#define OPENURL_GET_PHOTOURL_BY_OID     @"openaccess/person/getPhotoUrlByOid"

#define OPENURL_GETORGBYEID    @"openaccess/org/getorgbyeid"
//根据部门id获取子部门
#define OPENURL_GetOrgByOrgID  @"openaccess/org/getorgbyorgid"

#define OPENURL_SMSGETCODE          @"openaccess/user/getcode"
#define OPENURL_SMSVALICHECKCODE    @"openaccess/user/valicheckcode"

#define OPENURL_PERSON_MOVE_ORG   @"openaccess/person/moveorg"
#define OPENURL_PERSON_JOIN_COMPANY   @"openaccess/person/joindefaultcompany"

#define OPENURL_ADMIN_VALUE       @"openaccess/getAdminValue"

#define OPENURL_PHONE_INVITE         @"openaccess/person/mobileinvite"

#define OPENURL_GETAPPCONFIG         @"openaccess/getAppConfig"

#define OPENURL_SEND_ADMIN_MESSAGE        @"openaccess/sendAdminMessage"

#define OPENURL_GETORGCASVIRPERSONS        @"openaccess/contacts/getOrgCasvirPersons"//获取组织树信息

// 获取部门负责人
#define OPENURL_getHeaderByNetworkAndUserId         @"openaccess/user/getHeaderByNetworkAndUserId"

#define OPENURL_GETPERSONSCASVIRBYIDS               @"openaccess/contacts/getPersonsCasvirByIds"
#define OPENURL_savePersonAttribute @"openaccess/contacts/savePersonAttribute" //修改自定义字段的值
#define OPENURL_SAVEMYCONTACTS                      @"openaccess/contacts/savemycontacts"
#define OPENURL_SAVEOFFICEPROPERTIES                @"openaccess/contacts/savePersonProperties"
//多人语音会话
#define OPENURL_joinSession                         @"openaccess/contacts/joinSession"
#define OPENURL_quitSession                         @"openaccess/contacts/quitSession"
#define OPENURL_getSessionPersons                   @"openaccess/contacts/getSessionPersons"
#define OPENURL_getUidByPersonId                    @"openaccess/contacts/getUidByPersonId"
#define OPENURL_getPersonIdByUid                    @"openaccess/contacts/getPersonIdByUid"

#define OPENURL_CHANGELANGUAGE                      @"openaccess/rest/lanage/resetResource"
//#define OPENURL_GETORGCASVIRPERSONS                 @"openaccess/contacts/getClientOrgCasvirPersons"

// 获取当前工作圈管理员openId
#define OPENURL_getAdminByEid                     @"openaccess/newrest/getAdminByEid"

// 通过旧密码修改密码接口
#define OPENURL_CHANGE_PASSWORD_WITH_OLD_PASSWORD @"openaccess/newrest/changePasswordWithOldPassword"

#define OPENURL_getPersonByPhones @"openaccess/user/getPersonByPhonesAndEid"

//A.wang js桥createGroupByPhone
#define OPENURL_getPersonByCounts @"openaccess/user/getPersonByAccounts"
//A.wang 获取设备列表
#define OPENURL_getDeviceLists @"openaccess/user/grantDevices.json"
//A.wang 删除设备列表
#define OPENURL_deleteDevice @"openaccess/user/deleteGrantDevice.json"

//A.wang 获取邮箱验证码
#define OPENURL_SendEmail @"openaccess/user/sendEmail.json"
//A.wang 验证验证码
#define OPENURL_verifyCheckCode @"openaccess/user/verifyCheckCode.json"
//A.wang 设备唤醒时间
#define OPENURL_awakeDevice @"openaccess/user/awake.json"


static NSInteger const kAccountActivatedCode = 2050;
static NSInteger const kAccountNotActivatedCode = 2052;
static NSInteger const kAccountNotExistedCode = 2051;
static NSInteger const kCompanyMutilCode = 2024;
static NSInteger const kCompanyNotFoundCode = 2025;
static NSInteger const kAccountNotPhoneCodeActivated = 20410;
static NSInteger const kAccountNotPhoneCodePhone = 20411; //非手机号码支持-手机号码
static NSInteger const kAccountNotPhoneCodeEmail = 20412; //非手机号码支持-邮箱
//A.wang 非信任设备短信二次验证
static NSInteger const kAccountNotPhoneCodeverify = 2030; //非信任设备短信二次验证

static NSInteger const kWrongPassword = 1004;
static NSString *const kCompanyMutilNotification = @"CompanyMutilNotification";
static NSString *const kCompanyNotFoundNotification = @"CompanyNotFoundNotification";

@interface XTOpenSystemClient : MCloudClient

//登录认证
-(void)loginWithCust3gNo:(NSString *)cust3gNo
                userName:(NSString *)userName
                password:(NSString*)password
             appClientId:(NSString*)appClientId
                deviceId:(NSString*)deviceId
              deviceType:(NSString*)deviceType
                   token:(NSString *)token;

//手机号校验
- (void)phoneCheckWithPhone:(NSString *)phone;

//获取验证码
- (void)getCodeWithPhone:(NSString *)phone;

//验证码激活
- (void)activeWithPhone:(NSString *)phone
              checkCode:(NSString *)checkCode;

//短信验证设置密码
- (void)changepwdWithPhone:(NSString *)phone
                 checkCode:(NSString *)checkCode
                  password:(NSString *)password
               passwordack:(NSString *)passwordack;

//短信上行, 接受短信验证
- (void)smsGetCodeWithPhone:(NSString *)phone;
//短信上行, 校验验证码,轮询
- (void)smsValiCheckCodeWithPhone:(NSString *)phone token:(NSString *)token;



- (void)createCompanyWithEId:(NSString *)eId phone:(NSString *)phone name:(NSString *)name;

//persons = [phone1:name1,phone2:name2,...] name可以为空
//eId ＝ [BOSSetting sharedSetting].cust3gNo
- (void)inviteWithEId:(NSString *)eId
                eName:(NSString *)eName
              persons:(NSArray *)persons
                 name:(NSString *)name
                  URL:(NSString *)url;

- (void)updatePersonWithToken:(NSString *)token name:(NSString *)name;
- (void)elistWithToken:(NSString *)token;
- (void)getPhoneByOpenId:(NSString *)openId;

- (void)bindEmail:(NSString *)email secrect:(NSString *)pwd openId:(NSString *)openId;
- (void)verifyCodeWithPhone:(NSString *)phone checkCode:(NSString *)checkCode openId:(NSString *)openId;
- (void)fetchCodeWithPhone:(NSString *)phone openId:(NSString *)openId;
// 修改手机账号
- (void)updatePhoneAccountWithOpenId:(NSString *)openId
                               phone:(NSString *)phone
                           checkCode:(NSString *)checkCode;
//
- (void)phoneInviteWithEId:(NSString *)eId
                     eName:(NSString *)eName
                   persons:(NSArray *)persons
                      name:(NSString *)name
                    openId:(NSString *)openId
                       URL:(NSString *)url;

#pragma mark - open auth

- (void)getPubAccTokenWithOpenToken:(NSString *)openToken
                           pubAccId:(NSString *)pubAccId
                           deviceId:(NSString *)deviceId
                             menuId:(NSString *)menuId
                             openId:(NSString *)openId;

//已废弃，不再使用，用getLightAppURLWithMid替换
- (void)getNewOAuthTokenWithOpenToken:(NSString *)openToken
                                  eid:(NSString *)eid
                                appId:(NSString *)appId;

- (void)getPersonByEid:(NSString *)eid
             andOpenId:(NSString *)openId
                 token:(NSString *)token;

- (void)getPersonsByOids:(NSString *)oids
                   token:(NSString *)token;

///获取子部门
- (void)getOrgByOrgID:(NSString *)orgId;

- (void)getPersonsByPhones:(NSString *)phones
                       eid:(NSString *)eid
                     token:(NSString *)token;

//A.wang js桥createGroupByPhone
- (void)getPersonsByCounts:(NSArray *)counts eid:(NSString *)eid token:(NSString *)token;
//A.wang 删除设备列表
- (void)deleteGrantDevice:(NSString *)username deviceId:(NSString *)deviceId;
//A.wang 获取设备列表
- (void)getGrantDevices:(NSString *)username ;
//A.wang 获取邮箱验证码
- (void)sendEmail:(NSString *)username officePhone:(NSString *)officePhone;
//A.wang 验证验证码
- (void)verifyCheckCode:(NSString *)username verifyCode:(NSString *)verifyCode officePhone:(NSString *)officePhone;

//A.wang 设备唤醒时间
- (void)awakeDevice:(NSString *)username openId:(NSString *)openId  eid:(NSString *)eid;



- (void)getPhotoUrlByOid:(NSString *)oid;


//获取公司组织
- (void)getOrgByEid:(NSString *)eid;


// 人员挪部门
- (void)moveOrgWithEid:(NSString *)eid
                 nonce:(NSString *)nonce
              longName:(NSString *)longName
                openId:(NSString *)openId;



//获取该用户在企业的中是否是管理员
- (void)checkIsAdmin:(NSString *)openId
                 eid:(NSString *)eid
               token:(NSString *)token;

//获取企业的配置的所有参数值
- (void)getCompanyConfiguration:(NSString *)eid
                          token:(NSString *)token;

//加入到默认公司
- (void)joinToDefaultCompany:(NSString *)phone;

//获取应用地址
- (void)getAppConfig;

//通知管理员去设置组织架构
-(void)sendAdminMessageForNotOrganization;

//组织架构
- (void)orgTreeInfoWithOrgId:(NSString *)orgId;


//获取部门负责人
- (void)getHeaderByNetworkAndUserIdWithNetWorkId:(NSString *)networkId userId:(NSString *)userId;

//根据personIds获取人员信息
- (void)getPersonsCasvirByIds:(NSArray *)personIds;
- (void)saveOfficeWithName:(NSString *)name AndValue:(NSString *)value;
- (void)savePersonAttributeWithAttributeId:(NSString *)attributeId value:(NSString *)value;
//保存我的个人联系人信息
- (void)saveMyContacts:(NSArray *)contacts;
//多人语音会话
- (void)joinSessionWithGroupId:(NSString *)groupid PersonId:(NSString *)personid;
- (void)quitSessionWithGroupId:(NSString *)groupid PersonId:(NSString *)personid;
- (void)getSessionPersonsWithGroupId:(NSString *)groupid;
- (void)getUidByPersonIdWithPersonIds:(NSString *)personids;
- (void)getPersonIdByUidWithUids:(NSString *)uids;

//获取云app secrect
-(void)getYunAppSecrect:(NSString *)appId;

//切换语言
-(void)changeLanguage:(NSString *)key;

- (void)getAdminEid;

// 通过旧密码修改密码接口
- (void)changePasswordWithAccount:(NSString *)strAccount
                      oldPassword:(NSString *)strOldPassword
                      newPassword:(NSString *)strNewPassword;

@end
