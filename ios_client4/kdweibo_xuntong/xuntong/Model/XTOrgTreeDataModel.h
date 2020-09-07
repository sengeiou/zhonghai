//
//  XTOrgTreeDataModel.h
//  XT
//
//  Created by Gil on 13-7-17.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "BOSBaseDataModel.h"

@class XTOrgChildrenDataModel;
@interface XTOrgTreeDataModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *orgId;
@property (nonatomic, copy) NSString *orgName;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *parentName;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, strong) NSArray *personIds;
@property (nonatomic, strong) NSArray *leaders;
@property (nonatomic, strong) NSArray *employees;
@property (nonatomic, strong) NSArray *allPersons; // leaders+personIds／(employees和personIds看似一样,用的时候有区别)
@property (nonatomic, strong) NSArray *unallotPersons;
@property (nonatomic, assign) BOOL isFilterTeamAcc;

- (BOOL)isRootOrganization;
- (BOOL)isLeafOrganization;

@end

@interface XTOrgChildrenDataModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *orgId;
@property (nonatomic, copy) NSString *orgName;
@property (nonatomic, copy) NSString *personCount;
@property (nonatomic, assign) NSInteger partnerType;
@end

@interface XTOrgPersonDataModel : BOSBaseDataModel
@property (nonatomic, strong) NSString *personId;
@property (nonatomic, strong) NSString *job;
@property (nonatomic, strong) NSString *photoUrl;//头像
@property (nonatomic, assign) int orgUserType;//1表示部门负责人，其他表示不是部门负责人
@property (nonatomic, assign) int isPartJob;//1表示是兼职，其他表示不是兼职
@end

