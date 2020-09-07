//
//  KDSignSchemaParser.m
//  kdweibo_common
//
//  Created by Tan yingqi on 13-8-26.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDSignSchemaParser.h"

@implementation KDSignSchemaParser

- (KDSignInSchema *)parse:(NSDictionary *)body {
    if (body == nil || [body count] == 0) return nil;
    
    KDSignInSchema *s = [[KDSignInSchema alloc] init];// autorelease];
    s.count = [body integerForKey:@"count"];
    s.time =  [NSDate dateWithTimeIntervalSince1970:[body doubleForKey:@"time"] / 1000];
    return s;
}
@end
