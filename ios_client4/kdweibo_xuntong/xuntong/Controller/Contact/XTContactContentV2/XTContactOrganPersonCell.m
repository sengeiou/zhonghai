//
//  XTContactOrganPersonCell.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTContactOrganPersonCell.h"

@implementation XTContactOrganPersonCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //职位
        self.jobLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.jobLabel.font = FS5;
        self.jobLabel.textColor = FC2;
        self.jobLabel.backgroundColor = self.backgroundColor;
        [self.contentView addSubview:self.jobLabel];

    }
    return self;
}
#define headerImageViewWidthAndHeight 48.0f
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat offsetx = 10.0f;
    CGFloat offsety = 8.5f;
    CGRect rect = CGRectMake(offsetx,(CGRectGetHeight(self.bounds) - headerImageViewWidthAndHeight)/2, headerImageViewWidthAndHeight, headerImageViewWidthAndHeight);
    self.headerImageView.frame = rect;
    
    
    offsetx = CGRectGetMaxX(self.headerImageView.frame) + 10.f;
    offsety += 2.f;
    self.partnerImageView.frame = CGRectMake(offsetx, offsety, self.partnerImageView.frame.size.width, self.partnerImageView.frame.size.height);
    if(![self.person isEmployee])
    {
        //假如是外部员工，那名称就要右移
        self.partnerImageView.hidden = NO;
        offsetx = CGRectGetMaxX(self.partnerImageView.frame) + 5.f;
    }
    else
        self.partnerImageView.hidden = YES;
        
    
    rect = CGRectMake(offsetx, offsety, 232.f, 18.f);
    self.nameLabel.frame = rect;
    
    
    offsety = CGRectGetMaxY(self.nameLabel.frame) + 13.f;
    
    if(![self.person isEmployee])
        offsetx = CGRectGetMinX(self.partnerImageView.frame);
    rect = CGRectMake(offsetx, offsety, 232.f, 16.f);
    self.departmentLabel.frame =rect;
    self.departmentLabel.text = self.person.jobTitle;
    self.accessoryImageView.center = CGPointMake(CGRectGetWidth(self.contentView.frame) - 13.0f - CGRectGetWidth(self.accessoryImageView.frame), CGRectGetMidY(self.headerImageView.frame));
    
    
    if ( !self.isDisplay || self.departmentLabel.text == nil) {
        self.departmentLabel.text = nil;
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.headerImageView.center.y);
    } else {
        self.departmentLabel.text = self.person.jobTitle;
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.headerImageView.frame.origin.y + 5.0 + self.nameLabel.frame.size.height/2);
    }
    self.partnerImageView.center = CGPointMake(self.partnerImageView.center.x, self.nameLabel.center.y);
}

@end
