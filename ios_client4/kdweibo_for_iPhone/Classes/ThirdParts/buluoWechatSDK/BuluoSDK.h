//
//  BuluoSDK.h
//  BuluoSDK
//
//  Created by haining_huang on 16/5/26.
//  Copyright © 2016年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuluoObject.h"

@interface BuluoSDK : NSObject
/**
 *  向部落终端程序注册第三方应用。
 *  需要在每次启动第三方应用程序时调用。
 *
 *  @param appId     开发者AppKey
 *  @param appSecret 开发者AppSecret
 *
 *  @return 成功返回YES，失败返回NO。
 */
+ (BOOL)registerApp:(NSString *)appId withAppSecret:(NSString *)appSecret;

/**
 *  进入微信社区
 *
 *  @param openUser 用户对象
 *  @param webView  界面webView实例
 *  @param failure  错误信息
 */
+ (void)openCommunityWithOpenUser:(OpenUser *)openUser webView:(UIWebView *)webView failure:(void (^)(NSError *error))failure;

/**
 *  退出微信社区
 *  清理SDK的数据信息
 */
+ (void)exitCommunity;

@end
