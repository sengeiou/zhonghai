//
//  KDSchema.h
//  kdweibo
//
//  Created by Gil on 15/8/27.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Scheme.h"

@class MessageNewsEachDataModel;
@interface KDSchema : NSObject

+ (KDSchemeHostType)openWithUrl:(NSString *)url
                          appId:(NSString *)appId
                          title:(NSString *)title
                          share:(MessageNewsEachDataModel *)share
                     controller:(UIViewController *)controller;

//只处理已经定义的Schema，不处理http和https
+ (KDSchemeHostType)openWithUrl:(NSString *)url
                     controller:(UIViewController *)controller;

@end
