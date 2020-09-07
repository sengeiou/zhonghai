//
//  T9TrieSearchQueueResult.m
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "T9TrieSearchQueueResult.h"
#import "T9Utils.h"
#import "T9TrieSearchQueueResultData.h"

@interface T9TrieSearchQueueResult()

@end

static T9TrieSearchQueueResult * emptyResult = nil;
@implementation T9TrieSearchQueueResult

- (id)init
{
    self = [super init];
    if(self)
    {
        _datas = [[NSMutableDictionary alloc]init];
    }
    return self;
}

//TODO: 这个flag好象没啥作用？
- (id)initWithBool:(BOOL)flag
{
    self = [super init];
    if(self)
    {
        _result = [[NSMutableDictionary alloc]init];
    }
    return self;
}

+ (T9TrieSearchQueueResult*)EMPTY_SEARCH_RESULT
{
    if(emptyResult == nil)
    {
        emptyResult = [[T9TrieSearchQueueResult alloc]init];
    }
    return emptyResult;
}

- (BOOL) isEmpty
{
    return ([_datas count] == 0);
}

//权重规则：
//      匹配占比 (1-4)      ( 匹配词 / 总词数 * 16 - 1)
//      靠前度   (5-8)      ( 15 - 离第一个匹配单词的偏移)
//      匹配词个数(9-12)    (1 - n)
//      全匹配个数(13-16)   (1 - n)

// data: NSMutableDictionay<NSNumber(int),NSNumber(boolean)>
- (T9TrieSearchQueueResult*)interSet:(NSMutableDictionary *)data
{
    T9TrieSearchQueueResult * rtn = [[T9TrieSearchQueueResult alloc]init];
    BOOL isEmpty = [self isEmpty];
    
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        BOOL matchAll = [obj boolValue];
        int tmpkey = [key intValue];
        int idKey = tmpkey / 100;
        int wordLen = tmpkey % 100;
        id tmpObj = [_datas objectForKey:[NSNumber numberWithInt:idKey]];
        int32_t weight = -1;
        if(tmpObj != nil)
            weight = [tmpObj intValue];
        
        if(weight == -1 && !isEmpty)
        {
            //continue
        }
        else
        {
            if(weight == -1)
                weight = 0;
            weight += 0x0100;
            if (matchAll)
            {
                weight += 0x1000;
            }
            
            //高位：权重 低位：字符长度(临时)
            //去掉低位，只取一次的值,不要累加
            weight = (weight & 0xFF00);
            NSNumber * obj = [NSNumber numberWithInt: (weight + wordLen)];
            [rtn.datas setObject:obj forKey:[NSNumber numberWithInt:idKey]];
        }
    }];
    return rtn;
}

- (void) adjustResult:(T9TrieSearchQueueResult *) rs match:(NSArray*) match
{
    if(_result == nil || rs.datas == nil )
        return;
    
    int nw = [T9Utils getMatchWord:match];
    if(nw == 1)
        //如果只匹配一个单词，我们认为这种返回不合适，忽略此结果
        return;
    
    [rs.datas enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        int idKey = [key intValue];
        T9TrieSearchQueueResultData * trd = [[T9TrieSearchQueueResultData alloc] initWithPerson:idKey andWeight:0];
        
        int weight = [self adjustWeight:[obj intValue] matchLength:match];
        
        if([_result objectForKey:trd] == nil)
        {//属于新结果
            trd.weight = weight;
            trd.match = match;
            [_result setObject:[NSNumber numberWithInt:weight] forKey:trd];
        }
        else
        {//已存在，判断是否有更高匹配度，有则更新
            int weight1 = [[_result objectForKey:trd] intValue];
            int weight2 = weight;
            if (weight2 > weight1)
            {
                [_result removeObjectForKey:trd];
                trd.weight = weight2;
                trd.match = match;
                [_result setObject:[NSNumber numberWithInt:weight2] forKey:trd];
            }
        }
    }];
}

//补充 占比 和 靠前程度
- (int) adjustWeight:(int)oldWeight matchLength:(NSArray*)match;
{
    int weight = (oldWeight & 0xFF00);
    int wordLen = (oldWeight & 0x00FF);

    //占比
    int matchWordCount = [T9Utils getMatchWord:match];
    int rate = (matchWordCount * 15 ) / wordLen;
    
    //靠前程度
    int front = 15 - [self firstMatch:match];
    if(front < 0) front = 0;

    weight += rate;
    weight += (front <<4);
    
    return weight;
}

- (int) firstMatch:(NSArray*)x
{
    int ret = -1;
    for(int ii = 0,len = (int)[x count]; ii<len; ii++)
    {
        if ([x[ii] intValue] != 0)
        {
            return ii;
        }
    }
    return ret;
}


    
@end
