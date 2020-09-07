//
//  T9TrieSearchQueueNode.h
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class T9TrieSearchQueueNode;
@class T9TrieFirstNode;
@class T9TrieSearchQueueResult;
@interface T9TrieSearchQueueNode : NSObject

@property (nonatomic,retain) T9TrieSearchQueueNode * parent;
@property (nonatomic,retain) T9TrieFirstNode * currentNode;
@property (nonatomic) int begin;
@property (nonatomic) int matchLength;
@property (nonatomic,retain) T9TrieSearchQueueResult * lastSearchResult;
@property (nonatomic) int currentWord;

- (id) initWithParentNode:(T9TrieSearchQueueNode *)parent
                  curNode:(T9TrieFirstNode *)currentNode
                    begin:(int)begin
              matchLength:(int)matchLength
         lastSearchResult:(T9TrieSearchQueueResult *)last
              currentWord:(int)currentWord;

@end
