//
//  XTCell.m
//  XT
//
//  Created by Gil on 13-7-18.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTCell.h"

@interface XTCell ()
@property (nonatomic, strong) UIImageView *separateLineImageView;
@end

@implementation XTCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier xtCellStyle:(XTCellStyle)XTCellStyle
{
    self.XTCellStyle = XTCellStyle;
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.separateLineSpace = 0.0;
        
        self.textLabel.font = FS3;
        self.textLabel.textColor = FC1;
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        self.detailTextLabel.textColor = FC2;
        self.detailTextLabel.highlightedTextColor = self.detailTextLabel.textColor;
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.imageView.image = nil;
        

        if (self.XTCellStyle != XTCellNormal) {
            UIImageView *separateLineImageView = [[UIImageView alloc] init];
            separateLineImageView.backgroundColor = [UIColor clearColor];
            self.separateLineImageView = separateLineImageView;
            [self.contentView addSubview:separateLineImageView];
        } else {
            UIImageView *separateLineImageView = [[UIImageView alloc] init];
            separateLineImageView.backgroundColor = [UIColor clearColor];
            self.separateLineImageView = separateLineImageView;
            [self.contentView addSubview:separateLineImageView];
        }
    }
    return self;
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle
{
    if (selectionStyle != UITableViewCellSelectionStyleNone) {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor kdBackgroundColor1];
        self.selectedBackgroundView = bgColorView;
    } else {
        self.selectedBackgroundView = nil;
    }
    
    [super setSelectionStyle:selectionStyle];
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectZero];
        accessoryView.image = [UIImage imageNamed:@"common_img_vector"];
        accessoryView.highlightedImage = [UIImage imageNamed:@"common_img_vector"];
        [accessoryView sizeToFit];

        self.accessoryView = accessoryView;
    } else {
        self.accessoryView = nil;
    }
    
    [super setAccessoryType:accessoryType];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    
    
    
    if (self.textLabel.text.length > 0) {
        rect = self.textLabel.frame;
        rect.origin.x = CGRectGetMaxX(self.imageView.frame) +10;
        self.textLabel.frame = rect;
    }
    

    
    if (self.detailTextLabel.text.length > 0) {
        rect = self.detailTextLabel.frame;
        rect.origin.x = ScreenFullWidth - rect.size.width - 45.0;
        if (self.accessoryView != nil) {
            rect.origin.x -= (self.separateLineSpace - 15.0);
        }
        self.detailTextLabel.frame = rect;
    }
    
    if (self.XTCellStyle == XTCellSetting) {
        self.textLabel.textColor = BOSCOLORWITHRGBA(0x2E343D, 1.0);
        self.backgroundColor = [UIColor clearColor];
        self.separateLineImageView.frame = CGRectMake(15, 43.5, ScreenFullWidth, 0.5);
    }
    else if (self.XTCellStyle == XTCellContactFirst) {
        self.separateLineImageView.frame = CGRectMake(63, 48.5, ScreenFullWidth, 0.5);
    }
    else if (self.XTCellStyle == XTCellContactSecond) {
        self.separateLineImageView.frame = CGRectMake(0, 0, ScreenFullWidth, 0.5);
        self.backgroundColor = [UIColor clearColor];
    }
    else {
        self.separateLineImageView.frame = CGRectMake(self.separateLineSpace, CGRectGetHeight(self.bounds) - 1, CGRectGetWidth(self.bounds) - self.separateLineSpace, 0.5);
    }
    
}

@end
