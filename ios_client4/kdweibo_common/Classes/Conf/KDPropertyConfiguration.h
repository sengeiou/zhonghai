//
//  KDPropertyConfiguration.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDConfigurationBase.h"

@interface KDPropertyConfiguration : KDConfigurationBase {
@private
    
}

- (id) initWithData:(NSData *)data;
- (id) initWithPath:(NSString *)path;

@end
