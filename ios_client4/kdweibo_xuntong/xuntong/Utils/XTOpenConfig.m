//
//  XTOpenConfig.m
//  XT
//
//  Created by Gil on 13-11-25.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTOpenConfig.h"

@implementation XTOpenConfig

+ (XTOpenConfig *)sharedConfig {
	static dispatch_once_t pred;
	static XTOpenConfig *instance = nil;
	dispatch_once(&pred, ^{
	    instance = [[XTOpenConfig alloc] init];
	});
	return instance;
}

- (id)init {
	self = [super init];
	if (self) {
		_countryCode = nil;
		_phoneNumber = nil;
		_code = nil;
	}
	return self;
}

- (NSString *)longPhoneNumber {
    
    NSParameterAssert(self.countryCode);
    NSParameterAssert(self.phoneNumber);
    
    if ([self.countryCode isEqualToString:@"+86"]) {
        return self.phoneNumber;
    }
    return [self.countryCode stringByAppendingString:self.phoneNumber];
}

@end
