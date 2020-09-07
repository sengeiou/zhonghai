//
//  KDNullAuthorization.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDAuthorization.h"

@interface KDNullAuthorization : NSObject <KDAuthorization> {
@private
    
}

+ (KDNullAuthorization *) getInstance;

@end
