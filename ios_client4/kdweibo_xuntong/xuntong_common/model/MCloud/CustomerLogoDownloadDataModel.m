//
//  CustomerLogoDownloadDataModel.m
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "CustomerLogoDownloadDataModel.h"

@implementation CustomerLogoDownloadDataModel
@synthesize logo = _logo_;
@synthesize lastUpdateTime = _lastUpdateTime_;

- (id)init {
    self = [super init];
    if (self) {
        _logo_ = [[NSString alloc] init];
        _lastUpdateTime_ = [[NSString alloc] init];
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
        id logo = [dict objectForKey:@"logo"];
        id lastUpdateTime = [dict objectForKey:@"lastUpdateTime"];
        
        if (![logo isKindOfClass:[NSNull class]] && logo) {
            self.logo = logo;
        }
        if (![lastUpdateTime isKindOfClass:[NSNull class]] && lastUpdateTime) {
            self.lastUpdateTime = lastUpdateTime;
        }
    }
    return self;
}

- (void)dealloc {
    //BOSRELEASE_logo_);
    //BOSRELEASE_lastUpdateTime_);
    //[super dealloc];
}
@end
