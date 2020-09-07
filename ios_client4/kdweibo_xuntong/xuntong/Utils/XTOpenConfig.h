//
//  XTOpenConfig.h
//  XT
//
//  Created by Gil on 13-11-25.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMPDelegate.h"

@interface XTOpenConfig : NSObject

@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *code;

@property (assign, nonatomic) BOOL isCreater;

@property (strong, nonatomic, readonly) NSString *longPhoneNumber;

@property (nonatomic, weak) id<EMPLoginDelegate> loginDelegate;



//以下为短信上行接口回调字段
@property (nonatomic, strong) NSString *smsCode;
@property (nonatomic, strong) NSString *smsToken;
@property (nonatomic, strong) NSString *smsCMNumber;
@property (nonatomic, strong) NSString *smsCUNumber;
@property (nonatomic, strong) NSString *smsCTNumber;


+(XTOpenConfig *)sharedConfig;

@end
