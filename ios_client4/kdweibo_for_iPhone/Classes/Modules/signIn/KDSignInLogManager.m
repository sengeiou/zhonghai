//
//  KDSignInLogManager.m
//  kdweibo
//
//  Created by 张培增 on 2017/1/12.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDSignInLogManager.h"

NSString *const KDSignInFailedTypeNormal = @"签到失败";
NSString *const KDSignInFailedTypeLocation = @"定位失败";
NSString *const KDSignInFailedTypePOIError = @"获取POI出错";

@implementation KDSignInLogManager

+ (void)sendSignInLogWithFailureType:(NSString *)failureType errorMessage:(NSString *)errorMessage {
    DLog(@"\nfailureType:%@\n%@\nopenId:%@\neid:%@", failureType, errorMessage, [BOSConfig sharedConfig].user.openId, [BOSConfig sharedConfig].user.eid);
}

@end
