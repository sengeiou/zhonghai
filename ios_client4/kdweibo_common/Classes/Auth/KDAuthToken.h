//
//  KDAuthToken.h
//  kdweibo_common
//
//  Created by laijiandong on 12-8-20.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDAuthToken : NSObject <NSCoding> {
 @private
    NSString *keyToken_;
    NSString *secretToken_;
}

@property(nonatomic, copy) NSString *keyToken;
@property(nonatomic, copy) NSString *secretToken;

- (id)initWithKey:(NSString *)key secret:(NSString *)secret;

- (BOOL)isValid;

+ (KDAuthToken *)authTokenWithString:(NSString *)responseString;

@end
