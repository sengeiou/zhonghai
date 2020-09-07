//
//  XTPersonDetailHeaderView.m
//  XT
//
//  Created by Gil on 13-7-24.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTPersonDetailHeaderView.h"
#import "PersonSimpleDataModel.h"
#import "XTPersonHeaderImageView.h"
#import "UIImage+XT.h"
#import "BOSConfig.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#define ImageNameFlagDown @"user_img_collect_down.png"
#define ImageNameFlagNormal @"user_img_collect_normal.png"
#define buttonWidth 80
#define functionButtonWidth 44.0f  //收藏、关注按钮
#define photoImageWidth 68.f

@interface XTPersonDetailHeaderView ()

//UI
//@property (nonatomic, strong) XTPersonHeaderImageView *headerImageView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *nameBgView;
@property (nonatomic, strong) UIImageView *partnerImageView;
@property (nonatomic, strong) UIImageView *genderImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *jobTitleLabel;
//@property (nonatomic, strong) UIButton *favoritedButton;    //收藏
//@property (nonatomic, strong) UIButton *attentionButton;    //关注

//@property (nonatomic, strong) UIButton *friendsButton;  //关注
//@property (nonatomic, strong) UIButton *fansButton;     //粉丝
//@property (nonatomic, strong) UIButton *statusButton;   //微博
@property (nonatomic, strong) UIView *lineView1;
@property (nonatomic, strong) UIView *lineView2;


@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *sendCarteButton;
//@property (nonatomic, strong) UIButton *sendMessageButton;



@property (nonatomic, strong) UIButton *buttonFlag;
@property (nonatomic, strong) UIImageView *imageViewFlagDown;
@property (nonatomic, strong) UIImageView *imageViewFlagNormal;
@property (nonatomic, assign) BOOL bCollection; // 用户是否被搜藏
@property (nonatomic, assign) BOOL bShouldUpdateFlagTransition; // 是否需要继续更新flag的alpha

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UIImageView *unActivatedView;// 未激活

@end

@implementation XTPersonDetailHeaderView


- (id)initWithPerson:(PersonDataModel *)person withpublic:(BOOL)ispublic
{

//    CGFloat height = ispublic ? 114.0f : (220 - 15 + (isAboveiOS7 ? 20 : 0) + 39.0f + 39.0f);
    CGFloat height = ispublic ? 114.0f : (220 - 15 +  20);
    self = [super initWithFrame:CGRectMake(0.0, 0.0, ScreenFullWidth, height)];
    if (self) {
        isPublic = ispublic;
        self.backgroundColor = BOSCOLORWITHRGBA(0xF0F0F0, 1.0);
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.backgroundView];
        [self.scrollView addSubview:self.photoView];
        [self.scrollView addSubview:self.nameBgView];
        [self.scrollView addSubview:self.jobTitleLabel];
        //[self.scrollView addSubview:self.favoritedButton];
        //[self.scrollView addSubview:self.attentionButton];
        self.photoView.userInteractionEnabled = YES;
        [self.photoView setImageWithURL:[NSURL URLWithString:person.photoUrl] placeholderImage:[UIImage imageNamed:@"user_default_portrait"] scale:SDWebImageScalePreView];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewClick:)];
        [self.photoView addGestureRecognizer:gesture];
        self.nameLabel.text = self.person.personName;
        
//        if(!isPublic) {
//            self.bShouldUpdateFlagTransition = [person hasFavor];
//
//            UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView.frame)-39.f, ScreenFullWidth, 39.0f)];
//            bottomView.backgroundColor = [UIColor colorWithRGB:0xffffff];
//
//            self.friendsButton = [self buttonWithTitle:[NSString stringWithFormat:ASLocalizedString(@"XTPersonDetailHeaderView_Attention"), (long)_followCount]];
//            [bottomView addSubview:self.friendsButton];
//            self.fansButton = [self buttonWithTitle:[NSString stringWithFormat:ASLocalizedString(@"XTPersonDetailHeaderView_Fun"), (long)_fansCount]];
//            [bottomView addSubview:self.fansButton];
//            self.statusButton = [self buttonWithTitle:[NSString stringWithFormat:ASLocalizedString(@"XTPersonDetailHeaderView_WB"), (long)_statusCount]];
//            [bottomView addSubview:self.statusButton];
//            
//            
//            self.lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 12)];
//            self.lineView1.backgroundColor = BOSCOLORWITHRGBA(0xEAEFF3, 1.0f);
//            [bottomView addSubview:self.lineView1];
//            
//            self.lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 12)];
//            self.lineView2.backgroundColor = BOSCOLORWITHRGBA(0xEAEFF3, 1.0f);
//            [bottomView addSubview:self.lineView2];
//            
//          [self addSubview:bottomView];
//            
//        }

        if (person != nil && [person accountAvailable] && [person xtAvailable]) {
            self.unActivatedView.hidden = YES;
        }

        self.person = person;
    }
    return self;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    }
    return _scrollView;
}

- (UIImageView *)photoView {
    if (_photoView == nil) {
        _photoView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_scrollView.bounds) - photoImageWidth) / 2, 71.0, photoImageWidth, photoImageWidth)];
        _photoView.layer.cornerRadius = photoImageWidth/2;
        _photoView.layer.masksToBounds = YES;
        _photoView.layer.borderWidth = 2.0;
        _photoView.layer.borderColor = FC6.CGColor;
        _photoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [_photoView addSubview:self.unActivatedView];
    }
    return _photoView;
}

-(UIView *)nameBgView
{
    if(_nameBgView == nil)
    {
        _nameBgView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.photoView.frame), CGRectGetMaxY(self.photoView.frame) + [NSNumber kdDistance1], 0, 18.0f)];
        [_nameBgView addSubview:self.partnerImageView];
        [_nameBgView addSubview:self.nameLabel];
        [_nameBgView addSubview:self.genderImageView];
        
        _nameBgView.autoresizingMask = _photoView.autoresizingMask;
    }
    return _nameBgView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.partnerImageView.frame)+5, 0, 150, CGRectGetHeight(self.nameBgView.frame))];
        _nameLabel.center = CGPointMake(_nameLabel.center.x, self.partnerImageView.center.y);
        _nameLabel.font = FS3;
        _nameLabel.textColor = FC1;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.autoresizingMask = self.partnerImageView.autoresizingMask;
    }
    return _nameLabel;
}

- (UILabel *)jobTitleLabel {
    if (_jobTitleLabel == nil) {
        _jobTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.nameBgView.frame)+3, 150, CGRectGetHeight(self.nameBgView.frame))];
        _jobTitleLabel.center = CGPointMake(ScreenFullWidth/2, _jobTitleLabel.center.y);
        _jobTitleLabel.font = FS6;
        _jobTitleLabel.textColor = [UIColor colorWithRGB:0x768893];
        _jobTitleLabel.backgroundColor = [UIColor clearColor];
        _jobTitleLabel.textAlignment = NSTextAlignmentCenter;
        _jobTitleLabel.autoresizingMask = _nameBgView.autoresizingMask;
    }
    return _jobTitleLabel;
}

-(UIImageView *)partnerImageView
{
    //外部员工图标
    if(_partnerImageView == nil)
    {
        _partnerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.nameBgView.frame), CGRectGetHeight(self.nameBgView.frame))];
        _partnerImageView.image = [UIImage imageNamed:@"message_tip_shang_small"];
        //_partnerImageView.backgroundColor = [UIColor blueColor];
        //_partnerImageView.autoresizingMask = _photoView.autoresizingMask;
    }
    return _partnerImageView;
}

-(UIImageView *)genderImageView
{
    //性别图标
    if(_genderImageView == nil)
    {
        _genderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.nameLabel.frame)+2, 0, CGRectGetHeight(self.nameBgView.frame), CGRectGetHeight(self.nameBgView.frame))];
        _genderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _genderImageView.image = [UIImage imageNamed:@"profile_tip_male"];
        //_partnerImageView.backgroundColor = [UIColor blueColor];
        //_partnerImageView.autoresizingMask = _photoView.autoresizingMask;
    }
    return _genderImageView;
}

- (UIImageView *)backgroundView {
    if (_backgroundView == nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor whiteColor];
        //imageView.image = [UIImage imageNamed:@"profile_bg_top_male"];
        _backgroundView = imageView;
    }
    return _backgroundView;
}

////收藏
//-(UIButton *)favoritedButton
//{
//    if (_favoritedButton == nil) {
//        _favoritedButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenFullWidth/4, CGRectGetMinY(self.nameBgView.frame), functionButtonWidth, functionButtonWidth)];
//        [_favoritedButton setBackgroundImage:[UIImage imageNamed:@"profile_btn_function_normal"] forState:UIControlStateNormal];
//        [_favoritedButton setBackgroundImage:[UIImage imageNamed:@"profile_btn_function_normal@2x"] forState:UIControlStateHighlighted];
//        [_favoritedButton setTitle:ASLocalizedString(@"XTPersonDetailHeaderView_Collected")forState:UIControlStateNormal];
//        [_favoritedButton setTitleColor:FC2 forState:UIControlStateNormal];
//        [_favoritedButton setTitleColor:[UIColor colorWithRGB:0xDFEBF2] forState:UIControlStateHighlighted];
//        [_favoritedButton.titleLabel setFont:FS6];
//        [_favoritedButton addTarget:self action:@selector(favoritedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _favoritedButton;
//}
//
//-(UIButton *)attentionButton
//{
//    if(_attentionButton == nil){
//        _attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenFullWidth* 3/4, CGRectGetMinY(self.nameBgView.frame), functionButtonWidth, functionButtonWidth)];
//        [_attentionButton setBackgroundImage:[UIImage imageNamed:@"profile_btn_function_normal"] forState:UIControlStateNormal];
//        [_attentionButton setBackgroundImage:[UIImage imageNamed:@"profile_btn_function_normal@2x"] forState:UIControlStateHighlighted];
//        [_attentionButton setTitle:self.isFollowing ? ASLocalizedString(@"XTPersonDetailHeaderView_Attented"): ASLocalizedString(@"XTPersonDetailHeaderView_Attent")forState:UIControlStateNormal];
//        [_attentionButton setTitleColor:FC2 forState:UIControlStateNormal];
//        [_attentionButton setTitleColor:[UIColor colorWithRGB:0xDFEBF2] forState:UIControlStateHighlighted];
//        [_attentionButton.titleLabel setFont:FS6];
//        [_attentionButton addTarget:self action:@selector(attentionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    return _attentionButton;
//}

//- (UIButton *)buttonWithTitle:(NSString *)title
//{
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [btn setBackgroundColor:[UIColor clearColor]];
//    btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    [btn setTitleColor:[UIColor kdTextColor1] forState:UIControlStateNormal];
//    [btn setTitle:title forState:UIControlStateNormal];
//    
//    return btn;
//}

- (UIImageView *)unActivatedView {
    
    if(_unActivatedView == nil)
    {
        _unActivatedView = [[UIImageView alloc] initWithImage:[XTImageUtil headerXTAvailableImage]];
        _unActivatedView.frame = CGRectMake(0, 0, photoImageWidth, photoImageWidth);
        _unActivatedView.hidden = YES;
        
        UILabel *unactivatedLabel = [[UILabel alloc] init];
        unactivatedLabel.center = CGPointMake(self.photoView.frame.size.width/2, self.photoView.frame.size.height/2);
        unactivatedLabel.text = ASLocalizedString(@"KDInvitePhoneContactsViewController_un_active");
        unactivatedLabel.textAlignment = NSTextAlignmentCenter;
        unactivatedLabel.textColor = [UIColor colorWithRed:77/256.0 green:94/256.0 blue:105/256.0 alpha:1];
        
        unactivatedLabel.font = [UIFont systemFontOfSize:10];
        [unactivatedLabel sizeToFit];
        CGRect unactivatedFrame = unactivatedLabel.frame;
        unactivatedFrame.origin.x -= unactivatedFrame.size.width/2;
        unactivatedFrame.origin.y -= unactivatedFrame.size.height/2;
        unactivatedLabel.frame = unactivatedFrame;
        
        [_unActivatedView addSubview:unactivatedLabel];
        
    }
    return _unActivatedView;
}

-(void)photoViewClick:(UITapGestureRecognizer *)gestureRecognizer
{
    //add
    [KDEventAnalysis event: event_personal_profile_photo];
    //add
    [KDEventAnalysis eventCountly: event_personal_profile_photo];
    if(!KD_IS_BLANK_STR(self.person.photoUrl)){
        NSString *bigPhotoUrl = [NSString stringWithFormat:@"%@&spec=640",self.person.photoUrl];
        MJPhoto *mjPhoto = [[MJPhoto alloc] init];
        mjPhoto.originUrl =[NSURL URLWithString:bigPhotoUrl];
//        mjPhoto.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&spec=50",self.person.photoUrl]];
        mjPhoto.url = mjPhoto.originUrl;
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.bHideMenuBar = YES;
        browser.photos = @[mjPhoto];
        [browser show];
        [browser hideToolBar];
    }
}

//- (void)btnAction:(UIButton *)btn
//{
//    if(_delegate) {
//        if(btn == self.friendsButton) {
//            if([_delegate respondsToSelector:@selector(personDetailHeaderViewFriendsButtonPressed:)]) {
//                [_delegate personDetailHeaderViewFriendsButtonPressed:self];
//            }
//        }else if(btn == self.fansButton) {
//            if([_delegate respondsToSelector:@selector(personDetailHeaderViewFansButtonPressed:)]) {
//                [_delegate personDetailHeaderViewFansButtonPressed:self];
//            }
//        }else if(btn == self.statusButton) {
//            if([_delegate respondsToSelector:@selector(personDetailHeaderViewStatusButtonPressed:)]) {
//                [_delegate personDetailHeaderViewStatusButtonPressed:self];
//            }
//        }
//    }
//}

- (UIImage *)stretchImageWithImageName:(NSString *)imageName
{
    UIImage *img = [UIImage imageNamed:imageName];
    
    return [img stretchableImageWithLeftCapWidth:img.size.width * 0.5f topCapHeight:img.size.height * 0.5f];
}


//- (void)updateInfo
//{
//    [self.friendsButton setTitle:[NSString stringWithFormat:ASLocalizedString(@"XTPersonDetailHeaderView_Attention"), (long)_followCount] forState:UIControlStateNormal];
//    [self.fansButton setTitle:[NSString stringWithFormat:ASLocalizedString(@"XTPersonDetailHeaderView_Fun"), (long)_fansCount] forState:UIControlStateNormal];
//    [self.statusButton setTitle:[NSString stringWithFormat:ASLocalizedString(@"XTPersonDetailHeaderView_WB"), (long)_statusCount] forState:UIControlStateNormal];
//    
//    [self.friendsButton sizeToFit];
//    [self.fansButton sizeToFit];
//    [self.statusButton sizeToFit];
//    
//    [self setNeedsLayout];
//}


//- (void)setFollowCount:(NSInteger)followCount
//{
//    _followCount = followCount;
//    
//    [self updateInfo];
//}
//
//- (void)setFansCount:(NSInteger)fansCount
//{
//    _fansCount = fansCount;
//    
//    [self updateInfo];
//}
//
//- (void)setStatusCount:(NSInteger)statusCount
//{
//    _statusCount = statusCount;
//    
//    [self updateInfo];
//}

- (void)setPerson:(PersonDataModel *)person
{
    if (person == nil) {
        return;
    }
    if (_person != person) {
        _person = person;
    }
    if ([person accountAvailable] && [person xtAvailable]) {
        self.unActivatedView.hidden = YES;
        
    }else
    {
        self.unActivatedView.hidden = NO;
    }
//    self.headerImageView.person = person;
    NSString *url = person.photoUrl;

    if (person.photoUrl.length > 0) {
               if ([url rangeOfString:@"?"].location != NSNotFound) {
            url = [url stringByAppendingFormat:@"&spec=180"];
        }
        else {
            url = [url stringByAppendingFormat:@"?spec=180"];
        }
    }

    [self.photoView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"user_default_portrait"]  scale:SDWebImageScaleNone];
//     [self.photoView setImageWithURL:[NSURL URLWithString:person.photoUrl] placeholderImage:[UIImage imageNamed:@"user_default_portrait"]];
    self.nameLabel.text = person.personName;
    self.jobTitleLabel.text = person.jobTitle;
//    [self.favoritedButton setTitle:[person hasFavor] ? ASLocalizedString(@"XTPersonDetailHeaderView_Collect"): ASLocalizedString(@"XTPersonDetailHeaderView_Collected")forState:UIControlStateNormal];
//    [self.attentionButton setTitle:self.isFollowing ? ASLocalizedString(@"XTPersonDetailHeaderView_Attented"): ASLocalizedString(@"XTPersonDetailHeaderView_Attent")forState:UIControlStateNormal];
//    self.followButton.enabled = _person.wbUserId.length > 0;
////    self.sendMessageButton.hidden = [self isCurrentUser:person] || ![person isInCompany];
//    self.favoritedButton.hidden =([self isCurrentUser:person] || ![person isInCompany] || ![person isEmployee] || [BOSConfig sharedConfig].user.partnerType == 1);
//    self.attentionButton.hidden = ([self isCurrentUser:person] || ![person isInCompany] || ![person isEmployee] || [BOSConfig sharedConfig].user.partnerType == 1);
//    if(!isPublic) {
//        [self setFavoritedButtonImageWitFavor:[person hasFavor]];
//    }
    BOOL bShouldHidden = [self isCurrentUser:person] || ![person isInCompany];
    self.buttonFlag.hidden = bShouldHidden;
//    self.imageViewFlagDown.hidden = bShouldHidden;
//    self.imageViewFlagNormal.hidden = bShouldHidden;
//    if(person && (![person isEmployee] || [BOSConfig sharedConfig].user.partnerType == 1))
//    {
//        if(self.fansButton.superview && self.fansButton.superview.superview)
//            [self.fansButton.superview removeFromSuperview];
//    }
    
    
    [self setNeedsLayout];
}

- (BOOL)isCurrentUser:(PersonDataModel *)person
{
    return [[BOSConfig sharedConfig].user.userId isEqualToString:person.personId];
}

//- (void)setFavoritedButtonImageWitFavor:(BOOL)isFavor
//{
//    if(isFavor) {
//        [self.favoritedButton setImage:[UIImage imageNamed:@"user_btn_collect_down.png"] forState:UIControlStateNormal];
//    }else {
//        [self.favoritedButton setImage:[UIImage imageNamed:@"user_btn_collect_normal.png"] forState:UIControlStateNormal];
//    }
//    
//    if (isFavor)
//    {
//        self.bCollection = YES;
//        self.imageViewFlagDown.alpha = 1;
//        self.imageViewFlagNormal.alpha = 0;
//        
//    }
//    else
//    {
//        self.bCollection = NO;
//        self.imageViewFlagDown.alpha = 0;
//        self.imageViewFlagNormal.alpha = 1;
//    }
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    if(isPublic) {
//        //[self.nameLabel sizeToFit];
//    }else {
////        self.favoritedButton.frame = CGRectMake(ScreenFullWidth/4 - functionButtonWidth, CGRectGetMinY(self.nameBgView.frame), functionButtonWidth, functionButtonWidth);
////        self.attentionButton.frame = CGRectMake(ScreenFullWidth* 3/4, CGRectGetMinY(self.nameBgView.frame), functionButtonWidth, functionButtonWidth);
//        
//        //CGFloat offsetX = (ScreenFullWidth - buttonWidth *3.0f)/2.0f;
//        self.friendsButton.frame = CGRectMake(0, 2, ScreenFullWidth/3, 35);
//        //self.friendsButton.center = CGPointMake(ScreenFullWidth/4, self.friendsButton.center.y);
//        self.fansButton.frame = CGRectMake(CGRectGetMaxX(self.friendsButton.frame), 2, ScreenFullWidth/3, 35);
//        //self.fansButton.center = CGPointMake(ScreenFullWidth*2/4, self.friendsButton.center.y);
//        self.statusButton.frame = CGRectMake(CGRectGetMaxX(self.fansButton.frame), 2, ScreenFullWidth/3, 35);
//        //self.statusButton.center = CGPointMake(ScreenFullWidth*3/4, self.friendsButton.center.y);
//        
//        self.lineView1.center = CGPointMake(ScreenFullWidth/3,self.friendsButton.center.y);
//        self.lineView2.center = CGPointMake(ScreenFullWidth*2/3,self.friendsButton.center.y);
//    }
    
    if([self.person isEmployee] || !self.person)
    {
        self.partnerImageView.frame = CGRectZero;
    }
    else
    {
        CGRect frame = self.partnerImageView.frame;
        frame.size.width = CGRectGetHeight(self.nameBgView.frame);
        frame.size.height = CGRectGetHeight(self.nameBgView.frame);
        self.partnerImageView.frame = frame;
    }
    CGRect frame = self.nameLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.partnerImageView.frame)+5;
    self.nameLabel.frame = frame;
    [self.nameLabel sizeToFit];
    
    frame = self.nameBgView.frame;
    frame.size.width = CGRectGetMaxX(self.nameLabel.frame);
    self.nameBgView.frame = frame;
    self.nameBgView.center = CGPointMake(self.photoView.center.x, self.nameBgView.center.y);
    
    //性别
    frame = self.genderImageView.frame;
    frame.origin.x = CGRectGetMaxX(self.nameLabel.frame)+3;
    self.genderImageView.frame = frame;
    if(self.person.gender == 0)
    {
        self.genderImageView.hidden = YES;
    }
    else
    {
        self.genderImageView.hidden = NO;
        if(self.person.gender == 1)
            self.genderImageView.image = [UIImage imageNamed:@"profile_tip_male"];
        else
            self.genderImageView.image = [UIImage imageNamed:@"profile_tip_female"];
    }
}

//- (void)favoritedButtonAction:(UIButton *)btn
//{
//    //add
//    [KDEventAnalysis event:event_personal_favorite];
//    [KDEventAnalysis eventCountly:event_personal_favorite];
//    // 未激活人员不可收藏
//    if ([self.person accountAvailable] && ![self.person xtAvailable] && ![self.person hasFavor]) {
//        return;
//    }
//    if(_delegate && [_delegate respondsToSelector:@selector(personDetailHeaderViewFavoritedButtonPressed:)]) {
//        [_delegate personDetailHeaderViewFavoritedButtonPressed:self];
//    }
//}

//- (void)attentionButtonAction:(UIButton *)btn
//{
//    //add
//    [KDEventAnalysis event: event_personal_tofollow];
//    //add
//    [KDEventAnalysis eventCountly: event_personal_tofollow];
//    // 未激活人员不可关注
//    if ([self.person accountAvailable] && ![self.person xtAvailable] && !self.isFollowing) {
//        return;
//    }
//    if(_delegate && [_delegate respondsToSelector:@selector(personDetailHeaderViewAttentionButtonPressed:)]) {
//        [_delegate personDetailHeaderViewAttentionButtonPressed:self];
//    }
//}

//- (void)followButtonAction:(UIButton *)btn
//{
//    if(_delegate && [_delegate respondsToSelector:@selector(personDetailHeaderViewFollowButtonPressed:)]) {
//        [self.delegate personDetailHeaderViewFollowButtonPressed:self];
//    }
//}

- (void)sendCarteButtonAction:(UIButton *)btn
{
    if(_delegate && [_delegate respondsToSelector:@selector(personDetailHeaderViewSendCarteButtonPressed:)]) {
        [_delegate personDetailHeaderViewSendCarteButtonPressed:self];
    }
}

- (void)sendMesssageButtonAction:(UIButton *)btn
{
    if(_delegate && [_delegate respondsToSelector:@selector(personDetailHeaderViewSendMessageButtonPressed:)]) {
        [_delegate personDetailHeaderViewSendMessageButtonPressed:self];
    }
}

//- (void)setFollowing:(BOOL)isFollowing
//{
//    _isFollowing = isFollowing;
//    if(_isFollowing) {
//        [self.attentionButton setTitle:ASLocalizedString(@"XTPersonDetailHeaderView_Attented")forState:UIControlStateNormal];
//    }else {
//        [self.attentionButton setTitle:ASLocalizedString(@"XTPersonDetailHeaderView_Attent")forState:UIControlStateNormal];
//    }
//}

//- (void)setFollowCount:(NSInteger)followCount FansCount:(NSInteger)fansCount StatusesCount:(NSInteger)sc
//{
//    _followCount = followCount;
//    _fansCount = fansCount;
//    _statusCount = sc;
//    
//    [self updateInfo];
//}

//- (void)setShowFollowActivityView:(BOOL)isShown
//{
//    /*
//    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:0xff];
//    if(isShown) {
//        if(!indicator) {
//            indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//            indicator.tag = 0xff;
//            [self.followButton addSubview:indicator];
//            indicator.center = CGPointMake(CGRectGetWidth(self.followButton.bounds) * 0.5f, CGRectGetHeight(self.followButton.bounds) * 0.5f);
//        }
//        
//        [indicator startAnimating];
//    }else {
//        if(indicator) {
//            [indicator stopAnimating];
//            [indicator removeFromSuperview];
//        }
//    }
//     */
//}

//- (void)departmentButtonPressed:(UIButton *)btn
//{
//    if (self.person.orgId.length == 0) {
//        return;
//    }
//    [self.delegate personDetailHeaderViewDepartmentButtonPressed:self];
//}



//`````````````````````````darren 2014.10.13添加代码```````````````````````````````````

- (UIImageView *)imageViewFlagDown
{
    if (!_imageViewFlagDown)
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(268,0,38,78)];
        imageView.image = [UIImage imageNamed:ImageNameFlagDown];
        imageView.alpha = 0;
        _imageViewFlagDown = imageView;
    }
    return _imageViewFlagDown;
}

- (UIImageView *)imageViewFlagNormal
{
    if (!_imageViewFlagNormal)
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(268,0,38,78)];
        imageView.image = [UIImage imageNamed:ImageNameFlagNormal];
        imageView.alpha = 1;
        _imageViewFlagNormal = imageView;
    }
    return _imageViewFlagNormal;
}

- (UIButton *)buttonFlag
{
    if (!_buttonFlag)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(240,0,80,103);
        [button addTarget:self action:@selector(buttonFlagPressed) forControlEvents:UIControlEventTouchDown];
        button.backgroundColor = [UIColor clearColor];
        _buttonFlag = button;
    }
    return _buttonFlag;
}

//- (void)buttonFlagPressed
//{
//    if (!self.bCollection)
//    {
//        self.bCollection = YES;
//        self.imageViewFlagDown.alpha = 1;
//        self.imageViewFlagNormal.alpha = 0;
//        
//    }
//    else
//    {
//        self.bCollection = NO;
//        self.imageViewFlagDown.alpha = 0;
//        self.imageViewFlagNormal.alpha = 1;
//    }
//    
//    [self performSelector:@selector(favoritedButtonAction:) withObject:nil];
//
//}

- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset {
    CGRect frame = self.scrollView.frame;
    
    if (offset.y > 0) {
        frame.origin.y = MAX(offset.y * 0.5, 0);
        self.scrollView.frame = frame;
        self.clipsToBounds = YES;
    }
    else {
        CGFloat delta = 0.0f;
        CGRect rect = self.bounds;
        delta = fabs(MIN(0.0f, offset.y));
        rect.origin.y -= delta;
        rect.size.height += delta;
        self.scrollView.frame = rect;
        self.clipsToBounds = NO;
    }
}

//- (void)drawRect:(CGRect)rect {
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    CGPoint center = self.photoView.center;
//    CGFloat radius = self.photoView.frame.size.width/2 + 1;
//    //头像加一个圆环
//    [path addArcWithCenter:center radius:radius startAngle:M_PI_2*3 endAngle:M_PI_2*3-2*M_PI clockwise:NO];
//    
//    [[UIColor colorWithHexRGB:@"0xffffff"] setStroke];
//    path.lineWidth = 2;
//    
//    [path stroke];
//    
//}

@end
