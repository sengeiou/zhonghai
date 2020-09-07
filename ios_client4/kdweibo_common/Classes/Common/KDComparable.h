//
//  KDComparable.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KDComparable <NSObject>

@required

- (NSInteger) compareTo:(id)object;

@end
