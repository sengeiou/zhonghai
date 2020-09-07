//
//  KDGroupAvatarView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//
#import "KDGroupAvatarView.h"

@implementation KDGroupAvatarView

// Override
- (void)didSetupAvatarView {
    maskView_.layer.cornerRadius = 3.0;
    maskView_.layer.borderWidth = 1.0;
    maskView_.layer.borderColor = RGBCOLOR(240.0, 240.0, 240.0).CGColor;
}

// Override
- (UIImage *)defaultAvatar {
    return [UIImage imageNamed:@"group_default_portrait.png"];
}

- (void)dealloc {
    //[super dealloc];
}

@end
