//
//  KDTeamCell.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTeamCell.h"
#import "KDTeamLogoView.h"

@interface KDTeamCell() <UIGestureRecognizerDelegate>
{
    KDTeamLogoView *teamLogoImageView_;
    UILabel        *teamNameLabel_;
    UILabel        *teamNumberLabel_;
    UILabel        *addButtonLabel_;
    
    //for slide
    UIView *menuView_;
    UIView *frontView_;
    CGPoint startPoint_;
    UIPanGestureRecognizer *pan_;
    UITapGestureRecognizer *tap_;
    
    //weak reference
    UIView *topView_;
    UIView *bottomView_;
    UIView *addView_;
    UIView *seperatorView_;
}

@end

@implementation KDTeamCell

@synthesize community = community_;
@synthesize teamNameLabel = teamNameLabel_;
@synthesize teamNumberLabel = teamNumberLabel_;
@synthesize showAddButton = showAddButton_;
@synthesize showTeamNumber = showTeamNumber_;
@synthesize canSlide = canSlide_;
@synthesize needBottomSeperator = needBottomSeperator_;
@synthesize avatarView = teamLogoImageView_;
@synthesize contentEdgeInsets = contentEdgeInsets_;
@synthesize menuView = menuView_;
@synthesize frontView = frontView_;
@synthesize addButtonLabel = addButtonLabel_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        showAddButton_ = NO;
        showTeamNumber_ = YES;
        canSlide_ = NO;
        needBottomSeperator_ = YES;
        contentEdgeInsets_ = UIEdgeInsetsZero;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupViews];
    }
    
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(community_);
    //KD_RELEASE_SAFELY(teamLogoImageView_);
    //KD_RELEASE_SAFELY(teamNameLabel_);
    //KD_RELEASE_SAFELY(teamNumberLabel_);
    //KD_RELEASE_SAFELY(addButtonLabel_);
    //KD_RELEASE_SAFELY(menuView_);
    //KD_RELEASE_SAFELY(frontView_);
    
    //KD_RELEASE_SAFELY(pan_);
    //KD_RELEASE_SAFELY(tap_);
    
    //[super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    teamNameLabel_.highlighted = selected;
    teamNumberLabel_.highlighted = selected;
    addButtonLabel_.highlighted = selected;
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.x += contentEdgeInsets_.left;
    frame.origin.y += contentEdgeInsets_.top;
    frame.size.width -= (contentEdgeInsets_.left + contentEdgeInsets_.right);
    frame.size.height -= (contentEdgeInsets_.top + contentEdgeInsets_.bottom);
    
    [super setFrame:frame];
}

- (void)setupViews
{
    menuView_ = [[UIView alloc] initWithFrame:CGRectZero];
    menuView_.backgroundColor = RGBCOLOR(250, 250, 250);
    [self.contentView addSubview:menuView_];
    
    frontView_ = [[UIView alloc] initWithFrame:CGRectZero];
    frontView_.backgroundColor = RGBCOLOR(250, 250, 250);
    
    tap_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap_.enabled = canSlide_;
    [frontView_ addGestureRecognizer:tap_];
    [self.contentView addSubview:frontView_];
    
    pan_ = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan_.enabled = canSlide_; //canSlide_;
    pan_.delegate = self;
    [self.contentView addGestureRecognizer:pan_];
    
    topView_ = [self topView];
    bottomView_ = [self bottomView];
    
    if(topView_) {
        [self.contentView addSubview:topView_];
    }
    
    if(bottomView_) {
        [self.contentView addSubview:bottomView_];
    }
    
    seperatorView_ = [[UIView alloc] initWithFrame:CGRectZero];
    seperatorView_.backgroundColor = RGBCOLOR(203, 203, 203);
    [self.contentView addSubview:seperatorView_];
//    [seperatorView_ release];
    
    teamLogoImageView_ = [KDTeamLogoView avatarView];// retain];
    teamLogoImageView_.showVipBadge = NO;
    [frontView_ addSubview:teamLogoImageView_];
    
    teamNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    teamNameLabel_.backgroundColor = [UIColor clearColor];
    teamNameLabel_.font = [UIFont systemFontOfSize:15.0f];
    teamNameLabel_.highlightedTextColor = [UIColor whiteColor];
    [frontView_ addSubview:teamNameLabel_];
    
    teamNumberLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    teamNumberLabel_.backgroundColor = [UIColor clearColor];
    teamNumberLabel_.font = [UIFont systemFontOfSize:13.0f];
    teamNumberLabel_.textColor = RGBCOLOR(109, 109, 109);
    teamNumberLabel_.highlightedTextColor = [UIColor whiteColor];
    [frontView_ addSubview:teamNumberLabel_];
    
    
    addView_ = [[UIView alloc] initWithFrame:CGRectZero];
    
    addButtonLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    addButtonLabel_.font = [UIFont systemFontOfSize:15.0f];
    addButtonLabel_.backgroundColor = [UIColor clearColor];
    addButtonLabel_.textColor = RGBCOLOR(23, 131, 253);
    addButtonLabel_.highlightedTextColor = [UIColor whiteColor];
    addButtonLabel_.text = ASLocalizedString(@"加入");
    addButtonLabel_.frame = CGRectZero;
    [addView_ addSubview:addButtonLabel_];
    
    [frontView_ addSubview:addView_];
//    [addView_ release];
    
    self.backgroundView = nil;
    self.backgroundColor = RGBCOLOR(250, 250, 250);
    self.contentView.backgroundColor = RGBCOLOR(250, 250, 250);
}

- (void)setCommunity:(KDCommunity *)community
{
    if(community_ != community) {
//        [community_ release];
        community_ = community;// retain];
        
        [teamLogoImageView_ setAvatarDataSource:community_];
        [teamLogoImageView_ loadAvatar];
    }
    
    [self update];
}

- (void)setCanSlide:(BOOL)canSlide
{
    if(canSlide_ != canSlide) {
        canSlide_ = canSlide;
        
        pan_.enabled = canSlide_;
        tap_.enabled = canSlide_;
    }
}

- (void)setNeedBottomSeperator:(BOOL)needBottomSeperator
{
    if(needBottomSeperator != needBottomSeperator_) {
        needBottomSeperator_ = needBottomSeperator;
        
        seperatorView_.hidden = !needBottomSeperator_;
    }
}

- (void)changeAddTips:(BOOL)isAlreadyIn
{
    if(isAlreadyIn) {
        addButtonLabel_.textColor = RGBCOLOR(109, 109, 109);
        addButtonLabel_.text = ASLocalizedString(@"KDTeamCell_addButtonLabel_text");
    }else {
        addButtonLabel_.textColor = RGBCOLOR(23, 131, 253);
        addButtonLabel_.text = ASLocalizedString(@"加入");
    }
    
    [addButtonLabel_ sizeToFit];
}

- (void)update
{
    [self changeAddTips:community_.isAllowInto];
    
    teamNameLabel_.text = community_.name;
    [teamNameLabel_ sizeToFit];
    teamNumberLabel_.text = [NSString stringWithFormat:ASLocalizedString(@"KDTeamCell_teamNumberLabel_text"), community_.code ? community_.code : @""];
    [teamNumberLabel_ sizeToFit];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat offsetY = 0.0f;
    
    menuView_.frame = self.contentView.bounds;
    frontView_.frame = self.contentView.bounds;
    
    //layout top view
    if(topView_) {
        offsetY += CGRectGetHeight(topView_.bounds);
        
        topView_.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(topView_.bounds));
    }
    
    
    //layout middle view
    offsetY += 12.5f;
    teamLogoImageView_.frame = CGRectMake(10.0f, offsetY, 47.0f, 47.0f);
    
    
    if(showAddButton_) {
        addView_.hidden = NO;
        teamLogoImageView_.frame = CGRectMake(10.0f, (CGRectGetHeight(self.contentView.frame) - 40.0f) * 0.5f, 47.0f, 47.0f);
        addView_.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(addButtonLabel_.bounds) - 5.0f, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(addButtonLabel_.bounds)) * 0.5f, CGRectGetWidth(addButtonLabel_.bounds), CGRectGetHeight(addButtonLabel_.bounds));
    }else {
        addView_.hidden = YES;
        addView_.frame = CGRectMake(CGRectGetWidth(self.contentView.frame), 0, 0, 0);
    }
    
    if(showTeamNumber_) {
        teamNumberLabel_.hidden = NO;
        teamNameLabel_.frame = CGRectMake(CGRectGetMaxX(teamLogoImageView_.frame) + 15.0f, CGRectGetMinY(teamLogoImageView_.frame), MIN(CGRectGetWidth(teamNameLabel_.bounds), CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(teamLogoImageView_.frame) - 25.0f), CGRectGetHeight(teamNameLabel_.bounds));
        teamNumberLabel_.frame = CGRectMake(CGRectGetMinX(teamNameLabel_.frame), CGRectGetMaxY(teamNameLabel_.frame) + 6.0f, MIN(CGRectGetWidth(teamNumberLabel_.bounds), CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(teamLogoImageView_.frame) - 25.0f), CGRectGetHeight(teamNameLabel_.frame));
    }else {
        teamNumberLabel_.hidden = YES;
        
        teamNameLabel_.frame = CGRectMake(CGRectGetMaxX(teamLogoImageView_.frame) + 15.0f, teamLogoImageView_.center.y - CGRectGetHeight(teamNameLabel_.bounds) * 0.5f, MIN(CGRectGetWidth(teamNameLabel_.bounds), CGRectGetMinX(addView_.frame) - CGRectGetMaxX(teamLogoImageView_.frame) - 15.0f), CGRectGetHeight(teamNameLabel_.bounds));
    }
    
    offsetY += 40.0f;
    
    offsetY += 5.0f;
    
    //layout bottom view
    if(bottomView_) {
        bottomView_.frame = CGRectMake(0.0f, offsetY, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(bottomView_.bounds));
    }
    
    seperatorView_.frame = CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame) - 0.5f, CGRectGetWidth(self.frame), 0.5f);
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if(UIGestureRecognizerStateBegan == gesture.state) {
        startPoint_ = [gesture locationInView:self.contentView];
    }else if(UIGestureRecognizerStateChanged == gesture.state) {
        CGPoint curPoint = [gesture locationInView:self.contentView];
        
        //move left
        if(curPoint.x < startPoint_.x) {
            CGFloat distance = curPoint.x - startPoint_.x;
            CGRect frame = frontView_.frame;
            frame.origin.x += distance;
            frontView_.frame = frame;
        }else {
            //move right
            if(CGRectGetMinX(frontView_.frame) < 0) {
                CGFloat distance = curPoint.x - startPoint_.x;
                CGRect frame = frontView_.frame;
                frame.origin.x += distance;
                frontView_.frame = frame;
            }
        }
        
        startPoint_ = curPoint;
    }else if(UIGestureRecognizerStateCancelled == gesture.state || UIGestureRecognizerStateEnded == gesture.state) {
        CGFloat distance = fabs(CGRectGetMinX(frontView_.frame));
        if(distance > [self menuButtonWidth] * 0.35f) {
            [UIView animateWithDuration:0.25f animations:^{
                frontView_.frame = CGRectMake(-[self menuButtonWidth], 0.0f, CGRectGetWidth(frontView_.frame), CGRectGetHeight(frontView_.frame));
            }];
        }else if(distance < [self menuButtonWidth] * 0.35f) {
            [UIView animateWithDuration:0.25f animations:^{
                frontView_.frame = self.contentView.bounds;
            }];
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    if(CGRectGetMinX(frontView_.frame) < 0) {
        [UIView animateWithDuration:0.25f animations:^{
            frontView_.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frontView_.frame), CGRectGetHeight(frontView_.frame));
        }];
    }
}

//for subview override
- (CGFloat)menuButtonWidth
{
    return 80.0f;
}

+ (CGFloat)defaultHeight
{
    return 70.0f;
}

//for subview override
- (UIView *)topView
{
    return nil;
}

//for subview override
- (UIView *)bottomView
{
    return nil;
}

#pragma mark
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer == pan_) {
		UIScrollView *superview = (UIScrollView *)self.superview;
		CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:superview];
		// Make it scrolling horizontally
        if((fabs(translation.x) / fabs(translation.y)) > 1) {
            CGPoint location = [gestureRecognizer locationInView:self.contentView];
            if(CGRectContainsPoint(frontView_.frame, location)) {
                return YES;
            }else {
                return NO;
            }
        }else {
            return NO;
        }
	}
    
	return YES;
}

@end
