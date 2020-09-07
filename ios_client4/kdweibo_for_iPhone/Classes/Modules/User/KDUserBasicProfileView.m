//
//  KDUserBasicProfileView.m
//  kdweibo
//
//  Created by laijiandong on 12-10-12.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDUserBasicProfileView.h"

#import "KDManagerContext.h"

@interface KDUserBasicProfileView ()

@property(nonatomic, retain) UIImageView *backgroundImageView;

@property(nonatomic, retain) KDUserAvatarView *avatarView;

@property(nonatomic, retain) UILabel *screenNameLabel;
@property(nonatomic, retain) UILabel *departmentLabel;
@property(nonatomic, retain) UILabel *jobTitleLabel;

@end


@implementation KDUserBasicProfileView

@dynamic user;

@synthesize backgroundImageView=backgroundImageView_;
@synthesize avatarView=avatarView_;

@synthesize screenNameLabel=screenNameLabel_;
@synthesize departmentLabel=departmentLabel_;
@synthesize jobTitleLabel=jobTitleLabel_;
@synthesize isDetail = isDetail_;

@dynamic rightView;

@dynamic usingRightViewBounds;
@dynamic rightSideWidthInPercent;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        usingRightViewBounds_ = NO;
        isDetail_ = NO;
        rightSideWidthInPercent_ = 0.0;
        
        [self _setupUserBasicProfileView];
    }
    
    return self;
}

- (void)_setupUserBasicProfileView {
    // avatar view
    avatarView_ = [KDUserAvatarView avatarView];// retain];
    [self addSubview:avatarView_];
    
    // display name label
    screenNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    screenNameLabel_.backgroundColor = [UIColor clearColor];
    screenNameLabel_.font = [UIFont boldSystemFontOfSize:16.0];
    screenNameLabel_.adjustsFontSizeToFitWidth = YES;
    screenNameLabel_.minimumScaleFactor = 12.0;
    screenNameLabel_.textColor = [UIColor blackColor];
    screenNameLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self addSubview:screenNameLabel_];
    
    // department label
    departmentLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    departmentLabel_.backgroundColor = [UIColor clearColor];
    departmentLabel_.font = [UIFont systemFontOfSize:10.0];
    departmentLabel_.textColor = [UIColor blackColor];
    departmentLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self addSubview:departmentLabel_];
    
    // job title label
    jobTitleLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    jobTitleLabel_.backgroundColor = [UIColor clearColor];
    jobTitleLabel_.font = [UIFont systemFontOfSize:10.0];
    jobTitleLabel_.textColor = [UIColor blackColor];
    jobTitleLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self addSubview:jobTitleLabel_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (backgroundImageView_ != nil) {
        backgroundImageView_.frame = self.bounds;
    }
    
    CGFloat offsetX = 10.0;
    CGFloat offsetY = 6.0;
    CGFloat spacing = 5.0;
    
    CGRect rect = CGRectMake(offsetX, offsetY, 47.0, 47.0);
    avatarView_.frame = rect;
    
    offsetX += rect.size.width + spacing;
    offsetY = 8.0;
    
    CGFloat rightSideWidth = usingRightViewBounds_ ? rightView_.bounds.size.width : rightSideWidthInPercent_ * self.bounds.size.width;
    CGFloat width = (self.bounds.size.width - offsetX) - spacing - rightSideWidth;
    
    // screen name
    rect = CGRectMake(offsetX, offsetY, width, 16.0);
    screenNameLabel_.frame = rect;
    
    if(!isDetail_)
        screenNameLabel_.center = CGPointMake(screenNameLabel_.center.x, self.frame.size.height * 0.5);
    
    // department
    rect.origin.y += rect.size.height + 4.0;
    rect.size.height = 12.0;
    departmentLabel_.frame = rect;
    
    if(isDetail_) {
        if ([[KDManagerContext globalManagerContext].communityManager isCompanyDomain]) {
            // job
            rect.origin.y += rect.size.height;
            jobTitleLabel_.frame = rect;
        }
    }
    
    if (rightView_ != nil) {
        offsetY = (self.bounds.size.height - rightView_.bounds.size.height) * 0.5;
        rect = CGRectMake(self.bounds.size.width - rightSideWidth, offsetY, rightSideWidth, rightView_.bounds.size.height);
        rightView_.frame = rect;
    }
}

- (void)update {
    avatarView_.avatarDataSource = user_;
    if(!avatarView_.hasAvatar){
        [avatarView_ setLoadAvatar:YES];
    }
    
    screenNameLabel_.text = user_.screenName;
    
    if(isDetail_) {
        if ([[KDManagerContext globalManagerContext].communityManager isCompanyDomain]) {
            departmentLabel_.text = user_.department;
            jobTitleLabel_.text = user_.jobTitle;
            
        }else {
            departmentLabel_.text = user_.companyName;
        }
    }
}

- (void)setBackgroundImage:(UIImage *)image {
    if (backgroundImageView_ == nil) {
        backgroundImageView_ = [[UIImageView alloc] initWithImage:image];
        [self insertSubview:backgroundImageView_ atIndex:0x00];
    
    } else {
        backgroundImageView_.image = image;
    }
}

///////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Setter and Getter methods

- (void)setUser:(KDUser *)user {
    if (user_ != user) {
//        [user_ release];
        user_ = user;
    }
    
    [self update];
}

- (KDUser *)user {
    return user_;
}

- (void)setRightView:(UIView *)rightView {
    if (rightView_ != rightView) {
        if (rightView_ != nil) {
            if (rightView_.superview != nil) {
                [rightView_ removeFromSuperview];
            }
            
        }
        
        rightView_ = rightView;
        
        if (rightView_ != nil) {
            [self addSubview:rightView_];
            
            [self setNeedsLayout];
        }
    }
}

- (UIView *)rightView {
    return rightView_;
}

- (void)setUsingRightViewBounds:(BOOL)usingRightViewBounds {
    usingRightViewBounds_ = usingRightViewBounds;
    [self setNeedsLayout];
}

- (BOOL)usingRightViewBounds {
    return usingRightViewBounds_;
}

- (void)setRightSideWidthInPercent:(CGFloat)rightSideWidthInPercent {
    CGFloat value = rightSideWidthInPercent;
    if (rightSideWidthInPercent < 0.0) {
        value = 0.0;
    
    } else if (rightSideWidthInPercent > 1.0){
        value = 1.0;
    }
    
    rightSideWidthInPercent_ = value;
    [self setNeedsLayout];
}

- (CGFloat)rightSideWidthInPercent {
    return rightSideWidthInPercent_;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(user_);
    
    //KD_RELEASE_SAFELY(backgroundImageView_);
    
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(screenNameLabel_);
    //KD_RELEASE_SAFELY(departmentLabel_);
    //KD_RELEASE_SAFELY(jobTitleLabel_);
    
    //KD_RELEASE_SAFELY(rightView_);
    
    //[super dealloc];
}

@end
