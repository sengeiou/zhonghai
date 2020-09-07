//
//  KDTabBarController.m
//  kdweibo
//
//  Created by Gil on 15/7/2.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDTabBarController.h"
#import "XTUnreadImageView.h"
#import "KDInboxListViewController.h"
#import "KDStatusDetailViewController.h"
#import "KDSignInViewController.h"
#import "KDTaskDiscussViewController.h"
#import "KDDiscoveryViewController.h"
#import "KDMainTimelineViewController.h"
#import "KDInvitePhoneContactsViewController.h"
#import "KDTodoListViewController.h"
#import "BOSSetting.h"
#import "XTTimelineViewController.h"

@interface KDTabBarController () <UITabBarControllerDelegate>
@property (assign, nonatomic) int tapCount;
@property (weak, nonatomic) UIViewController *previousHandledViewController;
@end

@implementation KDTabBarController

- (id)init {
	self = [super init];
	if (self) {
		self.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:KDNotificationDidReceiveRemoteNotificationKey object:nil];
	}
	return self;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
	[super setSelectedIndex:selectedIndex];
	[self umengLogWithSelectedIndex:selectedIndex];
}

- (void)umengLogWithSelectedIndex:(NSUInteger)selectedIndex {
	switch (selectedIndex) {
		case 0:
			[KDEventAnalysis event:event_bottombar_session];
			break;

		case 1: {
			[KDEventAnalysis event:event_bottombar_contact];
			[KDEventAnalysis event:event_contact_kpi attributes:@{ label_contact_kpi_source : label_contact_kpi_source_contact }];
		}
		break;

		case 2:
			[KDEventAnalysis event:event_bottombar_app];
			break;

		case 3:
			[KDEventAnalysis event:event_bottombar_discover];
			break;

		default:
			break;
	}
}

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
    
    
    if(domain_name && commmunityManager.currentCompany.wbNetworkId){
        if([commmunityManager.currentCompany.wbNetworkId isEqualToString:domain_name]){
            [self gotoPushViewControllerByType:type withSthID:sthID];
        }else{
            CompanyDataModel *companyModel = [[CompanyDataModel alloc] init];
            companyModel.eid = domain_name;
            KDWeiboAppDelegate *appDelegate = (KDWeiboAppDelegate *)[KDWeiboAppDelegate getAppDelegate];
            [appDelegate changeNetWork:companyModel finished:^(BOOL finished){
                [self gotoPushViewControllerByType:type withSthID:sthID];
            }];
        }
    }
    
    if(shouldRemove) {
        [[KDSession globalSession] removePropertyForKey:KDRemoteNotificationUserInfoKey clearCache:YES];
    }
    
}

-(void)gotoPushViewControllerByType:(NSString *)type withSthID:(NSString *)sthID
{
    if([type isEqualToString:@"0"]) { //
        
    }else if([type isEqualToString:@"2"]) { // 评论
        [self gotoStatusDetailViewControllerWithID:sthID andType:type];
    }else if([type isEqualToString:@"1"]) {// 提及
        NSLog(ASLocalizedString(@"KDInboxListViewController_about"));
        [self gotoStatusDetailViewControllerWithID:sthID andType:type];
    }else if([type isEqualToString:@"6"]) {  //公告
        [KDSession globalSession].timelineType = KDTLStatusTypeBulletin; //当前的timeline 设为为公告
        [self gotoStatusDetailViewControllerWithID:sthID andType:type];
        
    }else if([type isEqualToString:@"3"]) {
        [(KDLeftTeamMenuViewController *)[[[KDWeiboAppDelegate getAppDelegate] sideMenuViewController] leftMenuViewController] showTodoView];
    }else if([type isEqualToString:@"4"]) {
        KDTaskDiscussViewController *dis = [[KDTaskDiscussViewController alloc] initWithTaskId:sthID];
        KDTodoListViewController *ctr = [(KDLeftTeamMenuViewController *)[[[KDWeiboAppDelegate getAppDelegate] sideMenuViewController] leftMenuViewController] showTodoView];
        [ctr.navigationController pushViewController:dis animated:NO];
    }
}

-(void)gotoStatusDetailViewControllerWithID:(NSString *)sthID andType:(NSString *)type
{
    [[KDWeiboAppDelegate getAppDelegate].timelineViewController toStatusDetailViewControllerWithID:sthID andType:type];
}


-(NSInteger)indexOfBackStatus
{
    NSString *openWorkWithID = [[BOSSetting sharedSetting] openWorkWithID];
    return KD_IS_BLANK_STR(openWorkWithID)?2:3;
}

- (UINavigationController *)gotoHomePageOfIndex:(NSInteger)index
{
    if (self.selectedIndex != index) {
//        [self displayViewAtIndex:index];
//        [_tabBar selectTabAtIndex:index];
        [self setSelectedIndex:index];
    }
    
    UINavigationController *nav = [self.viewControllers objectAtIndex:index];
    [nav popToRootViewControllerAnimated:NO];
    
    return nav;
}

#pragma mark - UITabBarControllerDelegate -

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UIViewController <KDTabBarControllerDelegate> *vc = (UIViewController <KDTabBarControllerDelegate> *)[[(UINavigationController *)viewController viewControllers] firstObject];
    
    if([vc isKindOfClass:[XTTimelineViewController class]]) {
        //add
        [KDEventAnalysis event:event_message_tab_count];
        [KDEventAnalysis eventCountly:event_message_tab_count];
    }else if ([vc isKindOfClass:[KDApplicationViewController class]]) {
        //add
        [KDEventAnalysis event: event_application_tab_count];
         [KDEventAnalysis eventCountly: event_application_tab_count];
    }else if ([vc isKindOfClass:[KDDiscoveryViewController class]]) {
        //add
        [KDEventAnalysis event: event_find_tab_count];
        [KDEventAnalysis eventCountly: event_find_tab_count];
    }else if ([vc isKindOfClass:[XTContentViewController class]]) {
        //add
        [KDEventAnalysis event: event_contacts_tab_count];
        [KDEventAnalysis eventCountly: event_contacts_tab_count];
    }
    
	self.tapCount++;

	BOOL hasTappedTwiceOnOneTab = NO;
	if (self.previousHandledViewController == viewController) {
		hasTappedTwiceOnOneTab = YES;
	}
	self.previousHandledViewController = viewController;

	CGFloat tapTimeRange = 0.3;
	if (self.tapCount == 2 && hasTappedTwiceOnOneTab) {
		// do something when tapped twice
		UIViewController <KDTabBarControllerDelegate> *vc = nil;
		if ([viewController isKindOfClass:[UINavigationController class]]) {
			vc = (UIViewController <KDTabBarControllerDelegate> *)[[(UINavigationController *)viewController viewControllers] firstObject];
		}
		if (vc && [vc respondsToSelector:@selector(tabBarSelectedTwice)]) {
			[NSObject cancelPreviousPerformRequestsWithTarget:vc];
			[vc tabBarSelectedTwice];
		}

		self.tapCount = 0;
		return NO;
	}
	else if (self.tapCount == 1) {
		BOOL isSameViewControllerSelected = tabBarController.selectedViewController == viewController;
		if (isSameViewControllerSelected) {
			// do something when tapped once
			UIViewController <KDTabBarControllerDelegate> *vc = nil;
			if ([viewController isKindOfClass:[UINavigationController class]]) {
				vc = (UIViewController <KDTabBarControllerDelegate> *)[[(UINavigationController *)viewController viewControllers] firstObject];
			}
			if (vc && [vc respondsToSelector:@selector(tabBarSelectedOnce)]) {
				[vc performSelector:@selector(tabBarSelectedOnce) withObject:nil afterDelay:tapTimeRange];
			}
		}

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(tapTimeRange * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			self.tapCount = 0;
		});
	}

	return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	//这里有个问题，双击的时候会重复统计两次
	[self umengLogWithSelectedIndex:tabBarController.selectedIndex];
}

@end

@implementation UITabBar (KDV6)

- (void)setBadgeValue:(int)badgeValue atIndex:(NSInteger)index {
    XTUnreadImageView *badgeValueView = [self badgeValueViewAtIndex:index];
    badgeValueView.hidden = (badgeValue <= 0);
    if (!badgeValueView.hidden) {
        [self setupBadgeValueView:badgeValueView unreadCount:badgeValue atIndex:index];
    }
}

- (XTUnreadImageView *)badgeValueViewAtIndex:(NSInteger)index {
    NSInteger tag = 999999 + index;
    XTUnreadImageView *badgeValueView = (XTUnreadImageView *)[self viewWithTag:tag];
    if (!badgeValueView) {
        badgeValueView  = [[XTUnreadImageView alloc] initWithParentView:self];
        badgeValueView.tag = tag;
        badgeValueView.hidden = YES;
        [self addSubview:badgeValueView];
    }
    return badgeValueView;
}

- (void)setupBadgeValueView:(XTUnreadImageView *)badgeValueView
                unreadCount:(int)unreadCount
                    atIndex:(NSInteger)index {
    badgeValueView.unreadCount = unreadCount;
    CGRect tabFrame = self.frame;
    float percentX = (index + 0.6) / self.items.count;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeValueView.frame = CGRectMake(x, y, CGRectGetWidth(badgeValueView.frame), CGRectGetHeight(badgeValueView.frame));
}

- (void)setDotHidden:(BOOL)hidden atIndex:(NSInteger)index {
    UIView *dotView = [self dotViewAtIndex:index];
    dotView.hidden = hidden;
}

- (UIView *)dotViewAtIndex:(NSInteger)index {
	NSInteger tag = 9999 + index;
	UIView *dotView = [self viewWithTag:tag];
	if (!dotView) {
		//新建小红点
		dotView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_img_new"]];
		dotView.tag = tag;
        
        //确定小红点的位置
		CGRect tabFrame = self.frame;
		float percentX = (index + 0.6) / self.items.count;
		CGFloat x = ceilf(percentX * tabFrame.size.width);
		CGFloat y = ceilf(0.1 * tabFrame.size.height);
		dotView.frame = CGRectMake(x, y, 9, 9);
        dotView.hidden = YES;
		[self addSubview:dotView];
	}
	return dotView;
}

@end
