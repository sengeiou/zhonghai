//
//  CustomerPublicKeyDataModel.m
//  EMPNativeContainer
//
//  Created by Gil on 12-11-16.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "CustomerPublicKeyDataModel.h"

@implementation CustomerPublicKeyDataModel
@synthesize publicKey = _publicKey_;

- (id)init {
    self = [super init];
    if (self) {
        _publicKey_ = [[NSString alloc] init];
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
        id publicKey = [dict objectForKey:@"publicKey"];
        
        if (![publicKey isKindOfClass:[NSNull class]] && publicKey) {
            self.publicKey = publicKey;
        }
    }
    return self;
}

- (void)dealloc {
    //BOSRELEASE_publicKey_);
    //[super dealloc];
}

@end
