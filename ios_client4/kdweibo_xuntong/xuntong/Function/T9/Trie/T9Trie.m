//
//  T9Trie.m
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "T9Trie.h"
#import "T9SearchPerson.h"
#import "T9TrieFirstNode.h"
#import "T9TrieSearchQueueNode.h"
#import "T9TrieSearchQueueResult.h"
#import "T9TrieSearchQueueResultData.h"
#import "T9SearchResult.h"
#import "T9Utils.h"
#import "T9TrieWordNode.h"

@interface T9Trie()
{
    T9TrieFirstNode * _root;
}

@end

@implementation T9Trie

- (id)initWithUsers:(NSArray *)users
{
    self = [super init];
    if(self)
    {
#if DEBUG
        NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
#endif
        T9TrieFirstNode * _tmpRoot = [[T9TrieFirstNode alloc]init];
        for (T9SearchPerson *user in users) {
            [_tmpRoot insertWithPinYinWords:user.fullPinyins object:user];
        }
        _root = _tmpRoot;
#if DEBUG
        NSLog(@"T9Trie init use : %lf s",[[NSDate date] timeIntervalSince1970] - t);
#endif
    }
    return self;
}

- (NSArray *)search:(NSString *)word
{
    T9TrieFirstNode * tmpRoot = _root;
    T9TrieSearchQueueResult * result = [[T9TrieSearchQueueResult alloc]initWithBool:YES];

    // NSArray<T9TrieSearchQueueNode>
    NSMutableArray * queue = [[NSMutableArray alloc]init];
    if(tmpRoot.next != nil)
    {
        [tmpRoot.next enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            T9TrieSearchQueueNode * queueNode =
            [[T9TrieSearchQueueNode alloc] initWithParentNode:nil curNode:obj begin:0 matchLength:0 lastSearchResult:[T9TrieSearchQueueResult EMPTY_SEARCH_RESULT] currentWord:0];
            [queue addObject:queueNode];
        }];
    }
    while([queue count] != 0)
    {
        T9TrieSearchQueueNode * seachQueueNode = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
        T9TrieFirstNode * node = seachQueueNode.currentNode;
        if(node == nil)
            continue;
        [self dfs:result searchWord:word queue:queue searchQueueNode:seachQueueNode index:seachQueueNode.begin wordTrie:node.trieWord];
        if(seachQueueNode.begin == 0 &&
           node.next != nil )
        {
            [node.next enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                T9TrieSearchQueueNode * queueNode =
                [[T9TrieSearchQueueNode alloc]
                    initWithParentNode:seachQueueNode
                                              curNode:obj
                                                begin:0
                                          matchLength:0
                                     lastSearchResult:[T9TrieSearchQueueResult EMPTY_SEARCH_RESULT]
                                          currentWord:seachQueueNode.currentWord + 1];
                [queue addObject:queueNode];
            }];
        }
    }
    //NSArray<T9SearchResult>
    NSMutableArray * rtn = [[NSMutableArray alloc]init];
    //NSSet<NSNumber(int)>
    NSMutableSet * idSet = [[NSMutableSet alloc]init];
    
    [result.result enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        T9TrieSearchQueueResultData * sqrd = key;
        int personId = sqrd.personId;
        if(![idSet containsObject:[NSNumber numberWithInt:personId]])
        {
            [idSet addObject:[NSNumber numberWithInt:personId]];
            [rtn addObject:[[T9SearchResult alloc]initWithUserId:personId
                                                     matchLength:sqrd.match
                                                          weight:sqrd.weight
                                                            type:T9ResultTypeT9]];
        }
    }];
    
    NSEnumerator * enumerator = [result.result keyEnumerator];
    T9TrieSearchQueueResultData * sqrd = nil;
    while ((sqrd = enumerator.nextObject))
    {
        int personId = sqrd.personId;
        if(![idSet containsObject:[NSNumber numberWithInt:personId]])
        {
            [idSet addObject:[NSNumber numberWithInt:personId]];
            [rtn addObject:[[T9SearchResult alloc]initWithUserId:personId
                                                     matchLength:sqrd.match
                                                          weight:sqrd.weight
                                                            type:T9ResultTypeT9]];
        }
    }
    return rtn;
}


/**
 * 搜索
 * input:
 *  searchWord:         搜索的关键词
 *  queue:              待搜索的队列
 *  searchQueueNode:    本次搜索的结点
 *  index:              搜索关键词的下标索引
 *  wordTrie:           待搜索的单词树
 * output:
 *  rtn:                搜索的结果
 *
 **/
- (void)dfs:(T9TrieSearchQueueResult *)rtn searchWord:(NSString*)searchWord
            queue:(NSMutableArray *)queue
            searchQueueNode:(T9TrieSearchQueueNode *)searchQueueNode
            index:(int)i
            wordTrie:(T9TrieWordNode *)wordTrie
{
    if(i >= searchWord.length)
        return;
    T9TrieFirstNode * node = searchQueueNode.currentNode;
    T9TrieSearchQueueResult * result = searchQueueNode.lastSearchResult;

    //TODO: 这里暂不考虑T9键盘的搜索，所以输入的某个键只存在单一字符，不代表多个字符
    char ch = [searchWord characterAtIndex:i];
    int index = [T9Utils getIndex:ch];
    T9TrieWordNode * nextTrie = nil;
    if(wordTrie.next != nil)
    {
        //在单词树中匹配
        nextTrie = [wordTrie.next objectForKey:[NSNumber numberWithInt:index]];
    }
    if(nextTrie != nil)
    {
        int len = i - searchQueueNode.begin + 1;
        if( i ==  searchWord.length - 1)
        {//搜索完成
            //记录每个单词的匹配情况
            NSMutableArray * matchLength = [[NSMutableArray alloc]init];
            //这是最后一个单词的匹配长度
            [matchLength insertObject:[NSNumber numberWithInt:len] atIndex:0];
            T9TrieSearchQueueNode * srTmp = searchQueueNode;
            while(srTmp != nil)
            {
                //循环加入之前搜索单词的匹配长度
                [matchLength insertObject:[NSNumber numberWithInt:srTmp.matchLength] atIndex:0];
                srTmp = srTmp.parent;
            }
            //去掉首字母树结点的值 ，无意义，不属于单词树。
            [matchLength removeObjectAtIndex:0];
            
            //用找到的节点的所有子数据（认定符合搜索结果） 和上一次的结果进行合并
            T9TrieSearchQueueResult * result1 = [result interSet:[nextTrie getAllData]];
            [rtn adjustResult:result1 match:matchLength];
        }
        
        [self dfs:rtn searchWord:searchWord queue:queue searchQueueNode:searchQueueNode index:i + 1 wordTrie:nextTrie];
        
        T9TrieSearchQueueResult * result1 = [result interSet:[nextTrie getAllData]];
        if (![result1 isEmpty] && node.next != nil)
        {
            [node.next enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                T9TrieSearchQueueNode * queueNode =
                    [[T9TrieSearchQueueNode alloc] initWithParentNode:searchQueueNode
                                                              curNode:obj begin:i + 1
                                                          matchLength:len
                                                     lastSearchResult:result1
                                                          currentWord:searchQueueNode.currentWord + 1];
                [queue addObject:queueNode];
            }];
        }
    }
}


@end
