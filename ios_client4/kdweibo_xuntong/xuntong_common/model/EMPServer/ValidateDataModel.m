//
//  ValidateDataModel.m
//  EMPNativeContainer
//
//  Created by Gil on 12-11-16.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "ValidateDataModel.h"

@implementation ValidateDataModel
@synthesize validateToken = _validateToken_;

-(id)init{
    self = [super init];
    if (self) {
        _validateToken_ = [[NSString alloc] init];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id validateToken = [dict objectForKey:@"validateToken"];
        if (![validateToken isKindOfClass:[NSNull class]] && validateToken) {
            self.validateToken = validateToken;
        }
    }
    return self;
}

-(void)dealloc
{
    //BOSRELEASE_validateToken_);
    //[super dealloc];
}

@end
