//
//  KDTeamLogoView.m
//  kdweibo
//
//  Created by shen kuikui on 13-11-26.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTeamLogoView.h"

@implementation KDTeamLogoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIImage *)defaultAvatar
{
    return [UIImage imageNamed:@"team_logo_placeholder_v3"];
}

@end
