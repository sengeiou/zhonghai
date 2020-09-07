//
//  T9TrieFirstNode.h
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class T9SearchPerson;
@class T9TrieWordNode;
@interface T9TrieFirstNode : NSObject
{
    
}
@property (nonatomic,retain)NSMutableDictionary * next; //<NSNumber(int),T9TrieFirstNode>
@property (nonatomic,retain)T9TrieWordNode * trieWord;

- (void)insertWithPinYinWords:(NSArray*)pinYinWords object:(T9SearchPerson *)user;

@end
