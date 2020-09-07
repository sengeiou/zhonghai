//
//  KDBaseScrollView.m
//  kdweibo_common
//
//  Created by DarrenZheng on 14-9-28.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDBaseScrollView.h"

@implementation KDBaseScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.delaysContentTouches = NO;
        self.canCancelContentTouches = YES;
    }
    return self;
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
        return YES;
}

@end
