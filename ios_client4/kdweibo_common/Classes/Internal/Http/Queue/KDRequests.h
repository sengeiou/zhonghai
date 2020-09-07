//
//  KDRequests.h
//  kdweibo
//
//  Created by Gil on 15/8/26.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDRequests : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *requests;

+ (KDRequests *)sharedRequests;

@end
