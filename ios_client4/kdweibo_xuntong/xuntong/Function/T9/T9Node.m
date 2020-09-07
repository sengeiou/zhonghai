//
//  T9Node.m
//  TestT9
//
//  Created by Gil on 13-1-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "T9Node.h"
#import "T9Trie.h"
#import "T9SearchResult.h"
#import "T9Utils.h"
#import "T9SearchPerson.h"

@interface T9Node()
+(NSMutableSet *)mergeSet:(NSSet *)set1 withSet:(NSSet *)set2;
@end

@implementation T9Node

-(void)dealloc
{
    [_root release];
    [super dealloc];
}

-(id)init
{
    self = [super init];
    if (self) {
        _root = [[Node alloc] init];
    }
    return self;
}

-(void)insertWithStr:(NSArray *)strArray object:(id)d
{
    if ([strArray count] == 0)
        return;
    Node *p = _root;
    for (int i = 0; i < [strArray count]; i++) {
        NSString *ss = [strArray objectAtIndex:i];
        if(ss.length == 0){
            continue;
        }
        int index = [T9Utils getIndex:[ss characterAtIndex:0]];
        if (p.next[index] != [NSNull null]) {
            p = p.next[index];
        } else {
            Node *q = [[[Node alloc] init] autorelease];
            p.next[index] = q;
            p = p.next[index];
        }
        [p.trie insertWithStr:ss object:d];
    }
}

+(NSMutableSet *)mergeSet:(NSSet *)set1 withSet:(NSSet *)set2
{
    NSMutableSet *rtn = [[[NSMutableSet alloc] init] autorelease];
    for (T9SearchPerson *obj in set1) {
        if ([set2 containsObject:obj])
            [rtn addObject:obj];
    }
    return rtn;
}

-(void)dfs:(Node *)p queue:(NSMutableArray *)queue chs:(char [])chs sr:(SearchResult2 *)sr length:(int)length result:(NSMutableArray *)resultSet trieNode:(TrieNode *)trieNode end:(int)end
{
    if (end >= length)
        return;
    NSString *currentStr = [T9Utils getChars:chs[end]];
    for (int i = 0; i < currentStr.length; i++) {
        char c = [currentStr characterAtIndex:i];
        int index = [T9Utils getIndex:c];
        if ([trieNode.next objectAtIndex:index] != [NSNull null]) {
            [self dfs:p queue:queue chs:chs sr:sr length:length result:resultSet trieNode:[trieNode.next objectAtIndex:index] end:end+1];
            NSMutableSet *trs = [(TrieNode *)[trieNode.next objectAtIndex:index] data];
            if (sr.probaSet != nil) {
                trs = [self.class mergeSet:trs withSet:sr.probaSet];
            }
            if (end + 1 == length) {
                NSMutableArray *matchLength = [NSMutableArray array];
                [matchLength addObject:[NSNumber numberWithInt:(end-sr.end+1)]];
                SearchResult2 *srTmp = sr;
                while (srTmp != nil) {
                    [matchLength insertObject:[NSNumber numberWithInt:srTmp.matchLength] atIndex:0];
                    srTmp = srTmp.parent;
                }
                [matchLength removeObjectAtIndex:0];
                [matchLength removeObjectAtIndex:0];
                
                int total = 0;
                for (NSNumber *num in matchLength) {
                    total += [num intValue];
                }
                for (T9SearchPerson *user in trs) {
                    int pinyinsLength = [user.fullPinyins count];
                    //计算权重
                    int weight = 0;
                    int mw = [T9Utils getMatchWord:matchLength];
                    if (pinyinsLength == 1 || mw > 1) {
                        weight += mw;
                        if (mw == pinyinsLength) {
                            weight += 100;
                        }
                        
                        int totalPinyins = 0;
                        for (NSString *pinyin in user.fullPinyins) {
                            totalPinyins += [pinyin length];
                        }
                        if (total == totalPinyins) {
                            weight += 1000;
                        }
                        [resultSet addObject:[[[T9SearchResult alloc] initWithUserId:user.userId matchLength:matchLength weight:weight type:T9ResultTypeT9] autorelease]];
                    }
                }
        
                continue;
            }
            for (id n in p.next) {
                if (n != [NSNull null])
                    [queue addObject:[[[SearchResult2 alloc] initWithParent:sr node:n begin:sr.end end:end+1 probaSet:trs matchLength:(end-sr.end+1)] autorelease]];
            }
        }
    }
}

-(NSArray *)search:(NSString *)str
{
    NSMutableArray *resultSet = [[[NSMutableArray alloc] init] autorelease];
    
    NSMutableArray *queue = [[[NSMutableArray alloc] init] autorelease];
    [queue addObject:[[[SearchResult2 alloc] initWithParent:nil node:_root begin:0 end:0 probaSet:nil matchLength:0] autorelease]];
    
    char chs[str.length];
    for (int i = 0; i < str.length; i++) {
        chs[i] = [str characterAtIndex:i];
    }
    
    while ([queue count] > 0) {
        SearchResult2 *sr = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
        
        Node *p = sr.node;
        
        [self dfs:p queue:queue chs:chs sr:sr length:str.length result:resultSet trieNode:p.trie.root end:sr.end];
        
        if (sr.begin + sr.end == 0) {
            for (id n in p.next) {
                if (n != [NSNull null])
                    [queue addObject:[[[SearchResult2 alloc] initWithParent:sr node:n begin:0 end:0 probaSet:nil matchLength:0] autorelease]];
            }
        }
    }
    
    if ([resultSet count] > 1) {
        //排序
        NSArray *sortedArray = [resultSet sortedArrayUsingComparator:^NSComparisonResult(T9SearchResult *a, T9SearchResult *b){
            return b.weight - a.weight;
        }];
        [resultSet removeAllObjects];
        
        //去重复
        NSMutableArray *userIds = [NSMutableArray array];
        for (T9SearchResult *eachResult in sortedArray) {
            if ([userIds containsObject:[NSNumber numberWithInt:eachResult.userId]]) {
                continue;
            }else{
                [userIds addObject:[NSNumber numberWithInt:eachResult.userId]];
                [resultSet addObject:eachResult];
            }
        }
    }
    return resultSet;
}

@end


@implementation Node

-(void)dealloc
{
    [_next release];
    [_trie release];
    [super dealloc];
}

-(id)init
{
    self = [super init];
    if (self) {
        _next = [[NSMutableArray alloc] initWithObjects:[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],nil];
        _trie = [[T9Trie alloc] init];
    }
    return self;
}

@end

@implementation SearchResult2

-(void)dealloc
{
    [_parent release];
    [_node release];
    [_probaSet release];
    [super dealloc];
}

-(id)initWithParent:(SearchResult2 *)parent node:(Node *)node begin:(int)begin end:(int)end probaSet:(NSSet *)probaSet matchLength:(int)matchLength
{
    self = [super init];
    if (self) {
        _parent = [parent retain];
        _node = [node retain];
        _begin = begin;
        _end = end;
        _probaSet = [probaSet retain];
        _matchLength = matchLength;
    }
    return self;
}

@end
