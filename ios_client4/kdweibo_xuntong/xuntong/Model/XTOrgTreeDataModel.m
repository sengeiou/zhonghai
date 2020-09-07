//
//  XTOrgTreeDataModel.m
//  XT
//
//  Created by Gil on 13-7-17.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTOrgTreeDataModel.h"
#import "PersonSimpleDataModel.h"
#import "BOSSetting.h"

@implementation XTOrgTreeDataModel

- (id)init {
    self = [super init];
    if (self) {
        _orgId = [[NSString alloc] init];
        _orgName = [[NSString alloc] init];
        _parentId = [[NSString alloc] init];
        _parentName = [[NSString alloc] init];
        _children = nil;
        _leaders = nil;
        _employees = nil;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        
        id orgId = [dict objectForKey:@"id"];
        if (![orgId isKindOfClass:[NSNull class]] && orgId) {
            self.orgId = orgId;
        }
        
        id orgName = [dict objectForKey:@"name"];
        if (![orgName isKindOfClass:[NSNull class]] && orgName) {
            self.orgName = orgName;
        }
        
        id parentId = [dict objectForKey:@"parentId"];
        if (![parentId isKindOfClass:[NSNull class]] && parentId) {
            self.parentId = parentId;
        }
        id parentName = [dict objectForKey:@"parentName"];
        if (![parentName isKindOfClass:[NSNull class]] && parentName) {
            self.parentName = parentName;
        }
        id children = [dict objectForKey:@"children"];
        if (![children isKindOfClass:[NSNull class]] && children && [children isKindOfClass:[NSArray class]]) {
            __block NSMutableArray *childrenArray = [NSMutableArray array];
            [children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if(obj && ![obj isKindOfClass:[NSNull class]])
                {
                    NSString *name = obj[@"name"];
                    if(name && ![name isEqualToString:@""] && name.length>0)
                    {
                        XTOrgChildrenDataModel *child = [[XTOrgChildrenDataModel alloc] initWithDictionary:obj];
                        [childrenArray addObject:child];
                    }
                }
            }];
            self.children = childrenArray;
        }
        
        
        if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
            id person = [dict objectForKey:@"personInfos"];
            if (![person isKindOfClass:[NSNull class]] && person && [person isKindOfClass:[NSArray class]]) {
                NSMutableArray *personArray = [NSMutableArray array];
                NSMutableArray *leaders = [NSMutableArray array];
                NSMutableArray *allPersons = [NSMutableArray array];
                [person enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:obj];
                    if (person.orgUserType == 1) {
                        [leaders addObject:person];
                    }else
                    {
                      [personArray addObject:person];
                    }
                    
                    [allPersons addObject:person];
                }];
                self.employees = personArray;
                self.personIds = personArray;
                self.leaders = leaders;
                self.allPersons = allPersons;
            }
            
            //只有跟组织才存在未分配部门的人员
            if ([self isRootOrganization]) {
                id unallotPersons = [dict objectForKey:@"unallotPersons"];
                if (![unallotPersons isKindOfClass:[NSNull class]] && unallotPersons && [unallotPersons isKindOfClass:[NSArray class]]) {
                    __block NSMutableArray *tmpUnallotPersons = [NSMutableArray array];
                    [(NSArray *)unallotPersons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            PersonSimpleDataModel *orgPerson = [[PersonSimpleDataModel alloc] initWithDictionary:obj];
                            [tmpUnallotPersons addObject:orgPerson];
                        }
                    }];
                    self.unallotPersons = tmpUnallotPersons;
                }
            }

            
        }else{
            id person = [dict objectForKey:@"person"];
            if (![person isKindOfClass:[NSNull class]] && person && [person isKindOfClass:[NSArray class]]) {
                NSArray *persons = (NSArray *)person;
                
                __block NSMutableArray *leaders = [NSMutableArray array];
                __block NSMutableArray *employees = [NSMutableArray array];
                __block NSMutableArray *personIds = [NSMutableArray array];
                [persons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        XTOrgPersonDataModel *orgPerson = [[XTOrgPersonDataModel alloc] initWithDictionary:obj];
                        if (orgPerson.orgUserType == 1) {
                            [leaders addObject:orgPerson];
                        }
                        else {
                            [employees addObject:orgPerson];
                        }
                        [personIds addObject:orgPerson.personId];
                    }
                }];
                self.leaders = leaders;
                self.employees = employees;
                self.personIds = personIds;
                self.allPersons = personIds;
            }
            
            //只有跟组织才存在未分配部门的人员
            if ([self isRootOrganization]) {
                id unallotPersons = [dict objectForKey:@"unallotPersons"];
                if (![unallotPersons isKindOfClass:[NSNull class]] && unallotPersons && [unallotPersons isKindOfClass:[NSArray class]]) {
                    __block NSMutableArray *tmpUnallotPersons = [NSMutableArray array];
                    [(NSArray *)unallotPersons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            XTOrgPersonDataModel *orgPerson = [[XTOrgPersonDataModel alloc] initWithDictionary:obj];
                            [tmpUnallotPersons addObject:orgPerson];
                        }
                    }];
                    self.unallotPersons = tmpUnallotPersons;
                }
            }
        }
    }
    return self;
}

- (void)setIsFilterTeamAcc:(BOOL)isFilterTeamAcc {
    if (isFilterTeamAcc) {
        __block NSMutableArray *tmpUnallotPersons = [NSMutableArray array];
        [(NSArray *)self.unallotPersons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
                PersonSimpleDataModel *person = obj;
                if (person.defaultPhone.length > 0) {
                    [tmpUnallotPersons addObject:person];
                }
            }
        }];
        self.unallotPersons = tmpUnallotPersons;
    }
    _isFilterTeamAcc = isFilterTeamAcc;
}

#pragma mark - method

- (BOOL)isRootOrganization
{
    if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
        return self.parentId.length == 0;
    }else{
        return self.parentId.length == 0;
    }
}

- (BOOL)isLeafOrganization
{
    return [self.children count] == 0;
}

@end

@implementation XTOrgChildrenDataModel

- (id)init {
    self = [super init];
    if (self) {
        _orgId = [[NSString alloc] init];
        _orgName = [[NSString alloc] init];
        _personCount = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        
        id orgId = [dict objectForKey:@"id"];
        if (![orgId isKindOfClass:[NSNull class]] && orgId) {
            self.orgId = orgId;
        }
        
        id orgName = [dict objectForKey:@"name"];
        if (![orgName isKindOfClass:[NSNull class]] && orgName) {
            self.orgName = orgName;
        }
        
        id personCount = [dict objectForKey:@"personCount"];
        if (![personCount isKindOfClass:[NSNull class]] && personCount) {
            self.personCount = personCount;
        }
        
        
        id partnerType = [dict objectForKey:@"partnerType"];
        if (![partnerType isKindOfClass:[NSNull class]] && partnerType) {
            self.partnerType = [partnerType integerValue];
        }
    }
    return self;
}

@end

@implementation XTOrgPersonDataModel

- (id)init {
    self = [super init];
    if (self) {
        _personId = [[NSString alloc] init];
        _job = [[NSString alloc] init];
        _orgUserType = 0;
        _isPartJob = 0;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        
        id personId = [dict objectForKey:@"personId"];
        if (![personId isKindOfClass:[NSNull class]] && personId) {
            self.personId = personId;
        }
        
        id job = [dict objectForKey:@"job"];
        if (![job isKindOfClass:[NSNull class]] && job) {
            self.job = job;
        }
        
        id orgUserType = [dict objectForKey:@"orgUserType"];
        if (![orgUserType isKindOfClass:[NSNull class]] && orgUserType) {
            self.orgUserType = [orgUserType intValue];
        }
        
        id isPartJob = [dict objectForKey:@"isPartJob"];
        if (![isPartJob isKindOfClass:[NSNull class]] && isPartJob) {
            self.isPartJob = [isPartJob intValue];
        }
    }
    return self;
}

@end