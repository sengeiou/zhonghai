//
//  GroupListDataModel.m
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "GroupListDataModel.h"
#import "GroupDataModel.h"
#import "PersonSimpleDataModel.h"
#import "XTDataBaseDao.h"
@implementation GroupListDataModel

- (id)init {
    self = [super init];
    if (self) {
        _count = 0;
        _unreadTotal = 0;
        _more = NO;
        _updateTime = [[NSString alloc] init];
        _list = [[NSMutableArray alloc] init];
        _publicMember = [[NSMutableArray alloc] init];
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
        id count = [dict objectForKey:@"count"];
        id unreadTotal = [dict objectForKey:@"unreadTotal"];
        id updateTime = [dict objectForKey:@"updateTime"];
        id list = [dict objectForKey:@"list"];
        id publicMember = [dict objectForKey:@"publicMember"];
        id more = [dict objectForKey:@"more"];
        
        if (![count isKindOfClass:[NSNull class]] && count) {
            self.count = [count intValue];
        }
        if (![unreadTotal isKindOfClass:[NSNull class]] && unreadTotal) {
            self.unreadTotal = [unreadTotal intValue];
        }
        if (![updateTime isKindOfClass:[NSNull class]] && updateTime) {
            self.updateTime = updateTime;
        }
        if (![more isKindOfClass:[NSNull class]] && more) {
            self.more = [more boolValue];
        }
        if (![list isKindOfClass:[NSNull class]] && list && [list isKindOfClass:[NSArray class]]) {
            for (id each in list) {
                GroupDataModel *group = [[GroupDataModel alloc] initWithDictionary:each];
                [self.list addObject:group];
            }
        }
        if (![publicMember isKindOfClass:[NSNull class]] && publicMember && [publicMember isKindOfClass:[NSArray class]]) {
            for (id each in publicMember) {
                PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:each];
                [self.publicMember addObject:person];
            }
        }
    }
    return self;
}

@end