//
//  KDContactDepartmentMultipleChoiceCell.m
//  kdweibo
//
//  Created by shen kuikui on 14-5-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDContactDepartmentMultipleChoiceCell.h"

@implementation KDContactDepartmentMultipleChoiceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.headerImageView.hidden = YES;
        self.departmentLabel.hidden = YES;
        
        
    }
    
    return self;
}

- (void)setDepartmentName:(NSString *)name
{
    self.nameLabel.text = name;
    [self.nameLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.nameLabel.frame;
    frame.origin.x = 55.0f;
    frame.origin.y = (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(self.nameLabel.frame)) * 0.5;
    self.nameLabel.frame = frame;
    
    self.selectStateView.center = CGPointMake(self.selectStateView.center.x, self.nameLabel.center.y);
    self.partnerImageView.hidden = YES;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


@end
