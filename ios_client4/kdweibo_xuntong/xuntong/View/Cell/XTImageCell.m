//
//  XTImageCell.m
//  XT
//
//  Created by Gil on 13-7-18.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTImageCell.h"

#define EXPAND_IMAGE_VIEW_TAG 1312

@implementation XTImageCell

@synthesize isExpand = _isExpand;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xffffff, 1.0);
        self.selectedBackgroundView = bgColorView;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        
        UIImageView *expandImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        expandImageView.tag = EXPAND_IMAGE_VIEW_TAG;
        expandImageView.backgroundColor = [UIColor clearColor];
        expandImageView.image = [UIImage imageNamed:@"common_img_vector.png"];
        [expandImageView sizeToFit];
        
        [self.contentView addSubview:expandImageView];
        
        expandImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        expandImageView.hidden = YES;
    }
    return self;
}

- (void)setExpand:(BOOL)isExpand
{
    if(isExpand != _isExpand) {
        _isExpand = isExpand;
        UIView *expandImageView = [self.contentView viewWithTag:EXPAND_IMAGE_VIEW_TAG];
        if(isExpand) {
            expandImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }else {
            expandImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        
        [expandImageView sizeToFit];
    }
}

- (void)setExpandViewHidden:(BOOL)expandViewHidden
{
    [self.contentView viewWithTag:EXPAND_IMAGE_VIEW_TAG].hidden = expandViewHidden;
}

- (BOOL)isExpandViewHidden
{
    return [self.contentView viewWithTag:EXPAND_IMAGE_VIEW_TAG].hidden;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    if (self.imageView.image != nil) {
        rect = self.imageView.frame;
        rect.origin.x = 15.0;
        self.imageView.frame = rect;
    }
    
    if (self.textLabel.text.length > 0) {
        rect = self.textLabel.frame;
        if (self.imageView.image != nil) {
            rect.origin.x = self.imageView.frame.origin.x + self.imageView.frame.size.width + 7.0;
        } else {
            rect.origin.x = 15.0;
        }
        self.textLabel.frame = rect;
    }
    
    UIView *expandView = [self.contentView viewWithTag:EXPAND_IMAGE_VIEW_TAG];
    CGSize expandSize = CGSizeMake(10, 6);
    if(expandView) {
        expandView.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - expandSize.width - 12.0f, (CGRectGetHeight(self.contentView.bounds) - expandSize.height) * 0.5f, expandSize.width, expandSize.height);
    }
}

@end
