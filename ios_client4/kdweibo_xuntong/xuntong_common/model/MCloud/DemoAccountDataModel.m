//
//  DemoAccountDataModel.m
//  EMPNativeContainer
//
//  Created by Gil on 12-11-21.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "DemoAccountDataModel.h"

@implementation DemoAccountDataModel
@synthesize cust3gNo = _cust3gNo_;
@synthesize userName = _userName_;
@synthesize password = _password_;

- (id)init {
    self = [super init];
    if (self) {
        _cust3gNo_ = [[NSString alloc] init];
        _userName_ = [[NSString alloc] init];
        _password_ = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id cust3gNo = [dict objectForKey:@"cust3gNo"];
        id userName = [dict objectForKey:@"userName"];
        id password = [dict objectForKey:@"password"];
        
        if (![cust3gNo isKindOfClass:[NSNull class]] && cust3gNo) {
            self.cust3gNo = cust3gNo;
        }
        if (![userName isKindOfClass:[NSNull class]] && userName) {
            self.userName = userName;
        }
        if (![password isKindOfClass:[NSNull class]] && password) {
            self.password = password;
        }
    }
    return self;
}

- (void)dealloc {
    //BOSRELEASE_cust3gNo_);
    //BOSRELEASE_userName_);
    //BOSRELEASE_password_);
    //[super dealloc];
}
@end
