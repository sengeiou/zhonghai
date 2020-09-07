//
//  UserDataModel.h
//  EMPNativeContainer
//
//  Created by Gil on 14-3-14.
//  Copyright (c) 2014年 Kingdee.com. All rights reserved.
//

@interface UserDataModel : NSObject <NSCoding>

@property (strong, nonatomic) NSString *bizId;
@property (strong, nonatomic) NSString *department;
@property (strong, nonatomic) NSString *emails;
@property (strong, nonatomic) NSString *email;
@property (assign, nonatomic) int gender;
@property (nonatomic, strong) NSString *companyName;
@property (strong, nonatomic) NSString *jobTitle;
@property (strong, nonatomic) NSString *lastUpdateTime;
@property (strong, nonatomic) NSString *orgId;
@property (strong, nonatomic) NSString *petName;
@property (strong, nonatomic) NSString *phones;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) NSString *bindedEmail;
@property (strong, nonatomic) NSString *bindedPhone;
@property (assign, nonatomic) int status;
@property (assign, nonatomic) int enableLanguage;

@property (strong, nonatomic) NSString *eid;//企业id
@property (strong, nonatomic) NSString *userId;//用户的personId
@property (strong, nonatomic) NSString *name;//用户名称
@property (strong, nonatomic) NSString *openId;//用户的open id
@property (strong, nonatomic) NSString *oId;//用户对外的id，给轻应用、公共号等鉴权使用
@property (strong, nonatomic) NSString *token;//open token

@property (assign, nonatomic) int isAdmin;
//云之家相关
@property (strong, nonatomic) NSString *wbUserId;
@property (strong, nonatomic) NSString *wbNetworkId;
@property (strong, nonatomic) NSString *oauthToken;
@property (strong, nonatomic) NSString *oauthTokenSecret;
@property (assign, nonatomic) int partnerType;//用户类型（0内部员工，1商务伙伴，即外部员工，2两者都有）

//@property (strong, nonatomic) NSString *cloudpassport;

// 团队账号
@property (strong, nonatomic) NSArray *teamAccount;


@property (copy, nonatomic) NSString *language;

@property (nonatomic, assign) NSInteger isVerify;

- (id)initWithDictionary:(NSDictionary *)dict;

- (BOOL)isDefaultAvatar;

- (NSString *)externalPersonId;

@end
