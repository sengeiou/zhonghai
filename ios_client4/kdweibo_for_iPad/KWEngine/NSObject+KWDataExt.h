//
//  NSObject+KWDataExt.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/28/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KWDataExt)

- (NSString *)kwStringForKey:(NSString *)key;
- (NSArray *)kwArrayForKey:(NSString *)key;
- (NSDictionary *)kwDictForKey:(NSString *)key;
- (NSDate *)kwDateForKey:(NSString *)key;
- (BOOL)kwBoolForKey:(NSString *)key;
- (NSNumber *)kwNumberForKey:(NSString *)key;
- (NSDecimalNumber *)kwDecimalNumberForKey:(NSString *)key;

- (BOOL)kwIsPresent;
- (BOOL)kwIsBlank;

@end
