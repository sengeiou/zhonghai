//
//  CustomerLogoDownloadDataModel.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 企业Logo下载接口数据模型
 */

#import "BOSBaseDataModel.h"

@interface CustomerLogoDownloadDataModel : BOSBaseDataModel{
    NSString *_logo_;
    NSString *_lastUpdateTime_;
}

//logo的BASE64编码
@property (nonatomic,copy) NSString *logo;

//logo最近更新时间,格式为毫秒数的字符串
@property (nonatomic,copy) NSString *lastUpdateTime;

@end
