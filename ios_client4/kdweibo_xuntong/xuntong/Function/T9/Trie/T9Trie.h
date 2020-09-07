//
//  T9Trie.h
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface T9Trie : NSObject

//TODO: 添加是否使用T9键盘搜索的开关


- (id)initWithUsers:(NSArray *)users;
- (NSArray *)search:(NSString *)word;

@end
