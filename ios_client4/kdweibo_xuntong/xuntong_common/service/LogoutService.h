//
//  LogoutService.h
//  Public
//
//  Created by Gil on 12-5-9.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMPServerClient;
@interface LogoutService : NSObject{
    EMPServerClient *_clientServer_;
}

/*
 @desc 运行注销服务
 @return void;
 */
- (void)run;

@end
