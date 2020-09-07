//
//  KDInviteTeamCell.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDInviteTeamCell.h"
#import "KDManagerContext.h"

@implementation KDInviteTeamCell
{
    UIView *topView_;
    UIView *bottomView_;
    
//    UILabel *userNameLabel_;
    UILabel *inviterNameLabel_;
    UIView *seperatorView_;
    
    UIButton *ignoreButton_;
    UIButton *joinButton_;
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

    }
    
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(topView_);
    //KD_RELEASE_SAFELY(bottomView_);
//    //KD_RELEASE_SAFELY(userNameLabel_);
    //KD_RELEASE_SAFELY(inviterNameLabel_);
    //KD_RELEASE_SAFELY(seperatorView_);
    //KD_RELEASE_SAFELY(ignoreButton_);
    //KD_RELEASE_SAFELY(joinButton_);
    
    //[super dealloc];
}

+ (CGFloat)defaultHeight
{
    return 30.0f + [super defaultHeight] + 60.0f;
}

- (void)update
{
    [super update];
    
//    KDUser *currentUser = [[KDManagerContext globalManagerContext].userManager currentUser];
//    userNameLabel_.text = [NSString stringWithFormat:ASLocalizedString(@"%@，你好！"), currentUser.username];
//    [userNameLabel_ sizeToFit];
    
    inviterNameLabel_.text = [NSString stringWithFormat:ASLocalizedString(@"KDInviteTeamCell_tips"), self.community.inviter];
    [inviterNameLabel_ sizeToFit];
}

- (UIView *)topView
{
    if(!topView_) {
        topView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 30.0f)];
        topView_.backgroundColor = RGBCOLOR(250, 250, 250);
        
//        userNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
//        userNameLabel_.backgroundColor = [UIColor clearColor];
//        userNameLabel_.font = [UIFont systemFontOfSize:15.0f];
//        [topView_ addSubview:userNameLabel_];
        
        inviterNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        inviterNameLabel_.backgroundColor = [UIColor clearColor];
//        inviterNameLabel_.font = userNameLabel_.font;
        inviterNameLabel_.font = [UIFont systemFontOfSize:15.0f];
        [topView_ addSubview:inviterNameLabel_];
        
        UIImage *image = [UIImage imageNamed:@"team_invite_dash"];
        seperatorView_ = [[UIView alloc] init];
        seperatorView_.backgroundColor = [UIColor colorWithPatternImage:image];
        [topView_ addSubview:seperatorView_];
    }
    
    return topView_;
}

- (UIView *)bottomView
{
    if(!bottomView_) {
        bottomView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 60.0f)];
        bottomView_.backgroundColor = RGBCOLOR(250, 250, 250);
        
        ignoreButton_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
        [ignoreButton_ addTarget:self action:@selector(ignore:) forControlEvents:UIControlEventTouchUpInside];
        [ignoreButton_ setTitle:ASLocalizedString(@"KDInviteTeamCell_ignore")forState:UIControlStateNormal];
        [ignoreButton_ setTitleColor:RGBCOLOR(70, 70, 70) forState:UIControlStateNormal];
        ignoreButton_.layer.borderWidth = 1.0f;
        ignoreButton_.layer.cornerRadius = 5.0f;
        ignoreButton_.layer.masksToBounds = YES;
        ignoreButton_.layer.borderColor = RGBCOLOR(203, 203, 203).CGColor;
        [bottomView_ addSubview:ignoreButton_];
        ignoreButton_.hidden = YES; //暂时不需要‘忽略’选项
        
        joinButton_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
        [joinButton_ addTarget:self action:@selector(join:) forControlEvents:UIControlEventTouchUpInside];
        [joinButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [joinButton_ setTitle:ASLocalizedString(@"KDInviteTeamCell_join")forState:UIControlStateNormal];
        [joinButton_ setBackgroundColor:RGBCOLOR(23, 131, 253)];
        joinButton_.layer.cornerRadius = 5.0f;
        joinButton_.layer.masksToBounds = YES;
        [bottomView_ addSubview:joinButton_];
    }
    
    return bottomView_;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    userNameLabel_.frame = CGRectMake(20.0f, 10.0f, CGRectGetWidth(topView_.frame) - 30.0f, CGRectGetHeight(userNameLabel_.bounds));
//    inviterNameLabel_.frame = CGRectMake(20.0f, CGRectGetMaxY(userNameLabel_.frame) + 8.0f, CGRectGetWidth(topView_.frame) - 30.0f, CGRectGetHeight(inviterNameLabel_.bounds));
    inviterNameLabel_.frame = CGRectMake(20.0f, (CGRectGetHeight(topView_.frame) - CGRectGetHeight(inviterNameLabel_.bounds)) * 0.5f, CGRectGetWidth(topView_.frame) - 30.0f, CGRectGetHeight(inviterNameLabel_.bounds));
    seperatorView_.frame = CGRectMake(8.0f, CGRectGetHeight(topView_.frame) - 1.0f, CGRectGetWidth(topView_.frame) - 16.0f, 1.0f);
    
    CGSize buttonSize = CGSizeMake(70, 30);
    joinButton_.frame = CGRectMake(CGRectGetWidth(bottomView_.frame) - buttonSize.width - 11.0f, CGRectGetHeight(bottomView_.frame) - 15.0f - buttonSize.height, buttonSize.width, buttonSize.height);
    ignoreButton_.frame = CGRectMake(CGRectGetMinX(joinButton_.frame) - buttonSize.width - 10.0f, CGRectGetMinY(joinButton_.frame), buttonSize.width, buttonSize.height);
}

- (void)ignore:(id)sender
{
    if(delegate_ && [delegate_ respondsToSelector:@selector(ignoreInviteInTeamCell:)]) {
        [delegate_ ignoreInviteInTeamCell:self];
    }
}

- (void)join:(id)sender
{
    if(delegate_ && [delegate_ respondsToSelector:@selector(joinTeamInTeamCell:)]) {
        [delegate_ joinTeamInTeamCell:self];
    }
}

@end
