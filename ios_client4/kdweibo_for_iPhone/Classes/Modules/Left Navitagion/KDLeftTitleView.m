//
//  KDLeftTitleView.m
//  kdweibo
//
//  Created by gordon_wu on 13-11-22.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//
#define  SEARCH_BTN_TAG      100
#define  SETTING_BTN_TAG     101
#define  AVATARVIEW_TAG      102
#define  NAME_LAB_TAG        103
#define  EMAIL_LAB_TAG       104
#define  INFO_CENTER_BTN_TAG 105

#import "KDLeftTitleView.h"
#import "KDAnimationAvatarView.h"

@implementation KDLeftTitleView
@synthesize user = user_;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/**
 *  @modified-reason:当前view的user可能会被多次赋值，故setup方法会被调用多次，会创建多余的子视图，故进行变更
 *  @modified-by:shenkuikui
 *  @modified-at:2013年11月27日14:53:55
 */
- (void) setup
{
    //查询按钮
    UIImage * searchBtn_image_Normal  = [UIImage imageNamed:@"search_normal_v3.png"];
    UIImage * searchBtn_image_Pressed = [UIImage imageNamed:@"search_pressed_v3.png"];
    
    UIButton *searchButton = (UIButton *)[self viewWithTag:SEARCH_BTN_TAG];
    if(!searchButton) {
        searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        searchButton.tag        = SEARCH_BTN_TAG;
        searchButton.backgroundColor = [UIColor clearColor];
        searchButton.frame      = CGRectMake(24, 67, searchBtn_image_Normal.size.width, searchBtn_image_Normal.size.height);
        [searchButton setImage:searchBtn_image_Normal  forState:UIControlStateNormal];
        [searchButton setImage:searchBtn_image_Pressed forState:UIControlStateHighlighted];
        [searchButton addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:searchButton];
    }
    
    //设置按钮
    UIButton *settingButton = (UIButton *)[self viewWithTag:SETTING_BTN_TAG];
    if(!settingButton) {
        UIImage * settingBtn_image_Normal  = [UIImage imageNamed:@"setting_normal_v3.png"];
        UIImage * settingBtn_image_Pressed = [UIImage imageNamed:@"setting_pressed_v3.png"];
        
        settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        settingButton.tag        = SETTING_BTN_TAG;
        settingButton.backgroundColor = [UIColor clearColor];
        settingButton.frame      = CGRectMake(self.frame.size.width-32-settingBtn_image_Normal.size.width, 67, settingBtn_image_Normal.size.width, settingBtn_image_Normal.size.height);
        [settingButton setImage:settingBtn_image_Normal  forState:UIControlStateNormal];
        [settingButton setImage:settingBtn_image_Pressed forState:UIControlStateHighlighted];
        [settingButton addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:settingButton];
    }
    
    //头像
    KDAnimationAvatarView * kdAnimationAvatarView = (KDAnimationAvatarView *)[self viewWithTag:AVATARVIEW_TAG];
    if(!kdAnimationAvatarView) {
        kdAnimationAvatarView = [[KDAnimationAvatarView alloc] initWithFrame:CGRectMake((settingButton.frame.origin.x-searchButton.frame.origin.x)/2+searchButton.frame.origin.x-30,36,97,97)];// autorelease];
        [kdAnimationAvatarView stopRotate];
        [kdAnimationAvatarView changeAvatarImageTo:[UIImage imageNamed:@"user_avatar_placeholder_v3.png"] animation:NO];
        kdAnimationAvatarView.tag                     = AVATARVIEW_TAG;
        [self addSubview:kdAnimationAvatarView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatarView:)];
        [kdAnimationAvatarView addGestureRecognizer:tap];
//        [tap release];
    }
    [kdAnimationAvatarView setAvatarImageURL:user_.profileImageUrl];
    
    //名称
    UILabel *nameLabel = (UILabel *)[self viewWithTag:NAME_LAB_TAG];
    if(!nameLabel) {
        nameLabel       = [[UILabel alloc] initWithFrame:CGRectZero];// autorelease];
        nameLabel.numberOfLines   = 1;
        nameLabel.font            = [UIFont systemFontOfSize:18];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor       = [UIColor whiteColor];
        nameLabel.textAlignment   = NSTextAlignmentCenter;
        nameLabel.lineBreakMode   = NSLineBreakByWordWrapping;
        nameLabel.tag             = NAME_LAB_TAG;
//        [self addSubview:nameLabel];
    }
    nameLabel.text            = user_.screenName;
    CGSize nameSize = [user_.username sizeWithFont:[UIFont systemFontOfSize:18]
                                 constrainedToSize:CGSizeMake(self.frame.size.width, 20)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    nameLabel.frame = CGRectMake(kdAnimationAvatarView.center.x-nameSize.width/2,131,nameSize.width,nameSize.height);
    
    /*
    //收到的团队邀请按钮
    UIButton *infoBtn = (UIButton *)[self viewWithTag:INFO_CENTER_BTN_TAG];
    if(!infoBtn) {
        infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        infoBtn.backgroundColor = [UIColor clearColor];
        infoBtn.tag = INFO_CENTER_BTN_TAG;
        infoBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [infoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [infoBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [infoBtn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:infoBtn];
        [self setInfoCount:0];
    }
     */
    
    //邮件
    UILabel *emailLabel = (UILabel *)[self viewWithTag:EMAIL_LAB_TAG];
    if(!emailLabel) {
        emailLabel       = [[UILabel alloc] initWithFrame:CGRectZero];// autorelease];
        emailLabel.numberOfLines   = 1;
        emailLabel.font            = [UIFont systemFontOfSize:14];
        emailLabel.backgroundColor = [UIColor clearColor];
        emailLabel.textColor       = [UIColor whiteColor];
        emailLabel.textAlignment   = NSTextAlignmentCenter;
        emailLabel.lineBreakMode   = NSLineBreakByWordWrapping;
        emailLabel.tag             = EMAIL_LAB_TAG;
//        [self addSubview:emailLabel];
    }
    emailLabel.text            = user_.email;
    NSString * email =@"gordon_wu@kingdee.com";
    CGSize emailSize = [email sizeWithFont:[UIFont systemFontOfSize:14]
                         constrainedToSize:CGSizeMake(self.frame.size.width, 16)
                             lineBreakMode:NSLineBreakByWordWrapping];
    emailLabel.frame = CGRectMake(kdAnimationAvatarView.center.x-emailSize.width/2,156,emailSize.width,emailSize.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView *nameView = [self viewWithTag:NAME_LAB_TAG];
    
    UIButton *infoBtn = (UIButton *)[self viewWithTag:INFO_CENTER_BTN_TAG];
    
    if(nameView && infoBtn) {
        infoBtn.frame = CGRectMake(CGRectGetMaxX(nameView.frame) + 2.0f, CGRectGetMidY(nameView.frame) - CGRectGetHeight(infoBtn.bounds) * 0.5f, CGRectGetWidth(infoBtn.bounds), CGRectGetHeight(infoBtn.bounds));
    }
}

/**
 *
 * 当user == user_时，会有问题，故更正。
 *
 */
- (void) setUser:(KDUser *)user
{
//    [user retain];
    //KD_RELEASE_SAFELY(user_);
    user_ = user;
    [self setup];
}

- (void)setInfoCount:(NSInteger)count
{
    if(count < 0) return;
    
    UIButton *infoBtn = (UIButton *)[self viewWithTag:INFO_CENTER_BTN_TAG];
    
    if(count == 0) {
        UIImage *bell = [UIImage imageNamed:@"left_invitation_none_v3.png"];
        [infoBtn setBackgroundImage:bell forState:UIControlStateNormal];
        infoBtn.frame = CGRectMake(0, 0, bell.size.width, bell.size.height);
        infoBtn.enabled = NO;
    }else {
        infoBtn.enabled = YES;
        UIImage *bg = [UIImage imageNamed:@"left_invitation_bg_v3.png"];
        CGSize imageSize = bg.size;
        bg = [bg stretchableImageWithLeftCapWidth:imageSize.width * 0.5f topCapHeight:imageSize.height * 0.5f];
        NSString *title = [NSString stringWithFormat:@"%ld", (long)count];
        CGSize titleSize = [title sizeWithFont:infoBtn.titleLabel.font];
        //13.0 = 3.0f（图片的尖嘴） + 2 * 5.0f（数字到button边缘的距离）
        [infoBtn setBackgroundImage:bg forState:UIControlStateNormal];
        [infoBtn setTitle:title forState:UIControlStateNormal];
        infoBtn.frame = CGRectMake(0.0f, 0.0f, MAX(imageSize.width, titleSize.width + 13.0f), imageSize.height);
    }
    
    [self setNeedsLayout];
}

- (void) btnPressed:(id) sender
{
    UIButton *btn = (UIButton *)sender;
    if(btn.tag == SEARCH_BTN_TAG) {
        if(_delegate && [_delegate respondsToSelector:@selector(leftTitleView:searchButtonClicked:)]) {
            [_delegate leftTitleView:self searchButtonClicked:btn];
        }
    }else if(btn.tag == SETTING_BTN_TAG) {
        if(_delegate && [_delegate respondsToSelector:@selector(leftTitleView:settingButtonClicked:)]) {
            [_delegate leftTitleView:self settingButtonClicked:btn];
        }
    }
//    if(btn.tag == INFO_CENTER_BTN_TAG) {
//        if(_delegate && [_delegate respondsToSelector:@selector(leftTitleView:infoCenterButtonClicked:)]) {
//            [_delegate leftTitleView:self infoCenterButtonClicked:btn];
//        }
//    }
}

- (void)tapAvatarView:(UITapGestureRecognizer *)gesture
{
    KDAnimationAvatarView *avatarView = (KDAnimationAvatarView *)[self viewWithTag:AVATARVIEW_TAG];
    if(_delegate && [_delegate respondsToSelector:@selector(leftTitleView:avatarViewClicked:)]) {
        [_delegate leftTitleView:self avatarViewClicked:avatarView];
    }
}

- (KDAnimationAvatarView *)avatarView
{
    return (KDAnimationAvatarView *)[self viewWithTag:AVATARVIEW_TAG];
}

- (void) dealloc
{
    //KD_RELEASE_SAFELY(user_);
    //[super dealloc];
}

@end
