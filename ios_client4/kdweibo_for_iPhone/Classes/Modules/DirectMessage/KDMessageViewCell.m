//
//  KDMessageViewCell.m
//  kdweibo
//
//  Created by 王 松 on 13-11-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDMessageViewCell.h"

#import "UIView+Blur.h"

#import "KDBadgeIndicatorView.h"

@interface KDMessageViewCell ()

@property (nonatomic, retain) UIImageView *iconImageView;

@property (nonatomic, retain) UILabel *nameLabel;

@property (nonatomic, retain) UILabel *contentLabel;

@property (nonatomic, retain) UILabel *dateLabel;

@property (nonatomic, retain) KDBadgeIndicatorView *bageImageView;

@property (nonatomic, retain) UIImageView *tipBadgeView;

@end

@implementation KDMessageViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat offsetY = 10.0;
    CGFloat offsetX = 10.0;
    
    CGRect rect = CGRectMake(offsetX, (self.bounds.size.height - 48.f) * 0.5, 48.f, 48.f);
    _iconImageView.frame = rect;
    CGFloat width = self.bounds.size.width - 30.0 - CGRectGetWidth(_iconImageView.frame);
    CGFloat pw = width * 0.5;
    
    rect = CGRectMake(CGRectGetWidth(_iconImageView.frame) + 20.f, offsetY, pw, 16.0);
    _nameLabel.frame = rect;
    
    rect.origin.x += pw ;
    _dateLabel.frame = rect;
    offsetY += rect.size.height + 12.f;
    [_contentLabel sizeToFit];

    rect = CGRectMake(CGRectGetMinX(_nameLabel.frame), offsetY, 195.f, _contentLabel.bounds.size.height);
    
    _contentLabel.frame = rect;
    
    self.tipBadgeView.center = CGPointMake(CGRectGetMaxX(self.iconImageView.frame) - 2.f, CGRectGetMaxY(self.iconImageView.frame) - 2.f);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)setupCell
{
    self.backgroundColor = MESSAGE_BG_COLOR;
    
    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bageImageView = [[KDBadgeIndicatorView alloc] initWithFrame:CGRectZero];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tipBadgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_oranage.png"]];
    _tipBadgeView.hidden = YES;
    
    [_bageImageView setBadgeBackgroundImage:[KDBadgeIndicatorView redBadgeBackgroundImage]];
    [_bageImageView setBadgeColor:[UIColor whiteColor]];
    [_bageImageView setbadgeTextFont:[UIFont systemFontOfSize:13]];
    
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.highlightedTextColor = [UIColor whiteColor];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    
    //content label
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.highlightedTextColor = [UIColor whiteColor];
    _contentLabel.textColor = MESSAGE_ACTNAME_COLOR;
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.numberOfLines = 1;
    _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    
    //date label
    _dateLabel.backgroundColor = [UIColor clearColor];
    _dateLabel.highlightedTextColor = [UIColor whiteColor];
    _dateLabel.textColor = MESSAGE_ACTDATE_COLOR;
    _dateLabel.font = [UIFont systemFontOfSize:13];
    _dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _dateLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:_iconImageView];
    [self.contentView addSubview:_bageImageView];
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_contentLabel];
    [self.contentView addSubview:_dateLabel];
    [self.contentView addSubview:_tipBadgeView];
    
    [self addBorderAtPosition:KDBorderPositionBottom];
}

- (void)setTitle:(NSString *)title
{
    if (_title != title) {
//        [_title release];
        _title = title;// retain];
        self.nameLabel.text = _title;
    }
    
}

- (void)setContent:(NSString *)content
{
    if (_content != content) {
//        [_content release];
        _content = content ;//retain];
    }
    self.contentLabel.text = _content;
    [self setNeedsLayout];
}

- (void)setDate:(NSString *)date
{
    if (_date != date) {
//        [_date release];
        _date = date;// retain];
    }
    self.dateLabel.text = _date;
    [self setNeedsLayout];
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
//        [_image release];
        _image = image;// retain];
        self.iconImageView.image = _image;
    }
}

- (void)setBadgeValue:(NSInteger)badgeValue
{
    _badgeValue = badgeValue;
    self.bageImageView.badgeValue = badgeValue;
    
    if ([self.bageImageView badgeIndicatorVisible]) {
        [self layoutBadgeIndicatorView];
    }
    [self setNeedsLayout];
}

- (void)layoutBadgeIndicatorView
{
    if (self.iconImageView) {
        CGSize contentSize = [self.bageImageView getBadgeContentSize];
        CGRect rect = self.bageImageView.frame;
        rect.size = contentSize;
        self.bageImageView.frame = rect;
        CGPoint point = CGPointMake(CGRectGetMaxX(self.iconImageView.frame) - 4.f, CGRectGetMaxY(self.iconImageView.frame) - 6.f);
        self.bageImageView.center = point;
    }
}

- (void)setShowbadgeTips:(BOOL)showbadgeTips
{
    _showbadgeTips = showbadgeTips;
    self.tipBadgeView.hidden = !showbadgeTips;
    if (!showbadgeTips) {
        self.tipBadgeView.center = CGPointMake(CGRectGetMaxX(self.iconImageView.frame) - 5.f, CGRectGetMaxY(self.iconImageView.frame) - 5.f);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.nameLabel.highlighted = selected;
    self.contentLabel.highlighted = selected;
    self.dateLabel.highlighted = selected;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_tipBadgeView);
    //KD_RELEASE_SAFELY(_iconImageView);
    //KD_RELEASE_SAFELY(_bageImageView);
    //KD_RELEASE_SAFELY(_nameLabel);
    //KD_RELEASE_SAFELY(_contentLabel);
    //KD_RELEASE_SAFELY(_dateLabel);
    //KD_RELEASE_SAFELY(_image);
    //KD_RELEASE_SAFELY(_title);
    //KD_RELEASE_SAFELY(_content);
    //KD_RELEASE_SAFELY(_date);
    //[super dealloc];
}

@end
