//
//  T9TrieSearchQueueNode.m
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "T9TrieSearchQueueNode.h"
#import "T9TrieFirstNode.h"
#import "T9TrieSearchQueueResult.h"

@interface T9TrieSearchQueueNode()

@end

@implementation T9TrieSearchQueueNode

- (id) initWithParentNode:(T9TrieSearchQueueNode *)parent
                  curNode:(T9TrieFirstNode *)currentNode
                    begin:(int)begin
              matchLength:(int)matchLength
         lastSearchResult:(T9TrieSearchQueueResult *)last
              currentWord:(int)currentWord
{
    self = [super init];
    if(self)
    {
        self.parent = parent;
        self.currentNode = currentNode;
        self.begin = begin;
        self.matchLength = matchLength;
        self.lastSearchResult = last;
        self.currentWord = currentWord;
    }
    return self;
}

@end
