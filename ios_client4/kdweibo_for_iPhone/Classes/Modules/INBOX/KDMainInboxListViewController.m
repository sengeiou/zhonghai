//
//  KDMainInboxListViewController.m
//  kdweibo
//
//  Created by AlanWong on 14-6-20.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDMainInboxListViewController.h"
#import "KDInboxListSubviewController.h"
#import "KDSendingStatusFailedMessagePromtView.h"
#import "KDDefaultViewControllerContext.h"
#import "KDTitleNavView.h"
@interface KDMainInboxListViewController ()<KDTitleNavViewDelegate>{
    struct {
        unsigned int onFirstEnterStage:1;
    }flags_;

}
@property (nonatomic,retain)KDInboxListSubviewController * topViewController;
@property (nonatomic,assign)KDInboxType currentType;
@property (nonatomic,retain)KDTitleNavView *titleNavView;
@end

@implementation KDMainInboxListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        flags_.onFirstEnterStage = 1;
        _currentType = KDInboxTypeAll;
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (flags_.onFirstEnterStage == 1) {
        flags_.onFirstEnterStage = 0;
        [self setupMenuView];
        [self switchToChildController:0];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setupMenuView{
    if(self.navigationItem) {
        //禁止自动设置内边距，坑爹
        [KDWeiboAppDelegate setExtendedLayout:self];
        
        self.title = NSLocalizedString(ASLocalizedString(@"KDDiscoveryViewController_replu"), nil);
        KDTitleNavView *titleNavView = [[KDTitleNavView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight-2, ScreenFullWidth, 40)];
        titleNavView.isFillWidth = YES;
        titleNavView.selectedColor = FC5;
        titleNavView.backgroundColor = [UIColor kdBackgroundColor2];
        titleNavView.titleArray = @[ASLocalizedString(@"KDAppSerachViewController_all"),ASLocalizedString(@"KDInboxListViewController_about"),ASLocalizedString(@"DraftTableViewCell_tips_4")];
        titleNavView.currentIndex = 0;
        titleNavView.delegate = self;
        self.titleNavView = titleNavView;
        [self.view addSubview:titleNavView];
//        [titleNavView release];

        
//        KDNavigationMenuView *menuView = [[KDNavigationMenuView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, self.navigationController.navigationBar.bounds.size.height) ];
//        
//        KDNavigationMenuItem *itemInbox = [KDNavigationMenuItem menuItemWithImageName:@"community_content_all" selectedImageName:@"community_content_all_selected" title:[NSString stringWithFormat:ASLocalizedString(@"提及回复%@全部"),KD_TITLE_PARTITION] iconImageName:@"community_header_all" ];
//        KDNavigationMenuItem *itemMetion = [KDNavigationMenuItem menuItemWithImageName:@"inbox_menu_metion" selectedImageName:@"inbox_menu_metion_selected" title:ASLocalizedString(@"提及")iconImageName:@"inbox_title_metion" ];
//        KDNavigationMenuItem *itemComment = [KDNavigationMenuItem menuItemWithImageName:@"inbox_menu_comment" selectedImageName:@"inbox_menu_comment_selected" title:ASLocalizedString(@"DraftTableViewCell_tips_4")iconImageName:@"inbox_title_comment" ];
//        menuView.delegate = self;
//        [menuView setItems:@[itemInbox,itemMetion,itemComment] index:_currentType];
//        [menuView displayMenuInView:self.view];
//        
//        self.navigationItem.titleView = menuView;
//        [menuView release];
    }
    
}
- (void)switchToChildController:(NSUInteger)index{
    KDInboxListSubviewController *toController = [[KDInboxListSubviewController alloc]initWithInboxType:_currentType];
    toController.inboxType = (KDInboxType)index;
    [self addChildViewController:toController];
    CGRect frame = self.view.bounds;
    frame.origin.y = self.titleNavView.frame.origin.y+self.titleNavView.frame.size.height;
    frame.size.height -= frame.origin.y;
    if (self.topViewController) {
        if (toController != self.topViewController) {
            //[self.topViewController shouldRestore];
            toController.view.frame = frame;
            [self transitionFromViewController:self.topViewController toViewController:toController duration:0.1f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished){
                [self.topViewController removeFromParentViewController];
                self.topViewController = toController;
            }];
    }
    }else {
        toController.view.frame = frame;
        [self.view addSubview:toController.view];
        self.topViewController = toController;
    }
}

-(void)clickTitle:(NSString *)title inIndex:(int)index
{
    if (index != _currentType) {
        _currentType = index;
//        KDNavigationMenuView *menuView = (KDNavigationMenuView * )self.navigationItem.titleView;
//        if (menuView) {
//            [menuView setCurrentIndex:index];
//        }
        [[[KDManagerContext globalManagerContext] unreadManager] notify]; //切换类型后重新通知unread。
        [self switchToChildController:index];
    }else { //点栏点击两次
        
        //       [self.topViewController re];
    }
}

@end
