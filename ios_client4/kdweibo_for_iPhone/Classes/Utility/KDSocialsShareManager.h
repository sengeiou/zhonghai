//
//  KDSocialsShareManager.h
//  kdweibo
//
//  Created by AlanWong on 14-8-5.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <TencentOpenAPI/QQApi.h>
#import "KDSocialShareModal.h"

@interface KDSocialsShareManager : NSObject

#define SHARE_MANAGER [KDSocialsShareManager shareSocialsShareManager]

+(KDSocialsShareManager *)shareSocialsShareManager;

//注册各个平台的信息
+ (void)registerQQ;
+ (void)registerWeChat;
+ (void)registerSinaWeibo;

//处理调用的URL
+ (BOOL)qqHandleOpenURL:(NSURL *)url;

+ (BOOL)weChatHandleOpenURL:(NSURL *)url
                   delegate:(id <WXApiDelegate>)delegate;

+ (BOOL)sinaWeiboHandleOpenURL:(NSURL *)url
                      delegate:(id <WeiboSDKDelegate>)delegate;



#pragma mark - 微博 -

// 文本
- (void)shareToWeiboWithText:(NSString *)text;

// 图片
- (void)shareToWeiboWithImageData:(NSData *)dataImage;

// 富文本
- (void)shareToWeiboWithTitle:(NSString *)strTitle
                  description:(NSString *)strDesc
                    thumbData:(NSData *)dataThumb
                   webpageUrl:(NSString *)strWebPageUrl;

#pragma mark - QQ/Qzone -

// 文本
- (void)shareToQQWithText:(NSString *)text
                  isQzone:(BOOL)bQzone;

// 图片
- (void)shareToQQWithImageData:(NSData *)dataImage
                       isQzone:(BOOL)bQzone;

// 富文本
- (void)shareToQQWithTitle:(NSString *)strTitle
               description:(NSString *)strDesc
                 thumbData:(NSData *)dataThumb
                webpageUrl:(NSString *)strWebPageUrl
                   isQzone:(BOOL)bQzone;

#pragma mark - 微信/朋友圈 -

// 文本
- (void)shareToWechatWithText:(NSString *)text
                   isTimeline:(BOOL)bTimeline;
// 图片
- (void)shareToWechatWithImageData:(NSData *)dataImage
                        isTimeline:(BOOL)bTimeline;

// 富文本
- (void)shareToWechatWithTitle:(NSString *)strTitle
                   description:(NSString *)strDesc
                     thumbData:(NSData *)dataThumb
                    webpageUrl:(NSString *)strWebPageUrl
                    isTimeline:(BOOL)bTimeline;


#pragma mark - SMS -

// 文本
- (void)shareToMessageText:(NSString *)text
                  delegate:(id <MFMessageComposeViewControllerDelegate>)delegate
            viewController:(UIViewController *)viewController;



#pragma mark - 旧接口 -

//- (void)shareToSinaWeiboText:(NSString *)text
//                       image:(UIImage *)image;
//
//- (void)shareToQQText:(NSString *)text
//             delegate:(id <KDSocialsShareManagerDelegate>)delegate;
//
//- (void)shareToQQImage:(UIImage *)image
//                 title:(NSString * )title
//           description:(NSString *)description
//          previewImage:(UIImage *)previewImage
//              delegate:(id <KDSocialsShareManagerDelegate>)delegate;
//
//- (void)shareToWeChatImage:(UIImage * )image
//                thumbImage:(UIImage *)thumbImage;
//
//- (void)shareToWeChatLinkUrl:(NSString * )urlString
//                       title:(NSString *)title
//                 description:(NSString *)description
//                  thumbImage:(UIImage *)thumbImage;


@end
