//
//  KDWideButton.m
//  kdweibo
//
//  Created by Darren on 15/7/13.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDWideButton.h"

@implementation KDWideButton

- (id)init
{
    if(self = [super init])
    {
        [self updateStyle];
    }
    return self;
}

- (void)updateStyle
{
    self.backgroundColor = FC5;
    [self setTintColor:FC6];
    [self.titleLabel setFont:FS2];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}

- (void)enableTouch
{
    self.enabled = YES;
    self.alpha = 1;
}

- (void)disableTouch
{
    self.enabled = NO;
    self.alpha = .5;
}

@end
