//
//  CustomerSearchDataModel.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 企业搜索数据模型
 限制企业列表个数为8个，以免暴露过多的企业列表信息
 */

#import "BOSBaseDataModel.h"

@interface CustomerSearchDataModel : BOSBaseDataModel{
    NSString *_cust3gNo_;
    NSString *_customerName_;
}

//企业3G号
@property (nonatomic,copy) NSString *cust3gNo;

//企业名称
@property (nonatomic,copy) NSString *customerName;

@end
