//
//  KDDiscoveryViewCell.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDDiscoveryViewCell.h"
#import "UIView+Blur.h"
@interface KDDiscoveryViewCell(){
    NSInteger badgeValue;
    UIImageView *customImageView;
    
    UIImageView *narrowImageView_;
    CALayer *topLine_;
    CALayer *leftLine_;
    CALayer *bottomLine_;
    CALayer *rightLine_;
}
@property (nonatomic, retain) UIImageView *tipBadgeView;
@end

@implementation KDDiscoveryViewCell

@synthesize avatarImageView;
@synthesize discoveryLabel;
@synthesize accessoryImageView;
@synthesize badgeImageView;
@synthesize userAvatar = userAvatar_;
@synthesize tipBadgeView;
@synthesize extendView = extendView_;
@synthesize inlineStyle = inlineStyle_;
@synthesize rowType = rowType_;
- (void)initWithInlineLineStyle : (KDDiscoveryViewCellInlineStyle)inlineStyle  reuseIdentifier : (NSString *)reuseIdentifier{
    inlineStyle_ = inlineStyle;
    [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        badgeValue = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.contentView.backgroundColor = self.backgroundColor; //UIColorFromRGB(0xfafafa);
        
        avatarImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        avatarImageView.backgroundColor = [UIColor clearColor];
        avatarImageView.layer.cornerRadius = 6;
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:avatarImageView];
        
        discoveryLabel = [[UILabel alloc]init];
        discoveryLabel.textColor = [UIColor blackColor];
        discoveryLabel.backgroundColor = [UIColor clearColor];
        discoveryLabel.textAlignment = NSTextAlignmentLeft;
        discoveryLabel.font = [UIFont systemFontOfSize:16.f];
        [self.contentView addSubview:discoveryLabel];
        
        accessoryImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_img_vector"]];
        [accessoryImageView sizeToFit];
        accessoryImageView.highlightedImage = [UIImage imageNamed:@"common_img_vector"];
        [self.contentView addSubview:accessoryImageView];
        

        badgeImageView = [[KDBadgeView alloc]init];
        [badgeImageView setBadgeBackgroundImage:[KDBadgeView newRedBadgeBackgroundImage]];
        [badgeImageView setBadgeColor:[UIColor whiteColor]];
        [badgeImageView setbadgeTextFont:[UIFont systemFontOfSize:11.5]];
        [self.contentView addSubview:badgeImageView];
        
        tipBadgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_img_new_dot"]];
        [tipBadgeView sizeToFit];
        tipBadgeView.hidden = YES;
        [self.contentView addSubview:tipBadgeView];
        
        UIView *selectBgView = [[UIView alloc] initWithFrame:self.bounds];// autorelease];
        selectBgView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        selectBgView.backgroundColor = UIColorFromRGB(0xdddddd);
        self.selectedBackgroundView = selectBgView;
        [self setupLines];

    }
    return self;
}



- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat offsetX = 15.f;
    CGFloat offsetY = 8.f;
    CGRect rect = CGRectMake(offsetX, offsetY, 35 , 35);
    avatarImageView.frame = rect;
    
    offsetX += CGRectGetWidth(avatarImageView.frame) + 10.f;
    rect = CGRectMake(offsetX, offsetY, CGRectGetWidth(self.bounds) - offsetX - 13.f , CGRectGetHeight(rect));
    discoveryLabel.frame = rect;
   
    [self.badgeImageView sizeToFit];
     //rect = self.badgeImageView.frame;
    CGPoint point = CGPointMake(CGRectGetMaxX(self.avatarImageView.frame) - 4.f, CGRectGetMinY(self.avatarImageView.frame) + 6.f);
    self.badgeImageView.center = point;

    
    accessoryImageView.center = CGPointMake(CGRectGetWidth(self.contentView.frame) - 10.0f - CGRectGetWidth(accessoryImageView.frame)*0.5, CGRectGetMidY(avatarImageView.frame));
    
    if (self.userAvatar) {
        rect = CGRectMake(CGRectGetMinX(accessoryImageView.frame) - 10.f - 35.f, (CGRectGetHeight(self.bounds) - 35) /2, 35, 35);
        userAvatar_.frame =rect;
   }
    
    self.tipBadgeView.center = CGPointMake(CGRectGetMaxX(self.avatarImageView.frame) - 2.f, CGRectGetMinY(self.avatarImageView.frame) +2.f);
    
    
    offsetX = 0.0f;
    offsetY = 7.0f;
    if (extendView_) {
        offsetY = CGRectGetMaxY(avatarImageView.frame)+ offsetY;
        extendView_.frame = CGRectMake(offsetX, offsetY,CGRectGetWidth(self.contentView.bounds)-offsetX *2, CGRectGetHeight(self.contentView.bounds) - offsetY);
    }
    
    rect = self.selectedBackgroundView.frame;
    rect.size.height = 50;
    self.selectedBackgroundView.frame = rect;
    //Ø[self setNeedsDisplay];
}

- (void)setExtendView:(KDTopicGridView *)extendView {
    if (extendView_ != extendView) {
        //[extendView_ removeFromSuperview];
//        [extendView_ release];
        extendView_ = extendView ;//retain];
        if (extendView_) {
            [self.contentView addSubview:extendView_];
        }
    }
}

- (void)setupLines
{
    topLine_ = [self genLine];
    //leftLine_ = [self genLine];
    bottomLine_ = [self genLine];
    //rightLine_ = [self genLine];
    
    [self.layer addSublayer:topLine_];
    //[self.layer addSublayer:leftLine_];
    [self.layer addSublayer:bottomLine_];
    //[self.layer addSublayer:rightLine_];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    narrowImageView_.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 13.0f, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(narrowImageView_.bounds)) * 0.5f, CGRectGetWidth(narrowImageView_.bounds), CGRectGetHeight(narrowImageView_.bounds));
    
    topLine_.frame = CGRectMake(CGRectGetMinX(self.discoveryLabel.frame), 0.0f, CGRectGetWidth(self.layer.frame), 0.4f);
    //leftLine_.frame = CGRectMake(0, 0, 0.5f, CGRectGetHeight(self.layer.frame));
    bottomLine_.frame = CGRectMake(CGRectGetMinX(self.discoveryLabel.frame), CGRectGetHeight(self.layer.frame) - 0.4f, CGRectGetWidth(self.layer.frame), 0.4f);
    //rightLine_.frame = CGRectMake(CGRectGetWidth(self.layer.frame) - 0.5f, 0.0f, 0.5f, CGRectGetHeight(self.layer.frame));
    
    if(self.rowType == FullRow)
    {
        topLine_.frame = CGRectMake(12.0f, 0.0f, CGRectGetWidth(self.layer.frame)-12, 0.4f);
        bottomLine_.frame = CGRectMake(12.0f, CGRectGetHeight(self.layer.frame) - 0.4f, CGRectGetWidth(self.layer.frame)-12, 0.4f);
    }
}

- (CALayer *)genLine
{
    CALayer *line = [CALayer layer];
    line.backgroundColor = UIColorFromRGB(0xdddddd).CGColor;
    
    return line;
}


- (void)setRowType:(RowType)rowType{
    rowType_ = rowType;
    [self applyRowType];
}

- (void)applyRowType
{
    switch (rowType_) {
        case FirstRow:
            topLine_.hidden = NO;
            bottomLine_.hidden = YES;
            break;
        case MiddleRow:
            topLine_.hidden = NO;
            bottomLine_.hidden = NO;
            break;
        case LastRow:
            topLine_.hidden = YES;
            bottomLine_.hidden = NO;
            break;
        case FullRow:
            topLine_.hidden = NO;
            bottomLine_.hidden = NO;
            break;
        default:
            topLine_.hidden = YES;
            bottomLine_.hidden = YES;
            break;
    }
}
- (void)setBadgeValue:(NSInteger)newbadgeValue
{
    badgeValue = newbadgeValue;
    self.badgeImageView.badgeValue = badgeValue;

}

- (void)setUserAvatar:(KDUserAvatarView *)userAvatar {
    if (userAvatar_ != userAvatar) {
        [userAvatar_ removeFromSuperview];
//        [userAvatar_ release];
        userAvatar_ = userAvatar;// retain];
        if (userAvatar_) {
            [self.contentView addSubview:userAvatar_];
        }
    }
}
- (void)showBadgeTipView :(BOOL)showed{
    if(showed == YES)
        self.tipBadgeView.hidden = NO;
    else
        self.tipBadgeView.hidden = YES;
}



- (void)dealloc{
    //KD_RELEASE_SAFELY(avatarImageView);
    //KD_RELEASE_SAFELY(userAvatar_);
    //KD_RELEASE_SAFELY(discoveryLabel);
    //KD_RELEASE_SAFELY(accessoryImageView);
    //KD_RELEASE_SAFELY(badgeImageView);
    //KD_RELEASE_SAFELY(extendView_);
    //[super dealloc];
}

@end
