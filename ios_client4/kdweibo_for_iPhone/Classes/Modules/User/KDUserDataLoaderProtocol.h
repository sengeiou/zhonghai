//
//  KDUserDataLoaderProtocol.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KDUserDataLoader <NSObject>
@required

- (void) loadUserData;

@end
