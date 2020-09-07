//
//  KDServiceActionPath.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDServiceActionPath.h"

#define KD_ACTION_PATH_DIVIDER   @":"

@implementation KDServiceActionPath

@synthesize actionPath=actionPath_;
@synthesize serviceName=serviceName_;

- (id)initWithActionPath:(NSString *)actionPath serviceName:(NSString *)serviceName {
    self = [super init];
    if (self) {
        actionPath_ = actionPath;// retain];
        serviceName_ = serviceName;// retain];
    }
    
    return self;
}

+ (KDServiceActionPath *)serviceActionPath:(NSString *)fullyActionPath {
    if (fullyActionPath == nil || [fullyActionPath length] <= 0x04) {
        // invalid action path, the minimal length must greater than 4. format: /a/:b
        return nil;
    }
    
    NSRange range = [fullyActionPath rangeOfString:KD_ACTION_PATH_DIVIDER];
    if (NSNotFound == range.location) {
        return nil; // can not find the divider symbol
    }
    
    if (range.location + 1 >= [fullyActionPath length]) {
        return nil; // the action path can not end with divider(:)
    }
    
    NSString *actionPath = [fullyActionPath substringToIndex:range.location]; // /a/
    NSString *serviceName = [fullyActionPath substringFromIndex:range.location + 1]; // b
    
    return [[KDServiceActionPath alloc] initWithActionPath:actionPath serviceName:serviceName];// autorelease];
}

// The format about fullyActionPath must like: /a/:func
- (BOOL)isEqualsToFullyActionPath:(NSString *)fullyActionPath {
    BOOL equals = NO;
    if (actionPath_ != nil && serviceName_ != nil && fullyActionPath != nil) {
        NSString *temp = [actionPath_ stringByAppendingFormat:@"%@%@", KD_ACTION_PATH_DIVIDER, serviceName_];
        equals = [temp isEqualToString:fullyActionPath];
    }
    
    return equals;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(actionPath_);
    //KD_RELEASE_SAFELY(serviceName_);
    
    //[super dealloc];
}

@end
