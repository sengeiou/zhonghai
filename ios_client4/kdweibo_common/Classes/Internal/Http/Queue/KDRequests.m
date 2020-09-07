//
//  KDRequests.m
//  kdweibo
//
//  Created by Gil on 15/8/26.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDRequests.h"

@interface KDRequests ()
@property (strong, nonatomic) NSMutableArray *requests;
@end

@implementation KDRequests

+ (KDRequests *)sharedRequests
{
    static dispatch_once_t once;
    static KDRequests *sharedRequests;
    dispatch_once(&once, ^{
        sharedRequests = [[self alloc] init];
    });
    return sharedRequests;
}

- (NSMutableArray *)requests {
    if (_requests == nil) {
        _requests = [NSMutableArray array];
    }
    return _requests;
}

@end
