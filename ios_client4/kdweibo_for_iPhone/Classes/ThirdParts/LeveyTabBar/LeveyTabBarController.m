//
//  LeveyTabBarControllerViewController.m
//  LeveyTabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import "LeveyTabBarController.h"
#import "LeveyTabBar.h"
#import "KDManagerContext.h"
#import "KDDefaultViewControllerContext.h"
#import "KDDMConversationViewController.h"
#import "KDInboxListViewController.h"
#import "KDStatusDetailViewController.h"
#import "KDSignInViewController.h"
#import "KDTaskDiscussViewController.h"
#import "KDDiscoveryViewController.h"
#import "KDMainTimelineViewController.h"
#import "KDInvitePhoneContactsViewController.h"
#import "KDTodoListViewController.h"

#define kTabBarHeight 50.0f

static LeveyTabBarController *leveyTabBarController;

@implementation UIViewController (LeveyTabBarControllerSupport)

- (LeveyTabBarController *)leveyTabBarController
{
	return leveyTabBarController;
}

@end

@interface LeveyTabBarController (private)
- (void)displayViewAtIndex:(NSUInteger)index;
@end

@implementation LeveyTabBarController
@synthesize delegate = _delegate;
@synthesize selectedViewController = _selectedViewController;
@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize tabBarHidden = _tabBarHidden;
@synthesize animateDriect;

#pragma mark -
#pragma mark lifecycle
- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr
{
	return  [self initWithViewControllers:vcs imageArray:arr tiltesArray:nil];
}

- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr tiltesArray:(NSArray *)titles
{
    self = [super init];
	if (self != nil)
	{
        _viewControllers = [NSMutableArray arrayWithArray:vcs];// retain];
		
		_containerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		
		_transitionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, _containerView.frame.size.height - kTabBarHeight)];
		
		_tabBar = [[LeveyTabBar alloc] initWithFrame:CGRectMake(0, _containerView.frame.size.height - kTabBarHeight, 320.0f, kTabBarHeight) buttonImages:arr titles:titles];
		_tabBar.delegate = self;
		
        leveyTabBarController = self;
        animateDriect = 0;
        [[KDManagerContext globalManagerContext].unreadManager addUnreadListener:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:KDNotificationDidReceiveRemoteNotificationKey object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLocalNotification:) name:KDNotificationDidReceiveLocalNotificationKey object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTeamTipsViewNotification:) name:KDTeamTipsViewDidTapNotification object:nil];
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
	[_containerView addSubview:_tabBar];
	self.view = _containerView;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    self.selectedIndex = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetSizeFormodalView:) name:kKDModalViewShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetSizeFormodalView:) name:kKDModalViewHideNotification object:nil];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	_tabBar = nil;
	_viewControllers = nil;
}

- (void)dealloc 
{
    [[KDManagerContext globalManagerContext].unreadManager removeUnreadListener:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tabBar.delegate = nil;
//	[_tabBar release];
//    [_containerView release];
//    [_transitionView release];
//	[_viewControllers release];
    _viewControllers = nil;
    //[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


//for push
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self didReceiveRemoteNotification:nil];
//    [self didReceiveLocalNotification:nil];
}

- (UINavigationController *)gotoHomePageOfIndex:(NSInteger)index
{
    if (self.selectedIndex != index) {
        [self displayViewAtIndex:index];
        [_tabBar selectTabAtIndex:index];
    }
    
    UINavigationController *nav = [self.viewControllers objectAtIndex:index];
    [nav popToRootViewControllerAnimated:NO];
    
    return nav;
}

/*
 
 
   0 短邮，1 提及，2 评论，3 代办，4 任务讨论，5 工作圈邀请，6 公告
 
 
 **/



- (void)didReceiveRemoteNotification:(NSNotification *)noti
{
    NSDictionary *dic = [[KDSession globalSession] propertyForKey:KDRemoteNotificationUserInfoKey];
    NSString *domain_name = [dic objectForKey:KDRemoteNotificationDomainNameKey];
    NSString *sthID = [dic objectForKey:KDRemoteNotificationIDKey];
    NSString *type = [dic objectForKey:KDRemoteNotificationTypeKey];
    
    if(type && [type isEqualToString:@"ti"]) {
        [[[KDWeiboAppDelegate getAppDelegate] sideMenuViewController] presentLeftMenuViewController];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationDidReceiveRemoteTeamInviteNotificationKey object:nil];
    }else {
        if(noti) {
            [[[KDWeiboAppDelegate getAppDelegate] sideMenuViewController] hideMenuViewController];
        }
    }
    BOOL shouldRemove = YES;
    KDCommunityManager *commmunityManager = [KDManagerContext globalManagerContext].communityManager;
 

    if(domain_name && commmunityManager.currentCompany && [commmunityManager.currentCompany.wbNetworkId isEqualToString:domain_name]){
        if([type isEqualToString:@"0"]) { //
            
        }else if([type isEqualToString:@"2"]) { // 评论
            KDDiscoveryViewController *discoveryController = [[KDDiscoveryViewController alloc] init];// autorelease];

            KDInboxListViewController *inbox = [[KDInboxListViewController alloc] initWithInboxType:kInboxTypeAll];// autorelease];
            KDStatusDetailViewController *sdvc = [[KDStatusDetailViewController alloc] initWithStatusID:sthID fromInbox:sthID];// autorelease];
            
            UINavigationController *nav = [self gotoHomePageOfIndex:2];
            nav.viewControllers = nil;
            [nav pushViewController:discoveryController animated:NO];
            [nav pushViewController:inbox animated:NO];
            [nav pushViewController:sdvc animated:NO];
        }else if([type isEqualToString:@"1"]) {// 提及
            NSLog(ASLocalizedString(@"提及"));
            KDDiscoveryViewController *discoveryController = [[KDDiscoveryViewController alloc] init] ;//autorelease];
                                                              KDInboxListViewController *inbox = [[KDInboxListViewController alloc] initWithInboxType:kInboxTypeAll];// autorelease];
                                                                                                  KDStatusDetailViewController *sdvc = [[KDStatusDetailViewController alloc] initWithStatusID:sthID fromInbox:sthID];// autorelease];
            UINavigationController *nav = [self gotoHomePageOfIndex:2];
            nav.viewControllers = nil;
            [nav pushViewController:discoveryController animated:NO];
            [nav pushViewController:inbox animated:NO];
            [nav pushViewController:sdvc animated:NO];
        }else if([type isEqualToString:@"6"]) {  //公告
           
            [KDSession globalSession].timelineType = KDTLStatusTypeBulletin; //当前的timeline 设为为公告
            
            KDDiscoveryViewController *discoveryController = [[KDDiscoveryViewController alloc] init];// autorelease];
            KDMainTimelineViewController *friendTimelineController = [[KDMainTimelineViewController alloc] init];// autorelease];
            KDStatusDetailViewController *detail = [[KDStatusDetailViewController alloc] initWithStatusID:sthID];// autorelease];
            UINavigationController *nav = [self gotoHomePageOfIndex:2];
            nav.viewControllers = nil;  //先清空当前的栈
            [nav pushViewController:discoveryController animated:NO];
            [nav pushViewController:friendTimelineController animated:NO];
            [nav pushViewController:detail animated:NO];
            
        }
//        else if([type isEqualToString:@"3"]) {
//            [(KDLeftTeamMenuViewController *)[[[KDWeiboAppDelegate getAppDelegate] sideMenuViewController] menuViewController] showTodoView];
//        }else if([type isEqualToString:@"4"]) {
//            KDTaskDiscussViewController *dis = [[KDTaskDiscussViewController alloc] initWithTaskId:sthID];// autorelease];
//            KDTodoListViewController *ctr = [(KDLeftTeamMenuViewController *)[[[KDWeiboAppDelegate getAppDelegate] sideMenuViewController] menuViewController] showTodoView];
//            [ctr.navigationController pushViewController:dis animated:NO];
//        }
    }
    
    if(shouldRemove) {
        [[KDSession globalSession] removePropertyForKey:KDRemoteNotificationUserInfoKey clearCache:YES];
    }
    
}

- (void)didReceiveLocalNotification:(NSNotification *)notification
{
    if(notification) {
        [[[KDWeiboAppDelegate getAppDelegate] sideMenuViewController] hideMenuViewController];
    }
    
    if([[KDSession globalSession] propertyForKey:KDLocalNotificationInfoKey]) {
        KDSignInViewController *sign = [[KDSignInViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
        [[self gotoHomePageOfIndex:4] pushViewController:sign animated:YES];
        
        [[KDSession globalSession] removePropertyForKey:KDLocalNotificationInfoKey clearCache:YES];
    }
}

- (void)didReceiveTeamTipsViewNotification:(NSNotification *)notification
{
    UINavigationController *nav = [self gotoHomePageOfIndex:3];
    KDInvitePhoneContactsViewController *invite = [[KDInvitePhoneContactsViewController alloc] initWithNibName:nil bundle:nil];
    invite.isNeedFilter = YES;
    
    [nav pushViewController:invite animated:YES];
    
//    [invite release];
}
#pragma mark - instant methods

- (LeveyTabBar *)tabBar
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
		_transitionView.frame = CGRectMake(0, 0, 320.0f, _containerView.frame.size.height - kTabBarHeight);
	}
}


- (void)hidesTabBar:(BOOL)yesOrNO animated:(BOOL)animated
{
    if ([[KDWeiboAppDelegate getAppDelegate] isLeftPresent]) {
        return;
    }
    
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
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.view.frame.size.height + kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
            if([[_transitionView subviews]count ] > 0 ) {
                [self resizeFrame:((UIView *)[[_transitionView subviews] objectAtIndex:0])];
            }
		}
		else 
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.view.frame.size.height - kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
            [self resizeFrame:((UIView *)[[_transitionView subviews] lastObject])];
		}
		[UIView commitAnimations];
	}
	else 
	{
		if (yesOrNO == YES)
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.view.frame.size.height + kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
            if([[_transitionView subviews]count ] > 0 ) {
              [self resizeFrame:((UIView *)[[_transitionView subviews] objectAtIndex:0])];
            }
		}
		else 
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.view.frame.size.height - kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
            [self resizeFrame:((UIView *)[[_transitionView subviews] lastObject])];
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

- (void) removeAllController
{
    for (int i=0;i<[_viewControllers count];i++){
        [self removeViewControllerAtIndex:i];
    }
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
    
    switch (index) {
        case 0:
            [KDEventAnalysis event:event_bottombar_session];
            break;
        case 1:
            [KDEventAnalysis event:event_bottombar_app];
            break;
        case 2:
            [KDEventAnalysis event:event_bottombar_discover];
            break;
        case 3:
            [KDEventAnalysis event:event_bottombar_contact];
            break;
        default:
            break;
    }
    
    // 切换时，先将前一个View移除  王松 2013-11-27
    
    UIViewController *preVC = [self.viewControllers objectAtIndex:_selectedIndex];
    [preVC.view removeFromSuperview];
    
    _selectedIndex = index;
    
	UINavigationController *selectedVC = [self.viewControllers objectAtIndex:index];
    //切换时跳转根视图,修正通知时引起的tabbar显示错误 song.wang 2014-01-06
    [selectedVC popToRootViewControllerAnimated:NO];
    
    [self resizeFrame:selectedVC.view];
    
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
- (void)tabBar:(LeveyTabBar *)tabBar didSelectIndex:(NSInteger)index
{
	if (self.selectedIndex == index) {
        UINavigationController *nav = [self.viewControllers objectAtIndex:index];
        UIViewController<LeveyTabBarControllerDelegate> *vc = (UIViewController<LeveyTabBarControllerDelegate> *)[nav.viewControllers firstObject];
        if ([vc respondsToSelector:@selector(tabBarSelectedOnce)]) {
            [vc tabBarSelectedOnce];
        }
//        [nav popToRootViewControllerAnimated:YES];
    }else {
        [self displayViewAtIndex:index];
    }
}

- (void)tabBar:(LeveyTabBar *)tabBar didDoubleSelectIndex:(NSInteger)index
{
    if (self.selectedIndex == index) {
        UINavigationController *nav = [self.viewControllers objectAtIndex:index];
        UIViewController<LeveyTabBarControllerDelegate> *vc = (UIViewController<LeveyTabBarControllerDelegate> *)[nav.viewControllers firstObject];
        if ([vc respondsToSelector:@selector(tabBarSelectedDouble)]) {
            [vc tabBarSelectedDouble];
        }
    }else {
        [self displayViewAtIndex:index];
    }
}

- (void)tabBar:(LeveyTabBar *)tabBar didLongPressSelectIndex:(NSInteger)index
{
    if (self.selectedIndex == index) {
        UINavigationController *nav = [self.viewControllers objectAtIndex:index];
        UIViewController<LeveyTabBarControllerDelegate> *vc = (UIViewController<LeveyTabBarControllerDelegate> *)[nav.viewControllers firstObject];
        if ([vc respondsToSelector:@selector(tabBarSelectedLongPress)]) {
            [vc tabBarSelectedLongPress];
        }
    }else {
        [self displayViewAtIndex:index];
    }
}

#pragma mark -
#pragma mark KDUnreadListener methods
/**
 *  从Unread中读取是否有最新的未读消息
 *
 *  @param unreadManager
 *  @param unread
 */

// 红点
- (void)unreadManager:(KDUnreadManager *)unreadManager unReadType:(KDUnreadType)unReadType{
    int inboxTotal =(int)unreadManager.unread.inboxTotal;
    [_tabBar setBadgeValue:DYNAMIC_BTN count:inboxTotal];
    [_tabBar showNewMessage:DYNAMIC_BTN show:inboxTotal == 0
     && ([unreadManager.unread publicStatuses] > 0
         || [unreadManager.unread hasNewgroupStatuses])];
    
    // 以上为原逻辑
    
    
    
    
    ////    /**
    ////     *  短邮和收件箱时显示数字，小组时显示点
    ////     */
    ////    if(directMessages>0||inBoxTotal>0){
    ////        [_tabBar showNewMessage:DIRECTMESSAGE_BTN show:NO];
    ////        [_tabBar setBadgeValue:DIRECTMESSAGE_BTN count:(inBoxTotal + directMessages)];
    ////    } else if(unread.hasNewgroupStatuses) {
    ////        [_tabBar setBadgeValue:DIRECTMESSAGE_BTN count:0];
    ////        [_tabBar showNewMessage:DIRECTMESSAGE_BTN show:YES];
    ////    } else {
    ////        [_tabBar setBadgeValue:DIRECTMESSAGE_BTN count:0];
    ////        [_tabBar showNewMessage:DIRECTMESSAGE_BTN show:NO];
    ////    }
    //
    //   // [_tabBar setBadgeValue:TODO_BTN count:undoTotal];
}


// 重新设置frame
- (void)resizeFrame:(UIView *)view
{
    if (self.tabBar.frame.origin.y + 0.01 >= self.view.frame.size.height) {
//        if (isAboveiOS7) {
            view.frame = self.view.bounds;
//        }else {
//            CGRect rect = _transitionView.frame;
//            rect.origin.y += 20.f;
//            rect.size.height -= 18.f;
//            view.frame = rect;
//        }
    }else {
//        if (isAboveiOS7) {
            CGRect rect = _transitionView.frame;
            rect.size.height -= self.tabBar.frame.size.height - 2.f;
            view.frame = rect;
//        }else {
//            CGRect rect = _transitionView.frame;
//            rect.origin.y += 20.f;
//            rect.size.height -= self.tabBar.frame.size.height + 18.f;
//            view.frame = rect;
//        }
    }
    
}

- (void)resetSizeFormodalView:(NSNotification *)notification
{
    if ([self shouldResize]) {
        [self hidesTabBar:![notification.name isEqual:kKDModalViewHideNotification] animated:YES];
    }
}

- (BOOL)shouldResize
{
    //1.判定是否已经滑到了右侧
    BOOL isInCenter = CGRectGetWidth([[KDDefaultViewControllerContext defaultViewControllerContext] topViewController].view.frame) == CGRectGetWidth([UIScreen mainScreen].bounds);
    //2.判定是否是顶层一级菜单
    BOOL isFirst =  self == [[KDDefaultViewControllerContext defaultViewControllerContext] topViewController]
                    && ((UINavigationController *)self.selectedViewController).viewControllers.count == 1;
    return isInCenter && isFirst;
}


@end
