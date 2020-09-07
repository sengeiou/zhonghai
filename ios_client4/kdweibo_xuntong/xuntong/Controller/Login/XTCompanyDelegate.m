//
//  XTCompany.m
//  XT
//
//  Created by Gil on 14-4-3.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import "XTCompanyDelegate.h"

@implementation XTOpenCompanyListDataModel

- (id)init
{
    self = [super init];
    if (self) {
        _openId = [[NSString alloc] init];
        _companys = nil;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id openId = [dict objectForKey:@"openId"];
        if (![openId isKindOfClass:[NSNull class]] && openId) {
            self.openId = openId;
        }
        
        id companys = [dict objectForKey:@"companys"];
        if (![companys isKindOfClass:[NSNull class]] && companys && [companys isKindOfClass:[NSArray class]]) {
            NSMutableArray *openCompanys = [NSMutableArray array];
            for (id company in companys) {
                XTOpenCompanyDataModel *openCompany = [[XTOpenCompanyDataModel alloc] initWithDictionary:company];
                [openCompanys addObject:openCompany];
            }
            self.companys = openCompanys;
        }
        
        id authstrCompanys = [dict objectForKey:@"authstrCompanys"];
        if (![authstrCompanys isKindOfClass:[NSNull class]] && authstrCompanys && [authstrCompanys isKindOfClass:[NSArray class]]) {
            NSMutableArray *openCompanys = [NSMutableArray array];
            for (id company in authstrCompanys) {
                XTOpenCompanyDataModel *openCompany = [[XTOpenCompanyDataModel alloc] initWithDictionary:company];
                [openCompanys addObject:openCompany];
            }
            self.authstrCompanys = openCompanys;
        }
    }
    return self;
}
- (BOOL)checkInvitedCompany:(NSString *)eid{
    for (XTOpenCompanyDataModel *data in _companys) {
        if ([data.companyId isEqual:eid]) {
            return YES;
        }
    }
//    for (XTOpenCompanyDataModel *data in _authstrCompanys) {
//        if ([data.companyId isEqual:eid]) {
//            return YES;
//        }
//    }
    return NO;
}
- (NSString *)invitedPersonInfo{
    return _openId;
}
@end


@implementation XTOpenCompanyDataModel

- (id)init
{
    self = [super init];
    if (self) {
        _companyId = [[NSString alloc] init];
        _companyName = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id companyId = [dict objectForKey:@"id"];
        if (![companyId isKindOfClass:[NSNull class]] && companyId) {
            self.companyId = companyId;
        }
        
        id companyName = [dict objectForKey:@"name"];
        if (![companyName isKindOfClass:[NSNull class]] && companyName) {
            self.companyName = companyName;
        }
    }
    return self;
}

@end
