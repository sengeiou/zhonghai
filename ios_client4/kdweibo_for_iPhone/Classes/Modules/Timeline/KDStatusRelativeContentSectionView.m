//
//  KDStatusRelativeContentSectionView.m
//  kdweibo
//
//  Created by laijiandong on 12-10-16.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusRelativeContentSectionView.h"

#import "KDStatus.h"
#import "UIViewAdditions.h"

@interface KDStatusRelativeContentSectionView ()

@property(nonatomic, retain) UIImageView *topDividerImageView;
@property(nonatomic, retain) UIImageView *bottomDividerImageView;
@property(nonatomic, retain) UIView *verticalDividerView;
@property(nonatomic, retain) UIButton *commentsBtn;
@property(nonatomic, retain) UIButton *forwardsBtn;
@property(nonatomic, retain) UIButton *likersBtn;
@property(nonatomic, retain) UIView *cursorView;
@property(nonatomic, retain) UIImageView *separatorView;

@end


@implementation KDStatusRelativeContentSectionView

@synthesize delegate=delegate_;
@dynamic selectedIndex;

@synthesize topDividerImageView = topDividerImageView_;
@synthesize bottomDividerImageView = bottomDividerImageView_;
@synthesize verticalDividerView=verticalDividerView_;

@synthesize commentsBtn=commentsBtn_;
@synthesize forwardsBtn=forwardsBtn_;
@synthesize likersBtn = likersBtn_;
@synthesize cursorView=cursorView_;
@synthesize separatorView = separatorView_;
@synthesize hideForward = hideForward_;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame selectedIndex:NSIntegerMax];
}


- (id)initWithFrame:(CGRect)frame selectedIndex:(NSInteger)selectedIndex hideForward:(BOOL)hide {
    self = [super initWithFrame:frame];
    
    if(self) {
        delegate_ = nil;
        selectedIndex_ = selectedIndex;
        lastSelectedIndex_ = NSIntegerMax;
        isAnimation_ = NO;
        hideForward_ = hide;
        
        [self _setupStatusDetailsSectionHeaderView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame selectedIndex:(NSInteger)selectedIndex {
    self = [super initWithFrame:frame];
    
    if(self) {
        delegate_ = nil;
        selectedIndex_ = selectedIndex;
        lastSelectedIndex_ = NSIntegerMax;
        isAnimation_ = NO;
        
        [self _setupStatusDetailsSectionHeaderView];
    }
    
    return self;
}

- (UIButton *)_actionButtonWithTitle:(NSString *)title selector:(SEL)selector {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [btn setTitleColor: MESSAGE_TOPIC_COLOR forState:UIControlStateSelected];
    [btn setTitleColor: MESSAGE_DATE_COLOR forState:UIControlStateNormal];
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn sizeToFit];
    
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)_setupStatusDetailsSectionHeaderView {
    self.backgroundColor = [UIColor whiteColor];
    UIImage *image = [UIImage stretchableImageWithImageName:@"status_relative_bg" resizableImageWithCapInsets:UIEdgeInsetsMake(10, 2, 10, 2)];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:image] ;
    backgroundView.frame = self.bounds;
    [self addSubview:backgroundView];
    //    [backgroundView release];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    //    CALayer * layer = [self layer];
    //    layer.borderColor = MESSAGE_LINE_COLOR.CGColor;
    //    layer.borderWidth = 0.5;
    //top divider image view
    //    UIImage *image = [UIImage imageNamed:@"home_page_cell_separator_bg.png"];
    //    image = [image stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    //
    //    topDividerImageView_ = [[UIImageView alloc] initWithImage:image];
    //    [self addSubview:topDividerImageView_];
    //
    //    //bottom divider image view
    //    bottomDividerImageView_ = [[UIImageView alloc] initWithImage:image];
    //    [self addSubview:bottomDividerImageView_];
    
    //    separatorView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_footer_top_separator_bg"]];
    //    [self addSubview:separatorView_];
    
    // comments button
    NSString *btnTitle = [self _formatCommentsButtonTitle:0];
    commentsBtn_ = [self _actionButtonWithTitle:btnTitle selector:@selector(didTapOnActionButton:)];// retain];
    [commentsBtn_ setSelected:(selectedIndex_ == 0)];
    [self addSubview:commentsBtn_];
    
    // vertical divider view
    verticalDividerView_ = [[UIView alloc] initWithFrame:CGRectZero];
    verticalDividerView_.backgroundColor = MESSAGE_LINE_COLOR;
    
    [self addSubview:verticalDividerView_];
    verticalDividerView_.hidden = self.hideForward;
    
    btnTitle = [self _formatForwardsButtonTitle:0];
    forwardsBtn_ = [self _actionButtonWithTitle:btnTitle selector:@selector(didTapOnActionButton:)];// retain];
    [forwardsBtn_ setSelected:(selectedIndex_ == 1)];
    [self addSubview:forwardsBtn_];
    //zgbin:客户要求屏蔽“转发”。2018.03.27
    //    forwardsBtn_.hidden = self.hideForward;
    forwardsBtn_.hidden = YES;
    //end
    
    btnTitle = ASLocalizedString(@"KDStatusDetailViewController_Like");
    likersBtn_ = [self _actionButtonWithTitle:btnTitle selector:@selector(didTapOnActionButton:)];// retain];
    [likersBtn_ setSelected:(selectedIndex_ == 2)];
    [self addSubview:likersBtn_];
    // cursor view
    cursorView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_detail_section_cursor"]];
    [self addSubview:cursorView_];
    
}

- (NSString *)_formatCommentsButtonTitle:(NSInteger)commentsCount {
    return [NSString stringWithFormat:ASLocalizedString(@"Reply"), commentsCount];
}

- (NSString *)_formatForwardsButtonTitle:(NSInteger)forwardsCount {
    return [NSString stringWithFormat:ASLocalizedString(@"Forward"), forwardsCount];
}

- (void)layoutCursorView {
    UIButton *anchor = [self btnAtIndex:selectedIndex_];
    
    cursorView_.frame = CGRectMake(anchor.frame.origin.x + (anchor.frame.size.width - cursorView_.image.size.width) * 0.5, self.frame.size.height - cursorView_.image.size.height, cursorView_.image.size.width, cursorView_.image.size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //    topDividerImageView_.frame = CGRectMake(8.0, 0.0, self.bounds.size.width - 16.0f, topDividerImageView_.bounds.size.height);
    //    bottomDividerImageView_.frame = CGRectMake(8.0f, self.bounds.size.height - 1.0f, self.bounds.size.width - 16.0f, 1.0f);
    // comments
    CGFloat offsetX = 5.0;
    
    CGRect rect = CGRectMake(offsetX, (CGRectGetHeight(self.bounds)-CGRectGetHeight(commentsBtn_.bounds))*0.5, commentsBtn_.bounds.size.width, CGRectGetHeight(commentsBtn_.bounds));
    commentsBtn_.frame = rect;
    
    CGFloat spacing = 9.0; // spacing
    
    // forwards
    if (forwardsBtn_) {
        offsetX += rect.size.width + spacing;
        rect.origin.x = offsetX;
        rect.origin.y =  (CGRectGetHeight(self.bounds)-CGRectGetHeight(forwardsBtn_.bounds))*0.5;
        rect.size.width = forwardsBtn_.bounds.size.width;
        forwardsBtn_.frame = rect;
    }
    if (verticalDividerView_) {
        // vertical divider view
        offsetX = rect.origin.x - 5.0;
        rect = CGRectMake(offsetX, 5.0, 1.0, CGRectGetHeight(self.bounds) - 10);
        verticalDividerView_.frame = rect;
    }
    
    [likersBtn_ sizeToFit];
    rect = likersBtn_.bounds;
    rect.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(rect) - 10;
    rect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(rect)) *0.5;
    likersBtn_.frame = rect;
    
    [self layoutCursorView];
}

- (void)didTapOnActionButton:(UIButton *)sender {
    NSInteger index = NSIntegerMax;
    
    lastSelectedIndex_ = selectedIndex_;
    
    if(sender == commentsBtn_) {
        index = 0x00;
    }else if(sender == forwardsBtn_) {
        index = 0x01;
    }else if(sender == likersBtn_) {
        index = 0x02;
    }
    
    self.selectedIndex = index;
}

- (void)_didSelectedIndex:(NSInteger)index {
    if (delegate_ != nil && [delegate_ respondsToSelector:@selector(statusSectionView:clickedAtIndex:)]) {
        [delegate_ statusSectionView:self clickedAtIndex:selectedIndex_];
    }
}

- (UIButton *)btnAtIndex:(NSInteger)idx
{
    switch (idx) {
        case 0x00:
            return commentsBtn_;
            break;
        case 0x01:
            return forwardsBtn_;
            break;
        case 0x02:
            return likersBtn_;
        default:
            return nil;
            break;
    }
}

- (void)_update {
    if (isAnimation_) return;
    isAnimation_ = YES;
    
    [self btnAtIndex:selectedIndex_].selected = YES;
    [self btnAtIndex:lastSelectedIndex_].selected = NO;
    
    [UIView animateWithDuration:0.25
                     animations:^(){
                         [self layoutCursorView];
                     }
                     completion:^(BOOL finished){
                         isAnimation_ = NO;
                         
                         [self _didSelectedIndex:selectedIndex_];
                     }];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex_ != selectedIndex) {
        selectedIndex_ = selectedIndex;
        
        [self _update];
    }
}

- (NSInteger)selectedIndex {
    return selectedIndex_;
}

- (void)updateWithStatus:(KDStatus *)status {
    NSString *btnTitle = [self _formatCommentsButtonTitle:status.commentsCount];
    [commentsBtn_ setTitle:btnTitle forState:UIControlStateNormal];
    [commentsBtn_ setTitle:btnTitle forState:UIControlStateSelected];
    [commentsBtn_ sizeToFit];
    
    btnTitle = [self _formatForwardsButtonTitle:status.forwardsCount];
    [forwardsBtn_ setTitle:btnTitle forState:UIControlStateNormal];
    [forwardsBtn_ setTitle:btnTitle forState:UIControlStateSelected];
    [forwardsBtn_ sizeToFit];
    
    btnTitle = [NSString stringWithFormat:ASLocalizedString(@"KDStatusRelativeContentSectionView_Like"),(long)status.likedCount];
    [likersBtn_ setTitle:btnTitle forState:UIControlStateNormal];
    [likersBtn_ setTitle:btnTitle forState:UIControlStateSelected];
    [likersBtn_ sizeToFit];
    
    [self setNeedsLayout];
}

- (void)setHideForward:(BOOL)hideForward {
    hideForward_ = hideForward;
    verticalDividerView_.hidden = hideForward_;
    forwardsBtn_.hidden = hideForward_;
}

- (void)dealloc {
    delegate_ = nil;
    
    //KD_RELEASE_SAFELY(topDividerImageView_);
    //KD_RELEASE_SAFELY(bottomDividerImageView_);
    //KD_RELEASE_SAFELY(verticalDividerView_);
    //KD_RELEASE_SAFELY(commentsBtn_);
    //KD_RELEASE_SAFELY(forwardsBtn_);
    //KD_RELEASE_SAFELY(cursorView_);
    //KD_RELEASE_SAFELY(likersBtn_);
    //KD_RELEASE_SAFELY(separatorView_);
    
    //[super dealloc];
}

@end

