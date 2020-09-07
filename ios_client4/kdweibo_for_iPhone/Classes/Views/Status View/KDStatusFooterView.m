//
//  KDStatusFooterView.m
//  kdweibo
//
//  Created by laijiandong on 12-9-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusFooterView.h"

#import "KDGroupStatus.h"
#import <QuartzCore/QuartzCore.h>
#import "KDWeiboAppDelegate.h"
#import "KDMentionMeStatus.h"
#import "KDCommentMeStatus.h"
#import "KDLikeTask.h"
#import "KDUploadTaskHelper.h"

#import "FriendsTimelineController.h"
#import "GroupTimelineController.h"
#import "KDDefaultViewControllerContext.h"
#import "KDFavoriteTask.h"
///////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDStatusFooterAttributeView class
@interface KDStatusFooterAttributeView : UIView {
 @private
    UIImageView *typeImageView_;
    UILabel *textLabel_;
}

@property(nonatomic, retain) UIImageView *typeImageView;
@property(nonatomic, retain) UILabel *textLabel;
@property(nonatomic, assign) BOOL selected;



- (void)setTypeImage:(UIImage *)image;
- (void)setText:(NSString *)text;
- (CGSize)optimalDisplaySize;

- (void)addTarget:(id)target andAction:(SEL)selector;

@end

@implementation KDStatusFooterAttributeView

@synthesize typeImageView=typeImageView_;
@synthesize textLabel=textLabel_;
@synthesize selected = selected_;

- (void)setSelected:(BOOL)selected {
    selected_ = selected;
    if (selected) {
      textLabel_.textColor = [UIColor whiteColor];
      self.layer.contents = (id)(id)[UIImage imageNamed:@"footer_bg_gray"].CGImage;
    }else {
      textLabel_.textColor = UIColorFromRGB(0x5d6772);
      self.layer.contents = (id)(id)[UIImage imageNamed:@"footer_bg_light_gray"].CGImage;
    }
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupFooterAttributeView];
        self.layer.contents = (id)[UIImage imageNamed:@"footer_bg_light_gray"].CGImage;
    }
    return self;
}

- (void)setupFooterAttributeView {
    // type image view
    typeImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:typeImageView_];
    
    // text label
    textLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel_.backgroundColor = [UIColor clearColor];
    textLabel_.textColor = UIColorFromRGB(0x5d6772);
    textLabel_.font = [UIFont systemFontOfSize:12.0];
    textLabel_.textAlignment = NSTextAlignmentCenter;
    textLabel_.adjustsFontSizeToFitWidth = YES;
    [self addSubview:textLabel_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat textWidth = CGRectGetWidth(textLabel_.frame);
    textWidth = MAX(textWidth, 20);
    CGRect rect;
    rect.size = textLabel_.frame.size;
    rect.size.width = textWidth;
    rect.origin.x = width-rect.size.width -4;
    rect.origin.y = (self.bounds.size.height - rect.size.height)*0.5 ;
    textLabel_.frame = rect;
    
    
    rect = typeImageView_.bounds;
    if(textLabel_.text) {
        rect.origin = CGPointMake(width- textWidth - CGRectGetWidth(rect)-2, (self.bounds.size.height - rect.size.height) * 0.5);
    }else {
        rect.origin = CGPointMake((width - CGRectGetWidth(rect)) * 0.5f, (self.bounds.size.height - rect.size.height) * 0.5f);
    }
    typeImageView_.frame = rect;
    
}

- (void)setTypeImage:(UIImage *)image {
    typeImageView_.image = image;
    [typeImageView_ sizeToFit];
}

- (void)setText:(NSString *)text {
    textLabel_.text = text;
    [textLabel_ sizeToFit];
}

- (CGSize)optimalDisplaySize {
//    CGFloat width = typeImageView_.bounds.size.width + textLabel_.bounds.size.width + 3.0; // spacing is 3.0
//    CGFloat height = MAX(typeImageView_.bounds.size.height , textLabel_.bounds.size.height);
//   
//    return CGSizeMake(width, height);
    return CGSizeMake(52, 20);
}

- (void)addTarget:(id)target andAction:(SEL)selector {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
//    [tap release];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(typeImageView_);
    //KD_RELEASE_SAFELY(textLabel_);
    
    //[super dealloc];
}

@end



///////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDStatusFooterView class

@interface KDStatusFooterView () //<KDMaskViewDelegate>

//@property(nonatomic, retain) UILabel *sourceLabel;
//@property(nonatomic, retain) UILabel *timeLabel;
@property(nonatomic, retain) KDStatusFooterAttributeView *commentAttrView;
@property(nonatomic, retain) KDStatusFooterAttributeView *forwardAttrView;
@property(nonatomic, retain) KDStatusFooterAttributeView *likeAttrView;
//@property(nonatomic, retain) UIButton *moreBtn;
@property(nonatomic, retain) KDStatus *status;

@end


@implementation KDStatusFooterView

//@synthesize sourceLabel= sourceLabel_;
@synthesize commentAttrView=commentAttrView_;
@synthesize forwardAttrView=forwardAttrView_;
//@synthesize moreBtn = moreBtn_;
//@synthesize timeLabel = timeLabel_;

@synthesize showAccurateGroupName=showAccurateGroupName_;
@synthesize status = status_;
@synthesize likeAttrView = likeAttrView_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        isUsingNormalCommentsIcon_ = YES;
        [self setupFooterView];
    }
    
    return self;
}

- (void)setupFooterView {
    /*
    // source label
    sourceLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    sourceLabel_.backgroundColor = [UIColor clearColor];
    sourceLabel_.textColor = RGBCOLOR(132, 132, 132);
    sourceLabel_.font = [UIFont systemFontOfSize:12.0];
    sourceLabel_.lineBreakMode = NSLineBreakByTruncatingMiddle;

    [self addSubview:sourceLabel_];
    
    timeLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    timeLabel_.backgroundColor = [UIColor clearColor];
    timeLabel_.textColor = RGBCOLOR(132, 132, 132);
    timeLabel_.font = [UIFont systemFontOfSize:12.0];
    //timeLabel_.lineBreakMode = UILineBreakModeHeadTruncation;
    [self addSubview:timeLabel_];
     */
    
    // comment attribute view
    commentAttrView_ = [[KDStatusFooterAttributeView alloc] initWithFrame:CGRectZero];
    [commentAttrView_ setTypeImage:[UIImage imageNamed:@"icon_comment_v3.png"]];
    [commentAttrView_ addTarget:self andAction:@selector(commentAttrViewTapped:)];
    [self addSubview:commentAttrView_];
    
    // forward attribute view
    forwardAttrView_ = [[KDStatusFooterAttributeView alloc] initWithFrame:CGRectZero];
    [forwardAttrView_ setTypeImage:[UIImage imageNamed:@"icon_forward_v3.png"]];
    [forwardAttrView_ addTarget:self andAction:@selector(forwardAttrViewTapped:)];
    [self addSubview:forwardAttrView_];
    
    sendingProgress_ = [[KDProgressIndicatorView alloc] initWithFrame:CGRectZero];
    sendingProgress_.hidden = YES;
    sendingProgress_.backgroundColor = [UIColor clearColor];
    [self addSubview:sendingProgress_];
    
    likeAttrView_ = [[KDStatusFooterAttributeView alloc] initWithFrame:CGRectZero];
    [likeAttrView_ setTypeImage:[UIImage imageNamed:@"icon_like_normal.png"]];
    [self addSubview:likeAttrView_];
    [likeAttrView_ addTarget:self andAction:@selector(likeAttrViewTapped:)];
    
    /*
    moreBtn_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [moreBtn_ setImage:[UIImage imageNamed:@"timeline_more_btn_v3.png"] forState:UIControlStateNormal];
    [moreBtn_ addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:moreBtn_];
     */
}

- (void)likeAttrViewTapped:(UIGestureRecognizer *)rgzr {
//    KDStatusLikeActionHelper *helper = [KDStatusLikeActionHelper shareLikeActionHelper];
//    [helper handleLike:self.status];
    KDLikeTask *task = [[KDLikeTask alloc] init];// autorelease];
    task.status = self.status;
    [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:task entityId:self.status.statusId];
}

- (void)forwardAttrViewTapped:(UIGestureRecognizer *)rgzr {
    if(self.status.forwardsCount == 0)
        [[KDDefaultViewControllerContext defaultViewControllerContext] showForwardViewController:self.status sender:self];
    else
        [[KDDefaultViewControllerContext defaultViewControllerContext] showDetailViewControllerOfStatus:self.status fromCommentOrForward:NO sender:self];
}

- (void)commentAttrViewTapped:(UIGestureRecognizer *)rgzr {
    if(self.status.commentsCount == 0)
        [[KDDefaultViewControllerContext defaultViewControllerContext] showCommentViewController:self.status sender:self];
    else
        [[KDDefaultViewControllerContext defaultViewControllerContext] showDetailViewControllerOfStatus:self.status fromCommentOrForward:YES sender:self];
}

/*
- (void)moreAction:(UIButton *)sender {
    BOOL isSelected = sender.selected;
    
    if(isSelected) {
        //已经选中，现在需要取消选中
        [moreBtn_ setImage:[UIImage imageNamed:@"timeline_more_btn_v3.png"] forState:UIControlStateNormal];
        [self hiddeMenuView];
        [self hiddeMaskView];
    }else {
        //未选中，需要选中
        [moreBtn_ setImage:[UIImage imageNamed:@"timeline_more_btn_selected_v3.png"] forState:UIControlStateNormal];
        [self showMaskView];
        [self showMenuView];
    }
    
    sender.selected = !isSelected;
}

- (void)createMission:(UIButton *)sender {
    [self moreAction:moreBtn_];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showCreateTaskViewControllerOfStatus:self.status sender:self];
}

- (void)favor:(UIButton *)sender {
    KDFavoriteTask *ft = [[KDFavoriteTask alloc] init];
    ft.status = status_;
    
    [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:ft entityId:status_.statusId];
    [ft release];
    
    [self moreAction:moreBtn_];
}
*/
- (UIViewController *)viewControllerNearView:(UIView *)v {
    UIView *view = v;
    while (view) {
        if([view.nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)view.nextResponder;
        }
        view = view.superview;
    }
    
    return nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
//    CGFloat pw = width * 0.3;
//    sourceLabel_.frame = CGRectMake(0.0, 0.0, pw, 20);
//    
//    CGRect frame = sourceLabel_.frame;
//    frame.origin.x = CGRectGetMaxX(frame)+2;
//    frame.size.width = width *0.45;
//    timeLabel_.frame = frame;


    CGFloat offsetX = 0.0;
    CGRect rect = CGRectZero;
    CGSize size = [likeAttrView_ optimalDisplaySize];
    
    if (!sendingProgress_.hidden) {
        CGRect temp = rect;
        temp.origin = CGPointMake(30.0f, height-size.height - 50.f);
        temp.size = CGSizeMake(100.0f, 26.0f);
        sendingProgress_.frame = temp;
        size = CGSizeZero;
    }
    
    if (!forwardAttrView_.hidden) {
        rect.origin = CGPointMake(0.0f, height - size.height - 10);
        rect.size = size;
        forwardAttrView_.frame = rect;
        offsetX += rect.size.width;
    }
    
    if (!commentAttrView_.hidden) {
        offsetX += 8.0f;
        rect.origin = CGPointMake(offsetX, height-size.height-10);
        rect.size = size;
        commentAttrView_.frame = rect;
        offsetX += rect.size.width;
    }
    
    if (!likeAttrView_.hidden) {
        offsetX += 8.0f;
        rect.size = size;
        rect.origin = CGPointMake(CGRectGetWidth(self.bounds) - size.width - 5.0f, height-size.height-10);
        
        likeAttrView_.frame = rect;
    }
    
    /*
    if(!moreBtn_.hidden) {
        moreBtn_.frame = CGRectMake(width - size.width - 10.0f, CGRectGetMinY(likeAttrView_.frame) + (size.height - size.height) * 0.5f, size.width, size.height);
    }
     */
}

- (NSString *)formatAttributeCount:(NSUInteger)count {
    if(count == 0) return nil;
    return (count > 10000) ? @"10000+" : [NSString stringWithFormat:@"%lu", (unsigned long)count];
}

- (void)setStatus:(KDStatus *)status {
    if (status_ != status) {
        [status_ removeObserver:self forKeyPath:@"commentsCount"];
        [status_ removeObserver:self forKeyPath:@"forwardsCount"];
        [status_ removeObserver:self forKeyPath:@"likedCount"];
        [status_ removeObserver:self forKeyPath:@"sendingProgress"];
//        [status_ release];
        status_ = status;// retain];
        [status_ addObserver:self forKeyPath:@"commentsCount" options:NSKeyValueObservingOptionNew context:NULL];
        [status_ addObserver:self forKeyPath:@"forwardsCount" options:NSKeyValueObservingOptionNew context:NULL];
        [status_ addObserver:self forKeyPath:@"likedCount" options:NSKeyValueObservingOptionNew context:NULL];
        [status_ addObserver:self forKeyPath:@"sendingProgress" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"commentsCount"]) {
        [self updateCommentCount];
          [self setNeedsLayout];
    }else if([keyPath isEqualToString:@"forwardsCount"]) {
        [self updateforwardCount];
          [self setNeedsLayout];
    }else if ([keyPath isEqualToString:@"likedCount"]) {
        [self updateLikeArrView];
        [self setNeedsLayout];
    }else if ([keyPath isEqualToString:@"sendingProgress"]) {
        [self updateProgress];
        [self setNeedsLayout];
    }
}

- (void)updateLikeArrView {
    BOOL  visible = [self shouldShowLikeAttrView];
    likeAttrView_.hidden = !visible;
    if (self.status.likedCount >0) {
        [likeAttrView_ setText:[self formatAttributeCount:self.status.likedCount]];
    }else {
        [likeAttrView_ setText:@"+1"];
    }
    BOOL liked = self.status.liked;
    if (liked) {
        [likeAttrView_ setTypeImage:[UIImage imageNamed:@"icon_like_selected"]];
    }else {
        [likeAttrView_ setTypeImage:[UIImage imageNamed:@"icon_like_normal"]];
    }
    likeAttrView_.selected = liked;
    
}

- (void)updateCommentCount {
    BOOL visible = status_.commentsCount > 0;
    if (visible) {
        if ([self isGroupStatus:status_]) {
            BOOL previous = isUsingNormalCommentsIcon_;
            //TODO:the new version kdstatus how to judge
            isUsingNormalCommentsIcon_ = [(KDGroupStatus *)status_ unread] ? NO : YES;
            
            [self updateCommentsAttrView:previous now:isUsingNormalCommentsIcon_];
        }
        
        NSString *commentsText = [self formatAttributeCount:status_.commentsCount];
        [commentAttrView_ setText:commentsText];
    }
    
    commentAttrView_.hidden = !visible;
}

- (void)updateforwardCount {
     BOOL visible = status_.forwardsCount > 0;
    if (visible) {
        NSString *forwardsText = [self formatAttributeCount:status_.forwardsCount];
        [forwardAttrView_ setText:forwardsText];
    }
    
    forwardAttrView_.hidden = !visible;
}
- (void)updateWithStatus:(KDStatus *)status {
    // source
    self.status = status;
//    NSString *source = (showAccurateGroupName_ && status.groupName != nil) ? status.groupName : status.source;
//    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"FROM_%@", @""), source ? source : @""];
//    sourceLabel_.text = text;
//    timeLabel_.text =  status.createdAtDateAsString ? status.createdAtDateAsString : @"";
    
    // comments count
    [self updateCommentCount];
    // forward count
    [self updateforwardCount];
    [self updateLikeArrView];
    [self setNeedsLayout];
}

- (BOOL)shouldShowLikeAttrView {
    BOOL should = NO;
    should = [[self.status propertyForKey:@"showLike"] boolValue];
    return should;
}

/////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark for group status

- (BOOL)isGroupStatus:(KDStatus *)status {
    return [status isKindOfClass:[KDGroupStatus class]];
}

- (void)updateCommentsAttrView:(BOOL)prevUsingNormal now:(BOOL)nowUsingNormal {
    if (prevUsingNormal == nowUsingNormal) return;
    
    UIColor *color = nowUsingNormal ? UIColorFromRGB(0x5d6772) : UIColorFromRGB(0xfd7903);
    UIImage *image = [UIImage imageNamed:(nowUsingNormal ? @"icon_comment_v3.png" : @"icon_comment_new.png")];
    
    commentAttrView_.textLabel.textColor = color;
    [commentAttrView_ setTypeImage:image];
}

+ (CGFloat)optimalStatusFooterHeight {
    return 44.0;
}

- (void)updateProgress
{
    assert([NSThread isMainThread]);
    float progress = status_.sendingProgress;
    if (progress < 1.0f) {
        if (sendingProgress_.hidden) {
            sendingProgress_.hidden = NO;
        }
        [sendingProgress_ setAvtivityIndicatorStartAnimation:YES];
        [sendingProgress_ setProgressPercent:progress info:nil];
        [self setNeedsLayout];
    }else {
        [sendingProgress_ setProgressPercent:.98 info:nil];
        [self performSelector:@selector(hiddenProgress) withObject:nil afterDelay:0.5];
    }
}

- (void)hiddenProgress
{
    sendingProgress_.hidden = YES;
}

- (void)dealloc {
    [status_ removeObserver:self forKeyPath:@"commentsCount"];
    [status_ removeObserver:self forKeyPath:@"forwardsCount"];
    [status_ removeObserver:self forKeyPath:@"likedCount"];
    [status_ removeObserver:self forKeyPath:@"sendingProgress"];
    //KD_RELEASE_SAFELY(status_);
//    //KD_RELEASE_SAFELY(sourceLabel_);
//    //KD_RELEASE_SAFELY(timeLabel_);
    //KD_RELEASE_SAFELY(commentAttrView_);
    //KD_RELEASE_SAFELY(forwardAttrView_);
    //KD_RELEASE_SAFELY(likeAttrView_);
    //KD_RELEASE_SAFELY(sendingProgress_);
//    //KD_RELEASE_SAFELY(moreBtn_);

    //[super dealloc];
}

@end
