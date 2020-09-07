//
//  KDLockControl.h
//  SaleProcess
//
//  Created by 曾昭英 on 12-10-13.
//  Copyright (c) 2012年 Achievo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kIsSetDone @"kIsSetDone"
#define kLockPW @"kLockPW"
#define kStopTime @"kStopTime"
#define kHasBeenUsed @"kHasBeenUsed"
@interface KDLockControl : NSObject

@property (nonatomic, strong) NSString *lockPassword;
@property (nonatomic) BOOL isSetDone;
@property (nonatomic ,assign) BOOL hasBeenUsed;
@property (nonatomic) BOOL isReadyToEnterPW;    //手势密码是否准备输入

@property(nonatomic) double stopTime;

+ (KDLockControl *)shared;

@end
//Pattern Lock