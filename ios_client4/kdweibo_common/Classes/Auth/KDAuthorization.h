//
//  KDAuthorization.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KDRequestWrapper;


enum {
    KDAuthorizationTypeNone = 0x00,
    KDAuthorizationTypeBasic,
    KDAuthorizationTypeXAuth
};

typedef NSUInteger KDAuthorizationType;


@protocol KDAuthorization <NSObject>
@required

- (KDAuthorizationType)getAuthorizationType;
- (NSString *)getAuthorizationHeader:(KDRequestWrapper *)req;

/**
 * Returns true if authorization credentials are set.
 *
 * @return true if authorization credentials are set
 */
- (BOOL) isEnabled;

@end
