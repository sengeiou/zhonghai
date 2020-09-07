//
//  CustomerLogoDownloadService.m
//  Public
//
//  Created by Gil on 12-5-8.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "CustomerLogoDownloadService.h"
#import "BOSSetting.h"
#import "MCloudClient.h"
#import "CustomerLogoDownloadDataModel.h"
#import "BOSFileManager.h"
#import "NSDataAdditions.h"

@implementation CustomerLogoDownloadService

-(void)run
{
    BOSSetting *setting = [BOSSetting sharedSetting];
    if (setting.cust3gNo.length == 0) {
        return;
    }
    
    if (_clientCloud_ == nil) {
        _clientCloud_ = [[MCloudClient alloc] initWithTarget:self action:@selector(customerLogoDownloadDidReceived:result:)];
    }
    [_clientCloud_ customerLogoDownloadWithCust3gNo:setting.cust3gNo lastUpdateTime:[setting.logoUpdateTimes objectForKey:setting.cust3gNo]];
}

-(void)customerLogoDownloadDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (!result.success || result.data == nil) {
        return;
    }
   
    CustomerLogoDownloadDataModel *logoDM = [[CustomerLogoDownloadDataModel alloc] initWithDictionary:result.data];// autorelease];
    if (![logoDM.logo isEqualToString:@""]) {
        //保存logo，更新logo下载时间
        BOSSetting *setting = [BOSSetting sharedSetting];
        [BOSFileManager writeToFile:[NSData base64DataFromString:logoDM.logo] fileName:[NSString stringWithFormat:@"%@_%@",PRE_CUSTOMERLOGONAME,setting.cust3gNo]];
        [setting.logoUpdateTimes setObject:logoDM.lastUpdateTime forKey:setting.cust3gNo];
        [setting saveSetting];
    }
}

- (void)dealloc
{
    //BOSRELEASE_clientCloud_);
    //[super dealloc];
}

@end
