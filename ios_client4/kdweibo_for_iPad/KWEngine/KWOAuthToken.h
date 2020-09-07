//
//  KWOAuthToken.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief container of oauth key and secret, and related utils
 */
@interface KWOAuthToken : NSObject

@property (retain, nonatomic) NSString *key;
@property (retain, nonatomic) NSString *secret;

+ (KWOAuthToken *)tokenWithKey:(NSString *)key secret:(NSString *)secret;
// - (KWOAuthToken *)initWithKey:(NSString *)key secret:(NSString *)secret;

- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding;

/// parse http GET query string and init new instance
+ (KWOAuthToken *)tokenFromQuerystring:(NSString *)query;

/// @return true if token is valid
- (BOOL)isValid;

/// @exception raise exception when token is invliad
- (void)validOrException;

@end
