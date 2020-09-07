//
//  KDApplicationOpenHelper.h
//  kdweibo
//
//  Created by sevli on 15/10/28.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDApplicationOpenHelper : NSObject

//跳转应用
+ (void)goToAppWithAppDataModel:(KDAppDataModel *)appDM Controller:(UIViewController *)controller;

//跳转第三方应用
+ (void)openNativeThirdPartAppWithAppDM:(KDAppDataModel *)appDM Controller:(UIViewController *)currentController;


+ (UIViewController *)currentViewController;

// navigation Reset
+ (void)resetApplicationViewControllerNavigationBar;

// 埋点
+ (void)EventAnalysisForApp:(NSString *)appId;


/**
 *  判断该应用是否已添加到应用中心
 *
 *  @param appDM 应用model
 *
 *  @return 是否已添加
 */
+ (BOOL)hasFavorite:(KDAppDataModel *)appDM;

/**
 *  应用的 打开/添加 操作
 *
 *  @param appDM       应用model
 *  @param controller  源调用controller
 *  @param addComplete 添加应用回调(不论成功与否)
 */
+ (void)operateApplication:(KDAppDataModel *)appDM controller:(UIViewController *)controller addComplete:(void(^)())addComplete;
@end

@interface KDAppDownLoadAlertManager : NSObject<UIAlertViewDelegate>

@property (nonatomic, copy) NSString *downLoadUrl;

+ (id)sharedManager;


@end