//
//  PersonDataModel.h
//  ContactsLite
//
//  Created by kingdee eas on 12-11-13.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "PersonSimpleDataModel.h"

@interface PersonDataModel : PersonSimpleDataModel <NSCoding>

@property (nonatomic, strong) NSMutableArray *contact;//联系方式,详见下说明
//@property (nonatomic, copy) NSString *orgId;//组织id, 有则返回, 没有则不返回
@property (nonatomic, assign, readonly) BOOL canSms;//是否支持发短信

//@property (nonatomic,strong) NSMutableArray *parttimejob;//职位显示，第一个默认为主职，其他为兼职

//addby fang
@property (nonatomic, copy) NSString *eName;//公司名称
@property (nonatomic, strong) NSArray *contactArray;            //contact数组
@property (nonatomic, strong) NSMutableArray *phoneArray;       //电话数组 (三个数组都是从contact数组解析得来的，包含KDContactInfo实例)
@property (nonatomic, strong) NSMutableArray *emailArray;       //email数组
@property (nonatomic, strong) NSMutableArray *otherArray;       //其他的数组

@property (nonatomic, strong) NSMutableArray *attributesArray;  // 人员详情自定义字段
// 可以修改的系统属性，跟字段名匹配  officePhone1:电话1, officePhone2:电话2, emails:邮箱, birthday:生日, gender:性别}
@property (nonatomic, strong) NSArray *mutableArray; // mutableArray

//系统字段
@property (nonatomic, strong) NSString *phone1;       //phone1
@property (nonatomic, strong) NSString *phone2;       //phone2
@property (nonatomic, strong) NSString *systemEmail;  //
@property (nonatomic, strong) NSString *birthday;     //
@property (nonatomic, assign) BOOL isVisible;//表示在用户详情中是否能看到联系方式
@property (nonatomic, strong) NSMutableArray *orgLeaders;       //上级，不存数据库

- (id)initWithPersonSimple:(PersonSimpleDataModel *)personSimple;
- (id)initWithOpenDictionary:(NSDictionary *)dict;
@end


typedef enum _ContactType{
    ContactOther = 0,//其他
    ContactCellPhone = 1,//手机
    ContactHomePhone = 2,//家庭电话
    ContactEmail = 3,//邮箱
    ContactAccount = 4//邮箱

}ContactType;

@interface ContactDataModel : BOSBaseDataModel <NSCoding>

@property (nonatomic, copy) NSString *ctext;//联系方式文本
@property (nonatomic, copy) NSString *cvalue;//联系方式的值
@property (nonatomic, assign) ContactType ctype;//联系方式类型

- (NSString *)formatedTextName;

@end

//@interface ParttimejobDataModel : BOSBaseDataModel <NSCoding>
//
//@property (nonatomic, copy) NSString *orgId;//组织id
//@property (nonatomic, copy) NSString *eName;//组织名，可有可无
//@property (nonatomic, copy) NSString *department;//部门名称
//@property (nonatomic, copy) NSString *jobTitle;//职位
//@property (nonatomic, assign) BOOL jobType;//职位类型
//
//
//@end