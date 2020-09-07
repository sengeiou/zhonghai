//
//  KDTipView.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-1-11.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDTipView.h"

#import "KDCommon.h"
#import "KDRefreshTableView.h"

#define KD_TIP_VIEW_TAG_NAME_LABEL          14
#define KD_TIP_VIEW_TAG_CONTENT_LABEL       10
#define KD_TIP_VIEW_TAG_BADGEVALUE_LABEL    11
#define KD_TIP_VIEW_TAG_BACKGROUND_VIEW     12
#define KD_TIP_VIEW_TAG_BUTTON              13
#define KD_TIP_VIEW_TAG_DIVDER              15
#define KD_TIP_VIEW_TAG_ARROW               16

#define KD_TIP_VIEW_TAG_BADGELABEL_BG       110

#define KD_TIP_VIEW_FONT_SIZE               15.0f

#define KD_TIP_VIEW_H_PADDING               26.0f
#define KD_TIP_VIEW_H_SPACING               6.0f
#define KD_TIP_VIEW_BADGE_SPACING           5.0f

NSString *const KDDidTapOnTipViewNotification = @"kd_notification_tap_on_tip_view";

static KDTipView *sharedInstance = nil;
static KDTipView *weiboStatusInstance = nil;

@interface KDTipView ()

@property (nonatomic, copy) NSString *lastContent;

@end

@implementation KDTipView

@synthesize lastContent = _lastContent;
@synthesize isVisible = _isVisible;

+ (KDTipView *)sharedTipView {
    @synchronized(self){
        if(!sharedInstance) {
            CGFloat offsetY = 44.0f;
//            if(isAboveiOS7) {
                offsetY += 20.0f;
//            }
            sharedInstance = [[KDTipView alloc] initWithFrame:CGRectMake(0.0, offsetY, 320.0f, 42.0f)];
        }
    }
    return sharedInstance;
}
+ (KDTipView *)weiboStatusTipView {
    @synchronized(self){
        if(!weiboStatusInstance) {
            weiboStatusInstance = [[KDTipView alloc] initWithFrame:CGRectMake(0.0, 44.0f, 320.0f, 42.0f)];
            [weiboStatusInstance viewWithTag:KD_TIP_VIEW_TAG_ARROW].hidden = NO;
        }
    }
    return weiboStatusInstance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
        _isVisible = NO;
        [[KDManagerContext globalManagerContext].unreadManager addUnreadListener:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPostWeibo:) name:kKDPostViewControllerDraftSendNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginLoading:) name:KDRefreshTableViewBeginLoadingNotification object:nil];
    }
    return self;
}

- (void)dealloc {
//    [name_ release];
//    [content_ release];
//    [badgeValue_ release];
//    [_lastContent release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isMemberOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)setupView {
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:KD_TIP_VIEW_FONT_SIZE];
    nameLabel.tag = KD_TIP_VIEW_TAG_NAME_LABEL;
    
    [self addSubview:nameLabel];
//    [nameLabel release];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.font = [UIFont systemFontOfSize:KD_TIP_VIEW_FONT_SIZE];
    contentLabel.tag = KD_TIP_VIEW_TAG_CONTENT_LABEL;

    [self addSubview:contentLabel];
//    [contentLabel release];
    
    UILabel *badgeValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    badgeValueLabel.backgroundColor = [UIColor clearColor];
    badgeValueLabel.textColor = [UIColor whiteColor];
    badgeValueLabel.textAlignment = NSTextAlignmentCenter;
    badgeValueLabel.font = [UIFont systemFontOfSize:KD_TIP_VIEW_FONT_SIZE];
    badgeValueLabel.tag = KD_TIP_VIEW_TAG_BADGEVALUE_LABEL;
    
    UIImage *badgeImage = [UIImage imageNamed:@"tip_view_badge_bg_v2.png"];
    badgeImage = [badgeImage stretchableImageWithLeftCapWidth:badgeImage.size.width * 0.5f topCapHeight:badgeImage.size.height * 0.5f];
    UIImageView *badgeImageView = [[UIImageView alloc] initWithImage:badgeImage];
    badgeImageView.tag = KD_TIP_VIEW_TAG_BADGELABEL_BG;

    
    [self addSubview:badgeValueLabel];
//    [badgeValueLabel release];
    [self insertSubview:badgeImageView belowSubview:badgeValueLabel];
//    [badgeImageView release];
    
//    UIImage *bgImage = [UIImage imageNamed:@"tip_view_bg_v2.png"];
//    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.75f topCapHeight:bgImage.size.height * 0.5f];
//    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
//    bgImageView.tag = KD_TIP_VIEW_TAG_BACKGROUND_VIEW;
//    [self insertSubview:bgImageView atIndex:0];
//    [bgImageView release];
    self.backgroundColor = RGBACOLOR(53, 53, 53, 0.95f);
    
//    UIImageView *leftArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_arrow.png"]];
//    leftArrow.tag = KD_TIP_VIEW_TAG_ARROW;
//    [self addSubview:leftArrow];
//    leftArrow.hidden = YES;
//    [leftArrow release];
    
    //divider
    UIImage *divImage = [UIImage imageNamed:@"seperator_v3.png"];
    divImage = [divImage stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    UIImageView *divIV = [[UIImageView alloc] initWithImage:divImage];// autorelease];
    divIV.tag = KD_TIP_VIEW_TAG_DIVDER;
    [self addSubview:divIV];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    button.tag = KD_TIP_VIEW_TAG_BUTTON;
    [button setImage:[UIImage imageNamed:@"close_btn_v3.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
//    UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedMe:)];
//    gest.delegate = self;
//    [self addGestureRecognizer:gest];
//    [gest release];
    [self addTarget:self action:@selector(clickedMe:) forControlEvents:UIControlEventTouchUpInside];
    
    self.hidden = YES;
    
    UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line.png"]];
    line.frame = CGRectMake(0.0f, self.frame.size.height - 1.f, self.frame.size.width, 1.f);
    [self addSubview:line];
//    [line release];
    
}

- (void)clickedMe:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:KDDidTapOnTipViewNotification object:self];
    if (self == weiboStatusInstance) {
        [self closeAction:nil];
    }
}

- (void)closeAction:(UIButton *)sender {
    weiboStatusInstance.frame =  CGRectMake(0.0, 44.f, 320.0f, 42.0f);
    sharedInstance.frame =  CGRectMake(0.0, 44.f, 320.0f, 42.0f);
    _isVisible = NO;
    self.lastContent = [self currentContent];
    [self removeFromSuperview];
}


- (void)setBadgeValue:(NSString *)badgeValue {
    if(![badgeValue isEqualToString:badgeValue_]) {
//        [badgeValue_ release];
        badgeValue_ = [badgeValue copy];
        
        [self setNeedsLayout];
    }
}

- (void)setContent:(NSString *)content {
    if(![content isEqualToString:content_]) {
//        [content_ release];
        content_ = [content copy];
        
        [self setNeedsLayout];
    }
}

- (void)setName:(NSString *)name {
    if(![name isEqualToString:name_]) {
//        [name_ release];
        name_ = [name copy];
        
        [self setNeedsDisplay];
    }
}

- (void)setName:(NSString *)name content:(NSString *)content andBadgeValue:(NSString *)badgeValue {
    BOOL isChanged = NO;
    
    if(![name isEqualToString:name_]) {
//        [name_ release];
        name_ = [name copy];
        
        isChanged = YES;
    }
    
    if(![content isEqualToString:content_]) {
//        [content_ release];
        content_ = [content copy];
        
        isChanged = YES;
    }
    
    if(![badgeValue_ isEqualToString:badgeValue]) {
//        [badgeValue_ release];
        badgeValue_ = [badgeValue copy];
        
        isChanged = YES;
    }
    
    if(isChanged) {
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = 42.0f;
    CGFloat width = 0.0f;
    
    //maxWidth = 320 - 24.0f - 15.0f - H_padding * 2 - H_spacing
//    CGFloat maxWidth = 281 - KD_TIP_VIEW_H_PADDING - KD_TIP_VIEW_H_PADDING - KD_TIP_VIEW_H_SPACING;
    CGFloat maxWidth = 263.0f;
    
    UIFont * f = [UIFont systemFontOfSize:KD_TIP_VIEW_FONT_SIZE];
    
    CGSize constrainedSize = CGSizeMake(MAXFLOAT, height);
    CGSize nameSize = [name_ sizeWithFont:f constrainedToSize:constrainedSize];
    CGSize contentSize = [content_ sizeWithFont:f constrainedToSize:constrainedSize];
    CGSize badgeSize = [badgeValue_ sizeWithFont:f constrainedToSize:constrainedSize];
    
    nameSize.width = MIN(nameSize.width, maxWidth - contentSize.width - 12.0f);
    
    width = (maxWidth - nameSize.width - contentSize.width - badgeSize.width) * 0.5f;
    width = MAX(12.0f, width);
//    width = 25.0f;
    
    if(name_) {
        UILabel *nameLabel = (UILabel *)[self viewWithTag:KD_TIP_VIEW_TAG_NAME_LABEL];
        if(nameLabel) {
            nameLabel.text = name_;
            nameLabel.frame = CGRectMake(width, (height - nameSize.height) * 0.5f, nameSize.width, nameSize.height);
            width += nameSize.width;
        }
    }
    
    if(content_) {
        UILabel *contentLabel = (UILabel *)[self viewWithTag:KD_TIP_VIEW_TAG_CONTENT_LABEL];
        if(contentLabel) {
            contentLabel.text = content_;
            contentLabel.frame = CGRectMake(width, (height - contentSize.height) * 0.5f, contentSize.width, contentSize.height);
            width += contentSize.width;
        }
    }
    
    UIImageView *bg = (UIImageView *)[self viewWithTag:KD_TIP_VIEW_TAG_BADGELABEL_BG];
    UILabel *badgeLabel = (UILabel *)[self viewWithTag:KD_TIP_VIEW_TAG_BADGEVALUE_LABEL];
    if(badgeValue_) {
        UIImage *badgeBG = [UIImage imageNamed:@"tip_view_badge_bg_v2.png"];
        
        badgeSize.width = (badgeSize.width + 2 * KD_TIP_VIEW_BADGE_SPACING > badgeBG.size.width) ? (badgeSize.width + 2 * KD_TIP_VIEW_BADGE_SPACING) : badgeBG.size.width;
        if(badgeSize.height < badgeBG.size.height) badgeSize.height = badgeBG.size.height;
        
        if(badgeLabel) {
            badgeLabel.hidden = NO;
            badgeLabel.text = badgeValue_;
            badgeLabel.frame = CGRectMake(MIN(width + KD_TIP_VIEW_H_SPACING, maxWidth - badgeSize.width), (height - badgeSize.height) * 0.5f, badgeSize.width, badgeSize.height);
            //width += (badgeSize.width + KD_TIP_VIEW_H_SPACING);
            
            if(bg) {
                bg.frame = badgeLabel.frame;
                bg.hidden = NO;
            }
        }
    }else {
        badgeLabel.hidden = YES;
        bg.hidden = YES;
    }

//    width += KD_TIP_VIEW_H_PADDING;
    
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
    
//    UIImageView *bgImageView = (UIImageView *)[self viewWithTag:KD_TIP_VIEW_TAG_BACKGROUND_VIEW];
//    if(bgImageView) {
//        bgImageView.frame = self.bounds;
//    }
    
    UIImageView *leftArrow = (UIImageView *)[self viewWithTag:KD_TIP_VIEW_TAG_ARROW];
    [leftArrow setFrame:CGRectMake(262.f - 35.f, (self.frame.size.height - 30.f) * 0.5f, 30.f, 30.f)];
    
    UIImageView *div = (UIImageView *)[self viewWithTag:KD_TIP_VIEW_TAG_DIVDER];
    if(div) {
        [div setFrame:CGRectMake(262.0f, 0.0f, 2.0f, height)];
    }
    UIView *btn = [self viewWithTag:KD_TIP_VIEW_TAG_BUTTON];
    if(btn) {
        btn.frame = CGRectMake(264.0f, 0.0f, self.frame.size.width - 263.0f, height);
    }
}

- (void)didPostWeibo:(NSNotification *)notification
{
    NSDictionary *info = (NSDictionary *)notification.object;
    BOOL isPost = [[info objectForKey:@"isPost"] boolValue];
    if (!isPost && self == weiboStatusInstance) {
        _isVisible = YES;
        _type = KDTipViewMessageType_SendError;
        NSString *content = ASLocalizedString(@"KDTipView_fail");
        [weiboStatusInstance setName:@" " content:content andBadgeValue:nil];
        self.hidden = NO;
        sharedInstance.hidden = YES;
    }else if(self == weiboStatusInstance){
        _isVisible = NO;
        self.hidden = YES;
    }
}

- (void)beginLoading:(NSNotification *)notification
{
    self.hidden = YES;
}



- (void)unreadManager:(KDUnreadManager *)unreadManager unReadType:(KDUnreadType)unReadType{
    KDUnread *unread = [unreadManager unread];
    if(unread.lastVisitType != KDUnReadLastVisitTypeNone && [unread lastVisitCount] && self == sharedInstance) {
        _type = (int)unread.lastVisitType;
        NSString *content = [NSString stringWithFormat:@"%@,%@", [unread lastVisitMessage], NSLocalizedString(@"CLICK_CHECK", @"")];
        NSString *badge = nil;
        
        if(unread.lastVisitCount > 1) {
            if(unread.lastVisitCount > 99) {
                badge = @"99+";
            } else {
                badge = [NSString stringWithFormat:@"%lu", (unsigned long)[unread lastVisitCount]];
            }
        }
        
        [self setName:unread.lastVisitorName content:content andBadgeValue:badge];
        self.hidden = NO;
        [self updateVisibleForSharedInstance];
        weiboStatusInstance.hidden = YES;
    }else if(self == sharedInstance){
        self.hidden = YES;
    }
}


- (void)updateVisibleForSharedInstance
{
    if(![_lastContent isEqualToString:[self currentContent]]) {
        _isVisible = YES;
    }
}

- (NSString *)currentContent
{
    return [NSString stringWithFormat:@"%@%@+%@", name_, content_, badgeValue_];
}

- (KDTipViewMessageType)msgType {
    return _type;
}

@end
