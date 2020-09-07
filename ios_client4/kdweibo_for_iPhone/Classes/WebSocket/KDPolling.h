//
//  KDPolling.h
//  kdweibo
//
//  Created by Gil on 15/12/1.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDNotificationChannelDelegate.h"

@interface KDPolling : NSObject

@property (weak, nonatomic) id<KDNotificationChannelDelegate> delegate;

- (void)startPolling;
- (void)cancelPolling;

- (BOOL)isPolling;

@end
