//
//  KDWebViewController+JSBridge.h
//  kdweibo
//
//  Created by Gil on 14-10-20.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDWebViewController.h"
#import "KDUserHelper.h"

@interface KDWebViewController (JSBridge)

- (void)executeJSBridge:(NSString *)url;

- (BOOL)jsBridgeActionWithTitle:(NSString *)title;

- (void)returnResult:(int)callbackId args:(NSDictionary *)resultDic;

//defback
- (BOOL)isDefBack;
- (void)defback;
- (void)resetDefback;

- (void)releaseSecondWindow;

- (void)rotateUIWithOrientation:(NSString *)orientation;
@end
