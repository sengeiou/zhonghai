//
//  T9TrieWordNode.h
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class T9SearchPerson;
@interface T9TrieWordNode : NSObject

@property (nonatomic,retain) NSMutableDictionary * next; //<NSNumber(int),T9TrieWordNode>
@property (nonatomic,retain) NSMutableDictionary * data; //<NSNumber(int),NSNumber(boolean)

-(void) insert:(NSString*)word object:(T9SearchPerson*)user;
- (NSMutableDictionary*) getAllData;

@end
