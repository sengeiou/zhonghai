//
//  CustomerSearchDataModel.m
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "CustomerSearchDataModel.h"

@implementation CustomerSearchDataModel
@synthesize cust3gNo = _cust3gNo_;
@synthesize customerName = _customerName_;

- (id)init {
    self = [super init];
    if (self) {
        _cust3gNo_ = [[NSString alloc] init];
        _customerName_ = [[NSString alloc] init];
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
        id customerName = [dict objectForKey:@"customerName"];
        
        if (![cust3gNo isKindOfClass:[NSNull class]] && cust3gNo) {
            self.cust3gNo = cust3gNo;
        }
        if (![customerName isKindOfClass:[NSNull class]] && customerName) {
            self.customerName = customerName;
        }
    }
    return self;
}

- (void)dealloc {

}

@end
