//
//  XTTimelineSetTableViewCell.m
//  kdweibo
//
//  Created by shen kuikui on 14-5-9.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTTimelineSetTableViewCell.h"

#define kIndicatorTag (1010)

@implementation XTTimelineSetTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView *indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_img_vector.png"]];
        indicator.tag = kIndicatorTag;
        [self.contentView addSubview:indicator];
        
        self.textLabel.highlightedTextColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10.0f, 2.0f, 48.0f, 48.0f);
    
    CGRect rect = self.textLabel.frame;
    rect.origin.x = CGRectGetMaxX(self.imageView.frame) + 10.0f;
    rect.origin.y = (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(rect)) * 0.5f;
    
    if (self.imageView.hidden) {
        rect.origin.x = 10.f;
        rect.size.width = self.contentView.frame.size.width - 20.f;
    }
    
    self.textLabel.frame = rect;
    
    UIView *indicator = [self.contentView viewWithTag:kIndicatorTag];
    if(indicator) {
        [indicator sizeToFit];
        indicator.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(indicator.bounds) - 13.0f, (CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight(indicator.bounds)) * 0.5f, CGRectGetWidth(indicator.bounds), CGRectGetHeight(indicator.bounds));
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
