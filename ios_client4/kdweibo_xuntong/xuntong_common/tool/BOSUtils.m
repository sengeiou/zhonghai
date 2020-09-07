//
//  BOSUtils.m
//  Public
//
//  Created by Gil on 12-5-23.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "BOSUtils.h"
#import "BOSConfig.h"

#define EMP_Version @"2.0.1"
#define EMP_Support_MiniOSVersion @"5.0"

@implementation BOSUtils

#pragma mark - url encode and decode
+(NSString*)urlEncode:(NSString *)string
{
//	NSString *newString = NSMakeCollectable([(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), kCFStringEncodingUTF8) autorelease]);
    NSString *newString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding));
	if (newString) {
		return newString;
	}
	return @"";
}

+(NSString*)urlDecode:(NSString *)string
{
//	NSString *newString = NSMakeCollectable([(NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef) string,CFSTR(""),kCFStringEncodingUTF8) autorelease]);
    NSString *newString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding));
	if (newString) {
		return newString;
	}
	return @"";
}

#pragma mark - analysis url
+(BOOL)analysisURL:(NSURL *)url result:(NSDictionary **)result
{
    //解析
    NSString *queryStr = [url query];//get url params string
    if (queryStr == nil || [queryStr isEqualToString:@""]) {
        return NO;
    }
    
    //格式1的分隔符，为了兼容之前的客户端调用
    NSString *delimiter1 = @"==";
    NSString *delimiter2 = @"&&";
    NSRange range = [queryStr rangeOfString:delimiter1];
    if (range.location == NSNotFound) {//格式2的分隔符
        delimiter1 = @"=";
        delimiter2 = @"&";
    }
    
    NSArray *paramsArray = [queryStr componentsSeparatedByString:delimiter2];
    if (paramsArray == nil || [paramsArray count] < 3) {//至少存在三个参数
        return NO;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *paramsString in paramsArray) {
        if (paramsString == nil || [paramsString isEqualToString:@""]) 
            continue;
        NSArray *array = [paramsString componentsSeparatedByString:delimiter1];
        if (array != nil && [array count] == 2) {
            NSString *key = [array objectAtIndex:0];
            NSString *value = [array objectAtIndex:1];
            if (key == nil || [key isEqualToString:@""] || value == nil || [value isEqualToString:@""])
                continue;//key 和 value 都不能为空
            if ([delimiter1 isEqualToString:@"=="])
                [dict setObject:value forKey:key];
            else {//vale需要url decode
                NSString *decodeValue = [self urlDecode:value];
                [dict setObject:decodeValue forKey:key];
            }
        }
    }
    if (dict == nil || [dict count] < 3) {
        return NO;
    }
    NSArray *keys = [dict allKeys];
    if ([keys containsObject:@"cust3gNo"] && [keys containsObject:@"userName"] && ([keys containsObject:@"password"] || ([keys containsObject:@"token"] && [keys containsObject:@"token_type"]))) {
        //通过参数验证，传出参数
        if (result) {
            *result = [NSDictionary dictionaryWithDictionary:dict];
        }
        return YES;
    }
    return NO;
}

#pragma mark - shouldAutorotateToInterfaceOrientation

+(BOOL)appShouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[BOSConfig sharedConfig].supportedOrientations containsObject:
         [NSNumber numberWithInt:interfaceOrientation]]) {
        return YES;
    }
	return NO;
}

#pragma mark - plist reader

+(NSDictionary*) getBundlePlist:(NSString*)plistName
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format errorDescription:&errorDesc];
    return temp;
}

#pragma mark - EMP

+ (NSString *)empVersion
{
    return EMP_Version;
}

+ (NSString *)empSupportOSMiniVersion
{
    return EMP_Support_MiniOSVersion;
}

@end
