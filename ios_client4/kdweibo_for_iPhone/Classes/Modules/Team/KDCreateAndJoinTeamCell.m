//
//  KDCreateAndJoinTeamCell.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-30.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDCreateAndJoinTeamCell.h"

@implementation KDCreateAndJoinTeamCell
{
    UILabel *tipsLabel_;
    
    UIButton *createButton_;
    UIButton *joinButton_;
}

@synthesize delegate = delegate_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(tipsLabel_);
    //KD_RELEASE_SAFELY(createButton_);
    //KD_RELEASE_SAFELY(joinButton_);
    
    //[super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    tipsLabel_.frame = CGRectMake((CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(tipsLabel_.bounds)) * 0.5f, 34.0f, CGRectGetWidth(tipsLabel_.bounds), CGRectGetHeight(tipsLabel_.bounds));
    createButton_.frame = CGRectMake((CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(createButton_.bounds)) * 0.5f, CGRectGetMaxY(tipsLabel_.frame) + 25.0f, CGRectGetWidth(createButton_.bounds), CGRectGetHeight(createButton_.bounds));
    joinButton_.frame = CGRectMake((CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(joinButton_.bounds)) * 0.5f, CGRectGetMaxY(createButton_.frame) + 30.0f, CGRectGetWidth(joinButton_.bounds), CGRectGetHeight(joinButton_.bounds));
}

- (void)setupView
{
    self.backgroundView = nil;
    self.backgroundColor = RGBCOLOR(250, 250, 250);
    self.contentView.backgroundColor = RGBCOLOR(250, 250, 250);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    tipsLabel_ = [[UILabel alloc] init];
    tipsLabel_.backgroundColor = [UIColor clearColor];
    tipsLabel_.textColor = RGBCOLOR(109, 109, 109);
    tipsLabel_.text = ASLocalizedString(@"KDCreateAndJoinTeamCell_regis");
    tipsLabel_.font = [UIFont systemFontOfSize:15.0f];
    [tipsLabel_ sizeToFit];
    
    [self.contentView addSubview:tipsLabel_];
    
    createButton_ = [self buttonWithImage:@"create_team_icon_v3.png" action:@selector(create:) andTitle:ASLocalizedString(@"KDCreateAndJoinTeamCell_regis")];// retain];
    [self.contentView addSubview:createButton_];
    
    joinButton_ = [self buttonWithImage:@"add_to_team_icon_v3.png" action:@selector(join:) andTitle:ASLocalizedString(@"KDCreateAndJoinTeamCell_join")];// retain];
    [self.contentView addSubview:joinButton_];
}

- (UIButton *)buttonWithImage:(NSString *)imageName action:(SEL)action andTitle:(NSString *)title
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 290.0f, 41.0f);
    UIButton *bgView = [[UIButton alloc] initWithFrame:rect];
    bgView.backgroundColor = RGBCOLOR(32, 192, 0);
    bgView.layer.cornerRadius = 5.0f;
    bgView.layer.masksToBounds = YES;
    [bgView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_narrow_v3.png"]];
    accessoryView.frame = CGRectMake(CGRectGetWidth(bgView.frame) - accessoryView.image.size.width - 15.f, (CGRectGetHeight(bgView.frame) - accessoryView.image.size.height) / 2.f, accessoryView.image.size.width, accessoryView.image.size.height);
    [bgView addSubview:accessoryView];
    [bgView addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [bgView setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [bgView setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 30.0f)];
    [bgView setTitle:title forState:UIControlStateNormal];
    
//    [accessoryView release];
    
    return bgView;// autorelease];
}

- (void)create:(id)sender
{
    if(delegate_ && [delegate_ respondsToSelector:@selector(createButtonClickedInCreateAndJoinTeamCell:)]) {
        [delegate_ createButtonClickedInCreateAndJoinTeamCell:self];
    }
}

- (void)join:(id)sender
{
    if(delegate_ && [delegate_ respondsToSelector:@selector(joinButtonClickedInCreateAndJoinTeamCell:)]) {
        [delegate_ joinButtonClickedInCreateAndJoinTeamCell:self];
    }
}

+ (CGFloat)defaultHeight
{
    return 256.0f;
}

@end
