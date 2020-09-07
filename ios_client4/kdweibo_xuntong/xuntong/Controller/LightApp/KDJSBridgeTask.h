//
//  KDJSBridgeTask.h
//  kdweibo
//
//  Created by shifking on 15/12/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDJSBridgeTask : NSObject
@property (assign , nonatomic) int          callbackId;
@property (strong , nonatomic) NSString     *functionName;
@property (strong , nonatomic) NSDictionary *args;
- (instancetype)initWithCallbackId:(int)callbackId functionName:(NSString *)functionName args:(NSDictionary *)args;
@end
