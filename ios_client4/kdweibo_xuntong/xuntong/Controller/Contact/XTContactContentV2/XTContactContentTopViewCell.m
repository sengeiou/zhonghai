//
//  XTContactContentTopViewCell.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTContactContentTopViewCell.h"
#import "UIView+Blur.h"
#define inlineColor 0xdddddd
#define headerImageViewWidthAndHeight 48.f

@implementation XTContactContentTopViewCell
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
//    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor kdBackgroundColor2];
    self.contentView.backgroundColor = self.backgroundColor;
    
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xdddddd, 1.0);
    self.selectedBackgroundView = bgColorView;
    
    
    avatarImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    avatarImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:avatarImageView];
    
    discoveryLabel = [[UILabel alloc]init];
    discoveryLabel.textColor = FC1;
    discoveryLabel.backgroundColor = [UIColor clearColor];
    discoveryLabel.textAlignment = NSTextAlignmentLeft;
    discoveryLabel.font = FS3;
    [self.contentView addSubview:discoveryLabel];
    
    accessoryImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_img_vector"]];
    [accessoryImageView sizeToFit];
    accessoryImageView.highlightedImage = [UIImage imageNamed:@"common_img_vector"];
    [self.contentView addSubview:accessoryImageView];
    
    //隐藏箭头
    accessoryImageView.hidden = YES;
    self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    self.separatorLineInset = UIEdgeInsetsMake(0, headerImageViewWidthAndHeight + 10*2, 0, 0);

}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat offsetX = 10.f;
    CGFloat offsetY = 7.5f;
    CGRect rect = CGRectMake(offsetX, (CGRectGetHeight(self.bounds) - headerImageViewWidthAndHeight)/2, headerImageViewWidthAndHeight , headerImageViewWidthAndHeight);
    avatarImageView.frame = rect;
    
    offsetX += CGRectGetWidth(avatarImageView.frame) + 10.f;
    rect = CGRectMake(offsetX, offsetY, CGRectGetWidth(self.bounds) - offsetX - 13.f , CGRectGetHeight(rect));
    discoveryLabel.frame = rect;
    CGPoint center = discoveryLabel.center;
    center.y = self.frame.size.height / 2;
    discoveryLabel.center = center;
    

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
    [color setStroke];
  
    [path moveToPoint:CGPointMake(self.separatorLineInset.left, CGRectGetHeight(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
    

    [path stroke];
}

@end
