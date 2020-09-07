//
//  DemoAccountDataModel.h
//  EMPNativeContainer
//
//  Created by Gil on 12-11-21.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "BOSBaseDataModel.h"

@interface DemoAccountDataModel : BOSBaseDataModel{
    NSString *_cust3gNo_;
    NSString *_userName_;
    NSString *_password_;
}

//演示3g号
@property (nonatomic,copy) NSString *cust3gNo;
//演示用户名
@property (nonatomic,copy) NSString *userName;
//演示密码
@property (nonatomic,copy) NSString *password;

@end
