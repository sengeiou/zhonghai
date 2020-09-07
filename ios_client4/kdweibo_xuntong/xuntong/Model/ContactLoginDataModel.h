//
//  ContactLoginDataModel.h
//  ContactsLite
//
//  Created by Gil on 12-11-30.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "LoginDataModel.h"

@class ExtraDataModel;
@interface ContactLoginDataModel : LoginDataModel
@property (nonatomic,strong) ExtraDataModel *extraData;
@end

@class PersonDataModel;
@class PubAccountListDataModel;
@interface ExtraDataModel : BOSBaseDataModel
@property (nonatomic, strong) PersonDataModel *user;
@property (nonatomic, strong) PubAccountListDataModel *pubAccount;
@property (nonatomic, strong) NSString *grammarId;
@property (nonatomic, assign) BOOL orgTree;
//云通行证
@property (nonatomic,copy) NSString *cloudpassport;

@end

@interface PubAccountListDataModel : BOSBaseDataModel <NSCoding>
//PubAccountDataModel list
@property (nonatomic,strong) NSMutableArray *list;
@end

@interface PubAccountDataModel : BOSBaseDataModel <NSCoding>
@property (nonatomic,copy) NSString *publicId;//公众号ID
@property (nonatomic,copy) NSString *name;//公众号名称
@property (nonatomic,copy) NSString *photoUrl;//图片URL
@property (nonatomic,assign) BOOL manager;//是否为管理员
@property (nonatomic,assign) int state;//公共号状态
@end
