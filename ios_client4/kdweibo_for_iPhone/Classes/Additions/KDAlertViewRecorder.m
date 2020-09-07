//
//  KDAlertViewRecorder.m
//  kdweibo
//
//  Created by kingdee on 17/5/8.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDAlertViewRecorder.h"

@implementation KDAlertViewRecorder

+ (KDAlertViewRecorder *)shareAlertViewRecorder
{
    static KDAlertViewRecorder *recoder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(recoder == nil){
            recoder = [[KDAlertViewRecorder alloc] init];
        }
    });
    return recoder;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alertViewArray = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
