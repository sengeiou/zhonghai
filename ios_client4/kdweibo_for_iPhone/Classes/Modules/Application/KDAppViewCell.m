//
//  KDAppViewCell.m
//  kdweibo
//
//  Created by 王 松 on 13-11-30.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDAppViewCell.h"
#import "UIView+Blur.h"

@interface KDAppViewCell()


@property (nonatomic, retain) UIImageView *narrowImageView;

@end

@implementation KDAppViewCell

@synthesize iconImageView = iconImageView_;
@synthesize narrowImageView = narrowImageView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addBorderAtPosition:KDBorderPositionBottom];
        iconImageView_ = [[KDImageView alloc] initWithFrame:CGRectMake(0, 0, 48.0f, 48.0f)];
        iconImageView_.backgroundColor = [UIColor clearColor];
        iconImageView_.image = [UIImage imageNamed:@"application_icon_default_v3.png"];
        [self addSubview:iconImageView_];
        
        narrowImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit_arrow.png"]];
        [narrowImageView_ sizeToFit];
        narrowImageView_.highlightedImage = [UIImage imageNamed:@"smallTriangle.png"];
        [self addSubview:narrowImageView_];
        
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(iconImageView_);
    //KD_RELEASE_SAFELY(narrowImageView_);
    
    //[super dealloc];
}

- (void)reset
{
    iconImageView_.image = [UIImage imageNamed:@"application_icon_default_v3.png"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.narrowImageView.frame = CGRectMake(CGRectGetWidth(self.frame) - 13.0f - CGRectGetWidth(self.narrowImageView.bounds), (CGRectGetHeight(self.frame) - CGRectGetHeight(self.narrowImageView.bounds)) * 0.5f, CGRectGetWidth(self.narrowImageView.bounds), CGRectGetHeight(self.narrowImageView.bounds));
    self.iconImageView.frame = CGRectMake(10.f, (CGRectGetHeight(self.frame) - 48.f) * 0.5f, 48.f, 48.f);
    self.iconImageView.backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    CGRect rect = self.iconImageView.frame;
    rect.origin.x = CGRectGetMaxX(self.iconImageView.frame) + 5.f;
    rect.size.width = 195.f;
    self.textLabel.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.textLabel.highlighted = selected;
    narrowImageView_.highlighted = selected;
}

@end
