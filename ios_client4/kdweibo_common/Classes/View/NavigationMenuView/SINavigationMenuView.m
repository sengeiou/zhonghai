//
//  SINavigationMenuView.m
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/19/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import "SINavigationMenuView.h"
#import "QuartzCore/QuartzCore.h"
#import "SIMenuConfiguration.h"

@interface SINavigationMenuView  ()
@property (nonatomic, retain) SIMenuTable *table;
@property (nonatomic, retain) UIView *menuContainer;
@end

@implementation SINavigationMenuView
@synthesize items = _items;
@synthesize menuContainer = _menuContainer;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        frame.origin.y += 1.0;
        self.menuButton = [[SIMenuButton alloc] initWithFrame:frame] ;//autorelease];
        self.menuButton.title.text = title;
        [self.menuButton addTarget:self action:@selector(onHandleMenuTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.menuButton];
    }
    return self;
}

- (void)displayMenuInView:(UIView *)view
{
    self.menuContainer = view;
}
- (void)setItems:(NSArray *)items
{
//    if (_items)
//        [_items release];
    _items = items;// retain];
    
    if (self.table) {
        self.table.items = items;
        [self.table.table reloadData];
    }
}
#pragma mark -
#pragma mark Actions
- (void)onHandleMenuTap:(id)sender
{
    if (self.menuButton.isActive) {
        NSLog(@"On show");
        [self onShowMenu];
    } else {
        NSLog(@"On hide");
        [self onHideMenu];
    }
}

- (void)onShowMenu
{
    if (!self.table) {
//        UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
//        CGRect frame = mainWindow.frame;
//        frame.origin.y += self.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
        //iOS7 适配 王松
        //修正动画弹出高度
        self.table = [[SIMenuTable alloc] initWithFrame:self.menuContainer.bounds items:self.items];// autorelease];
        self.table.menuDelegate = self;
    }
    [self.menuContainer addSubview:self.table];
    [self rotateArrow:M_PI];
    [self.table show];
}

- (void)onHideMenu
{
    [self rotateArrow:0];
    [self.table hide];
}

- (void)rotateArrow:(float)degrees
{
    [UIView animateWithDuration:[SIMenuConfiguration animationDuration] delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.menuButton.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
    } completion:NULL];
}

#pragma mark -
#pragma mark Delegate methods
- (void)didSelectItemAtIndex:(NSUInteger)index
{
    self.menuButton.isActive = !self.menuButton.isActive;
    self.menuButton.title.text = [self.items objectAtIndex:index];
    [self onHandleMenuTap:nil];
    [self.delegate didSelectItemAtIndex:index];
}

- (void)didBackgroundTap
{
    self.menuButton.isActive = !self.menuButton.isActive;
    [self onHandleMenuTap:nil];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc
{
    self.items = nil;
    self.menuButton = nil;
    self.table = nil;
    self.menuContainer = nil;
    //[super dealloc];
}

@end
