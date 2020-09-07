//
//  XTShareManager.m
//  kdweibo
//
//  Created by Gil on 14-4-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTShareManager.h"
#import "XTShareDataModel.h"

#import "KDWeiboAppDelegate.h"
#import "KDForwardChooseViewController.h"
#import "UIImage+Extension.h"

@implementation XTShareManager

+ (BOOL)shareWithDictionary:(NSDictionary *)result
{
    int shareType = [[result objectForKey:@"shareType"] intValue];
    if (shareType < ShareMessageText || shareType > ShareMessageApplication) {
        return NO;
    }
    
//    XTShareDataModel *shareDM = [[XTShareDataModel alloc] initWithDictionary:result];
//    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentShare];
//    contentViewController.shareData = shareDM;
//    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
//    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
    
    
    XTShareDataModel *shareDM = [[XTShareDataModel alloc] initWithDictionary:result];
    [shareDM.params setObject:[UIImage capture:[UIApplication sharedApplication].keyWindow] forKey:@"screenimage"];
    
    NSString *groupId = shareDM.params[@"groupId"];
    if (![groupId isKindOfClass:[NSNull class]] && groupId.length > 0) {
        return YES;
    }
    
    KDForwardChooseViewController *contentViewController = [[KDForwardChooseViewController alloc] initWithCreateExtenalGroup:YES];
    contentViewController.isMulti = NO;
    contentViewController.isFromConversation = YES;
    contentViewController.hidesBottomBarWhenPushed = YES;
    contentViewController.isFromFileDetailViewController = NO;   //触发转发文件埋点
    //contentViewController.fileDetailDictionary = notify.userInfo;
    contentViewController.shareData = shareDM;
    //contentViewController.delegate = self;
    contentViewController.type = XTChooseContentShare;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
    
    return YES;
}

+ (BOOL)shareWithDictionary:(NSDictionary *)result andChooseContentType:(XTChooseContentType)type
{
    int shareType = [[result objectForKey:@"shareType"] intValue];
    if (shareType < ShareMessageText || shareType > ShareMessageApplication) {
        return NO;
    }
    
    XTShareDataModel *shareDM = [[XTShareDataModel alloc] initWithDictionary:result];
//    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:type];
//    contentViewController.shareData = shareDM;
//    
//    //KDNavigationController -->KDNavigationController by Tan Yingqi@2014.08.07
//    //修复 "我的收藏"页面left navigationbar item 显示不正常的bug
//    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
//    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
    
    
    KDForwardChooseViewController *contentViewController = [[KDForwardChooseViewController alloc] initWithCreateExtenalGroup:YES];
    contentViewController.isMulti = YES;
    contentViewController.isFromConversation = YES;
    contentViewController.hidesBottomBarWhenPushed = YES;
    contentViewController.isFromFileDetailViewController = NO;   //触发转发文件埋点
    //contentViewController.fileDetailDictionary = notify.userInfo;
    contentViewController.shareData = shareDM;
    //contentViewController.delegate = self;
    contentViewController.type = type;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
    

    
    return YES;
}

@end
