//
//  SCPLocalKVStorage.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 8/9/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCPLocalKVStorage : NSMutableDictionary

+ (id)inst;

+ (id)objectForKey:(id)aKey;
+ (void)setObject:(id)anObject forKey:(id)aKey;
+ (void)removeObjectForKey:(id)key;
+ (void)reset;

@end
