//
//  LeveyTabBarControllerViewController.m
//  LeveyTabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import "KDProfileDetailTabBarController.h"
#import "KDProfileDetailTabBar.h"

#import "KDWeiboAppDelegate.h"

#import "NetworkUserController.h"
#import "BlogViewController.h"
#import "KDTrendsViewController.h"
#import "KDFavoriteStatusesViewController.h"
#import "UIView+Blur.h"
#import "KDUser.h"

#define kTabBarHeight 50.0f

static KDProfileDetailTabBarController *leveyTabBarController;

@implementation UIViewController (KDProfileDetailTabBarControllerSupport)

- (KDProfileDetailTabBarController *)leveyTabBarController
{
	return leveyTabBarController;
}

@end

@interface KDProfileDetailTabBarController (private)
- (void)displayViewAtIndex:(NSUInteger)index;
@end

@implementation KDProfileDetailTabBarController
@synthesize delegate = _delegate;
@synthesize selectedViewController = _selectedViewController;
@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize tabBarHidden = _tabBarHidden;
@synthesize animateDriect;
@synthesize currentUser = currentUser_;

#pragma mark -
#pragma mark lifecycle
+ (id)profileDetailViewController
{
    NSArray *viewControllers = [NSArray arrayWithObjects:
                                [self viewControllerWithClass:[NetworkUserController class] title:ASLocalizedString(@"KDMainTimelineViewController_follow")imageName:@"icon_friend_v2.png"],
                                [self viewControllerWithClass:[NetworkUserController class] title:ASLocalizedString(@"KDProfileDetailTabBarController_Fellow")imageName:@"icon_fans_v2.png"],
                                [self viewControllerWithClass:[BlogViewController class] title:ASLocalizedString(@"XTPersonDetailViewController_WB")imageName:@"icon_blog_v2.png"],
                                [self viewControllerWithClass:[KDTrendsViewController class] title:ASLocalizedString(@"KDDiscoveryViewController_topic")imageName:@"icon_topic_v2.png"],
                                [self viewControllerWithClass:[KDFavoriteStatusesViewController class] title:ASLocalizedString(@"KDABActionTabBar_tips_1")imageName:@"icon_favorite_v2.png"],
                                nil];
    
    NSMutableDictionary *imgDic = [NSMutableDictionary dictionaryWithCapacity:3];
	[imgDic setObject:[UIImage imageNamed:@"profile_follow_icon_v3.png"] forKey:@"Default"];
	[imgDic setObject:[UIImage imageNamed:@"profile_follow_hl_icon_v3.png"] forKey:@"Highlighted"];
	[imgDic setObject:[UIImage imageNamed:@"profile_follow_hl_icon_v3.png"] forKey:@"Seleted"];
	NSMutableDictionary *imgDic2 = [NSMutableDictionary dictionaryWithCapacity:3];
	[imgDic2 setObject:[UIImage imageNamed:@"profile_fans_icon_v3.png"] forKey:@"Default"];
	[imgDic2 setObject:[UIImage imageNamed:@"profile_fans_hl_icon_v3.png"] forKey:@"Highlighted"];
	[imgDic2 setObject:[UIImage imageNamed:@"profile_fans_hl_icon_v3.png"] forKey:@"Seleted"];
	NSMutableDictionary *imgDic3 = [NSMutableDictionary dictionaryWithCapacity:3];
	[imgDic3 setObject:[UIImage imageNamed:@"dynamic_Default.png"] forKey:@"Default"];
	[imgDic3 setObject:[UIImage imageNamed:@"dynamic_Highlighted.png"] forKey:@"Highlighted"];
	[imgDic3 setObject:[UIImage imageNamed:@"dynamic_Highlighted.png"] forKey:@"Seleted"];
	NSMutableDictionary *imgDic4 = [NSMutableDictionary dictionaryWithCapacity:3];
	[imgDic4 setObject:[UIImage imageNamed:@"profile_topic_icon_v3.png"] forKey:@"Default"];
	[imgDic4 setObject:[UIImage imageNamed:@"profile_topic_hl_icon_v3.png"] forKey:@"Highlighted"];
	[imgDic4 setObject:[UIImage imageNamed:@"profile_topic_hl_icon_v3.png"] forKey:@"Seleted"];
	NSMutableDictionary *imgDic5 = [NSMutableDictionary dictionaryWithCapacity:3];
	[imgDic5 setObject:[UIImage imageNamed:@"profile_favorite_icon_v3.png"] forKey:@"Default"];
	[imgDic5 setObject:[UIImage imageNamed:@"profile_favorite_hl_icon_v3.png"] forKey:@"Highlighted"];
	[imgDic5 setObject:[UIImage imageNamed:@"profile_favorite_hl_icon_v3.png"] forKey:@"Seleted"];
	
	NSArray *imgArr = [NSArray arrayWithObjects:imgDic,imgDic2,imgDic3,imgDic4, imgDic5, nil];
    
    KDProfileDetailTabBarController *tab = [[KDProfileDetailTabBarController alloc] initWithViewControllers:viewControllers imageArray:imgArr titles:@[ASLocalizedString(@"KDMainTimelineViewController_follow"), ASLocalizedString(@"KDProfileDetailTabBarController_Fellow"), ASLocalizedString(@"XTPersonDetailViewController_WB"), ASLocalizedString(@"KDDiscoveryViewController_topic"), ASLocalizedString(@"KDABActionTabBar_tips_1")]];
    
    [tab.tabBar setBackgroundImage:[UIImage imageNamed:@"tab_bar_bg.png"]];
    [tab setTabBarTransparent:NO];
    
    [tab hidesTabBar:NO animated:NO];
    
    return tab;// autorelease];
}


- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr
{
	return [self initWithViewControllers:vcs imageArray:arr titles:nil];
}

- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr titles:(NSArray *)titles
{
	self = [super init];
	if (self != nil)
	{
        _viewControllers = [NSMutableArray arrayWithArray:vcs];// retain];
		
        CGRect rect = [[UIScreen mainScreen] bounds];
		_containerView = [[UIView alloc] initWithFrame:rect];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
		_transitionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, _containerView.frame.size.height - kTabBarHeight)];
        _transitionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
		_tabBar = [[KDProfileDetailTabBar alloc] initWithFrame:CGRectMake(0, _containerView.frame.size.height - kTabBarHeight, ScreenFullWidth, kTabBarHeight) buttonImages:arr titles:titles];
		_tabBar.delegate = self;
        _tabBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        leveyTabBarController = self;
        animateDriect = 0;
	}
	return self;
}

- (void)loadView 
{
	[super loadView];
    
    CGRect rect = _transitionView.frame;
//    if (!isAboveiOS7) {
        rect.size.height -= 20.f;
        rect.origin.y = 20.f;
//    }
    UIView *bgView = [[UIView alloc] initWithFrame:rect];
    bgView.backgroundColor =  MESSAGE_BG_COLOR;
    [_containerView addSubview:bgView];
    [_containerView sendSubviewToBack:bgView];
//    [bgView release];
	
	[_containerView addSubview:_transitionView];
//	[_containerView addSubview:_tabBar];
	self.view = _containerView;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    self.selectedIndex = 0;
}

+ (UIViewController *) viewControllerWithClass:(Class)clazz title:(NSString *)title imageName:(NSString *)imageName {
    UIViewController *vc = [[clazz alloc] initWithNibName:nil bundle:nil];// autorelease];

    [KDWeiboAppDelegate setExtendedLayout:vc];
    
    vc.tabBarItem.title = title;
    
    vc.title = title;
    
    vc.view.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
    
    return vc;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	_tabBar = nil;
	_viewControllers = nil;
}

- (void)dealloc 
{
    _tabBar.delegate = nil;
//	[_tabBar release];
//    [_containerView release];
//    [_transitionView release];
//	[_viewControllers release];
    //KD_RELEASE_SAFELY(currentUser_);
    //[super dealloc];
}

#pragma mark - instant methods

- (KDProfileDetailTabBar *)tabBar
{
	return _tabBar;
}

- (BOOL)tabBarTransparent
{
	return _tabBarTransparent;
}

- (void)setTabBarTransparent:(BOOL)yesOrNo
{
	if (yesOrNo == YES)
	{
		_transitionView.frame = _containerView.bounds;
	}
	else
	{
		_transitionView.frame = CGRectMake(0, 0, ScreenFullWidth, _containerView.frame.size.height - kTabBarHeight);
	}
}

- (void)hidesTabBar:(BOOL)yesOrNO animated:(BOOL)animated
{
	if (yesOrNO == YES)
	{
		if (self.tabBar.frame.origin.y == self.view.frame.size.height)
		{
			return;
		}
	}
	else 
	{
		if (self.tabBar.frame.origin.y == self.view.frame.size.height - kTabBarHeight)
		{
			return;
		}
	}
	
	if (animated == YES)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3f];
		if (yesOrNO == YES)
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y + kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
		else 
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y - kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
		[UIView commitAnimations];
	}
	else 
	{
		if (yesOrNO == YES)
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y + kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
		else 
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y - kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
        }
	}
}

- (NSUInteger)selectedIndex
{
	return _selectedIndex;
}
- (UIViewController *)selectedViewController
{
    return [_viewControllers objectAtIndex:_selectedIndex];
}

-(void)setSelectedIndex:(NSUInteger)index
{
    [self displayViewAtIndex:index];
    [_tabBar selectTabAtIndex:index];
}

- (void)removeViewControllerAtIndex:(NSUInteger)index
{
    if (index >= [_viewControllers count])
    {
        return;
    }
    // Remove view from superview.
    [[(UIViewController *)[_viewControllers objectAtIndex:index] view] removeFromSuperview];
    // Remove viewcontroller in array.
    [_viewControllers removeObjectAtIndex:index];
    // Remove tab from tabbar.
    [_tabBar removeTabAtIndex:index];
}

- (void)insertViewController:(UIViewController *)vc withImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index
{
    [_viewControllers insertObject:vc atIndex:index];
    [_tabBar insertTabWithImageDic:dict atIndex:index];
}


#pragma mark - Private methods
- (void)displayViewAtIndex:(NSUInteger)index
{
    // Before change index, ask the delegate should change the index.
    if ([_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) 
    {
        if (![_delegate tabBarController:self shouldSelectViewController:[self.viewControllers objectAtIndex:index]])
        {
            return;
        }
    }
    // If target index if equal to current index, do nothing.
    if (_selectedIndex == index && [[_transitionView subviews] count] != 0) 
    {
        return;
    }

    _selectedIndex = index;
    
	UIViewController *selectedVC = [self.viewControllers objectAtIndex:index];
	
	selectedVC.view.frame = _transitionView.frame;
    
	if ([selectedVC.view isDescendantOfView:_transitionView]) 
	{
		[_transitionView bringSubviewToFront:selectedVC.view];
	}
	else
	{
		[_transitionView addSubview:selectedVC.view];
	}
    
    // Notify the delegate, the viewcontroller has been changed.
    if ([_delegate respondsToSelector:@selector(tabBarController:didSelectViewController::)]) 
    {
        [_delegate tabBarController:self didSelectViewController:selectedVC];
    }
}

#pragma mark -
#pragma mark tabBar delegates
- (void)tabBar:(KDProfileDetailTabBar *)tabBar didSelectIndex:(NSInteger)index
{
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    self.navigationItem.title = vc.tabBarItem.title;
    
	if (self.selectedIndex == index) {
        UINavigationController *nav = [self.viewControllers objectAtIndex:index];
        [nav popToRootViewControllerAnimated:YES];
    }else {
        [self displayViewAtIndex:index];
    }
    
    [self setSelectedTabIndex:index];
}

- (void)setSelectedTabIndex:(NSUInteger)selectedIndex {
    if(selectedIndex < [self.viewControllers count]){
        self.selectedIndex = selectedIndex;
        
        UIViewController *vc = [self.viewControllers objectAtIndex:selectedIndex];
        [self loadDataSourceWithViewController:(id<KDUserDataLoader>)vc];
        
        self.navigationItem.title = vc.tabBarItem.title;
    }
}

- (void)loadDataSourceWithViewController:(id<KDUserDataLoader>)userDataLoader {
    [userDataLoader loadUserData];
}

- (KDUser *)currentUser {
    return currentUser_;
}

- (void)setCurrentUser:(KDUser *)currentUser {
    if(currentUser_ != currentUser){
//        [currentUser_ release];
        currentUser_ = currentUser;// retain];
        
        NSArray *controllers = self.viewControllers;
        
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

@end
