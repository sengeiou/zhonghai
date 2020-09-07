//
//  KDNoItemView.m
//  kdweibo
//
//  Created by KongBo on 15/9/7.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDNoItemView.h"
#import "UIColor+KDV6.h"

@implementation KDNoItemView

- (instancetype)initShowInView:(UIView *)superview
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, kd_StatusBarAndNaviHeight + 44, superview.frame.size.width, superview.frame.size.height - kd_StatusBarAndNaviHeight - 44);
        NSString *titleStr = ASLocalizedString(@"KDNoItemView_Tip_1");
        self.backgroundColor = [UIColor kdBackgroundColor2];
        CGSize titleSize = [ASLocalizedString(@"KDNoItemView_Tip_2")sizeWithFont:FS4 constrainedToSize:CGSizeMake(MAXFLOAT, 16)];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width - titleSize.width)/2, 150, titleSize.width, 42)];
        titleLabel.text = titleStr;
        titleLabel.textColor = FC3;
        titleLabel.font = FS4;
        titleLabel.numberOfLines = 2;
        [self addSubview:titleLabel];
        
        self.backgroundColor = [UIColor kdBackgroundColor1];
        [superview addSubview:self];
    }
    return self;
}

- (void)hiddenView
{
    if(self){
       [self removeFromSuperview];
    }
}

@end
