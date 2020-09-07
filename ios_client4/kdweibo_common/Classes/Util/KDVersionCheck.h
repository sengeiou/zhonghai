//
//  KDVersionCheck.h
//  kdweibo_common
//
//  Created by Gil on 14-9-19.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDVersionCheck : NSObject

@property (nonatomic, assign) BOOL showUpdateInfo;

+ (void)checkUpdate:(BOOL)showUpdateInfo;
+ (void)checkVersionInfoVisible:(BOOL)visible info:(NSString *)info;

@end
