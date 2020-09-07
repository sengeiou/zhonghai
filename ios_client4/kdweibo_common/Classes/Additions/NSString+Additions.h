//
//  NSString+Additions.h
//
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDCommon.h"
#import <CoreLocation/CoreLocation.h>

@interface NSString (KD_Additions)

// utility methods

+ (NSString *)randomStringWithWide:(int)randomWide;
+ (NSString *)formatContentLengthWithBytes:(KDUInt64)bytes;


////////////////////////////////////////////////////////////////

- (NSString*)encodeAsURLWithEncoding:(NSStringEncoding)encoding;

/**
 * escape URL query component.
 */
- (NSString *)escapeAsURLQueryParameter;

// 从当前字符串中根据参数名称搜索参数值
- (NSString *)searchAsURLQueryWithNeedle:(NSString *)needle;


////////////////////////////////////////////////////////////////

// 按照中文长度模式来计算长度
- (NSInteger)textLength;

/**
 * Generate MD5 digest key from current string
 */
- (NSString *)MD5DigestKey;

- (unichar)convertFirstToAZCharacter;
- (NSString *)convertChineseToAZSequence;

- (NSUInteger)convertFirstCharacterToAZIndex;

/**
 * remove the '/' at the index of 1
 */
- (NSString *)stringByAdjustingToValidURLSuffix;

//去掉短邮标题的'(x人)'
- (NSString *)stringByRemovingDMSubjectPostfix;

//- (NSString *)truncateLocationInfo;
//
//- (NSString *)stringByAddLocationInfo:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate;
+ (NSString *)getGuid;
@end
