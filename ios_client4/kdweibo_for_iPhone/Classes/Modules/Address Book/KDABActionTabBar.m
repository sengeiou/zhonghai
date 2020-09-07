//
//  KDABActionTabBar.m
//  kdweibo
//
//  Created by laijiandong on 12-11-6.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDABActionTabBar.h"

@interface KDABActionTabBar ()

@property(nonatomic, retain) NSMutableArray *actionButtons;
@property(nonatomic, retain) NSArray *dividers;

@property(nonatomic, retain) UIImageView *backgroundImageView;
@property(nonatomic, retain) UIImageView *shadowImageView;
@property(nonatomic, retain) UIImageView *arrowCursorView;
@property(nonatomic, retain) UIImageView *glowImageView;

@end

@implementation KDABActionTabBar 

@synthesize delegate=delegate_;
@synthesize type=type_;
@synthesize selectedIndex=selectedIndex_;

@synthesize actionButtons=actionButtons_;
@synthesize dividers=dividers_;

@synthesize backgroundImageView=backgroundImageView_;
@synthesize shadowImageView=shadowImageView_;
@synthesize arrowCursorView=arrowCursorView_;
@synthesize glowImageView=glowImageView_;

- (id)initWithFrame:(CGRect)frame type:(KDABActionTabBarType)type selectedIndex:(NSInteger)selectedIndex {
    self = [super initWithFrame:frame];
    if (self) {
        type_ = type;
        selectedIndex_ = selectedIndex;
        
        [self _setupABActionTabBar];
    }
    
    return self;
}

- (void)_setupABActionTabBar {
    // background image view
    NSString *imageName = [self _isABActionTabBar] ? @"bottom_bg.png" : @"bottom_bg.png";
    UIImage *image = [UIImage imageNamed:imageName];
    
//    image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5f topCapHeight:image.size.height * 0.5f];
    backgroundImageView_ = [[UIImageView alloc] initWithImage:image];
    backgroundImageView_.backgroundColor = [UIColor clearColor];
    [self addSubview:backgroundImageView_];
    
    self.backgroundColor = [UIColor clearColor];
    
    if ([self _isABActionTabBar]) {
        // shadow image view
        image = [UIImage imageNamed:@"ab_action_bar_shadow_bg_v2.png"];
        shadowImageView_ = [[UIImageView alloc] initWithImage:image];
        [self addSubview:shadowImageView_];
        
        // glow image view
        image = [UIImage imageNamed:@"address_book_selected_bg_v2.png"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5f topCapHeight:image.size.height * 0.5f];
        glowImageView_ = [[UIImageView alloc] initWithImage:image];
        glowImageView_.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width / 3.0f, self.bounds.size.height);
        [self addSubview:glowImageView_];
        
        // arrow cursor image view
        image = [UIImage imageNamed:@"address_book_cursor_v2.png"];
        arrowCursorView_ = [[UIImageView alloc] initWithImage:image];
        [arrowCursorView_ sizeToFit];
        [self addSubview:arrowCursorView_];
        
        // action buttons
        NSArray *btnTitles = @[NSLocalizedString(@"AB_RECENTLY_CONTACTS", @""),
                                NSLocalizedString(@"AB_ALL_CONTACTS", @""),
                                NSLocalizedString(@"AB_FAVORITED_CONTACTS", @"")];
        
        actionButtons_ = [[NSMutableArray alloc] initWithCapacity:[btnTitles count]];
        
        UIButton *btn = nil;
        for (NSString *title in btnTitles) {
            btn = [self _actionTabBarButtonWithTitle:title];
            [self addSubview:btn];
            [actionButtons_ addObject:btn];
        }
        
        // dividers
        NSUInteger count = [actionButtons_ count] - 1;
        NSUInteger idx = 0;
        
        NSMutableArray *dividers = [[NSMutableArray alloc] initWithCapacity:count];
        UIImageView *dv = nil;
        
        image = [UIImage imageNamed:@"address_book_selected_bg_v2.png"];
        image = [image stretchableImageWithLeftCapWidth:1 topCapHeight:image.size.height * 0.5f];
        
        for (; idx < count; idx++) {
            dv = [[UIImageView alloc] initWithImage:image];
            
            [self addSubview:dv];
            [dividers addObject:dv];
            
//            [dv release];
        }
        
        self.dividers = dividers;
//        [dividers release];
    
    } else {
        // action buttons
        NSArray *dataSource = @[@"ab_person_unfavorited_v3.png", [NSNull null],
                                @"ab_person_save_v3.png", @"ab_person_save_hl_v3.png",
                                @"ab_person_share_v3.png", @"ab_person_share_hl_v3.png"];
        NSArray *titles = @[ASLocalizedString(@"KDABActionTabBar_tips_1"), ASLocalizedString(@"KDABActionTabBar_tips_2"), ASLocalizedString(@"KDABActionTabBar_tips_3")];
        
        NSUInteger count = [dataSource count];
        actionButtons_ = [[NSMutableArray alloc] initWithCapacity:(count / 2)];
        
        UIButton *btn = nil;
        NSInteger idx = 0;
        for (; idx < count; idx++) {
            btn = [self _actionBarButtonWithImageName:dataSource[idx] highlightedImageName:dataSource[idx + 1]];
            [btn setTitle:titles[idx / 2] forState:UIControlStateNormal];
            [btn setTitleColor:MESSAGE_NAME_COLOR forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(3, 10, 0, 0)];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
            [self addSubview:btn];
            [actionButtons_ addObject:btn];
            
            idx += 1;
        }
    }
}

- (UIButton *)_actionTabBarButtonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.showsTouchWhenHighlighted = YES;
    btn.backgroundColor = [UIColor clearColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:93.0f/255 green:93.0f/255 blue:93.0f/255 alpha:1.0f] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(_actionButtonFire:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (UIButton *)_actionBarButtonWithImageName:(NSString *)imageName highlightedImageName:(id)hlImageName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = [UIImage imageNamed:imageName];
    [btn setImage:image forState:UIControlStateNormal];
    
    if (hlImageName != [NSNull null]) {
        image = [UIImage imageNamed:(NSString *)hlImageName];
        [btn setImage:image forState:UIControlStateHighlighted];
    }

    [btn addTarget:self action:@selector(_actionButtonFire:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    backgroundImageView_.frame = CGRectMake(0, height - backgroundImageView_.image.size.height, width, backgroundImageView_.image.size.height);
    
    CGRect rect = CGRectZero;
    if (shadowImageView_ != nil) {
        rect = shadowImageView_.bounds;
        rect.origin.y = -3.0;
        rect.size.width = width;
        shadowImageView_.frame = rect;
    }
    
    NSUInteger count = [actionButtons_ count];
    CGFloat pw = floorf(width / count);
    
    if ([self _isABActionTabBar]) {
        [self _layoutCursorIndicatorView];
    }
    
    CGFloat offsetX = 0.0;
    rect = CGRectMake(offsetX, (height - 40.0) * 0.5, pw, 40.0);
    for (UIButton *btn in actionButtons_) {
        btn.frame = rect;
        
        offsetX += rect.size.width;
        rect.origin.x = offsetX;
    }
}

- (void)_layoutCursorIndicatorView {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat pw = floorf(width / [actionButtons_ count]) + 1.0;
    
    CGRect rect = arrowCursorView_.bounds;
    rect.origin = CGPointMake(selectedIndex_ * pw + (pw - rect.size.width) * 0.5, -1.0);
    arrowCursorView_.frame = rect;
    
    rect = CGRectMake(selectedIndex_ * pw - 1.0, 0.0, pw + 2.0, height);
    glowImageView_.frame = rect;
    
    NSUInteger idx = 0;
    rect = CGRectMake(0.0, 0.0, 1.0, height);
    for (UIView *v in dividers_) {
        rect.origin.x = pw * (1 + idx);
        v.frame = rect;
    
        idx++;
    }
}

- (void)_actionButtonFire:(UIButton *)btn {
    NSUInteger index = [actionButtons_ indexOfObject:btn];
    self.selectedIndex = index;
}

- (void)_didChangeSelectedIndex {
    [UIView animateWithDuration:0.25
                     animations:^() {
                         [self _layoutCursorIndicatorView];
                     }];
}

- (BOOL)_isABActionTabBar {
    return type_ == KDABActionTabBarTypeTabBar;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex_ != selectedIndex || ![self _isABActionTabBar]) {
        selectedIndex_ = selectedIndex;
        
        if ([self _isABActionTabBar]) {
            [self _didChangeSelectedIndex];
        }
        
        if (delegate_ != nil && [delegate_ respondsToSelector:@selector(actionTabBar:didSelectAtIndex:)]) {
            [delegate_ actionTabBar:self didSelectAtIndex:selectedIndex_];
        }
    }
}

- (NSInteger)selectedIndex {
    return selectedIndex_;
}

- (UIButton *)actionBarButtonAtIndex:(NSUInteger)index {
    if (index >= [actionButtons_ count]) return nil;

    return actionButtons_[index];
}

- (void)dealloc {
    delegate_ = nil;
    
    //KD_RELEASE_SAFELY(backgroundImageView_);
    //KD_RELEASE_SAFELY(shadowImageView_);
    //KD_RELEASE_SAFELY(arrowCursorView_);
    //KD_RELEASE_SAFELY(glowImageView_);
    
    //KD_RELEASE_SAFELY(actionButtons_);
    //KD_RELEASE_SAFELY(dividers_);
    
    //[super dealloc];
}

@end
