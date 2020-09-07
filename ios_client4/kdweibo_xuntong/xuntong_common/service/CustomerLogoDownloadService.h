//
//  CustomerLogoDownloadService.h
//  Public
//
//  Created by Gil on 12-5-8.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PRE_CUSTOMERLOGONAME @"customerLogo"

@class MCloudClient;
@interface CustomerLogoDownloadService : NSObject{
    MCloudClient *_clientCloud_;
}

/*
 @desc 运行企业Logo下载服务；
 下载完成后以“customerLogo_cust3gNo”的名称命名放在Documents文件夹下;
 @return void;
 */
-(void)run;

@end
