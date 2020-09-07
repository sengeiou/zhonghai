//
//  KDNavigationMenuView.m
//  kdweibo
//
//  Created by Tan yingqi on 13-11-21.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDNavigationMenuView.h"
#import "KDTopActionToolbar.h"
#import "KDNavigationMenuButton.h"
#import "KDNavigationMenuItem.h"

@interface KDNavigationMenuView()<KDTopActionToolbarDelegate>{
    BOOL _isMaskAnimating;
    BOOL _isArrowAnimating;
    BOOL _isToolBarAnimating;
    
    
}
@property(nonatomic, retain) KDNavigationMenuButton *menuBtn;
@property(nonatomic, retain) KDTopActionToolbar *toolbar;
@property(nonatomic, retain) UIView *menuContainer;

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) UIView *maskView;
@end

@implementation KDNavigationMenuView
@synthesize items = items_;
@synthesize menuBtn = menuBtn_;
@synthesize toolbar = toolbar_;
@synthesize menuContainer = menuContainer_;
@synthesize delegate = delegate_;
@synthesize currentIndex = currentIndex_;
@synthesize type = type_;
@synthesize title = title_;
@synthesize maskView = maskView_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        menuBtn_ = [[KDNavigationMenuButton alloc] initWithFrame:frame];
        [menuBtn_ addTarget:self action:@selector(menuBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:menuBtn_];
        type_ = kMenuTypeDefault;
        currentIndex_ = NSNotFound;
    }
    return self;
}


- (void)updateMenuTitle {
    KDNavigationMenuItem *item = [self.items objectAtIndex:currentIndex_];
    NSString *title = title_;
    if (!title)
        title = item.title;
    
    NSArray *titles = [title componentsSeparatedByString:KD_TITLE_PARTITION];
    if ([titles count]>1)
        title = [titles objectAtIndex:0];
    
    menuBtn_.titleLabel.text = title;
    
    UIImage *image = [UIImage imageNamed:item.iconImageName];
    menuBtn_.iconImageView.image = image;
    
}

- (void)setTitle:(NSString *)title
{
    if (title_) {
//        [title_ release];
        title_ = nil;
    }
    
    title_ = title;// retain];
}

- (void)displayMenuInView:(UIView *)view {
    self.menuContainer = view;
}
- (void)setItems:(NSArray *)items index:(NSInteger)index
{
//    if (items_)
//        [items_ release];
    items_ = items;// retain];
    
    if (index <0 || index > [items count] - 1) {
        index = 0;
    }
    self.currentIndex = index;
    
    //初始化toolbar
    self.toolbar.dataSource = items;
   
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex_ != currentIndex) {
        currentIndex_ = currentIndex;
        [self updateMenuTitle];
        
        self.toolbar.selectedIndex = currentIndex;
    }
}

- (void)setItems:(NSArray *)items {
    [self setItems:items index:0];
}

- (KDTopActionToolbar *) toolbar {
    if (!toolbar_) {
        toolbar_ =[[KDTopActionToolbar alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 90)];
        toolbar_.delegate = self;
        if (type_ == kMenuTypeCommunity) {
            CGRect rect = toolbar_.frame;
            rect.size.height  +=  3;
            toolbar_.frame = rect;
            
            rect.origin.y = 90.f;
            rect.size.width = CGRectGetWidth(rect)/4.0f;
            rect.size.height = 3.0f;
            rect.origin.x = 0.f;
            
            UIView *a = [[UIView alloc] initWithFrame:rect];
            [a setBackgroundColor:UIColorFromRGB(0x9196a4)];
            
            rect.origin.x += rect.size.width;
            UIView *f = [[UIView alloc] initWithFrame:rect];
            [f setBackgroundColor:UIColorFromRGB(0x1a85ff)];
            
            rect.origin.x += rect.size.width;
            UIView *s = [[UIView alloc] initWithFrame:rect];
            [s setBackgroundColor:UIColorFromRGB(0xff6600)];
            
            rect.origin.x += rect.size.width;
            UIView *t = [[UIView alloc] initWithFrame:rect];
            [t setBackgroundColor:UIColorFromRGB(0x20c000)];
            
            [toolbar_ addSubview:a];
            [toolbar_ addSubview:f];
            [toolbar_ addSubview:s];
            [toolbar_ addSubview:t];
//            [f release];
//            [s release];
//            [t release];
//            [a release];
//            
            [toolbar_ updateTitleColor];
            

        }
        
    }
    return toolbar_;
}

- (BOOL)canTouch {
    return !_isArrowAnimating&&!_isMaskAnimating &&!_isToolBarAnimating;
}



- (UIView *)maskView {
    if (!maskView_) {
        maskView_ = [[UIView alloc] initWithFrame:CGRectZero];
        maskView_.backgroundColor = [UIColor blackColor];
        UIGestureRecognizer *grzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuBtnTapped:)];
        [maskView_ addGestureRecognizer:grzr];
//        [grzr release];
    }
    return maskView_;
}

- (void)showMaskView {
    if (self.menuContainer) {
        if (self.toolbar) {
           
           __block CGRect frame = self.menuContainer.bounds;
            self.maskView.frame = frame;
            [self.menuContainer addSubview:maskView_];
            [self.menuContainer bringSubviewToFront:self.maskView];
            self.maskView.hidden = NO;
            self.maskView.alpha = 0;
            
             _isMaskAnimating = YES;
            [UIView animateWithDuration:0.5f animations:^(void) {
                    //self.maskView.hidden = NO;
                self.maskView.alpha = 0.5f;
            } completion:^(BOOL finished) {
                _isMaskAnimating = NO;
            }];
        }
    }
}

- (void)hideMaskView {
    if ([self.maskView superview]) {
        _isMaskAnimating = YES;
        [UIView animateWithDuration:0.5f animations:^(void) {
            //self.maskView.hidden = NO;
            self.maskView.alpha = 0.0f;
        }completion:^(BOOL fisnished) {
             [self.maskView removeFromSuperview];
            _isMaskAnimating = NO;
        }];
        
    }
}

- (void)onShowToolbar {
    self.toolbar.frame = CGRectMake(0, 0, self.menuContainer.bounds.size.width, 90);
    [self showMaskView];
    [self.menuContainer addSubview:self.toolbar];
    [self rotateArrow:M_PI];
    _isToolBarAnimating = YES;
    [self.toolbar show:^(void) {
        _isToolBarAnimating = NO;
    }];
}

- (void)onHideToolbar {
    [self hideMaskView];
    _isToolBarAnimating = YES;
    [self.toolbar hide:^(void) {
        _isToolBarAnimating = NO;
    }];
    [self rotateArrow:0];
}

- (void)rotateArrow:(float)degrees {
    _isArrowAnimating = YES;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.menuBtn.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
    } completion:^(BOOL finished) {
        _isArrowAnimating = NO;
    }];
}

- (void)menuBtnTapped:(id)sender {
    if (![self canTouch]) {
        return;
    }
    self.menuBtn.isActive = !self.menuBtn.isActive;
    if (self.menuBtn.isActive) {
        NSLog(@"On show");
        [self onShowToolbar];
    } else {
        NSLog(@"On hide");
        [self onHideToolbar];
    }
}

- (void)hideNavigationToolBar {
    if(self.menuBtn.isActive) {
        [self menuBtnTapped:nil];
    }
}

- (void)topActionToolBar:(KDTopActionToolbar *)toolbar didSelectAtIndex:(NSInteger)index {
    [self menuBtnTapped:nil];
        self.currentIndex = index;
        if (delegate_ && [delegate_ respondsToSelector:@selector(didSelectItemAtIndex:)]) {
            [delegate_ didSelectItemAtIndex:index];
        }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(title_);
    //KD_RELEASE_SAFELY(items_);
    //KD_RELEASE_SAFELY(menuBtn_);
    //KD_RELEASE_SAFELY(toolbar_);
    //KD_RELEASE_SAFELY(maskView_);
    //KD_RELEASE_SAFELY(menuContainer_);
    //[super dealloc];
}
@end
