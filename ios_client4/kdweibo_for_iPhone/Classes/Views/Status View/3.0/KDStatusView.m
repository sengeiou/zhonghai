//
//  KDStatusView.m
//  kdweibo
//
//  Created by Tan yingqi on 10/26/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDStatusView.h"
#import "KDUserAvatarView.h"
#import <QuartzCore/QuartzCore.h>
#import "KDLikeTask.h"
#import "KDUploadTaskHelper.h"
#import "KDDatabaseHelper.h"
#import "BOSSetting.h"

#pragma  mark - KDStatusView
@implementation KDStatusView
- (id)initWithFrame:(CGRect)frame  {
    self =[super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xfafafa);
        CALayer * layer = [self layer];
        layer.borderColor = UIColorFromRGB(0xcbcbcb).CGColor;
        layer.borderWidth = 0.5;
    }
    return self;
}

@end

#pragma  mark - KDSubStatusView
@implementation KDSubStatusView: KDLayouterView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage stretchableImageWithImageName:@"inbox_comment_bg" resizableImageWithCapInsets:UIEdgeInsetsMake(10, 30, 10, 10)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = frame;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
        //        [imageView release];
    }
    return self;
}
@end


#pragma  mark - KDStatusCoreTextView

@implementation KDStatusCoreTextView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateContent {
    textView_ = [[KDStatusExpressionLabel alloc] initWithFrame:CGRectZero andType:
                 KDExpressionLabelType_Expression|KDExpressionLabelType_URL|KDExpressionLabelType_USERNAME|KDExpressionLabelType_TOPIC urlRespondFucIfNeed:NULL];
    textView_.backgroundColor = [UIColor clearColor];
    textView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:textView_];
    textView_.textColor = MESSAGE_TOPIC_COLOR;
    textView_.font = [UIFont systemFontOfSize:[(KDCoreTextLayouter*)layouter_ fontSize]];
    [super updateContent];
}

@end

#pragma  mark - KDSubStatusCoreTextView
@implementation KDSubStatusCoreTextView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ///
        
    }
    return self;
}


- (void)updateContent {
    textView_ = [[KDStatusExpressionLabel alloc] initWithFrame:CGRectZero andType:[(KDCoreTextLayouter*)layouter_ type] urlRespondFucIfNeed:NULL];
    textView_.backgroundColor = [UIColor clearColor];
    textView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:textView_];
    
    textView_.textColor = MESSAGE_NAME_COLOR;
    textView_.font = [UIFont systemFontOfSize:[(KDCoreTextLayouter*)layouter_ fontSize]];
    
    [super updateContent];
}

@end

#pragma  mark - KDCommentStatusCoreTextView
@implementation KDCommentStatusCoreTextView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
    }
    return self;
}

- (void)updateContent {
    textView_ = [[KDExpressionLabel alloc] initWithFrame:CGRectZero andType:[(KDCoreTextLayouter*)layouter_ type] urlRespondFucIfNeed:NULL];
    textView_.backgroundColor = [UIColor clearColor];
    textView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    textView_.textColor = MESSAGE_NAME_COLOR;
    textView_.font = [UIFont systemFontOfSize:[(KDCoreTextLayouter*)layouter_ fontSize]];
    [self addSubview:textView_];
    [super updateContent];
}
@end


#pragma  mark - KDLikedStatusCoreTextView
@implementation KDLikedStatusCoreTextView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateContent {
    likedLabel_ = [[UILabel alloc] init];
    likedLabel_.backgroundColor = [UIColor clearColor];
    likedLabel_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:likedLabel_];
    likedLabel_.textColor = MESSAGE_TOPIC_COLOR;
    likedLabel_.numberOfLines = 0;
    likedLabel_.font = [UIFont systemFontOfSize:[(KDCoreTextLayouter*)layouter_ fontSize]];
    [super updateContent];
}

@end


#pragma  mark - KDMicroCommentStatusCoreTextView
@implementation KDMicroCommentStatusCoreTextView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateContent {
    microCommentLabel_ = [[UILabel alloc] init];
    microCommentLabel_.backgroundColor = [UIColor clearColor];
    microCommentLabel_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:microCommentLabel_];
    microCommentLabel_.textColor = MESSAGE_TOPIC_COLOR;
    microCommentLabel_.numberOfLines = 0;
    microCommentLabel_.font = [UIFont systemFontOfSize:[(KDCoreTextLayouter*)layouter_ fontSize]];
    [super updateContent];
}

@end


#pragma  mark - KDMoreStatusCoreTextView
@implementation KDMoreStatusCoreTextView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateContent {
    moreLabel_ = [[UILabel alloc] init];
    moreLabel_.backgroundColor = [UIColor clearColor];
    moreLabel_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:moreLabel_];
    moreLabel_.textColor = MESSAGE_TOPIC_COLOR;
    moreLabel_.numberOfLines = 0;
    moreLabel_.font = [UIFont systemFontOfSize:[(KDCoreTextLayouter*)layouter_ fontSize]];
    [super updateContent];
}

@end

#pragma  mark - KDEmptyStatusCoreTextView
@implementation KDEmptyStatusCoreTextView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateContent {
    [super updateContent];
}

@end


#pragma  mark - KDLayouterHeaderView
@interface KDLayouterHeaderView ()
@property(nonatomic,retain)KDUserAvatarView *avatarView;
@property(nonatomic, retain)UIButton *nameBtn;
@property(nonatomic, retain)UILabel *descriptionLabel;
@property(nonatomic, retain)UIButton *moreBtn;
@property(nonatomic, retain)UIButton *resendBtn ; //出错后重新发送
@property(nonatomic, retain)UIButton *deleteBtn;  //出错删除
@end

@implementation KDLayouterHeaderView
@synthesize avatarView = avatarView_;
@synthesize nameBtn = nameBtn_;
@synthesize descriptionLabel = descriptionLable_;
@synthesize moreBtn = moreBtn_;
@synthesize resendBtn = resendBtn_;
@synthesize deleteBtn = deleteBtn_;

- (id)init {
    self =[super init];
    if (self) {
        // self.clipsToBounds = NO;
        avatarView_ = [KDUserAvatarView avatarView];// retain];
        [avatarView_ addTarget:self action:@selector(didTapOnAvatar:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:avatarView_];
        
        nameBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
        nameBtn_.backgroundColor = [UIColor clearColor];
        nameBtn_.titleLabel.font = [UIFont systemFontOfSize:16];
        
        [nameBtn_ setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [nameBtn_ addTarget:self action:@selector(didTapOnAvatar:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nameBtn_];
        
        moreBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
        UIImage *image  = [UIImage imageNamed:@"status_more_operation"];
        [moreBtn_ setImage:image forState:UIControlStateNormal];
        moreBtn_.bounds = CGRectMake(0, 0, image.size.width + 20,image.size.height + 20);
        [moreBtn_ addTarget:self action:@selector(moreBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [moreBtn_ setContentMode:UIViewContentModeCenter];
        moreBtn_.backgroundColor = [UIColor clearColor];
        [self addSubview:moreBtn_];
    }
    return self;
    
}

- (void)nameLabelTapped:(UIGestureRecognizer *)grzr {
    [self didTapOnAvatar:nil];
}
- (void)didTapOnAvatar:(id)sender {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:[(KDStatusHeaderLayouter *)self.layouter user] sender:self];
}

- (void)updateContent {
    //avatarView_
    KDStatusHeaderLayouter *layouter = (KDStatusHeaderLayouter *)self.layouter;
    avatarView_.avatarDataSource = layouter.user;
    if(!avatarView_.hasAvatar)
        [avatarView_ setLoadAvatar:YES];
    [nameBtn_ setTitle:layouter.user.screenName forState:UIControlStateNormal];
    KDStatus *status = self.layouter.data;
    if (status.sendingState  == KDStatusSendingStateFailed || (status.sendingState == KDStatusSendingStateProcessing && ![[KDUploadTaskHelper shareUploadTaskHelper] isTaskOnRunning:status.statusId])) {
        if (status.sendingState == KDStatusSendingStateProcessing) {
            status.sendingState = KDStatusSendingStateFailed;
            [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
                if ([status isGroup]) {
                    [statusDAO saveGroupStatus:(KDGroupStatus *)status database:fmdb];
                }else {
                    [statusDAO saveStatus:status database:fmdb];
                }
                return nil;
            } completionBlock:nil];
            
        }
        resendBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];//retain];
        resendBtn_.bounds = CGRectMake(0, 0, 60, 30);
        [resendBtn_ setTitle:ASLocalizedString(@"KDStatusView_resendBtn_title")forState:UIControlStateNormal];
        resendBtn_.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        resendBtn_.backgroundColor = [UIColor clearColor];
        [resendBtn_ setTitleColor:RGBCOLOR(98, 148, 252) forState:UIControlStateNormal];
        [resendBtn_ addTarget:self action:@selector(resendBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:resendBtn_];
        
        deleteBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];//retain];
        deleteBtn_.bounds = CGRectMake(0, 0, 50, 30);
        [deleteBtn_ setTitle:ASLocalizedString(@"KDCommentCell_delete")forState:UIControlStateNormal];
        deleteBtn_.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [deleteBtn_ setTitleColor:RGBCOLOR(98, 148, 252) forState:UIControlStateNormal];
        deleteBtn_.backgroundColor = [UIColor clearColor];
        [deleteBtn_ addTarget:self action:@selector(deleteBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn_];
        
        moreBtn_.hidden = YES;
        
    }else if(status.sendingState == KDStatusSendingStateProcessing) {
        resendBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];//retain];
        resendBtn_.bounds = CGRectMake(0, 0, 60, 30);
        [resendBtn_ setTitle:ASLocalizedString(@"KDStatusView_sending")forState:UIControlStateNormal];
        resendBtn_.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        resendBtn_.backgroundColor = [UIColor clearColor];
        [resendBtn_ setTitleColor:RGBCOLOR(98, 148, 252) forState:UIControlStateNormal];
        [resendBtn_ addTarget:self action:@selector(resendBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:resendBtn_];
        moreBtn_.hidden = YES;
    }
    else {
        descriptionLable_ = [[UILabel alloc] init];
        descriptionLable_.backgroundColor = [UIColor clearColor];
        descriptionLable_.font = [UIFont systemFontOfSize:12];
        NSString *time = layouter.time;
        time = KD_IS_BLANK_STR(time)?@"":time;
        NSString *from = layouter.from;
        from = KD_IS_BLANK_STR(from)?@"":from;
        descriptionLable_.text = [NSString stringWithFormat:ASLocalizedString(@"KDStatusDetailViewController_sourceLabel_text"),time,from];
        descriptionLable_.textColor = MESSAGE_DATE_COLOR;
        [self addSubview:descriptionLable_];
        moreBtn_.hidden = NO;
    }
    
    [super updateContent];
}

- (void)resendBtnTapped:(id)sender {
    
    KDStatus *status = layouter_.data;
    if (status.sendingState != KDStatusSendingStateFailed) {
        return;
    }
    
    [resendBtn_ setTitle:ASLocalizedString(@"KDStatusView_sending")forState:UIControlStateNormal];
    KDNormalStatusUploadTask *statusTask = [[KDNormalStatusUploadTask alloc] init];// autorelease];
    statusTask.entity = status;
    [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:statusTask entityId:status.statusId];
    
}

- (void)deleteBtnTapped:(id)sender {
    KDStatus *status = layouter_.data;
    if (status.sendingState == KDStatusSendingStateNone ||
        status.sendingState == KDStatusSendingStateProcessing ||
        status.sendingState == KDStatusSendingStateSuccess) {
        return;
    }
    [[KDDefaultViewControllerContext defaultViewControllerContext] deleteStatus:status];
}

- (void)moreBtnTapped:(id)sender {
    KDStatus *status = layouter_.data;
    //    NSMutableArray *actionSheetItems = [[@[ASLocalizedString(@"转为任务"),!status.favorited?ASLocalizedString(@"KDABActionTabBar_tips_1"):ASLocalizedString(@"KDABPersonDetailsViewController_tips_3"),[KDWeiboAppDelegate isLoginUserID:status.author.userId]?ASLocalizedString(@"KDCommentCell_delete"):@"",ASLocalizedString(@"举报")] mutableCopy] autorelease];
    NSMutableArray *actionSheetItems = nil;
    if([[BOSSetting sharedSetting] allowMsgInnerMobileShare])
        actionSheetItems =[@[ASLocalizedString(@"KDDefaultViewControllerContext_to_task"),!status.favorited?ASLocalizedString(@"KDABActionTabBar_tips_1"):ASLocalizedString(@"KDABPersonDetailsViewController_tips_3"),[KDWeiboAppDelegate isLoginUserID:status.author.userId]?ASLocalizedString(@"KDCommentCell_delete"):@""] mutableCopy];// autorelease];
    else
        actionSheetItems =[@[!status.favorited?ASLocalizedString(@"KDABActionTabBar_tips_1"):ASLocalizedString(@"KDABPersonDetailsViewController_tips_3"),[KDWeiboAppDelegate isLoginUserID:status.author.userId]?ASLocalizedString(@"KDCommentCell_delete"):@""] mutableCopy];// autorelease];
    
    if(![status isGroup]) {
        [actionSheetItems insertObject:ASLocalizedString(@"KDDefaultViewControllerContext_share_conversation")atIndex:1];
    }
    
    [[KDDefaultViewControllerContext defaultViewControllerContext] showActionSheetByStatus:status actionSheetItems:actionSheetItems];
}

- (void)layoutSubviews {
    
    [descriptionLable_ sizeToFit];
    [nameBtn_ sizeToFit];
    CGRect frame = self.bounds;
    frame.size.width = 34;
    frame.size.height = 34;
    frame.origin.x = 8;
    frame.origin.y = 8;
    avatarView_.frame = frame;
    
    frame = nameBtn_.frame;
    frame.size.width = fminf(frame.size.width, 180.0f);
    frame.size.height = 20;
    frame.origin.y = 7;
    frame.origin.x = CGRectGetMaxX(avatarView_.frame)+10;
    nameBtn_.frame = frame;
    
    if (resendBtn_) {
        frame = resendBtn_.frame;
        frame.origin.x = CGRectGetMaxX(avatarView_.frame)+ 6;
        frame.origin.y = CGRectGetHeight(self.bounds)- CGRectGetHeight(frame)+6;
        resendBtn_.frame = frame;
    }
    if (deleteBtn_) {
        frame = deleteBtn_.frame;
        frame.origin.x = CGRectGetMaxX(resendBtn_.frame) + 5;
        frame.origin.y = CGRectGetMinY(resendBtn_.frame);
        deleteBtn_.frame = frame;
    }
    
    if (descriptionLable_) {
        frame = descriptionLable_.frame;
        frame.origin.x = CGRectGetMaxX(avatarView_.frame)+ 10;
        frame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(frame)-1;
        descriptionLable_.frame = frame;
    }
    
    frame = moreBtn_.bounds;
    frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(frame);
    moreBtn_.frame = frame;
    
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(nameBtn_);
    //KD_RELEASE_SAFELY(descriptionLable_);
    //KD_RELEASE_SAFELY(moreBtn_);
    //KD_RELEASE_SAFELY(resendBtn_);
    //KD_RELEASE_SAFELY(deleteBtn_);
    //[super dealloc];
}
@end


#pragma  mark - KDFooterItemView
@implementation KDFooterItemView
@synthesize label = label_;
@synthesize iconImageView = iconImageView_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:iconImageView_];
        
        label_ = [[UILabel alloc] initWithFrame:CGRectZero];
        label_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [label_ setFont:[UIFont systemFontOfSize:13.0]];
        [label_ setTextColor:RGBCOLOR(170, 170, 170)];
        label_.backgroundColor = [UIColor clearColor];
        [self addSubview:label_];
        
        [self setBackgroundImage:[UIImage imageNamed:@"todo_menu_done_selected"] forState:UIControlStateHighlighted];
    }
    return self;
}

- (void)layoutSubviews {
    [label_ sizeToFit];
    [iconImageView_ sizeToFit];
    
    CGRect frame = label_.bounds;
    frame.origin.x = CGRectGetWidth(iconImageView_.frame) +7;
    frame.origin.y = (CGRectGetHeight(self.bounds)- CGRectGetHeight(frame)) *0.5;
    label_.frame = frame;
    
}

- (CGSize)sizeThatFits:(CGSize)size {
    [label_ sizeToFit];
    [iconImageView_ sizeToFit];
    return CGSizeMake(CGRectGetWidth(iconImageView_.bounds) + 10 +CGRectGetWidth(iconImageView_.bounds), CGRectGetHeight(iconImageView_.bounds));
}


+ (KDFooterItemView *)buttonWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    KDFooterItemView *btn = [[KDFooterItemView alloc] initWithFrame:CGRectZero];// autorelease];
    btn.iconImageView.image = image;
    return btn;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(label_);
    //KD_RELEASE_SAFELY(iconImageView_);
    //[super dealloc];
}

@end


#pragma  mark - KDLayouterFooterView
@interface  KDLayouterFooterView()
@property(nonatomic,retain)UIButton *forwardBtn;
@property(nonatomic,retain)UIButton *commentBtn;
@property(nonatomic,retain)UIButton *likeBtn;
@property(nonatomic,retain)UIImageView *separatorImageView;
@property(nonatomic,retain)NSMutableArray *btns;
@property(nonatomic,retain)KDStatus *status;
@end

@implementation KDLayouterFooterView
@synthesize commentBtn = commentBtn_;
@synthesize forwardBtn = forwardBtn_;
@synthesize likeBtn = likeBtn_;
@synthesize separatorImageView = separatorImageView_;
@synthesize btns = btns_;
@synthesize status = status_;

- (void)dealloc {
    //KD_RELEASE_SAFELY(forwardBtn_);
    //KD_RELEASE_SAFELY(commentBtn_);
    //KD_RELEASE_SAFELY(likeBtn_);
    //KD_RELEASE_SAFELY(btns_);
    //KD_RELEASE_SAFELY(separatorImageView_);
    self.status = nil;
    //[super dealloc];
}


- (UIButton *)buttonWithImageName:(NSString *)imageName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"todo_selected_bg"] forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [btn setTitleColor:RGBCOLOR(170, 170, 170) forState:UIControlStateNormal];
    return btn;
    
}

- (id)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        // forwardBtn_ = [[KDFooterItemView buttonWithImageName:@"status_forward_icon"] retain];
        //zgbin:客户要求屏蔽转发 2018.03.27
        //        forwardBtn_ = [self buttonWithImageName:@"status_forward_icon"];// retain];
        //
        //         [forwardBtn_ addTarget:self action:@selector(forwardBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        //
        //        [self addSubview:forwardBtn_];
        if (!btns_) {
            btns_ = [[NSMutableArray alloc] init];
        }
        //        [btns_ addObject:forwardBtn_];
        //end
        
        // commentBtn_ = [[KDFooterItemView buttonWithImageName:@"status_comment_icon"] retain];
        commentBtn_ = [self buttonWithImageName:@"status_comment_icon"];// retain];
        [commentBtn_ setImage:[UIImage imageNamed:@"comment_new"] forState:UIControlStateSelected];
        [commentBtn_ addTarget:self action:@selector(commentBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        //[rgzr release];
        
        [self addSubview:commentBtn_];
        [btns_ addObject:commentBtn_];
        
        // likeBtn_ = [[KDFooterItemView buttonWithImageName:@"status_like_icon"] retain];
        likeBtn_ = [self buttonWithImageName:@"status_like_icon"] ;//retain];
        [likeBtn_ addTarget:self action:@selector(likeBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [likeBtn_ setImage:[UIImage imageNamed:@"status_like_icon_selected"] forState:UIControlStateSelected];
        
        [self addSubview:likeBtn_];
        [btns_ addObject:likeBtn_];
        
        separatorImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_footer_top_separator_bg"]];
        [self addSubview:separatorImageView_];
        
    }
    return self;
}

- (void)forwardBtnTapped:(id)sender {
    if (self.status.sendingState == KDStatusSendingStateFailed ||self.status.sendingState == KDStatusSendingStateProcessing) {
        return;
    }
    [[KDDefaultViewControllerContext defaultViewControllerContext] showForwardViewController:self.status sender:self];
}

- (void)commentBtnTapped:(id)sender {
    if (self.status.sendingState == KDStatusSendingStateFailed ||self.status.sendingState == KDStatusSendingStateProcessing) {
        return;
    }
    if (self.status.commentsCount >0) {
        [[KDDefaultViewControllerContext defaultViewControllerContext] showDetailViewControllerOfStatus:self.status fromCommentOrForward:YES sender:self];
    }else {
        [[KDDefaultViewControllerContext defaultViewControllerContext] showCommentViewController:self.status commentedSatatus:nil delegate:nil sender:self showOriginalStatus:YES];
    }
}

- (void)likeBtnTapped:(id)sender {
    
    KDLikeTask *task = [[KDLikeTask alloc] init];// autorelease];
    task.status = self.status;
    [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:task entityId:self.status.statusId];
    //    [self updateContent];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"timeLineRefresh" object:self userInfo:nil];
}

- (void)updateContent {
    self.status = layouter_.data;
    if (self.status.sendingState == KDStatusSendingStateFailed ||
        self.status.sendingState == KDStatusSendingStateProcessing) {
        //        forwardBtn_.label.textColor = MESSAGE_DATE_COLOR;
        //        commentBtn_.label.textColor = MESSAGE_DATE_COLOR;
        //        likeBtn_.label.textColor = MESSAGE_DATE_COLOR;
        forwardBtn_.enabled = NO;
        commentBtn_.enabled = NO;
        likeBtn_.enabled = NO;
    }
    if ([status_ isKindOfClass:[KDGroupStatus class]] ||[status_ isGroup] || status_.isPrivate) {
        forwardBtn_.hidden = YES;
    }
    [super updateContent];
}

/**
 *  KVO 监听 评论数、转发数、赞。
 *
 *
 */
- (void)setStatus:(KDStatus *)status {
    if (status_ != status) {
        if (status_) {
            [status_ removeObserver:self forKeyPath:@"commentsCount"];
            [status_ removeObserver:self forKeyPath:@"forwardsCount"];
            [status_ removeObserver:self forKeyPath:@"likedCount"];
            [status_ removeObserver:self forKeyPath:@"liked"];
            if ([status_ respondsToSelector:@selector(unread)]) {
                [status_ removeObserver:self forKeyPath:@"unread"];
            }
        }
        //        [status_ release];
        status_ = status ;//retain];
        if (status_) {
            [status_ addObserver:self forKeyPath:@"commentsCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
            [status_ addObserver:self forKeyPath:@"forwardsCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
            [status_ addObserver:self forKeyPath:@"likedCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
            [status_ addObserver:self forKeyPath:@"liked" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
            if ([status_ respondsToSelector:@selector(unread)]) {
                [status_ addObserver:self forKeyPath:@"unread" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
            }
        }
        
    }
}

-(NSString *)adjustedCount:(NSInteger) count {
    return count >9999 ?@"9999+":[NSString stringWithFormat:@"%ld",(long)count];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"commentsCount"]) {
        NSString *title = status_.commentsCount >0?[self adjustedCount:status_.commentsCount]:ASLocalizedString(@"DraftTableViewCell_tips_4");
        
        [commentBtn_ setTitle:title forState:UIControlStateNormal];
    }else if([keyPath isEqualToString:@"forwardsCount"]) {
        
        NSString *title = status_.forwardsCount >0?[self adjustedCount:status_.forwardsCount]:ASLocalizedString(@"KDStatusDetailViewController_Forward");
        
        [forwardBtn_ setTitle:title forState:UIControlStateNormal];
    }else if ([keyPath isEqualToString:@"likedCount"]) {
        NSString *title = status_.likedCount >0?[self adjustedCount:status_.likedCount]:ASLocalizedString(@"KDStatusDetailViewController_Like");
        [likeBtn_ setTitle:title forState:UIControlStateNormal];
    }else if([keyPath isEqualToString:@"liked"]) {
        likeBtn_.selected = status_.liked;
    }else if ([keyPath isEqualToString:@"unread"]) {
        BOOL unread = NO;
        if ([status_ respondsToSelector:@selector(unread)] && [status_ isKindOfClass:[KDGroupStatus class]]) {
            unread = [(KDGroupStatus *)status_ unread];
        }
        // [commentBtn_ setTitleColor:unread?[UIColor redColor]:RGBCOLOR(170, 170, 170) forState:UIControlStateNormal];
        commentBtn_.selected = unread;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    CGRect frame = self.bounds;
    frame.size.height = 1;
    separatorImageView_.frame = frame;
    
    NSInteger count;
    NSMutableArray *visibleBtns = [NSMutableArray array];
    for (UIButton *btn in btns_) {
        if (!btn.hidden) {
            [visibleBtns addObject:btn];
        }
    }
    count = [visibleBtns count];
    if (count == 0) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(self.bounds)/count;
    for (NSInteger i = 0; i<count; i++) {
        UIButton *theBtn = [visibleBtns objectAtIndex:i];
        //[theBtn sizeToFit];
        theBtn.bounds = CGRectMake(0, 0, width, CGRectGetHeight(self.bounds));
        theBtn.center = CGPointMake(width*i+width*0.5, CGRectGetHeight(self.bounds)*0.5);
    }
}

@end


#pragma  mark - KDGroupFlagLayouterView
@implementation KDGroupFlagLayouterView
@synthesize statusFromGroupTipView = statusFromGroupTopView_;

- (id)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        statusFromGroupTopView_ = [[KDStatusFromGroupTipView alloc] initWithFrame:CGRectZero];
        statusFromGroupTopView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:statusFromGroupTopView_];
        
    }
    return self;
}

- (void)updateContent {
    if (layouter_) {
        //
        [statusFromGroupTopView_ setupViewWithGroupName:((KDGroupFlagLayouter *)layouter_).groupName];
    }
    [super updateContent];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(statusFromGroupTopView_);
    //[super dealloc];
}
@end


@interface KDVoteLayouterView ()
@property(nonatomic,retain)UIButton *voteButton;

@end
@implementation KDVoteLayouterView
@synthesize voteButton = voteButton_;

- (id)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        voteButton_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
        [voteButton_ setImage:[UIImage imageNamed:@"status_vote_btn"] forState:UIControlStateNormal];
        [voteButton_ setImage:[UIImage imageNamed:@"status_vote_btn_hl"] forState:UIControlStateHighlighted];
        [voteButton_ setTitleColor:MESSAGE_DATE_COLOR forState:UIControlStateNormal];
        [voteButton_ setTitleEdgeInsets:UIEdgeInsetsMake(32, 10, 0, 0)];
        voteButton_.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [voteButton_ setTitle:ASLocalizedString(@"参与投票")forState:UIControlStateNormal];
        voteButton_.frame = CGRectMake(0, 0, 120, voteButton_.imageView.image.size.height);
        [voteButton_ addTarget:self action:@selector(voteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:voteButton_];
        
    }
    return self;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(voteButton_);
    //[super dealloc];
}

- (void)voteButtonTapped:(id)sender {
    KDStatus *status = layouter_.data;
    NSString *voteId = status.extraMessage.referenceId;
    [[KDDefaultViewControllerContext defaultViewControllerContext] showVoteControllerWithVoteId:voteId sender:self];
}
@end

@implementation KDStatusDocumentLayouterView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.docListView.textColor = RGBCOLOR(62, 62, 62);
    }
    return self;
}
@end

@implementation KDSubStatusDocumentLayouterView
- (id)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {
        self.docListView.textColor = RGBCOLOR(109,109,109);
    }
    return self;
}
@end

@implementation KDCommentCellLayouterView
- (id)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
@end

#pragma  mark - KDCommentHeadLayouterView
@interface KDCommentHeadLayouterView()
@property(nonatomic,retain)UILabel *nameLabel;
@property(nonatomic,retain)UILabel *timeLabel;
@end

@implementation KDCommentHeadLayouterView
@synthesize nameLabel = nameLabel_;
@synthesize timeLabel = timeLabel_;

- (id)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {
        // self.docListView.textColor = RGBCOLOR(109,109,109);
        nameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel_.backgroundColor = [UIColor clearColor];
        nameLabel_.textColor = [UIColor blackColor];
        nameLabel_.font = [UIFont systemFontOfSize:16.0f];
        [self addSubview:nameLabel_];
        
        timeLabel_  = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel_.backgroundColor = [UIColor clearColor];
        timeLabel_.textColor = MESSAGE_DATE_COLOR;
        timeLabel_.font = [UIFont systemFontOfSize:11.0f];
        [self addSubview:timeLabel_];
        
    }
    return self;
}

- (void)updateContent {
    KDStatus *staus = layouter_.data;
    nameLabel_.text = staus.author.screenName;
    timeLabel_.text = staus.createdAtDateAsString;
    [super updateContent];
}

- (void)layoutSubviews {
    nameLabel_.frame = CGRectMake(0, 0, 164, CGRectGetHeight(self.bounds));
    [timeLabel_ sizeToFit];
    timeLabel_.center = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(timeLabel_.bounds)*0.5, CGRectGetMidY(timeLabel_.bounds));
    
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(nameLabel_);
    //KD_RELEASE_SAFELY(timeLabel_);
    //[super dealloc];
}
@end


#pragma  mark - KDExtendStatusThumbnailsView
@implementation KDExtendStatusThumbnailsView
@synthesize thumbnailView = thumbnailView_;

- (void)updateContent {
    if (layouter_) {
        thumbnailView_ = [KDThumbnailView thumbnailViewWithSize:[KDImageSize defaultThumbnailImageSize]];// retain];
        thumbnailView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:thumbnailView_];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnThumbnailView:)];
        [thumbnailView_ addGestureRecognizer:tapGesture];
        //        [tapGesture release];
        
        id<KDImageDataSource> imageDataSource = ((KDThumbnailsLayouter *)layouter_).imageSource;
        [thumbnailView_ setImageDataSourceWithNoLoading:imageDataSource];
        [super updateContent];
    }
}

- (void) didTapOnThumbnailView:(UIGestureRecognizer *)gestureRecognizer {
    
    KDCompositeImageSource *imageSource = ((KDThumbnailsLayouter *)layouter_).imageSource;
    NSArray *attachemtns = [imageSource propertyForKey:@"attachments"];
    if (attachemtns)
        [[KDDefaultViewControllerContext defaultViewControllerContext] showImagesOrVideos:((KDThumbnailsLayouter *)layouter_).imageSource startIndex:0 sender:self];
    else
        [[KDDefaultViewControllerContext defaultViewControllerContext] showImages:((KDThumbnailsLayouter *)layouter_).imageSource startIndex:0 srcImageViews:[NSArray arrayWithObject:thumbnailView_.thumbnailView]];
    
    //     [[KDDefaultViewControllerContext defaultViewControllerContext] showImagesOrVideos:((KDThumbnailsLayouter *)layouter_).imageSource startIndex:0 sender:self];
}


- (void)loadThumbailsImage {
    if(((KDThumbnailsLayouter *)layouter_).imageSource ){
        [thumbnailView_ setLoadThumbnail:YES];
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(thumbnailView_);
    //[super dealloc];
}

@end


#pragma  mark - KDExtendStatusLayouterView
@implementation KDExtendStatusLayouterView

- (id)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {
        UIImage * image = [UIImage stretchableImageWithImageName:@"extend_status_bg" resizableImageWithCapInsets:UIEdgeInsetsMake(10,
                                                                                                                                  30, 5, 10)];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:image];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        backgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:backgroundView];
        //        [backgroundView release];
        
    }
    return self;
}

@end


#pragma  mark - KDExtendStatusCoreTextLayouterView
@implementation KDExtendStatusCoreTextLayouterView

- (void)updateContent {
    textView_ = [[KDExpressionLabel alloc] initWithFrame:CGRectZero andType:[(KDCoreTextLayouter*)layouter_ type] urlRespondFucIfNeed:NULL];
    textView_.backgroundColor = [UIColor clearColor];
    textView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    textView_.textColor = MESSAGE_NAME_COLOR;
    textView_.font = [UIFont systemFontOfSize:[(KDCoreTextLayouter*)layouter_ fontSize]];
    [self addSubview:textView_];
    
    [super updateContent];
}

- (void)layoutSubviews {
    
    
}
@end



#pragma  mark - KDExtendStatusForwardedStatusCoreTextLayouterView
@interface  KDExtendStatusForwardedStatusCoreTextLayouterView()
@property(nonatomic,retain)UIImageView *separatorImageView;
@end

@implementation KDExtendStatusForwardedStatusCoreTextLayouterView
@synthesize separatorImageView = separatorImageView_;

- (id)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {
        // self.docListView.textColor = RGBCOLOR(109,109,109);
        separatorImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_footer_top_separator_bg"]];
        [self addSubview:separatorImageView_];
    }
    return self;
}

- (void)updateContent {
    textView_ = [[KDExpressionLabel alloc] initWithFrame:CGRectZero andType:[(KDCoreTextLayouter*)layouter_ type] urlRespondFucIfNeed:NULL];
    textView_.backgroundColor = [UIColor clearColor];
    textView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    textView_.textColor = MESSAGE_NAME_COLOR;
    textView_.font = [UIFont systemFontOfSize:[(KDCoreTextLayouter*)layouter_ fontSize]];
    [self addSubview:textView_];
    
    [super updateContent];
}

- (void)layoutSubviews {
    CGRect frame = self.bounds;
    frame.size.height = 1.0f;
    frame.origin.y = -2;
    separatorImageView_.frame = frame;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(separatorImageView_);
    //[super dealloc];
}
@end

