//
//  KDAppUserDefaultsAdapter.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDAppUserDefaultsProtocol.h"

@class KDAppUserDefaultsCache;

@interface KDAppUserDefaultsAdapter : NSObject <KDAppUserDefaultsProtocol> {
@private
    id<KDAppUserDefaultsProtocol> appUserDefaultsImpl_;
}

@end
