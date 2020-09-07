//
//  T9SearchFactory.m
//  TestT9
//
//  Created by Gil on 13-1-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "T9SearchFactory.h"
#import "T9Node.h"
#import "XTDataBaseDao.h"
#import "T9SearchPerson.h"
#import "T9SearchResult.h"

@implementation T9SearchFactory

static T9SearchFactory *instance = nil;

+(T9SearchFactory *)getInstance
{
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[T9SearchFactory alloc] init];
        }
    }
    return instance;
}

-(id)init
{
    self = [super init];
    if (self) {
		_t9 = [[T9Node alloc] init];
        
        NSArray *users = [[XTDataBaseDao sharedDatabaseDaoInstance] queryAllUsers];
        
        self.personTotalCount = [users count];
        
#if DEBUG
        NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
#endif
        
        for (T9SearchPerson *user in users) {
            [_t9 insertWithStr:user.fullPinyins object:user];
        }
        
#if DEBUG
        NSLog(@"T9SearchFactory init use : %lf s",[[NSDate date] timeIntervalSince1970] - t);
#endif
        
    }
    return self;
}

-(void)reloadData
{
    if (_t9) {
        BOSRELEASE(_t9);
        [self init];
    }
}

- (BOOL)isPhoneNumber:(NSString *)word
{
    for (int i = 0; i < [word length]; i++) {
        char c = [word characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            continue;
        } else {
            return NO;
        }
    }
    return YES;
}

- (NSArray *)search:(NSString *)word
{
    
#if DEBUG
    NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
#endif
    
    if (_t9 == nil) {
        [self init];
    }
    word = [word stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableArray *resultSet = [NSMutableArray array];
    if (word.length > 0) {
        //T9搜索
        [resultSet addObjectsFromArray:[_t9 search:word]];
        //电话号码搜索
        if (word.length >= 4 && [self isPhoneNumber:word]) {
            [resultSet addObjectsFromArray:[self searchWithPhoneNumberNotSorted:word]];
            
            if ([resultSet count] > 1) {
                //排序
                NSArray *sortedArray = [resultSet sortedArrayUsingComparator:^NSComparisonResult(T9SearchResult *a, T9SearchResult *b){
                    return b.weight - a.weight;
                }];
                [resultSet removeAllObjects];
                //去除重复
                __block NSMutableArray *userIds = [NSMutableArray array];
                [sortedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    T9SearchResult *eachResult = (T9SearchResult *)obj;
                    if (![userIds containsObject:[NSNumber numberWithInt:eachResult.userId]]) {
                        //重新组装结果集
                        [userIds addObject:[NSNumber numberWithInt:eachResult.userId]];
                        [resultSet addObject:eachResult];
                    }
                }];
            }
        }
    }
    
#if DEBUG
    NSLog(@"Search : %@ \tuse : %lf秒     \tresult : %d",word,[[NSDate date] timeIntervalSince1970] - t,[resultSet count]);
#endif
    
    return resultSet;
}

- (NSArray *)searchWithNames:(NSArray *)words
{
    
#if DEBUG
    NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
#endif
    
    NSMutableArray *resultSet = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryUsersWithNames:words]];
    
    if ([resultSet count] > 1) {
        //排序
        NSArray *sortedArray = [resultSet sortedArrayUsingComparator:^NSComparisonResult(T9SearchResult *a, T9SearchResult *b){
            return b.weight - a.weight;
        }];
        [resultSet removeAllObjects];
        //去除重复
        __block NSMutableArray *userIds = [NSMutableArray array];
        [sortedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            T9SearchResult *eachResult = (T9SearchResult *)obj;
            if (![userIds containsObject:[NSNumber numberWithInt:eachResult.userId]]) {
                //重新组装结果集
                [userIds addObject:[NSNumber numberWithInt:eachResult.userId]];
                [resultSet addObject:eachResult];
            }
        }];
    }
    
#if DEBUG
    NSLog(@"Search : %@ \tuse : %lf秒     \tresult : %d",[words componentsJoinedByString:@","],[[NSDate date] timeIntervalSince1970] - t,[resultSet count]);
#endif
    
    return resultSet;
}

- (NSArray *)searchWithPhoneNumber:(NSString *)word
{
    NSMutableArray *resultSet = [NSMutableArray arrayWithArray:[self searchWithPhoneNumberNotSorted:word]];
    
    if ([resultSet count] > 1) {
        //排序
        NSArray *sortedArray = [resultSet sortedArrayUsingComparator:^NSComparisonResult(T9SearchResult *a, T9SearchResult *b){
            return b.weight - a.weight;
        }];
        [resultSet removeAllObjects];
        //去除重复
        __block NSMutableArray *userIds = [NSMutableArray array];
        [sortedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            T9SearchResult *eachResult = (T9SearchResult *)obj;
            if (![userIds containsObject:[NSNumber numberWithInt:eachResult.userId]]) {
                //重新组装结果集
                [userIds addObject:[NSNumber numberWithInt:eachResult.userId]];
                [resultSet addObject:eachResult];
            }
        }];
    }
    
    return resultSet;
}

- (NSArray *)searchWithPhoneNumberNotSorted:(NSString *)word
{
    return [[XTDataBaseDao sharedDatabaseDaoInstance] queryUsersWithPhoneNumber:word];
}

@end
