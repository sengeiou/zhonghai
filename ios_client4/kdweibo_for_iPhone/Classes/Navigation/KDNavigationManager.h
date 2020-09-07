//
//  KDNavigationManager.h
//  kdweibo
//
//  Created by Gil on 15/7/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDNavigationManager : NSObject <UINavigationControllerDelegate>
+ (instancetype)sharedNavigationManager;
//一级界面
@property (strong, nonatomic) NSArray *tabViewControllers;
@end

@interface UIViewController (KDNavigationManager)
@property (strong, nonatomic, readonly) NSString *backBtnTitle;
@end
