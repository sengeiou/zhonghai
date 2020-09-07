//
//  KDJSBridgeTask.m
//  kdweibo
//
//  Created by shifking on 15/12/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDJSBridgeTask.h"

@implementation KDJSBridgeTask

- (instancetype)initWithCallbackId:(int)callbackId functionName:(NSString *)functionName args:(NSDictionary *)args {
    if (self = [super init]){
        _callbackId = callbackId;
        _functionName = functionName;
        _args = args;
    }
    return self;
}

@end
