//
//  T9TrieWordNode.m
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "T9TrieWordNode.h"
#import "T9SearchPerson.h"
#import "T9Utils.h"

@implementation T9TrieWordNode

-(void) insert:(NSString*)word object:(T9SearchPerson*)user
{
    T9TrieWordNode * p = self;
    for(int i = 0, len =(int)[word length]; i < len; i ++ )
    {
        int index = [T9Utils getIndex:[word characterAtIndex:i]];
        if ( p.next == nil )
        {
            p.next = [[NSMutableDictionary alloc]init];
        }
        T9TrieWordNode * tp = [p.next objectForKey:[NSNumber numberWithInt:index]];
        if(tp != nil)
        {
            p = tp;
        }
        else
        {
            tp = [[T9TrieWordNode alloc]init];
            [p.next setObject:tp forKey:[NSNumber numberWithInt:index]];
            p = tp;
        }
    }
    
    if (p.data == nil)
    {
        p.data = [[NSMutableDictionary alloc]init];
    }
    int wordLen = (int)[user.fullPinyins count];
    int dataValue = user.userId * 100 + wordLen;
    [p.data setObject:[NSNumber numberWithBool:YES]
               forKey:[NSNumber numberWithInt:dataValue]];
}

- (NSMutableDictionary*) getAllData
{
    //NSMutableDictionary<NSNumber(int),NSNumber(boolean)>
    NSMutableDictionary * rtn = [[NSMutableDictionary alloc]init];
    if(_data != nil )
    {
        for(NSNumber * number in [_data allKeys])
        {
            //我们认为在此结点的单词，属于全匹配，置标志yes.
            [rtn setObject:[NSNumber numberWithBool:YES] forKey:number];
        }
    }
    if(_next != nil)
    {
        for(NSNumber * number in [_next allKeys])
        {
            T9TrieWordNode * p = [_next objectForKey:number];
            NSAssert(p != nil , @"p must not nil!");
            [self getChildData:rtn wordTrie:p];
        }
    }
    return rtn;
}

- (void) getChildData:(NSMutableDictionary *)rtn  wordTrie:(T9TrieWordNode *)p
{
    if (p.data != nil)
    {
        for(NSNumber * number in [p.data allKeys])
        {
            //这是匹配结点后续的子结点，属于模糊匹配的单词，置状态no
            [rtn setObject:[NSNumber numberWithBool:NO] forKey:number];
        }
    }
    if(p.next != nil )
    {
        for(NSNumber * number in [p.next allKeys])
        {
            T9TrieWordNode * cp = [p.next objectForKey:number];
            NSAssert(cp != nil, @"cp must not nil!");
            [self getChildData:rtn wordTrie:cp];
        }
    }
}

@end
