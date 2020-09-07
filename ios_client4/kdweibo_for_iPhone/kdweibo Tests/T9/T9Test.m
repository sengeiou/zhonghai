//
//  T9Test.m
//  kdweibo
//
//  Created by stone on 14-5-14.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "T9.h"
#import "T9SearchPerson.h"
#import "T9SearchResult.h"

#define kKeyUserId      @"userId"
#define kKeyFullPinYins @"fullPinYins"

@interface T9Test : XCTestCase
{
    T9 * _t9;
}

@end



@implementation T9Test

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self initT9];
}

- (void)initT9
{
    NSArray * usersDict = @[
                            @{kKeyUserId:@101,kKeyFullPinYins:@"zhang shan"},
                            @{kKeyUserId:@102,kKeyFullPinYins:@"li si"},
                            @{kKeyUserId:@103,kKeyFullPinYins:@"wang ma zhi"},
                            @{kKeyUserId:@104,kKeyFullPinYins:@"zheng liu"},
                            @{kKeyUserId:@105,kKeyFullPinYins:@"dong fang bu bai"},
                            @{kKeyUserId:@106,kKeyFullPinYins:@"zhao xiao long"},
                            @{kKeyUserId:@107,kKeyFullPinYins:@"zhao zhi long"},
                            @{kKeyUserId:@108,kKeyFullPinYins:@"fang bu bai"},
                            @{kKeyUserId:@201,kKeyFullPinYins:@"guan hua"},
                            @{kKeyUserId:@202,kKeyFullPinYins:@"geng hong"},
                            @{kKeyUserId:@203,kKeyFullPinYins:@"gu hao"},
                            @{kKeyUserId:@204,kKeyFullPinYins:@"gao hua rong"},
                            @{kKeyUserId:@205,kKeyFullPinYins:@"zheng ge ge"},
                            @{kKeyUserId:@206,kKeyFullPinYins:@"wo shi shui"},
                            @{kKeyUserId:@207,kKeyFullPinYins:@"wo shi shui"},
                            @{kKeyUserId:@301,kKeyFullPinYins:@"  00   song  kai \n"},
                            @{kKeyUserId:@302,kKeyFullPinYins:@"xia guo yong"},
                            @{kKeyUserId:@303,kKeyFullPinYins:@"xiong y"},
                            @{kKeyUserId:@304,kKeyFullPinYins:@"xiong yuan yi"},
                            ];
    NSMutableArray * users = [[NSMutableArray alloc]initWithCapacity:4];
    for(NSDictionary *d in usersDict)
    {
        T9SearchPerson * ps = [[T9SearchPerson alloc]initWithDictionary:d];
        [users addObject:ps];
    }
    _t9 = [[T9 alloc]init];
    [_t9 initTrieWithUsers:users];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//测试普通搜索
- (void)testSearch
{
    NSArray * resultArr = [_t9 search:@"xx"];
    //匹配的应该是：无
    XCTAssert([resultArr count] == 0, @"search %lu users!",(unsigned long)[resultArr count]);

    resultArr = [_t9 search:@"zh"];
    //匹配的应该是：无 原因是只匹配一个单词会被忽略
    XCTAssert([resultArr count] == 0, @"search %lu users!",(unsigned long)[resultArr count]);

    resultArr = [_t9 search:@"zl"];
    //匹配的应该是：104(zheng liu) 107(zhao zhi long)
    // zhao xiao long 不符合，因为没有连续匹配单词，会抛弃
    XCTAssert([resultArr count] == 2, @"search %lu users!",(unsigned long)[resultArr count]);
    
    resultArr = [_t9 search:@"xiongy"];
    XCTAssert([resultArr count] == 2, @"search %lu users!",(unsigned long)[resultArr count]);
    
}

//测试搜索后的排序
- (void)testOrder
{
    NSArray * resultArr = [_t9 search:@"ghua"];
    //匹配的应该是：无
    XCTAssert([resultArr count] == 2, @"search %lu users!",(unsigned long)[resultArr count]);
    
    resultArr = [_t9 search:@"fbb"];
    //匹配的应该是：108(fang bu bai) 权重 3,15,15
    //            105(dong fang bu bai) 匹配度是：[0,1,1,1]
    //              权重  3,14, 3 * 15 /4 = 11 -> 0x03EB
    //  返回的值 108,105
    XCTAssert([resultArr count] == 2, @"search %lu users!",(unsigned long)[resultArr count]);
    if([resultArr count] == 2)
    {
        T9SearchResult * result = [resultArr objectAtIndex:0];
        XCTAssert(result.userId == 108, @"userid:%d",result.userId);
        result = [resultArr objectAtIndex:1];
        XCTAssert(result.userId == 105, @"userid:%d",result.userId);
    }
}

//测试最优的匹配方式
- (void)testMach
{
    NSArray * resultArr = [_t9 search:@"zhengg"];
    //查找到的是： zheng ge ge 按匹配度高的原则，应该是：zheng gx xx match:(5,1)
    XCTAssert([resultArr count] == 1, @"count:%lu",(unsigned long)[resultArr count]);
    if([resultArr count] == 1)
    {
        T9SearchResult * result = [resultArr objectAtIndex:0];
        NSArray * matchLength = @[@5,@1];
        XCTAssertTrue([result.matchLength isEqualToArray:matchLength], @"match is : %@",
                      [result.matchLength description]);
    }
}

//测试权重的计算
- (void)testWeight
{
    NSArray * resultArr = [_t9 search:@"fangbubai"];
    //匹配的应该是：105(dong fang bu bai) 108(fang bu bai)
    //  105权重是：3,3,14, 3 * 15 /4 = 11  --> 0x33EB
    //  108权重是：3,3,15,15 --> 0x33FF
    XCTAssert([resultArr count] == 2, @"search %lu users!",(unsigned long)[resultArr count]);
    if([resultArr count] == 2)
    {
        T9SearchResult * result = [resultArr objectAtIndex:0];
        int weight = 0x33FF;
        XCTAssert(result.weight == weight,@"match 108 weight:%d",result.weight);
        result = [resultArr objectAtIndex:1];
        XCTAssert(result.userId == 105, @"serach result (1) %d",result.userId);
        weight = 0x33EB;
        XCTAssert(result.weight == weight,@"match 105 weight:%d",result.weight);
    }
    resultArr = [_t9 search:@"zhangshan"];
    //匹配的应该是：101(zhang shan) 匹配度是(zhang shax)：[5,3]
    //权重：2（全词匹配个数) 2 (匹配词数) 15 (靠前)  15 (占比)
    //      0x22FF
    XCTAssert([resultArr count] == 1, @"search %lu users!",(unsigned long)[resultArr count]);
    if([resultArr count] == 1)
    {
        T9SearchResult * result = [resultArr objectAtIndex:0];
        XCTAssert(result.userId == 101, @"search result %d",result.userId);
        XCTAssert( [result.matchLength count] == 2, @"match length:%lu",(unsigned long)[result.matchLength count]);
        if([result.matchLength count] == 2)
        {
            NSArray * matchLength = @[@5,@4];
            XCTAssertTrue([result.matchLength isEqualToArray:matchLength], @"match is : %@",
                          [result.matchLength description]);
            XCTAssert(result.weight == 0x22FF,@"match weight:%X",result.weight);
        }
    }
}

- (void)testDuplicateName
{
    NSArray * resultArr = [_t9 search:@"woss"];
    XCTAssert([resultArr count] == 2, @"count:%lu",(unsigned long)[resultArr count]);
    T9SearchResult * result = [resultArr objectAtIndex:0];
    XCTAssert(result.userId == 207, @"result (0) %d",result.userId);
    result = [resultArr objectAtIndex:1];
    XCTAssert(result.userId == 206, @"result (1) %d",result.userId);
}

- (void)testSpecialData
{
    NSArray * resultArr = [_t9 search:@"songk"];
    XCTAssert([resultArr count] == 1, @"count:%lu",(unsigned long)[resultArr count]);
    T9SearchResult * result = [resultArr objectAtIndex:0];
    XCTAssert(result.userId == 301, @"result (0) %d",result.userId);
    
}

- (void)testHightLight
{
    
    NSArray * resultArr = [_t9 search:@"songk"];
    T9SearchResult * result = [resultArr objectAtIndex:0];
    XCTAssertNotNil([result calcHighlightPinYin:@"  00   song  kai \n"], @"ok!");
    
}

@end
