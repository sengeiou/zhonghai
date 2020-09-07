//
//  RCPMemCacheMgr.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/23/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCPMemCacheMgr : NSObject

@property (nonatomic) NSUInteger limit;

+ (RCPMemCacheMgr *)memCacheMgr;
+ (RCPMemCacheMgr *)memCacheMgrWithLimit:(NSUInteger)limit;
- (RCPMemCacheMgr *)initWithLimit:(NSUInteger)limit;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;
- (void)reset;
@end
