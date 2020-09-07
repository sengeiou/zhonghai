//
//  T9TrieFirstNode.m
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "T9TrieFirstNode.h"
#import "T9TrieWordNode.h"
#import "T9Utils.h"

@interface T9TrieFirstNode()
{
    
}

@end

@implementation T9TrieFirstNode

- (id)init
{
    self = [super init];
    if(self)
    {
        _trieWord = [[T9TrieWordNode alloc]init];
    }
    return self;
}

- (void)insertWithPinYinWords:(NSArray*)pinYinWords object:(T9SearchPerson *)user
{
    if ([pinYinWords count] == 0)
        return;
    
    T9TrieFirstNode * p = self;
    for(NSString * word in pinYinWords)
    {
        if(word == nil || [word length] == 0)
            continue;
        char ch = [word characterAtIndex:0];
        int index = [T9Utils getIndex:ch];
        if (p.next == nil)
            p.next = [[NSMutableDictionary alloc]init];
        T9TrieFirstNode * tp = [p.next objectForKey:[NSNumber numberWithInt:index]];
        if(tp != nil)
        {
            p = tp;
        }
        else
        {
            tp = [[T9TrieFirstNode alloc]init];
            [p.next setObject:tp forKey:[NSNumber numberWithInt:index]];
            p = tp;
        }
        [p.trieWord insert:word object:user];
    }
}

@end
