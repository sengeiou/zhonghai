//
//  SimplePersonListDataModel.m
//  kdweibo
//
//  Created by wenbin_su on 15/5/21.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "SimplePersonListDataModel.h"
#import "PersonSimpleDataModel.h"

@implementation SimplePersonListDataModel
-(id)init
{
    self = [super init];
    if (self) {
        _count = 0;
        _totalCount = 0;
        _hasMore = NO;
        _list = [[NSMutableArray alloc] init];
        _delList = [[NSMutableArray alloc] init];
        _lastUpdateScore = 0;
    }
    
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    
    if (self) {
        id count = [dict objectForKey:@"count"];
        id list = [dict objectForKey:@"list"];
        id delList = [dict objectForKey:@"delList"];
        
        
        
        id totalCount = [dict objectForKey:@"totalCount"];
        id hasMore = [dict objectForKey:@"hasMore"];
        id lastUpdateScore = [dict objectForKey:@"lastUpdateScore"];
        
        if (![count isKindOfClass:[NSNull class]] && count) {
            self.count = [count intValue];
        }
        
        if (![list isKindOfClass:[NSNull class]] && list && [list isKindOfClass:[NSArray class]]) {
            for (id each in list) {
                PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:each];
                //                [person setGroupId:_groupId];
                [_list addObject:person];
            }
        }
        
        if (![delList isKindOfClass:[NSNull class]] && delList && [delList isKindOfClass:[NSArray class]]) {
            for (NSString * each in delList) {
                [_delList addObject:each];
            }
        }
        if (![totalCount isKindOfClass:[NSNull class]] && totalCount) {
            self.totalCount = [totalCount intValue];
        }
        
        if (![hasMore isKindOfClass:[NSNull class]] && hasMore) {
            self.hasMore = [hasMore boolValue];
        }
        
        if (![lastUpdateScore isKindOfClass:[NSNull class]] && lastUpdateScore) {
            self.lastUpdateScore = [lastUpdateScore integerValue];
        }
        
    }
    
    return self;
}

- (void)setIsFilterTeamAcc:(BOOL)isFilterTeamAcc {
    if (isFilterTeamAcc) {
        __block NSMutableArray *tmpPersons = [NSMutableArray array];
        [(NSArray *)self.list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PersonSimpleDataModel *person = obj;
            if (person.defaultPhone.length > 0) {
                [tmpPersons addObject:person];
            }
        }];
        self.list = tmpPersons;
    }
    _isFilterTeamAcc = isFilterTeamAcc;
}

@end
