//
//  PersonSimpleDataModel.h
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "BOSBaseDataModel.h"
@class GroupDataModel;
@class UserDataModel;
@interface PersonSimpleDataModel : BOSBaseDataModel

//通用
@property (nonatomic, strong) NSString *personId;//personId或者pubAccId
@property (nonatomic, strong) NSString *personName;//名称
@property (nonatomic, strong) NSString *photoUrl;//头像
@property (nonatomic, strong) NSString *defaultPhone;//默认联系号码(先取手机再取座机)
@property (nonatomic, assign) int gender;//性别
@property (nonatomic, strong) NSString *department;//部门
@property (nonatomic, strong) NSString *jobTitle;//职位
@property (nonatomic, strong) NSString *fullPinyin;//全拼
@property (nonatomic, strong) NSString *wbUserId;//微博用户id
@property (nonatomic, assign) BOOL isAdmin;//是不是工作圈管理员
@property (nonatomic, strong) NSString *eid;//企业id
@property (nonatomic, strong) NSString *oid;//轻应用使用的openId
@property (nonatomic, strong) NSString *orgId;//部门的id
@property (nonatomic, strong) NSString *activeTime; //用户激活时间，旧用户为nil
@property (nonatomic, assign) int orgUserType;//1表示部门负责人，其他表示不是部门负责人

@property (nonatomic,strong) NSMutableArray *parttimejob;//职位显示，第一个默认为主职，其他为兼职
@property (nonatomic, assign) BOOL isPartJob;//是不是兼职
/*
 第一位表示帐号是否可用
 第二位表示是否开通讯通
 第三位表示是否收藏
 第四位表示是否为公共帐号
 */
@property (nonatomic, assign) int status;

@property (nonatomic, assign) int state;//-1 删除 / 0 修改 / 1 审核 / 2 启用


//T9 Person
@property (nonatomic, assign) int userId;

//公共账号信息
@property (nonatomic, strong) NSString *menu;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSString *reply;
@property (nonatomic, strong) NSString *subscribe; //关注状态
@property (nonatomic, strong) NSString *canUnsubscribe; //是否可取消关注
@property (assign, nonatomic) BOOL manager;//是否为管理员
@property (assign, nonatomic) int share;//公共号内容能否被分享，0不限制，1限制，2内部允许，3外部允许
@property (nonatomic, assign) BOOL fold;//是否参与折叠
@property (nonatomic, assign ) BOOL remind; //是否开启消息提醒
@property (nonatomic, assign ) BOOL hisNews; //是否允许历史消息查看

//搜索高亮字段
@property (nonatomic, strong) NSString *highlightName;
@property (nonatomic, strong) NSString *highlightFullPinyin;
@property (nonatomic, strong) NSString *highlightDefaultPhone;

@property (nonatomic, assign) int partnerType;//用户类型，0内部人员，1外部人员，2内部兼职外部人员;
@property (nonatomic, strong ) GroupDataModel *group; //表示personId是否表示groupId，由group封装完成

@property (nonatomic, strong) NSString *personScore;

- (BOOL)isEmployee;//判断是否带有内部人员属性

//帐号是否可用
- (BOOL)accountAvailable;
//是否开通了讯通
- (BOOL)xtAvailable;
//是否为公共帐号
- (BOOL)isPublicAccount;
//是否有头像
- (BOOL)hasHeaderPicture;

//是否已收藏
- (BOOL)hasFavor;
//切换收藏状态
- (void)toggleFavor;

- (BOOL)isInCompany;

//- (GroupDataModel *)packageGroup :(GroupType)type;//封装成一个groupdata

//是否允许内部、外部转发
-(BOOL)allowInnerShare;
-(BOOL)allowOuterShare;

-(NSString *)getGenderDescription:(int)gender;
@end


@interface ParttimejobDataModel : BOSBaseDataModel <NSCoding>

@property (nonatomic, copy) NSString *orgId;//组织id
@property (nonatomic, copy) NSString *eName;//组织名，可有可无
@property (nonatomic, copy) NSString *department;//部门名称
@property (nonatomic, copy) NSString *jobTitle;//职位
@property (nonatomic, assign) BOOL jobType;//职位类型
@property (nonatomic, assign) NSUInteger partnerType;//商务伙伴类型

@property (nonatomic, assign) NSUInteger totalSection;//商务伙伴类型
@end

@interface NSString (PersonSimpleDataModel)
- (BOOL)isPublicAccount;
- (BOOL)isExternalPerson;
- (BOOL)isExternalGroup;
@end
