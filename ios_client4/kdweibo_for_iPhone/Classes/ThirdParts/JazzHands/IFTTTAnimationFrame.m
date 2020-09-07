//
//  IFTTTAnimationFrame.m
//  JazzHands
//
//  Created by Devin Foley on 9/27/13.
//  Copyright (c) 2013 IFTTT Inc. All rights reserved.
//

#import "IFTTTAnimationFrame.h"

@implementation IFTTTAnimationFrame

- (NSString *)description
{
    return [NSString stringWithFormat:@"[<frame = %@>--<alpha = %f>--<hidden = %d>]", NSStringFromCGRect(_frame), _alpha, _hidden];
}

@end
