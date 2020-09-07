//
//  NSStringAdditions.m
//  Weibo
//
//  Created by junmin liu on 10-9-29.
//  Copyright 2010 Openlab. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSStringAdditions.h"

@implementation NSString (Additions)

+ (NSString *)generateGuid {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
	NSString	*uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
	CFRelease(uuidObj);
    return uuidString ;//autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isWhitespaceAndNewlines {
	NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	for (NSInteger i = 0; i < self.length; ++i) {
		unichar c = [self characterAtIndex:i];
		if (![whitespace characterIsMember:c]) {
			return NO;
		}
	}
	return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isEmptyOrWhitespace {
	return !self.length ||
	![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Copied and pasted from http://www.mail-archive.com/cocoa-dev@lists.apple.com/msg28175.html
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding {
	NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
	NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:self];// autorelease];
	while (![scanner isAtEnd]) {
		NSString* pairString = nil;
		[scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
		[scanner scanCharactersFromSet:delimiterSet intoString:NULL];
		NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
		if (kvPair.count == 2) {
			NSString* key = [[kvPair objectAtIndex:0]
							 stringByReplacingPercentEscapesUsingEncoding:encoding];
			NSString* value = [[kvPair objectAtIndex:1]
							   stringByReplacingPercentEscapesUsingEncoding:encoding];
			[pairs setObject:value forKey:key];
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:pairs];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query {
	NSMutableArray* pairs = [NSMutableArray array];
	for (NSString* key in [query keyEnumerator]) {
		NSString* value = [query objectForKey:key];
		value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
		value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
		NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
		[pairs addObject:pair];
	}
	
	NSString* params = [pairs componentsJoinedByString:@"&"];
	if ([self rangeOfString:@"?"].location == NSNotFound) {
		return [self stringByAppendingFormat:@"?%@", params];
	} else {
		return [self stringByAppendingFormat:@"&%@", params];
	}
}
- (BOOL)isNumText{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}
@end
