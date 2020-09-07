//
//  KDThreadRequst.h
//  KDWebPluginDemo
//
//  Created by gordon_wu on 14-3-14.
//  Copyright (c) 2014年 gordon_wu. All rights reserved.
//

#import "ASIFormDataRequest.h"

@interface KDThreadRequst : ASIFormDataRequest

@property (strong, nonatomic) NSString *openId;
@property (strong, nonatomic) NSString *eId;

@end
