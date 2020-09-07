//
//  ProfileViewDetailController.m
//  TwitterFon
//
//  Created by apple on 11-4-1.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewDetailController.h"
#import "KDWeiboAppDelegate.h"

#import "NetworkUserController.h"
#import "BlogViewController.h"
#import "KDTrendsViewController.h"
#import "KDFavoriteStatusesViewController.h"
#import "UIView+Blur.h"
#import "KDUser.h"

@implementation ProfileViewDetailController

@synthesize currentUser=currentUser_;

- (UIViewController *) viewControllerWithClass:(Class)clazz title:(NSString *)title imageName:(NSString *)imageName {
    UIViewController *vc = [[clazz alloc] initWithNibName:nil bundle:nil];// autorelease];
    if([vc isKindOfClass:[KDTrendsViewController class]] && currentUser_) {
        [(KDTrendsViewController *)vc setUser:currentUser_];
    }
    
    [KDWeiboAppDelegate setExtendedLayout:vc];
    
    vc.tabBarItem.title = title;
    
    vc.view.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
    
    for(UIView *v in vc.view.subviews) {
        if([v isKindOfClass:[KDRefreshTableView class]]) {
            KDRefreshTableView *tv = (KDRefreshTableView *)v;
            tv.shouldKeepOriginalContentInset = YES;
//            if(isAboveiOS7) {
                tv.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
//            }else {
//                tv.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//            }
        }
    }
    
    return vc;
} 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
        
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.hidden = YES;
    self.tabBar.alpha = 0.0f;
    self.viewControllers = [NSArray arrayWithObjects:
                            [self viewControllerWithClass:[NetworkUserController class] title:ASLocalizedString(@"KDMainTimelineViewController_follow")imageName:@"icon_friend_v2.png"],
                            [self viewControllerWithClass:[NetworkUserController class] title:ASLocalizedString(@"KDProfileDetailTabBarController_Fellow")imageName:@"icon_fans_v2.png"],
                            [self viewControllerWithClass:[BlogViewController class] title:ASLocalizedString(@"XTPersonDetailViewController_WB")imageName:@"icon_blog_v2.png"],
                            [self viewControllerWithClass:[KDTrendsViewController class] title:ASLocalizedString(@"KDDiscoveryViewController_topic")imageName:@"icon_topic_v2.png"],
                            [self viewControllerWithClass:[KDFavoriteStatusesViewController class] title:ASLocalizedString(@"KDABActionTabBar_tips_1")imageName:@"icon_favorite_v2.png"],
                            nil];
    
    [self setupToolBar];
}

- (void)setupToolBar {
    NSArray *images = [NSArray arrayWithObjects:
                       @{@"image" : [UIImage imageNamed:@"profile_follow_icon_v3.png"], @"title" : ASLocalizedString(@"KDMainTimelineViewController_follow")},
                       @{@"image" : [UIImage imageNamed:@"profile_fans_icon_v3.png"], @"title" : ASLocalizedString(@"KDProfileDetailTabBarController_Fellow")},
                       @{@"image" : [UIImage imageNamed:@"dynamic_Default.png"], @"title" : ASLocalizedString(@"XTPersonDetailViewController_WB")},
                       @{@"image" : [UIImage imageNamed:@"profile_topic_icon_v3.png"], @"title" : ASLocalizedString(@"KDDiscoveryViewController_topic")},
                       @{@"image" : [UIImage imageNamed:@"profile_favorite_icon_v3.png"], @"title" : ASLocalizedString(@"KDABActionTabBar_tips_1")},
                       nil];
    menuView_ = [[KDMenuView alloc] initWithFrame:self.tabBar.frame delegate:self images:images];
    UIImage *bgImage = [UIImage imageNamed:@"bottom_bg.png"];
//    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.5f topCapHeight:bgImage.size.height * 0.5f];
    [menuView_ setBackgroundImage:bgImage];
    menuView_.backgroundImageView.frame = CGRectMake(0, 0, 320, 46.0f);
    [menuView_ setBackgroundColor:RGBCOLOR(237, 237, 237)];
     menuView_.autoresizingMask = super.tabBar.autoresizingMask;
    
    CGFloat menuViewHeight = 46.0f;
//    if(isAboveiOS7) {
        menuViewHeight = 45.0f;
//    }
    
    if(super.tabBar.superview) {
        menuView_.frame = CGRectMake(0, CGRectGetHeight(super.tabBar.superview.frame) - menuViewHeight, CGRectGetWidth(self.tabBar.frame), menuViewHeight);
        [super.tabBar.superview insertSubview:menuView_ aboveSubview:super.tabBar];
        self.tabBar.superview.backgroundColor = RGBCOLOR(237, 237, 237);
        
//        if(isAboveiOS7) {
//            self.tabBar.superview.backgroundColor = [UIColor clearColor];
//        }else {
//            self.tabBar.superview.backgroundColor = RGBCOLOR(237, 237, 237);
//        }
    }
    
    [menuView_ renderLayerWithView:menuView_.superview];
}

- (void)changeTitleWithViewController:(UIViewController *)vc {
    self.navigationItem.title = vc.tabBarItem.title;
}

- (void)loadDataSourceWithViewController:(id<KDUserDataLoader>)userDataLoader {
    [userDataLoader loadUserData];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)vc {
	[self changeTitleWithViewController:vc];
    [self loadDataSourceWithViewController:(id<KDUserDataLoader>)vc];
}

- (void)setSelectedTabIndex:(NSUInteger)selectedIndex {
    if(selectedIndex < [super.viewControllers count]){
        super.selectedIndex = selectedIndex;
        
        UIViewController *vc = [self.viewControllers objectAtIndex:selectedIndex];
        [self changeTitleWithViewController:vc];
        [self loadDataSourceWithViewController:(id<KDUserDataLoader>)vc];
        [self setMenuViewSelecteIndex:selectedIndex];
    }
}

- (KDUser *)currentUser {
    return currentUser_;
}

- (void)setCurrentUser:(KDUser *)currentUser {
    if(currentUser_ != currentUser){
//        [currentUser_ release];
        currentUser_ = currentUser;// retain];
        
        NSArray *controllers = super.viewControllers;
        
        NetworkUserController *friendsViewController = [controllers objectAtIndex:0x00];
        friendsViewController.owerUser = currentUser;
        friendsViewController.isFollowee = YES;
        
        NetworkUserController *followersViewController = [controllers objectAtIndex:0x01];
        followersViewController.owerUser = currentUser;
        followersViewController.isFollowee = NO;
        
        ((BlogViewController *)[controllers objectAtIndex:0x02]).user = currentUser_;
        ((KDTrendsViewController *)[controllers objectAtIndex:0x03]).user = currentUser_;
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(currentUser_);
    
    //[super dealloc];
}

#pragma makr - KDMenuViewDelegate Methods
- (void)menuView:(KDMenuView *)menuView configMenuButton:(UIButton *)button atIndex:(NSUInteger)index {
    NSArray *images = [NSArray arrayWithObjects:
                       @"profile_follow_hl_icon_v3.png",
                       @"profile_fans_hl_icon_v3.png",
                       @"dynamic_Highlighted.png",
                       @"profile_topic_hl_icon_v3.png",
                       @"profile_favorite_hl_icon_v3.png",
                       nil];
    
    [button setImage:[UIImage imageNamed:[images objectAtIndex:index]] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:[images objectAtIndex:index]] forState:UIControlStateSelected];
    
    UIImage *image = [button imageForState:UIControlStateNormal];
    NSString *title = [button titleForState:UIControlStateNormal];
    CGSize   size = [title sizeWithFont:button.titleLabel.font];
    
    [button setTitleColor:RGBCOLOR(109, 109, 109) forState:UIControlStateNormal];
    [button setTitleColor:RGBCOLOR(71, 130, 251) forState:UIControlStateSelected];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(32.0f, -image.size.width, 0.0f, 0.0f)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(-10.0f, 0, 0.0f, -size.width)];
}

- (void)menuView:(KDMenuView *)menuView clickedMenuItemAtIndex:(NSInteger)index {
    [self setSelectedTabIndex:index];
    [self setMenuViewSelecteIndex:index];
}

- (void)setMenuViewSelecteIndex:(NSUInteger)selectedIndex {
    NSUInteger count = [menuView_.menuItems count];
    
    for(NSUInteger index = 0; index < count; index++) {
        KDMenuItem *item = [menuView_ menuItemAtIndex:index];
        [(UIButton *)item.customView setSelected:(index == selectedIndex)];
    }
}

@end
