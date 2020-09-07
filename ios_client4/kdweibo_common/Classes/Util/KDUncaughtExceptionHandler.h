//
//  KDUncaughtExceptionHandler.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-19.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDUncaughtExceptionHandler : NSObject {
@private
    
}

+ (NSArray *) backtrace;
- (void) handleException:(NSException *)exception;

@end


void KDInstallUncaughtExceptionHandler();
