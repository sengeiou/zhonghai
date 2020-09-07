//
//  XTContactGroupViewCell.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTContactGroupViewCell.h"
#import "UIView+Blur.h"

@implementation XTContactGroupViewCell

@synthesize avatarImageView;
@synthesize discoveryLabel;
@synthesize accessoryImageView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView{
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self setBackgroundColor:[UIColor clearColor]];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xdddddd, 1.0);
    self.selectedBackgroundView = bgColorView;
    
    avatarImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    avatarImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:avatarImageView];
    
    discoveryLabel = [[UILabel alloc]init];
    discoveryLabel.textColor = MESSAGE_ACTNAME_COLOR;
    discoveryLabel.backgroundColor = [UIColor clearColor];
    discoveryLabel.textAlignment = NSTextAlignmentLeft;
    discoveryLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [self.contentView addSubview:discoveryLabel];
    accessoryImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_img_vector"]];
    [accessoryImageView sizeToFit];
    accessoryImageView.highlightedImage = [UIImage imageNamed:@"common_img_vector"];
    [self.contentView addSubview:accessoryImageView];
}

#define avaImageWithAndHeight 35.f
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat offsetX = 10.f;
    CGFloat offsetY = 10.f;
    CGRect rect = CGRectMake(offsetX, (self.bounds.size.height - avaImageWithAndHeight)/2, avaImageWithAndHeight , avaImageWithAndHeight);
    avatarImageView.frame = rect;
    
    offsetX += CGRectGetWidth(avatarImageView.frame) + 10.f;
    rect = CGRectMake(offsetX, offsetY, CGRectGetWidth(self.bounds) - offsetX - 13.f , CGRectGetHeight(rect));
    discoveryLabel.frame = rect;
    
    accessoryImageView.center = CGPointMake(CGRectGetWidth(self.contentView.frame) - 13.0f - CGRectGetWidth(accessoryImageView.frame), CGRectGetMidY(avatarImageView.frame));
    
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    
    
    [MESSAGE_CT_COLOR set];
    [path fill];
    
    path = [UIBezierPath bezierPath];
    path.lineWidth = 1.f;
    UIColor *color = UIColorFromRGB(0xdddddd);
    [color set];
    
    [path moveToPoint:CGPointMake(0, CGRectGetHeight(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
    
    
    [path stroke];
}



@end
