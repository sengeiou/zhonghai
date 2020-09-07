//
//  BOSUtils.h
//  Public
//
//  Created by Gil on 12-5-23.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOSUtils : NSObject

/*
 @desc URL编码和解码,编码和解码格式为kCFStringEncodingUTF8;
 @param string; -- 需要编码或解码的字符串
 @return 编码或者解码后的字符串;
 */
+(NSString*)urlEncode:(NSString *)string;//编码
+(NSString*)urlDecode:(NSString *)string;//解码

/*
 @desc 解析URL用于第三方应用调用;
 
 目前支持的URL格式为：
 格式1：Scheme://p?cust3gNo==(***)&&userName==(***)&&password==(***)&&token==(***)&&token_type==(***)
 格式2：Scheme://p?cust3gNo=(***)&userName=(***)&password=(***)&token=(***)&token_type=(***)
 注：格式1不作任何处理，怎么传入就怎么传出，比较容易出错（为了兼容老版本而保留）；格式2要求传入的参数值已做URL编码，解析事会对
 参数值解码后传出。推荐使用第二种方式。
 
 @param url; -- 跳入的URL
 @param result; -- 解析后的结果,解析失败是为nil
 @return 解析成功或者失败;
 */
+(BOOL)analysisURL:(NSURL*)url result:(NSDictionary **)result;

/*
 @desc 判断应用是否支持某种屏幕方向;
 @param interfaceOrientation; -- 屏幕方向
 @return BOOL;
 */
+(BOOL)appShouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

/*
 @desc Returns the contents of the named plist bundle, loaded as a dictionary object
 @param plistName; -- 配置文件名
 @return NSDictionary;
 */
+(NSDictionary*)getBundlePlist:(NSString*)plistName;

/*
 @desc emp container的版本号
 @return NSString;
 */
+ (NSString *)empVersion;
/*
 @desc emp container支持的系统最小版本号
 @return NSString;
 */
+ (NSString *)empSupportOSMiniVersion;

@end
