//
//  KDSignInSchema.m
//  kdweibo_common
//
//  Created by Tan yingqi on 13-8-26.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDSignInSchema.h"

@implementation KDSignInSchema
@synthesize count = count_;
@synthesize time = time_;
- (void)dealloc {
    //KD_RELEASE_SAFELY(time_);
    //[super dealloc];
}
@end
