//
//  KDAlertViewRecorder.h
//  kdweibo
//
//  Created by kingdee on 17/5/8.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDAlertViewRecorder : NSObject

@property (nonatomic, strong)NSMutableArray * alertViewArray;

+ (KDAlertViewRecorder *)shareAlertViewRecorder;

@end
