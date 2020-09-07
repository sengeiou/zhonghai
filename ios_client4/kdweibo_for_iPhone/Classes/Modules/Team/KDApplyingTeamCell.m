//
//  KDApplyingTeamCell.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDApplyingTeamCell.h"

@implementation KDApplyingTeamCell
{
    UILabel  *applyingLabel_;
    UIButton *cancelButton_;
}

@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.showAddButton = NO;
        self.showTeamNumber = NO;
//        self.canSlide = YES;
        
        [self configMenuView];
    }
    
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(applyingLabel_);
    //KD_RELEASE_SAFELY(cancelButton_);
    
    //[super dealloc];
}

+ (CGFloat)defaultHeight
{
    //44.0f for bottom view.
    return [super defaultHeight];
}

- (void)configMenuView
{
    cancelButton_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    [cancelButton_ setBackgroundColor:RGBCOLOR(221, 221, 221)];
    [cancelButton_ addTarget:self action:@selector(cancelApply:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton_ setTitle:ASLocalizedString(@"KDApplyingTeamCell_cancel_apply")forState:UIControlStateNormal];
    [cancelButton_ setTitleColor:RGBCOLOR(116, 116, 116) forState:UIControlStateNormal];
    cancelButton_.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.menuView addSubview:cancelButton_];
    
    applyingLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    applyingLabel_.backgroundColor = [UIColor clearColor];
    applyingLabel_.text = ASLocalizedString(@"KDApplyingTeamCell_cancel_audit");
    applyingLabel_.textColor = RGBCOLOR(251, 87, 0);
    applyingLabel_.font = [UIFont systemFontOfSize:15.0f];
    [applyingLabel_ sizeToFit];
    [self.frontView addSubview:applyingLabel_];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    applyingLabel_.frame = CGRectMake(CGRectGetWidth(self.frontView.frame) - CGRectGetWidth(applyingLabel_.bounds) - 13.0f, (CGRectGetHeight(self.frontView.frame) - CGRectGetHeight(applyingLabel_.bounds)) * 0.5f, CGRectGetWidth(applyingLabel_.bounds), CGRectGetHeight(applyingLabel_.bounds));
    
    CGSize btnSize = CGSizeMake(80, 70);
    cancelButton_.frame = CGRectMake(CGRectGetWidth(self.menuView.frame) - btnSize.width, (CGRectGetHeight(self.menuView.frame) - btnSize.height) * 0.5f, btnSize.width, btnSize.height);
    
    if(CGRectGetMaxX(self.teamNameLabel.frame) > CGRectGetMinX(applyingLabel_.frame)) {
        self.teamNameLabel.frame = CGRectMake(CGRectGetMinX(self.teamNameLabel.frame), CGRectGetMinY(self.teamNameLabel.frame), CGRectGetMinX(applyingLabel_.frame) - 10.0f - CGRectGetMinX(self.teamNameLabel.frame), CGRectGetHeight(self.teamNameLabel.frame));
    }
    
    if(CGRectGetMaxX(self.teamNumberLabel.frame) > CGRectGetMinX(applyingLabel_.frame)) {
        self.teamNumberLabel.frame = CGRectMake(CGRectGetMinX(self.teamNumberLabel.frame), CGRectGetMinY(self.teamNumberLabel.frame), CGRectGetMinX(applyingLabel_.frame) - CGRectGetMinX(self.teamNumberLabel.frame) - 10.0f, CGRectGetHeight(self.teamNumberLabel.frame));
    }
}

- (void)cancelApply:(id)sender
{
    if(delegate_ && [delegate_ respondsToSelector:@selector(cancelApplyTeamOfApplyingTeamCell:)]) {
        [delegate_ cancelApplyTeamOfApplyingTeamCell:self];
    }
}

@end
