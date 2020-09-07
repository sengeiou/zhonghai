//
//  KDFailureSignInTask.h
//  kdweibo
//
//  Created by lichao_liu on 15/3/17.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSignInRecord.h"

@interface KDFailureSignInTask : NSObject {
    UIViewController *_controller;
}
+ (id)sharedFailureSignInTask;

- (void)setUpData;

- (void)stopFailureSignInTask;

- (void)uploadFailedRecord;

@end
