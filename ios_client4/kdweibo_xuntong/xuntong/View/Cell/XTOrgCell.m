//
//  XTOrgCell.m
//  kdweibo
//
//  Created by fang.jiaxin on 16/5/3.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "XTOrgCell.h"

@implementation XTOrgCell

-(void)layoutSubviews
{
    [super layoutSubviews];
    if(self.imageView.image)
    {
        CGRect frame = self.imageView.frame;
        frame.size = CGSizeMake(15, 15);
        self.imageView.frame = frame;
        self.imageView.center = CGPointMake(self.imageView.center.x, self.frame.size.height/2);
    }
}

@end
