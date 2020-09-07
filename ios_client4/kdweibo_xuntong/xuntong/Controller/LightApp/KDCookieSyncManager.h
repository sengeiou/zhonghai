//
//  WKCookieSyncManager.h
//  kdweibo
//
//  Created by lichao_liu on 16/5/10.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@interface KDCookieSyncManager : NSObject
+ (instancetype)sharedWKCookieSyncManager;
@property (nonatomic, strong) WKProcessPool *processPool;
- (void)clearCookie;
@end
