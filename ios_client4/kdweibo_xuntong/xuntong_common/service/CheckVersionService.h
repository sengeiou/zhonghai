//
//  CheckVersionService.h
//  Public
//
//  Created by Gil on 12-5-8.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCloudClient;
@interface CheckVersionService : NSObject <UIAlertViewDelegate> {
    MCloudClient *_clientCloud_;
    NSString *_updateURL_;
    NSString *_newversion_;
}

//新版本的url
@property (nonatomic,copy) NSString *updateURL;

//要升级到的新版本
@property (nonatomic,copy) NSString *newversion;

/*
 @desc 运行版本更新检测服务，如果有更新，会提示用户;
 @return void;
 */
-(void)run;

@end
