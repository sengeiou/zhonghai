//
//  WKCookieSyncManager.m
//  kdweibo
//
//  Created by lichao_liu on 16/5/10.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDCookieSyncManager.H"

@implementation KDCookieSyncManager
+ (instancetype)sharedWKCookieSyncManager{
    static KDCookieSyncManager *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (WKProcessPool *)processPool{
    if(!_processPool){
        _processPool = [[NSClassFromString(@"WKProcessPool") alloc] init];
    }
    return _processPool;
}

- (void)clearCookie{
    _processPool = nil;
}
@end
