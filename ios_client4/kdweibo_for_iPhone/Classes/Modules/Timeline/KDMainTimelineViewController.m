//
//  KDMainTimelineViewController.m
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-31.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDMainTimelineViewController.h"
#import "KDNavigationMenuView.h"
#import "KDSendingStatusFailedMessagePromtView.h"
#import "KDDefaultViewControllerContext.h"
#import "KDTitleNavView.h"


@interface KDMainTimelineViewController ()<KDNavigationMenuViewDelegate,KDTitleNavViewDelegate> {
    struct {
        unsigned int onFirstEnterStage:1;
    }flags_;
    
}
@property(nonatomic,assign) FriendsTimelineController *topViewController;
@property(nonatomic,strong) KDTitleNavView *titleNavView;
@end

@implementation KDMainTimelineViewController

- (void)dealloc {
    
    //[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
          flags_.onFirstEnterStage = 1;
    }
    return self;
}


- (void)switchToChildController {
    KDTLStatusType type = [KDSession globalSession].timelineType;
    FriendsTimelineController *toController = [[FriendsTimelineController alloc] initWithNibName:nil bundle:nil];// autorelease];
    //toController.view.frame = CGRectMake(0, CGRectGetMaxY(self.titleNavView.frame),ScreenFullWidth, ScreenFullHeight - CGRectGetMaxY(self.titleNavView.frame));
    toController.timelineType = type;
    [self addChildViewController:toController];
    CGRect frame = self.view.bounds;
    frame.origin.y = self.titleNavView.frame.origin.y+self.titleNavView.frame.size.height;
    frame.size.height -= frame.origin.y;
    if (self.topViewController) {
        if (toController != self.topViewController) {
            //[self.topViewController shouldRestore];
            toController.view.frame = frame;
            [self transitionFromViewController:self.topViewController toViewController:toController duration:0.0f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished){
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


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    if (flags_.onFirstEnterStage == 1) {
        flags_.onFirstEnterStage = 0;
        [self switchToChildController];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //解决高度上升
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)
//        self.edgesForExtendedLayout=UIRectEdgeNone;
    
    [self setupMenuView];
    [self setNavigationItem];
}

- (void)setNavigationItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"nav_bar_edit_btn_bg"];
    UIImage *highligthImage = [UIImage imageNamed:@"nav_bar_edit_btn_bg_highlight"];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highligthImage forState:UIControlStateHighlighted];
    
    [button sizeToFit];
    //修正超过两个字时，显示不全bug 王松 2013-12-03
    CGFloat titltWidth = CGRectGetWidth(button.titleLabel.frame) - 5.f;
    CGFloat imageWidth = CGRectGetWidth(button.imageView.frame) + 6.f;
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, titltWidth, 0, -titltWidth)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth)];
    
    
    [button sizeToFit];
    
    [button addTarget:self action:@selector(rightBarButtonItemTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    float width = kRightNegativeSpacerWidth;
    negativeSpacer.width = width - 10;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightBarButtonItem, nil];
//    [rightBarButtonItem release];
    
}

- (void)rightBarButtonItemTapped:(id)sender {
   
    //add
    [KDEventAnalysis event: event_tendency_release_weibo];
    [KDEventAnalysis eventCountly: event_tendency_release_weibo];
    
    PostViewController *pvc = [[PostViewController alloc] init] ;//autorelease];
    pvc.isSelectRange = YES;
    pvc.draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
    [KDWeiboAppDelegate setExtendedLayout:pvc];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showPostViewController:pvc];
}

- (void)setupMenuView
{
    //禁止自动设置内边距，坑爹
    //self.automaticallyAdjustsScrollViewInsets = NO;
    [KDWeiboAppDelegate setExtendedLayout:self];
    
    self.title = NSLocalizedString(ASLocalizedString(@"KDDefaultViewControllerContext_trends"), nil);
    KDTitleNavView *titleNavView = [[KDTitleNavView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight-2, ScreenFullWidth, 40)];
    titleNavView.isFillWidth = YES;
    titleNavView.selectedColor = FC5;
    titleNavView.backgroundColor = [UIColor kdBackgroundColor2];
    titleNavView.titleArray = @[ASLocalizedString(@"KDDefaultViewControllerContext_trends"),ASLocalizedString(@"KDMainTimelineViewController_follow"),ASLocalizedString(@"KDMainTimelineViewController_hot"),ASLocalizedString(@"KDMainTimelineViewController_notice")];
    titleNavView.currentIndex = 0;
    titleNavView.delegate = self;
    self.titleNavView = titleNavView;
    [self.view addSubview:titleNavView];
//    [titleNavView release];
}


-(void)clickTitle:(NSString *)title inIndex:(int)index
{
    if (index != [[KDSession globalSession] timelineType] - 1) {
        // [self setTimelineType:index +1]; //设置当前的statusType;
//        KDNavigationMenuView *menuView = (KDNavigationMenuView * )self.navigationItem.titleView;
//        if (menuView) {
//            [menuView setCurrentIndex:index];
//        }
        
        [KDSession globalSession].timelineType = index +1;
        // [[KDSession globalSession] saveTimelineType:[KDSession globalSession].timelineType]; //保存
        [[[KDManagerContext globalManagerContext] unreadManager] notify]; //切换类型后重新通知unread。
        
        [self switchToChildController];
    }else { //点栏点击两次
        
        [self.topViewController reload];
    }
}



- (void)tabBarSelectedOnce
{
    KDNavigationMenuView *menuView =  (KDNavigationMenuView*)self.navigationItem.titleView;
    if (menuView) {
        [menuView hideNavigationToolBar];
    }
    
    [self.topViewController reload];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
