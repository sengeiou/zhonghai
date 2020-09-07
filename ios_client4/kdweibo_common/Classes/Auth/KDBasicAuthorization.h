//
//  KDBasicAuthorization.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDAuthorization.h"

@interface KDBasicAuthorization : NSObject <KDAuthorization> {
@private
    NSString *identifier_;
    NSString *password_;
    NSString *basic_;
}

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *password;

- (id) initWithIdentifier:(NSString *)identifier password:(NSString *)password;

@end
