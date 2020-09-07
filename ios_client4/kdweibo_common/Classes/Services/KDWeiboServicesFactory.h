//
//  KDWeiboServicesFactory.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDWeiboServices.h"

@interface KDWeiboServicesFactory : NSObject {
@private
    id<KDWeiboServices> defaultWeiboServices_;
}

- (id<KDWeiboServices>) getDefaultKDWeiboServices;

@end
