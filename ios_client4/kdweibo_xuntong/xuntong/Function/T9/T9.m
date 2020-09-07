//
//  T9.m
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "T9.h"
#import "T9Trie.h"
#import "XTDataBaseDao.h"
#import "T9SearchPerson.h"
#import "T9SearchResult.h"
#import "XTInitializationManager.h"

static T9 * _instance;
static dispatch_once_t _t9_disptatch_once;
@interface T9()
{
    T9Trie * _t9Trie;
    dispatch_block_t _initFinishBlock;
}

@end

@implementation T9

+ (T9 *)sharedInstance
{
    dispatch_once(&_t9_disptatch_once, ^{
        _instance = [[T9 alloc]init];
        [_instance initTrie];
    });
    return _instance;
}

- (NSArray *)search:(NSString *)word
{
    if (word.length == 0) {
        return nil;
    }
    
#if DEBUG
    NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
#endif
    NSArray *resultSet;
    T9SearchTextType type = [self calcSearchType:word];
    switch (type)
    {
        case T9SearchTextChinese:
        case T9SearchTextPinyinNumber:
            resultSet = [self searchWithName:word];
            break;
        case T9SearchTextNumber:
            resultSet = [self searchWithNumber:word];
            break;
        case T9SearchTextOther:
            resultSet = [self searchWithPinYin:word];
            break;
        default:
            NSAssert1(NO, @"calcSearchType error %d!", type);
            break;
    };
#if DEBUG
    NSLog(ASLocalizedString(@"Search : %@ By %d \tuse : %lf秒     \tresult : %d"),word, type,
          [[NSDate date] timeIntervalSince1970] - t,[resultSet count]);
#endif
    return resultSet;
}

- (void)initTrie
{
    NSArray *users = [[XTDataBaseDao sharedDatabaseDaoInstance] queryAllUsers];
    [self initTrieWithUsers:users];
}

- (void)reloadData
{
    [self initTrie];
}

+ (T9SearchTextType)calcSearchType:(NSString *)word
{
    return [[T9 sharedInstance] calcSearchType:word];
}

- (T9SearchTextType)calcSearchType:(NSString*)word
{
    word = [word stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //有中文
    if ([self hasHanzi:word]) {
        return T9SearchTextChinese;
    }
    
    //纯数字
    if ([self isPhoneNumber:word]) {
        return T9SearchTextNumber;
    }
    
    //数字+拼音
    if ([self hasNumber:word]) {
        return T9SearchTextPinyinNumber;
    }
    
    //其它(纯拼音)
    return T9SearchTextOther;
}

- (void)initTrieWithUsers:(NSArray*)users
{
    _personTotalCount = (int)[users count];
    _t9Trie = [[T9Trie alloc] initWithUsers:users];
}

- (NSArray *)searchWithPinYin:(NSString *)word
{
    if(_t9Trie == nil)
    {
        [self initTrie];
    }
    //修改搜索规则,超过四位字母的时候搜索姓名
    NSMutableArray *resultSet;
    if([word length] > 1){
         resultSet = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryUsersWithName:word]];
    }else{
          resultSet = [NSMutableArray array];
    }
    [resultSet addObjectsFromArray:[_t9Trie search:word]];
    
    if ([resultSet count] > 1)
    {
        //排序
        return [resultSet sortedArrayUsingComparator:^NSComparisonResult(T9SearchResult *a, T9SearchResult *b){
            if(b.weight == a.weight)
            {
                //TODO: 这种排序不合理，最好按拼音进行排序，暂时这样处理。
                return b.userId - a.userId;
            }
            else
                return b.weight - a.weight;
        }];
    }
    
    return resultSet;
}

- (NSArray *)searchWithNumber:(NSString *)word
{
    //先搜姓名
    NSMutableArray *resultSet = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryUsersWithName:word]];
    
    //如果大于3位数字，再去搜索电话号码
    if (word.length >= 4) {
        NSMutableArray *resultSet1 = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryUsersWithPhoneNumber:word]];
        [resultSet1 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![resultSet containsObject:obj]) {
                [resultSet addObject:obj];
            }
        }];
    }
    
    if ([resultSet count] > 1)
    {
        //排序
        return [resultSet sortedArrayUsingComparator:^NSComparisonResult(T9SearchResult *a, T9SearchResult *b){
            return b.weight - a.weight;
        }];
    }
    
    return resultSet;
    
}

- (NSArray *)searchWithName:(NSString *)word
{
    
    NSMutableArray *resultSet = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryUsersWithName:word]];
    
    if ([resultSet count] > 1)
    {
        //排序
        return [resultSet sortedArrayUsingComparator:^NSComparisonResult(T9SearchResult *a, T9SearchResult *b){
            return b.weight - a.weight;
        }];
    }
    return resultSet;
}

- (BOOL)hasNumber:(NSString *)word
{
    for (int i = 0; i < [word length]; i++)
    {
        char c = [word characterAtIndex:i];
        if (c >= '0' && c <= '9')
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isPhoneNumber:(NSString *)word
{
    for (int i = 0; i < [word length]; i++)
    {
        char c = [word characterAtIndex:i];
        if (c >= '0' && c <= '9')
        {
            continue;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)hasHanzi:(NSString *)word
{
    for(int i = 0; i < [word length]; i++)
    {
        int a = [word characterAtIndex:i];
        // 中文的编码区间为：0x4E00--0x9FBB
        if( a > 0x4E00 && a < 0x9FBB)
        {
            return YES;
        }
    }
    return NO;
}

- (void)firstInitial:(void (^)(BOOL isInitial))isInitialingBlock
        initFinished:(void (^)(void))initFinishedBlock
{
    
    if (![[XTInitializationManager sharedInitializationManager] canUseT9Search])
    {
        if([[XTInitializationManager sharedInitializationManager] isFirstInitializing])
        {
            //正在初始化....
            isInitialingBlock(YES);
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(firstInitFinish:)
                                                         name: kInitializationFirstCompletionNotification object:nil];
            _initFinishBlock = initFinishedBlock;
            return;
        }
        else
        {
            //已经初始化过，但可能初始化失败了，所以不能使用t9.
            isInitialingBlock(NO);
        }
    }
    //初始化已经完成
    initFinishedBlock();
}

- (void)firstInitFinish:(NSNotification *)note
{
    //初始化成功完成啦！
    _initFinishBlock();
}

@end
