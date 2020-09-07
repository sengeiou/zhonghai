//
//  KDWeiboGlobals.h
//  kdweibo_common
//
//  Created by laijiandong on 13-1-4.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDObject.h"

@interface KDWeiboGlobals : KDObject

+ (KDWeiboGlobals *)defaultWeiboGlobals;

- (void)disconnectDatabaseConnection;
- (void)signOut;

@end
