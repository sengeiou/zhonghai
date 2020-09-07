//
//  T9Node.h
//  TestT9
//
//  Created by Gil on 13-1-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Node;
@class T9SearchPerson;
@interface T9Node : NSObject

@property (nonatomic,retain) Node *root;

-(void)insertWithStr:(NSArray *)strArray object:(T9SearchPerson *)d;
-(NSArray *)search:(NSString *)str;

@end


@class T9Trie;
@interface Node : NSObject

@property (nonatomic,retain) NSMutableArray *next;
@property (nonatomic,retain) T9Trie *trie;

@end

@interface SearchResult2 : NSObject

@property (nonatomic,retain) SearchResult2 *parent;
@property (nonatomic,retain) Node *node;
@property (nonatomic,assign) int begin;
@property (nonatomic,assign) int end;
@property (nonatomic,retain) NSSet *probaSet;
@property (nonatomic,assign) int matchLength;

-(id)initWithParent:(SearchResult2 *)parent
               node:(Node *)node
              begin:(int)begin
                end:(int)end
           probaSet:(NSSet *)probaSet
        matchLength:(int)matchLength;

@end
