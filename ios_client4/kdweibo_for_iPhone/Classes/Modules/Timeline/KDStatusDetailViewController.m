//
//  KDStatusDetailViewController.m
//  kdweibo
//
//  Created by shen kuikui on 12-12-14.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDStatusDetailViewController.h"

#import "KDProgressModalViewController.h"
#import "KDWeiboAppDelegate.h"
#import "ResourceManager.h"
#import "KDDefaultViewControllerFactory.h"
#import "KDDefaultViewControllerContext.h"
#import "KDWeiboServicesContext.h"
#import "KDServiceActionInvoker.h"

#import "KDStatusCellForDetailView.h"
#import "KDNotificationView.h"
#import "KDErrorDisplayView.h"
#import "MBProgressHUD.h"

#import "KDAttachmentViewController.h"
#import "TrendStatusViewController.h"
#import "KDVoteViewController.h"
#import "ProfileViewController.h"
#import "KDDatabaseHelper.h"

#import "KDTopic.h"
#import "KDStatusCounts.h"

#import "NSDictionary+Additions.h"
#import "UIViewController+Navigation.h"
#import "KDManagerContext.h"
#import "KDUploadTaskHelper.h"
#import "KDLikeTask.h"
#import "DTCoreText.h"
#import "KDVideoPlayerController.h"
#import "IssuleViewController.h"
#import "KDTaskDiscussViewController.h"
#import "KDStatusLayouter.h"
#import "KDStatusDataset.h"
#import "KDStatusCell.h"
#import "MJPhotoBrowser.h"
#import "KDLike.h"
#import "MJPhoto.h"
#import "KDWebViewController.h"
#import "BOSSetting.h"
#import "XTPersonDetailViewController.h"

typedef enum {
    KDStatusDetailViewControllerActionSheetCommentHandles = 1000,
    KDStatusDetailViewControllerActionSheetForwardHandles,
    KDStatusDetailViewControllerActionSheetDeleteStatus,
    KDStatusDetailViewControllerActionSheetDelectComment
}KDStatusDetailViewControllerActionSheetType;

typedef enum {
    KDStatusDetailViewHandlerProfile,
    KDStatusDetailViewHandlerTask,
    KDStatusDetailViewHandlerReply,
    KDStatusDetailViewHandlerDelete,
    KDStatusDetailViewHandlerCopy,
    KDStatusDetailViewHandlerForward,
    KDStatusDetailViewHandlerDetail,
    KDStatusDetailViewHandlerCancel
}KDStatusDetailViewHandlerType;

#define COMMENT_FLAG  (1)
#define FORWARD_FLAG   (0)
#define LIKER_FLAG    (2)

NSString * const KDNotificationInboxStatusReset = @"KDNotificationInboxStatusReset";

@interface KDStatusDetailViewHandler : NSObject

@property (nonatomic, assign) KDStatusDetailViewHandlerType handlerType;
@property (nonatomic, copy)   NSString *title;


+ (KDStatusDetailViewHandler *)handlerWithType:(KDStatusDetailViewHandlerType)type title:(NSString *)title;

@end

@implementation KDStatusDetailViewHandler

@synthesize handlerType, title;

- (void)dealloc
{
    //KD_RELEASE_SAFELY(title);
    //[super dealloc];
}

+ (KDStatusDetailViewHandler *)handlerWithType:(KDStatusDetailViewHandlerType)type title:(NSString *)title {
    KDStatusDetailViewHandler *handler = [[KDStatusDetailViewHandler alloc] init] ;//autorelease];
    handler.handlerType = type;
    handler.title = title;
    
    return handler;
}

@end

@interface KDStatusDetailViewController () <KDVideoPlayerManagerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy)   NSString *statusId;
@property (nonatomic, retain) UIActivityIndicatorView *activityindicatorView;
@property (nonatomic, retain) UILabel *sourceLabel;
@property (nonatomic, retain) NSMutableArray *toolBarItems;
//@property (nonatomic, retain) NSMutableArray *actionSheetItems;
@property (nonatomic, retain) KDStatusDataset *commentDataset;
@property (nonatomic, retain) KDStatusDataset *forwardDataset;
@property (nonatomic, retain) NSMutableArray  *likers;
@property (nonatomic, retain) NSCache *cellCache;

//status有任何更新都应该调用此方法
- (void)statusUpdate;
- (void)setUpToolBar;

- (void)showTipsOrNot;

- (void)fetchCommentsForStatus;
- (void)fetchForwardsForStatus;
- (void)fetchStatusById;
- (void)fetchReplyAndForwardCountForStatus:(KDStatus *)inStatus;
- (void)fetchUserProfile;
//- (void)destroyCurrentStatus;
- (void)destroySelectedComment;
- (void)refreshCurrentStatus;

- (void)getContentForCurrentStatus;

- (void)clickedStatusCell;
- (void)refreshKDRefreshTableViewSideView;
- (NSString *)titleForHandler:(KDStatusDetailViewHandlerType)handler;
- (NSArray *)currentHandlers;
- (void)replyStatus;
- (void)deleteCurrentStatus;
@end

@implementation KDStatusDetailViewController

@synthesize status = status_;
@synthesize statusId = statusId_;
@synthesize activityindicatorView = activityindicatorView_;
@synthesize sourceLabel = sourceLabel_;
@synthesize toolBarItems = toolBarItems_;
//@synthesize actionSheetItems = actionSheetItems_;
@synthesize commentDataset = commentDataset_;
@synthesize forwardDataset = forwardDataset_;
@synthesize likers = likers_;
@synthesize cellCache = cellCache_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = ASLocalizedString(@"KDVoteViewController_navigationItem_title");
        
        statusDetailViewControllerFlags_.initializedWithStatus = 0;
        statusDetailViewControllerFlags_.initializedWithStatusId = 0;
        statusDetailViewControllerFlags_.initializedFromFroward = 0;
        statusDetailViewControllerFlags_.loadingComments = 0;
        statusDetailViewControllerFlags_.loadingForwards = 0;
        statusDetailViewControllerFlags_.loadingLikers = 0;
        statusDetailViewControllerFlags_.commentsHasMore = 1;
        statusDetailViewControllerFlags_.forwardsHasMore = 1;
        statusDetailViewControllerFlags_.likersHasMore = 1;
        statusDetailViewControllerFlags_.showingComments = 1;
        statusDetailViewControllerFlags_.isRefreshing = 0;
        statusDetailViewControllerFlags_.dismissed = 0;
        
        pageCursorForComments_ = 0;
        pageCursorForForwards_ = 0;
        pageCursorForLikers_   = 1;
        
        comments_ = nil;
        forwards_ = nil;
        likers_   = nil;
        statusId_ = nil;
        inboxId_  = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusAttrUpdate:) name:kKDStatusAttributionShouledUpdated object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToTaskDetail:) name:@"KDTaskDetailViewStatusDisclosure" object:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldRefresh:) name:kKDStatusDetailShouldFresh object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldDelete:) name:kKDStatusShouldDeleted object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stautsUploadTaskFinished:) name:@"TaskFinished" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postingStatus:) name:kKDStatusOnPosting object:nil];
        
    }
    return self;
}

- (id)initWithStatus:(KDStatus *)status {
    self = [self initWithNibName:nil bundle:nil];
    
    if(self) {
        statusDetailViewControllerFlags_.initializedWithStatus = 1;
        
        self.status = status;
        
    }
    
    return self;
}


- (id)initWithStatus:(KDStatus *)status fromCommentOrForward:(BOOL)isComment {
    self = [self initWithStatus:status];
    
    if(self) {
        statusDetailViewControllerFlags_.initializedFromFroward = isComment ? 1 : 2;
        statusDetailViewControllerFlags_.showingComments = isComment ? 1 : 0;
    }
    
    return self;
}

- (id)initWithStatusID:(NSString *)statusID {
    self = [self initWithNibName:nil bundle:nil];
    if(self) {
        statusDetailViewControllerFlags_.initializedWithStatusId = 1;
        
        status_ = nil;
        
        self.statusId = statusID;
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    return self;
}

- (id)initWithStatusID:(NSString *)statusID fromCommentOrForward:(BOOL)isComment {
    self = [self initWithStatusID:statusID];
    
    if(self) {
        statusDetailViewControllerFlags_.initializedFromFroward = isComment ? 1 : 2;
        statusDetailViewControllerFlags_.showingComments = isComment ? 1 : 0;
    }
    
    return self;
}
- (id)initWithStatusID:(NSString *)statusID fromInbox:(NSString *)inboxId
{
    self = [self initWithStatusID:statusID];
    
    if(self) {
        statusDetailViewControllerFlags_.initializedFromFroward = 3;
        inboxId_ =inboxId;// retain];
    }
    
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    //[super dealloc];
    
    //预防内存泄漏
    tableView_.dataSource = nil;
    tableView_.delegate = nil;
    
    
    //    if(inboxId_)
    //KD_RELEASE_SAFELY(inboxId_);
    
    //KD_RELEASE_SAFELY(status_);
    //KD_RELEASE_SAFELY(sectionView_);
    
    //KD_RELEASE_SAFELY(cellCache_);
    
    //KD_RELEASE_SAFELY(comments_);
    //KD_RELEASE_SAFELY(forwards_);
    ////KD_RELEASE_SAFELY(likers_);
    
    //KD_RELEASE_SAFELY(commentDataset_);
    //KD_RELEASE_SAFELY(forwardDataset_);
    
    
    //KD_RELEASE_SAFELY(statusDetailView_);
    //KD_RELEASE_SAFELY(userProfileView_);
    //KD_RELEASE_SAFELY(userNameBtn_);
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(activityindicatorView_);
    //KD_RELEASE_SAFELY(sourceLabel_);
    //KD_RELEASE_SAFELY(toolBarItems_);
    ////KD_RELEASE_SAFELY(actionSheetItems_);
    //KD_RELEASE_SAFELY(actionMenuView_);
    
}


- (NSCache *)cellCache {
    if (!cellCache_) {
        cellCache_ = [[NSCache alloc] init];
        cellCache_.totalCostLimit = 1000; //设置上限
    }
    return cellCache_;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor kdBackgroundColor1];//RGBCOLOR(232, 232, 232); ;
    
    
    //需要减去 头部70 和底部44
    tableView_ = [[KDRefreshTableView alloc] initWithFrame:CGRectMake(6.0f, 0.0f, self.view.bounds.size.width-12, self.view.bounds.size.height - 46.0f) kdRefreshTableViewType:KDRefreshTableViewType_Footer];// autorelease];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView_.backgroundColor = [UIColor clearColor];
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView_.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView_];
    
    NSInteger selectedIndex = (statusDetailViewControllerFlags_.initializedFromFroward == 2) ? 1 : 0;
    sectionView_ = [[KDStatusRelativeContentSectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView_.bounds.size.width, 30.0f) selectedIndex:selectedIndex hideForward:status_ &&[status_ isGroup]];
    sectionView_.delegate = self;
    sectionView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self setUpNavigationBar];
    
    
    if(status_) {
        [self setUpToolBar];
        [self statusUpdate];
        
    }
}

- (void)setUpNavigationBar {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"navigationItem_more"];
    
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"navigationItem_more_press"] forState:UIControlStateHighlighted];
    [btn sizeToFit];
    // [btn setImageEdgeInsets:UIEdgeInsetsMake(0, titltWidth, 0, -titltWidth)];
    [btn addTarget:self action:@selector(rightBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:btn];// autorelease];
    NSArray *rightNavigationItems;
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];// autorelease];
    float width = kRightNegativeSpacerWidth;
    negativeSpacer.width = width - 5.f;
    rightNavigationItems =  @[negativeSpacer, rightItem];
    self.navigationItem.rightBarButtonItems = rightNavigationItems;
    //self.navigationControlle
}


- (void)rightBarButtonTapped:(id)sender {
    if (!status_) {
        return;
    }
    //配置actionsheet
    //    NSMutableArray *actionSheetItems = [[@[ASLocalizedString(@"转为任务"),!status_.favorited?ASLocalizedString(@"KDABActionTabBar_tips_1"):ASLocalizedString(@"KDABPersonDetailsViewController_tips_3"),[KDWeiboAppDelegate isLoginUserID:status_.author.userId]?ASLocalizedString(@"KDCommentCell_delete"):@"",ASLocalizedString(@"刷新"),ASLocalizedString(@"举报")] mutableCopy] autorelease];
    NSMutableArray *actionSheetItems = nil;
    if([[BOSSetting sharedSetting] allowMsgInnerMobileShare])
        actionSheetItems = [@[ASLocalizedString(@"KDDefaultViewControllerContext_to_task"),!status_.favorited?ASLocalizedString(@"KDABActionTabBar_tips_1"):ASLocalizedString(@"KDABPersonDetailsViewController_cancel"),[KDWeiboAppDelegate isLoginUserID:status_.author.userId]?ASLocalizedString(@"KDCommentCell_delete"):@"",ASLocalizedString(@"KDSubscribeViewController_Refresh")] mutableCopy];// autorelease];
    else
        actionSheetItems = [@[!status_.favorited?ASLocalizedString(@"KDABActionTabBar_tips_1"):ASLocalizedString(@"KDABPersonDetailsViewController_cancel"),[KDWeiboAppDelegate isLoginUserID:status_.author.userId]?ASLocalizedString(@"KDCommentCell_delete"):@"",ASLocalizedString(@"KDSubscribeViewController_Refresh")] mutableCopy];// autorelease];
    
    if(![status_ isGroup]) {
        [actionSheetItems insertObject:ASLocalizedString(@"KDDefaultViewControllerContext_share_conversation")atIndex:1];
    }
    [[KDDefaultViewControllerContext defaultViewControllerContext] showActionSheetByStatus:status_ actionSheetItems:actionSheetItems];
}

//- (void)viewDidUnload {
//    tableView_ = nil;
//    //KD_RELEASE_SAFELY(sectionView_);
//
//    //KD_RELEASE_SAFELY(userProfileView_);
//    //KD_RELEASE_SAFELY(statusDetailView_);
//
//    actionMenuView_ = nil;
//    userNameBtn_ = nil;
//
//
//    [super viewDidUnload];
//}

- (void)viewControllerWillDismiss {
    statusDetailViewControllerFlags_.dismissed = 1;
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BOOL isTempStatus = [status_.statusId hasPrefix:@"temp_"];
    if(statusDetailViewControllerFlags_.initializedWithStatus == 1 && !isTempStatus) {
        statusDetailViewControllerFlags_.initializedWithStatus = 0;
        
        [self getContentForCurrentStatus];
    }else if(statusDetailViewControllerFlags_.initializedWithStatusId == 1) {
        statusDetailViewControllerFlags_.initializedWithStatusId = 0;
        
        [self fetchStatusById];
    }
}

- (void)statusUpdate {
    if(!userProfileView_) {
        userProfileView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width - 20, 45.0f)];
        userProfileView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        userProfileView_.backgroundColor = [UIColor clearColor];
        
        avatarView_ = [KDUserAvatarView avatarView];// retain];
        avatarView_.frame = CGRectMake(8.0f, 8.0f, 34.0f, 34.0f);
        [userProfileView_ addSubview:avatarView_];
        [avatarView_ addTarget:self action:@selector(didTapOnAvatar:) forControlEvents:UIControlEventTouchUpInside];
        
        userNameBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
        [userNameBtn_ setFrame:CGRectMake(CGRectGetMaxX(avatarView_.frame) + 15, CGRectGetMinY(avatarView_.frame)-2, 200.0f, 20)];
        [userNameBtn_ addTarget:self action:@selector(didTapOnAvatar:) forControlEvents:UIControlEventTouchUpInside];
        
        userNameBtn_.backgroundColor = [UIColor clearColor];
        userNameBtn_.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [userNameBtn_ setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [userProfileView_ addSubview:userNameBtn_];
        
        sourceLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(userNameBtn_.frame), CGRectGetMaxY(userNameBtn_.frame) +10, 200, 12)];
        sourceLabel_.font = [UIFont systemFontOfSize:12.0f];
        sourceLabel_.textColor = RGBACOLOR(136, 136, 136, 136);
        sourceLabel_.backgroundColor = [UIColor clearColor];
        [userProfileView_ addSubview:sourceLabel_];
        
    }
    
    avatarView_.avatarDataSource = status_.author;
    if(!avatarView_.hasAvatar)
        [avatarView_ setLoadAvatar:YES];
    
    [userNameBtn_ setTitle:status_.author.screenName forState:UIControlStateNormal];
    UILabel *label = [[UILabel alloc] init ];// autorelease];
    label.font = [UIFont systemFontOfSize:16.0f];
    label.text = status_.author.screenName;
    [label sizeToFit];
    
    CGRect frame  = userNameBtn_.bounds;
    frame.size.width = fminf(label.frame.size.width, 180.0f);
    frame.size.height = 20;
    frame.origin.x = CGRectGetMaxX(avatarView_.frame) + 9;
    frame.origin.y = CGRectGetMinY(avatarView_.frame)-2;
    userNameBtn_.frame = frame;
    
    
    sourceLabel_.text = [NSString stringWithFormat:ASLocalizedString(@"KDStatusDetailViewController_sourceLabel_text"),[status_ createdAtDateAsString],status_.source];
    
    frame = sourceLabel_.frame;
    //frame = CGRectGetMinX(userNameBtn_.frame), CGRectGetMaxY(userNameBtn_.frame) +10, 200, 12);
    frame.origin.x =  CGRectGetMinX(userNameBtn_.frame);
    frame.origin.y = CGRectGetMaxY(userNameBtn_.frame) +5;
    sourceLabel_.frame = frame;
    
    if(!statusDetailView_) {
        statusDetailView_ = [[KDStatusDetailView alloc] initWithFrame:CGRectMake(0.0f, userProfileView_.frame.size.height, self.view.bounds.size.width -16, 0.0f)];
        statusDetailView_.delegate = self;
        statusDetailView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    statusDetailView_.status = status_;
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, statusDetailView_.frame.size.height + userProfileView_.frame.size.height+20)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    frame = tableHeaderView.bounds;
    frame.origin.y = 10;
    frame.size.height-=20;
    
    UIView *background = [[UIView alloc] initWithFrame:frame];
    background.backgroundColor = [UIColor kdBackgroundColor2];//MESSAGE_CT_COLOR;
    CALayer * layer = [background layer];
    layer.borderColor = [UIColor kdBackgroundColor2].CGColor;
    layer.borderWidth = 0.5;
    
    [tableHeaderView addSubview:background];
    //    [background release];
    background.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    frame = userProfileView_.frame;
    frame.size.width = background.bounds.size.width;
    userProfileView_.frame = frame;
    frame = statusDetailView_.bounds;
    frame.origin.y = CGRectGetMaxY(userProfileView_.frame);
    frame.size.width = background.bounds.size.width;
    statusDetailView_.frame = frame;
    
    [background addSubview:userProfileView_];
    [background addSubview:statusDetailView_];
    
    
    tableHeaderView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    tableView_.tableHeaderView = tableHeaderView;
    //    [tableHeaderView release];
    
    [sectionView_ updateWithStatus:status_];
    
    if(statusDetailViewControllerFlags_.initializedFromFroward == 1 || statusDetailViewControllerFlags_.initializedFromFroward == 2) {
        [tableView_ setContentOffset:CGPointMake(0.0f, tableView_.tableHeaderView.frame.size.height-64)];
    }
    
    [self freshLiked];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/******************************************Private Methods******************************************/


- (void)setUpToolBar {
    if(!actionMenuView_) {
        NSDictionary *forwardItem = @{@"title":ASLocalizedString(@"KDStatusDetailViewController_Forward"),@"image":[UIImage imageNamed:@"status_detail_forward.png"]};
        NSDictionary *commentItem = @{@"title":ASLocalizedString(@"DraftTableViewCell_tips_4"),@"image":[UIImage imageNamed:@"status_detail_comment"]};
        NSDictionary *likeItem = @{@"title":ASLocalizedString(@"KDStatusDetailViewController_Like"),@"image": [UIImage imageNamed:@"status_detail_like"]};
        // NSDictionary *taskItem = @{@"title":ASLocalizedString(@"转为任务"),@"image":[UIImage imageNamed:@"tool_bar_task.png"]};
        // NSDictionary *deleteItem = @{@"title":ASLocalizedString(@"KDCommentCell_delete")};
        // NSDictionary *favoriteItem = @{@"title":ASLocalizedString(@"KDABActionTabBar_tips_1")};
        //NSDictionary *reportItem = @{@"title":ASLocalizedString(@"举报")};
        
        //zgbin:客户要求屏蔽“转发”。2018.03.27
        self.toolBarItems = [NSMutableArray arrayWithObjects:/*forwardItem,*/commentItem,likeItem, nil];
        //end
        
        //       / self.actionSheetItems = [NSMutableArray arrayWithObjects:taskItem,deleteItem,favoriteItem,reportItem,nil];
        
        if (status_.isPrivate || [status_ isKindOfClass:[KDGroupStatus class]] ||[status_ isGroup]) {
            //
            [self.toolBarItems removeObject:forwardItem];
        }
        
        //        if ([KDWeiboAppDelegate isLoginUserID:status_.author.userId ]) { //非本人的微博不能够删除
        //            [self.actionSheetItems removeObject:deleteItem];
        //        }
        //
        CGRect frame = CGRectMake(0.0, self.view.bounds.size.height - 46.0, self.view.bounds.size.width, 46.0);
        actionMenuView_ = [[KDMenuView alloc] initWithFrame:frame delegate:self images:self.toolBarItems];
        actionMenuView_.offSetY = 2.f;
        //            UIImage *image =[UIImage stretchableImageWithImageName:@"bottom_bg.png" resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5)];
        //            [actionMenuView_ setBackgroundImage:image];
        actionMenuView_.backgroundColor = [UIColor kdBackgroundColor2];
        actionMenuView_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:actionMenuView_];
        
    }
}


- (void)freshLiked {
    KDMenuItem *likeItem = [actionMenuView_ menuItembyTitle:ASLocalizedString(@"KDStatusDetailViewController_Like")];
    if (likeItem) {
        [(UIButton *)(likeItem.customView) setSelected:status_.liked && status_.likedCount >0];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)home {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showUserProfile:(id)sender {
    //TODO:swith User to KDUser in class ProfileViewController
    //    ProfileViewController *pvc = [[ProfileViewController alloc] initWithUser:status_.author];
    //    [self.navigationController pushViewController:pvc animated:YES];
    //    [pvc release];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:status_.author sender:sender];
}

- (void)showTipsOrNot {
    UILabel *infoLabel = (UILabel *)[placeHolderCell_ viewWithTag:' il '];
    if(!infoLabel) {
        infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, placeHolderCell_.bounds.size.width, 30)];
        
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.textColor = RGBCOLOR(200, 200, 200);
        infoLabel.font = [UIFont systemFontOfSize:15.0];
        infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        infoLabel.textAlignment = NSTextAlignmentCenter;
        
        infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        infoLabel.tag = ' il ';
        [placeHolderCell_ addSubview:infoLabel];
        //        [infoLabel release];
    }
    UIImageView * tipIconImageView = (UIImageView *)[placeHolderCell_ viewWithTag:234];
    if (!tipIconImageView) {
        tipIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 57, 57)];
        [placeHolderCell_ addSubview:tipIconImageView];
        tipIconImageView.tag = 234;
        //        [tipIconImageView release];
    }
    tipIconImageView.center = CGPointMake(CGRectGetMidX(placeHolderCell_.bounds), 90);
    tipIconImageView.image = nil;
    //判断条件：1、当有回复，而且回复已经加载了一部分的时候（转发同理），placeHolderCell什么也不显示；
    //        2、其余情况都需要显示某种信息；
    
    if(((statusDetailViewControllerFlags_.showingComments == 1) && commentDataset_ && [commentDataset_ count] > 0) || ((statusDetailViewControllerFlags_.showingComments == 0) && forwardDataset_ && [forwardDataset_ count] > 0)) {
        infoLabel.text = nil;
    } else {
        if(statusDetailViewControllerFlags_.showingComments == 1) {
            if(statusDetailViewControllerFlags_.loadingComments == 1)
                infoLabel.text = ASLocalizedString(@"LOADING_COMMENTS");
            else if(status_.commentsCount <= 0) {
                infoLabel.text = ASLocalizedString(@"KWIStatusVCtrl_NoReply");
                tipIconImageView.image = [UIImage imageNamed:@"status_detail_no_comment"];
            }
            else
                infoLabel.text = ASLocalizedString(@"NO_Data_up_Refresh");
        } else if(statusDetailViewControllerFlags_.showingComments == 0){
            if(statusDetailViewControllerFlags_.loadingForwards == 1)
                infoLabel.text = ASLocalizedString(@"LOADING_FORWARDS");
            else if(status_.forwardsCount <= 0) {
                infoLabel.text = ASLocalizedString(@"KWIStatusVCtrl_NotForward");
                tipIconImageView.image = [UIImage imageNamed:@"status_detail_no_forward"];
            }else
                infoLabel.text = ASLocalizedString(@"NO_Data_up_Refresh");
        }else {
            if(statusDetailViewControllerFlags_.loadingLikers == 1) {
                infoLabel.text = ASLocalizedString(@"KDStatusDetailViewController_loading");
            }else if(likers_.count == 0) {
                infoLabel.text = ASLocalizedString(@"KDStatusDetailViewController_NoLike");
                tipIconImageView.image = [UIImage imageNamed:@"status_detail_like"];
            }else if(likers_.count > 0){
                infoLabel.text = @"";
            }
            else {
                infoLabel.text = ASLocalizedString(@"NO_Data_up_Refresh");
            }
        }
    }
    if (tipIconImageView.image && infoLabel.text) {
        infoLabel.frame = CGRectOffset(infoLabel.bounds, 0, CGRectGetMaxY(tipIconImageView.frame));
    }else if (infoLabel.text) {
        infoLabel.frame = CGRectOffset(infoLabel.bounds, 0, 70);
    }
    
}

- (void)clickedStatusCell {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = (statusDetailViewControllerFlags_.showingComments == 1) ? KDStatusDetailViewControllerActionSheetCommentHandles : KDStatusDetailViewControllerActionSheetForwardHandles;
    
    NSArray *currentHandlers = [self currentHandlers];
    for(KDStatusDetailViewHandler *handler in currentHandlers) {
        [actionSheet addButtonWithTitle:handler.title];
        if(handler.handlerType == KDStatusDetailViewHandlerDelete)
            actionSheet.destructiveButtonIndex = [currentHandlers indexOfObject:handler];
        if(handler.handlerType == KDStatusDetailViewHandlerCancel)
            actionSheet.cancelButtonIndex = [currentHandlers indexOfObject:handler];
    }
    
    [actionSheet showInView:self.view];
    //    [actionSheet release];
}

- (void)getContentForCurrentStatus {
    if(statusDetailViewControllerFlags_.showingComments == 1)
        [self fetchCommentsForStatus];
    else if(statusDetailViewControllerFlags_.showingComments == 0) {
        [self fetchForwardsForStatus];
    }else {
        [self fetchLikersForStatus];
    }
    
    [tableView_ reloadData];
    
    [self fetchReplyAndForwardCountForStatus:status_];
    
    if([status_ hasForwardedStatus])
        [self fetchReplyAndForwardCountForStatus:status_.forwardedStatus];
    
    if(KD_IS_BLANK_STR(status_.author.jobTitle) && KD_IS_BLANK_STR(status_.author.department)) {
        [self fetchUserProfile];
    }
}

- (NSString *)titleForHandler:(KDStatusDetailViewHandlerType)handler {
    //TODO:
    NSString *key = nil;
    switch (handler) {
        case KDStatusDetailViewHandlerProfile:
            key = @"KD_STATUS_DETAIL_VIEW_PROFILE";
            break;
        case KDStatusDetailViewHandlerTask:
            key = ASLocalizedString(@"KDStatusDetailViewController_Task");
            break;
        case KDStatusDetailViewHandlerReply:
            key = @"KD_STATUS_DETAIL_VIEW_REPLY";
            break;
        case KDStatusDetailViewHandlerDelete:
            key = @"KD_STATUS_DETAIL_VIEW_DELETE";
            break;
        case KDStatusDetailViewHandlerDetail:
            key = @"KD_STATUS_DETAIL_VIEW_DETAIL";
            break;
        case KDStatusDetailViewHandlerCopy:
            key = @"KD_STATUS_DETAIL_VIEW_COPY";
            break;
        case KDStatusDetailViewHandlerForward:
            key = @"KD_STATUS_DETAIL_VIEW_FORWARD";
            break;
        case KDStatusDetailViewHandlerCancel:
            key = @"KD_STATUS_DETAIL_VIEW_CANCEL";
            break;
        default:
            break;
    }
    
    return NSLocalizedString(key, @"");
}

- (BOOL)isMyStatus {
    return [[KDManagerContext globalManagerContext].userManager isCurrentUserId:status_.author.userId];
}

- (BOOL)isNotMyStatusButMyComment {
    return [[KDManagerContext globalManagerContext].userManager isCurrentUserId:selectedStatus_.author.userId];
}


- (NSArray *)currentHandlers {
    NSMutableArray *handlers = [NSMutableArray arrayWithCapacity:4];
    
#define HANDLER_ADD_EXECUTOR(type) [handlers addObject:[KDStatusDetailViewHandler handlerWithType:(type) title:[self titleForHandler:(type)]]]
    
    if(statusDetailViewControllerFlags_.showingComments == 1) {
        //如果正在发送或者发送失败
        
        if (selectedStatus_.sendingState != KDStatusSendingStateFailed &&
            selectedStatus_.sendingState != KDStatusSendingStateProcessing) {
            
            if([[BOSSetting sharedSetting] allowMsgInnerMobileShare])
                HANDLER_ADD_EXECUTOR(KDStatusDetailViewHandlerTask);
            HANDLER_ADD_EXECUTOR(KDStatusDetailViewHandlerReply);
        }
        
        if([[BOSSetting sharedSetting] allowMsgInnerMobileShare])
            HANDLER_ADD_EXECUTOR(KDStatusDetailViewHandlerCopy);
        HANDLER_ADD_EXECUTOR(KDStatusDetailViewHandlerProfile);
        if([self isMyStatus] || [self isNotMyStatusButMyComment]) {
            HANDLER_ADD_EXECUTOR(KDStatusDetailViewHandlerDelete);
        }
    }else {
        HANDLER_ADD_EXECUTOR(KDStatusDetailViewHandlerReply);
        HANDLER_ADD_EXECUTOR(KDStatusDetailViewHandlerForward);
        HANDLER_ADD_EXECUTOR(KDStatusDetailViewHandlerDetail);
    }
    
    //    [handlers addObject:[KDStatusDetailViewHandler handlerWithType:KDStatusDetailViewHandlerCancel title:[self titleForHandler:KDStatusDetailViewHandlerCancel]]];
    HANDLER_ADD_EXECUTOR(KDStatusDetailViewHandlerCancel);
    
    return handlers;
}

- (void)destroyComment {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:ASLocalizedString(@"Global_Cancel")
                                               destructiveButtonTitle:ASLocalizedString(@"KD_STATUS_DETAIL_VIEW_CONFIRM")
                                                    otherButtonTitles:nil];
    actionSheet.tag = KDStatusDetailViewControllerActionSheetDelectComment;
    
    [actionSheet showInView:self.view];
    //    [actionSheet release];
}



- (void)forwardStatus:(KDStatus *)status {
    if (!status) {
        return;
    }
    
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeForwardStatus];
    draft.commentForStatusId = status.statusId;
    
    if([status hasForwardedStatus]) {
        draft.commentForStatusId = status.forwardedStatus.statusId;
        
        NSString *text = nil;
        NSString *sourceStatusContentText = nil;
        if (status.forwardedStatus.author != nil) {
            text = [NSString stringWithFormat:@"//@%@:%@", status.author.username, status.text];
        }
        else
        {
            text = [NSString stringWithFormat:@"//@%@", status.text];
        }
        draft.content = text;
        
        if (sourceStatusContentText != nil) {
            sourceStatusContentText = [NSString stringWithFormat:@"%@:%@", status.forwardedStatus.author.username, status.forwardedStatus.text];
        }
        else
        {
            sourceStatusContentText = status.forwardedStatus.text;
        }
        draft.originalStatusContent = sourceStatusContentText;
    } else
        draft.originalStatusContent = [NSString stringWithFormat:@"%@:%@", status.author.screenName, status.text];
    
    if([status isKindOfClass:[KDGroupStatus class]]) {
        draft.groupId = status.groupId;
        draft.groupName = [status.groupName copy];// autorelease];
    }
    
    pvc.draft = draft;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc];// autorelease];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)openStatusEditor:(KDDraftType)type status:(KDStatus *)status comment:(KDStatus *)commentStatus {
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    
    KDDraft *draft = [KDDraft draftWithType:type];
    draft.commentForStatusId = status.statusId;
    if (commentStatus) {
        draft.commentForCommentId = commentStatus.statusId;
        draft.replyScreenName = commentStatus.author.screenName;
        draft.originalStatusContent = [NSString stringWithFormat:ASLocalizedString(@"回复%@的评论: %@"), commentStatus.author.screenName, commentStatus.text];
    }else {
        draft.originalStatusContent = [NSString stringWithFormat:@"%@: %@", status.author.screenName, status.text];
        
    }
    
    //    //[draft setProperty:status forKey:@"commentedStatus"];
    ////    if(commentId != nil) {
    ////        draft.commentForCommentId = commentId;
    ///        for(KDStatus *comment in commentDataset_.allStatuses) {
    //            if([commentId isEqualToString:comment.statusId]) {
    //
    //            }
    //        }
    //    }else {
    //        draft.originalStatusContent = [NSString stringWithFormat:@"%@: %@", status.author.screenName, status.text];
    //    }
    
    if(status.groupId && status.groupName) {
        draft.groupId = status.groupId;
        draft.groupName = status.groupName;
    }
    
    pvc.draft = draft;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc];// autorelease];
    [self presentViewController:nav animated:YES completion:nil];
}


/**
 *  点击toolbar 对应的操作，包含了友盟点击事件
 */

- (void)replyStatus {
    //[self openStatusEditor:KDDraftTypeCommentForStatus status:status_ commentId:nil];
}

- (void)forward {
    [self forwardStatus:status_];
}

- (void)createTask {
    [self goToTaskCreate:status_ type:KDCreateTaskReferTypeStatus];
}

- (void)like {
    //[self toggleLiked];
}
- (void)deleteStatus {
    [self deleteCurrentStatus];
}

- (void)favorite {
    //    [self toggleFavorite];
}

- (void)refresh {
    [self refreshCurrentStatus];
}

- (void)deleteCurrentStatus {
    //    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"删除微博？")//                                                             delegate:self
    //                                                    cancelButtonTitle:NSLocalizedString(@"KD_STATUS_DETAIL_VIEW_CANCEL", @"")
    //                                               destructiveButtonTitle:NSLocalizedString(@"KD_STATUS_DETAIL_VIEW_CONFIRM", @"")
    //                                                    otherButtonTitles:nil];
    //    actionSheet.tag = KDStatusDetailViewControllerActionSheetDeleteStatus;
    //    [actionSheet showInView:self.view];
    //    [actionSheet release];
}

- (void)refreshKDRefreshTableViewSideView {
    if(statusDetailViewControllerFlags_.showingComments == 1)
        [tableView_ setBottomViewHidden:(statusDetailViewControllerFlags_.commentsHasMore == 0)];
    else if(statusDetailViewControllerFlags_.showingComments == 0)
        [tableView_ setBottomViewHidden:(statusDetailViewControllerFlags_.forwardsHasMore == 0)];
    else {
        [tableView_ setBottomViewHidden:(statusDetailViewControllerFlags_.likersHasMore == 0)];
    }
}

- (void)didFinishedLoading:(int)loadinContentFlag {
    if(loadinContentFlag == COMMENT_FLAG) {
        statusDetailViewControllerFlags_.loadingComments = 0;
    }else if(loadinContentFlag == FORWARD_FLAG) {
        statusDetailViewControllerFlags_.loadingForwards = 0;
    }else if(loadinContentFlag == LIKER_FLAG) {
        statusDetailViewControllerFlags_.loadingLikers = 0;
        
    }
    
    [tableView_ finishedLoadMore];
    [tableView_ reloadData];
    [self refreshKDRefreshTableViewSideView];
    
    if(statusDetailViewControllerFlags_.isRefreshing == 1) {
        statusDetailViewControllerFlags_.isRefreshing = 0;
        [self removeActivityAtRefresh];
        //[self hideActivityIndicator];
    }
    
}

- (void)goBack {
    UINavigationController *nav = (UINavigationController *)self.navigationController;
    NSArray *viewControllers = [nav viewControllers];
    if ([viewControllers indexOfObject:self] != 0) { // not root controller
        [nav popViewControllerAnimated:YES];
    }
}

/*************************************Data Fetch Methods*************************************/
- (void)fetchCommentsForStatus {
    if(statusDetailViewControllerFlags_.loadingComments == 1) return;
    
    statusDetailViewControllerFlags_.loadingComments = 1;
    
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"id" stringValue:status_.statusId]
      setParameter:@"count" stringValue:@"20"]
     setParameter:@"cursor" integerValue:pageCursorForComments_];
    
    __block KDStatusDetailViewController *sdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if(results != nil) {
                NSDictionary *info = (NSDictionary *)results;
                
                //                if (sdvc -> comments_ == nil) {
                //                    sdvc -> comments_ = [[NSMutableArray alloc] init];
                //                }
                
                
                NSArray *comments = [info objectForKey:@"comments"];
                NSInteger nextCursor = [info integerForKey:@"nextCursor"];
                
                if ([comments count] < 20 || nextCursor < sdvc -> pageCursorForComments_) {
                    (sdvc -> statusDetailViewControllerFlags_).commentsHasMore = 0;
                }
                
                sdvc -> pageCursorForComments_ = nextCursor;
                // [sdvc -> comments_ addObjectsFromArray:comments];
                for (KDStatus *status in comments) {
                    [self cellForStatus:status];
                }
                [sdvc.commentDataset  mergeStatuses:comments atHead:NO];
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:sdvc.view.window];
            }
        }
        
        [sdvc didFinishedLoading:COMMENT_FLAG];
        
        // release current view controller
        //        [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:commentsByCursor" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)fetchForwardsForStatus {
    if(statusDetailViewControllerFlags_.loadingForwards == 1) return;
    
    statusDetailViewControllerFlags_.loadingForwards = 1;
    
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"id" stringValue:status_.statusId]
      setParameter:@"count" stringValue:@"20"]
     setParameter:@"page" integerValue:pageCursorForForwards_];
    
    __block KDStatusDetailViewController *sdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                sdvc -> pageCursorForForwards_ ++;
                
                NSArray *forwards = (NSArray *)results;
                if ([forwards count] < 20) {
                    (sdvc -> statusDetailViewControllerFlags_).forwardsHasMore = 0;
                }
                
                //                if(sdvc -> forwards_ == nil) {
                //                    sdvc -> forwards_ = [[NSMutableArray alloc] initWithCapacity:20];
                //                }
                
                //[sdvc -> forwards_ addObjectsFromArray:forwards];
                for (KDStatus *status in forwards) {
                    [self cellForStatus:status];
                }
                [sdvc.forwardDataset mergeStatuses:forwards atHead:NO];
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:sdvc.view.window];
            }
        }
        
        [sdvc didFinishedLoading:FORWARD_FLAG];
        
        // release current view controller
        //        [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:forwards" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)fetchStatusById {
    KDQuery *query = [KDQuery queryWithName:@"id" value:statusId_];
    [query setProperty:statusId_ forKey:@"statusId"];
    
    if (statusDetailViewControllerFlags_.initializedFromFroward == 3 && inboxId_)
        [query setParameter:@"inboxid" stringValue:inboxId_];
    
    __block KDStatusDetailViewController *sdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if(results) {
                NSDictionary *info = results;
                
                BOOL isExist = [info boolForKey:@"isExist"];
                if (!isExist) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                        message:NSLocalizedString(@"KD_STATUS_DETAIL_VIEW_UNEXIST", @"")
                                                                       delegate:sdvc
                                                              cancelButtonTitle:ASLocalizedString(@"KD_STATUS_DETAIL_VIEW_CONFIRM")
                                                              otherButtonTitles:nil];
                    
                    [alertView show];
                    //                    [alertView release];
                    
                    // release current view controller
                    //                    [sdvc release];
                    
                    return;
                }
                
                KDStatus *status = [info objectForKey:@"status"];
                sdvc.status = status;
                
                [sdvc setUpToolBar];
                [sdvc statusUpdate];
                
                sdvc->sectionView_.hideForward = [status isGroup]; //是否隐藏转发。
                
                [MBProgressHUD hideHUDForView:sdvc.view animated:YES];
                
                [sdvc getContentForCurrentStatus];
                
                if (statusDetailViewControllerFlags_.initializedFromFroward == 3 && inboxId_)
                {
                    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
                        id<KDInboxDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] inboxDAO];
                        
                        [threadDAO updateInboxStatusWithStatusId:statusId_ database:fmdb];
                        return nil;
                    } completionBlock:^(id results){
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationInboxStatusReset object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"isSuccess",statusId_,@"statusId", nil]];
                    }];
                    
                    
                }
                
            }
            
        } else {
            if (![response isCancelled]) {
                if(response.statusCode == 400) {
                    [KDErrorDisplayView showErrorMessage:NSLocalizedString(@"STATUS_DID_DELETED", @"")
                                                  inView:sdvc.view.window];
                    
                } else {
                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                                  inView:sdvc.view.window];
                }
                
                [sdvc goBack];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationInboxStatusReset object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"isSuccess",statusId_,@"statusId", nil]];
        }
        
        // release current view controller
        //        [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:showById" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)fetchReplyAndForwardCountForStatus:(KDStatus *)inStatus {
    KDQuery *query = [KDQuery queryWithName:@"ids" value:inStatus.statusId];
    
    __block KDStatusDetailViewController *sdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if(results != nil) {
                NSArray *countList = results;
                if ([countList count] > 0) {
                    KDStatusCounts *statusCount = countList[0];
                    inStatus.forwardsCount = statusCount.forwardsCount;
                    inStatus.commentsCount = statusCount.commentsCount;
                    inStatus.likedCount = statusCount.likedCount;
                }
                
                if ([inStatus.statusId isEqualToString:(sdvc -> status_).forwardedStatus.statusId]) {
                    (sdvc -> statusDetailView_).showDigit = YES;
                }
                
                if (inStatus == sdvc -> status_) {
                    if (sdvc -> sectionView_) {
                        [sdvc -> sectionView_ updateWithStatus:inStatus];
                    }
                }
            }
            
        } else {
            if(![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:sdvc.view.window];
            }
            
            if([inStatus.statusId isEqualToString:(sdvc -> status_).forwardedStatus.statusId]) {
                (sdvc -> status_).forwardedStatus.forwardsCount = 0;
                (sdvc -> status_).forwardedStatus.commentsCount = 0;
                
                [sdvc -> statusDetailView_ setNeedsLayout];
            }
        }
        
        // release current view controller
        //        [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:counts" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)fetchUserProfile {
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:status_.author.userId];
    
    __block KDStatusDetailViewController *sdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if(results) {
                KDUser *user = (KDUser *)results;
                
                (sdvc -> avatarView_).avatarDataSource = user;
                if(!(sdvc -> avatarView_).hasAvatar)
                    [sdvc -> avatarView_ loadAvatar];
                
                [(sdvc -> userNameBtn_) setTitle:user.screenName forState:UIControlStateNormal];
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:sdvc.view.window];
            }
        }
        
        // release current view controller
        //        [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/users/:show" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)destroyCurrentStatusSuccess {
    
    NSArray *viewArray = self.navigationController.viewControllers;
    UIViewController *viewController = [viewArray objectAtIndex:[viewArray count]-2];
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        preViewController_ = [(UITabBarController *)viewController selectedViewController];
        
    }
    else {
        preViewController_ = viewController;
    }
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.type = @"suckEffect";
    
    [self.navigationController.view.layer addAnimation:animation forKey:@"removestatus"];
    [self.navigationController popViewControllerAnimated:NO];
    
}

#define LIKE_COUNT_PER_PAGE (20)
- (void)fetchLikersForStatus {
    if(statusDetailViewControllerFlags_.loadingLikers == 1) return;
    
    statusDetailViewControllerFlags_.loadingLikers = 1;
    
    KDQuery *query = [KDQuery queryWithName:@"ref_id" value:status_.statusId];
    [query setParameter:@"ref_type" stringValue:@"microblog"];
    [query setParameter:@"page" intValue:(int)pageCursorForLikers_];
    [query setParameter:@"count" intValue:LIKE_COUNT_PER_PAGE];
    
    __block KDStatusDetailViewController *sdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if([response isValidResponse]) {
            
            if(!sdvc.likers) {
                sdvc.likers = [NSMutableArray array];
            }else if(sdvc->pageCursorForLikers_ == 1) {
                [sdvc.likers removeAllObjects];
            }
            
            if(results) {
                NSArray *likeList = (NSArray *)results;
                
                //                [sectionView_ updateLikedCount:[likeList count]];
                if(likeList.count > 0) {
                    sdvc->pageCursorForLikers_++;
                    
                    [sdvc.likers addObjectsFromArray:likeList];
                    
                    if(likeList.count < LIKE_COUNT_PER_PAGE) {
                        sdvc->statusDetailViewControllerFlags_.likersHasMore = 0;
                    }else {
                        sdvc->statusDetailViewControllerFlags_.likersHasMore = 1;
                    }
                }
            }
        }else {
            if(![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:sdvc.view.window];
            }
        }
        
        [sdvc didFinishedLoading:LIKER_FLAG];
        //        [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/like/:getLikers" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

//- (void)destroyCurrentStatus {
//    KDQuery *query = [KDQuery queryWithName:@"id" value:status_.statusId];
//    [query setProperty:status_.statusId forKey:@"statusId"];
//
//    __block KDStatusDetailViewController *sdvc = [self retain];
//    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
//        if([response isValidResponse] && (sdvc -> statusDetailViewControllerFlags_).dismissed == 0) {
//            if ([(NSNumber *)results boolValue]) {
//                [sdvc destroyCurrentStatusSuccess];
//            }
//        } else {
//            if (![response isCancelled]) {
//                id result = [response responseAsJSONObject];
//                if (result) {
//                        NSString *message = [(NSDictionary *)result objectForKey:@"message"];
//                        NSRange range = [message rangeOfString:ASLocalizedString(@"微博已删除或不存在")];
//                        if (range.location != NSNotFound) {
//                            [sdvc destroyCurrentStatusSuccess];
//                            return ;
//                        }
//                    }
//                [KDErrorDisplayView showErrorMessage:NSLocalizedString(@"STATUSES_DESTORY_STATUS_DID_FAIL", @"")
//                                              inView:sdvc.view.window];
//            }
//        }
//
//        // release current view controller
//        [sdvc release];
//    };
//
//    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:destoryById" query:query
//                                 configBlock:nil completionBlock:completionBlock];
//}

- (void)destroySelectedComment {
    // 删除选中的评论
    NSUInteger deleteCommentIndex = [self.commentDataset indexOfStatus:selectedStatus_];
    
    KDQuery *query = [KDQuery queryWithName:@"id" value:selectedStatus_.statusId];
    [query setProperty:selectedStatus_.statusId forKey:@"commentId"];
    
    __block KDStatusDetailViewController *sdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse] && (sdvc -> statusDetailViewControllerFlags_).dismissed == 0) {
            if (results != nil && [(NSNumber *)results boolValue]) {
                id obj = [sdvc.commentDataset statusAtIndex:deleteCommentIndex];
                if (obj == sdvc -> selectedStatus_) {
                    [sdvc.cellCache removeObjectForKey:selectedStatus_.statusId];
                    [sdvc.commentDataset removeStatusAtIndex:(int)deleteCommentIndex];
                    [sdvc -> tableView_ reloadData];
                    
                    (sdvc -> status_).commentsCount = ((sdvc -> status_).commentsCount > 1) ? ((sdvc -> status_).commentsCount - 1) : 0;
                    if (sdvc -> sectionView_ == nil) {
                        [sdvc -> sectionView_ updateWithStatus:sdvc -> status_];
                    }
                }
            }
            
        } else {
            if (![response isCancelled]) {
                NSString *message = NSLocalizedString(@"COMMENTS_DESTORY_COMMENT_DID_FAIL", @"");
                [KDErrorDisplayView showErrorMessage:message inView:sdvc.view.window];
            }
        }
        
        // release current view controller
        //        [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:commentDestory" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

//- (void)toggleFavorite {
//    // 收藏 or 取消收藏
//    if(status_.favorited)
//        [self cancelFavorite];
//    else
//        [self createFavorite];
//}

//- (void)toggleLiked {
//    //[[KDStatusLikeActionHelper shareLikeActionHelper] handleLike:self.status];
//    [self showActivityOnToolBar:3];
//    KDLikeTask *task = [[KDLikeTask alloc ] init];
//    task.status = self.status;
//    [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:task entityId:self.status.statusId];
//    [task release];
//
//}

//- (void)createFavorite {
//    [actionMenuView_ setMenuEnabled:NO atIndex:0x02];
//
//    KDQuery *query = [KDQuery queryWithName:@"id" value:status_.statusId];
//     [self showActivityOnToolBar:5];
//    __block KDStatusDetailViewController *sdvc = [self retain];
//    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
//        [(sdvc -> actionMenuView_) setMenuEnabled:YES atIndex:0x02];
//
//        NSDictionary *info = results;
//        BOOL success = [[info objectForKey:@"success"] boolValue];
//        BOOL favorited = [[info objectForKey:@"favorited"] boolValue];
//
//        NSString *message = nil;
//        if (success) {
//            message = NSLocalizedString(@"FAVORITES_CREATED_SUCCESS", @"");
//            (sdvc -> status_).favorited = YES;
//
//        } else {
//            message = favorited ? NSLocalizedString(@"FAVORITES_FAVORITED_YET", @"")
//                                : NSLocalizedString(@"FAVORITES_CREATED_FAIL", @"");
//            (sdvc -> status_).favorited = favorited;
//        }
//
//        [sdvc freshFavorited];
//
//        [[KDNotificationView defaultMessageNotificationView] showInView:sdvc.view.window
//                                                                message:message
//                                                                   type:KDNotificationViewTypeNormal];
//
//        // release current view controller
//        [self removeActivityOnToolBar:5];
//        [sdvc release];
//    };
//
//    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/favorites/:create" query:query
//                                 configBlock:nil completionBlock:completionBlock];
//}

//- (void)cancelFavorite {
//    [actionMenuView_ setMenuEnabled:NO atIndex:0x02];
//
//    [self showActivityOnToolBar:5];
//    KDQuery *query = [KDQuery queryWithName:@"id" value:status_.statusId];
//    [query setProperty:status_.statusId forKey:@"entityId"];
//
//    __block KDStatusDetailViewController *sdvc = [self retain];
//    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
//        [sdvc -> actionMenuView_ setMenuEnabled:YES atIndex:0x02];
//
//        NSString *message = nil;
//        if([results boolValue]) {
//            (sdvc -> status_).favorited = NO;
//            message = NSLocalizedString(@"FAVORITES_DESTORYED_SUCCESS", @"");
//
//        } else {
//            message = NSLocalizedString(@"FAVORITES_DESTORYED_FAIL", @"");
//        }
//
//        [sdvc freshFavorited];
//        [[KDNotificationView defaultMessageNotificationView] showInView:sdvc.view.window
//                                                                message:message
//                                                                 type:KDNotificationViewTypeNormal];
//
//        [self removeActivityOnToolBar:5];
//        // release current view controller
//        [sdvc release];
//    };
//
//    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/favorites/:destoryById" query:query
//                                 configBlock:nil completionBlock:completionBlock];
//}


- (void)refreshCurrentStatus {
    if(statusDetailViewControllerFlags_.isRefreshing == 1) return;
    
    statusDetailViewControllerFlags_.isRefreshing = 1;
    [self showActivityAtRefresh];
    [self fetchReplyAndForwardCountForStatus:status_];
    
    if(status_.hasForwardedStatus)
        [self fetchReplyAndForwardCountForStatus:status_.forwardedStatus];
    
    if(statusDetailViewControllerFlags_.showingComments == 1) {
        pageCursorForComments_ = 0;
        //        if(comments_) {
        //            [comments_ removeAllObjects];
        //        }
        self.commentDataset = nil;
        [self fetchCommentsForStatus];
    }else if(statusDetailViewControllerFlags_.showingComments == 0) {
        pageCursorForForwards_ = 0;
        self.forwardDataset = nil;
        
        [self fetchForwardsForStatus];
    }else {
        pageCursorForLikers_ = 1;
        
        [self fetchLikersForStatus];
    }
}

#define KD_TAG_ACTIVITY_ACTIONVIEW  120
//@comment:
/*
 *  ------------------------------------------------------------
 *      myself   |   group   |    visibleCount    |    position
 *  ------------------------------------------------------------
 *        √      |    √      |          4         |       2
 *  ------------------------------------------------------------
 *        √      |    ×      |          5         |       3
 *  ------------------------------------------------------------
 *        ×      |    √      |          3         |       2
 *  ------------------------------------------------------------
 *        ×      |    ×      |          4         |       3
 *  ------------------------------------------------------------
 */


- (void)showActivityIndicator {
    if (!activityindicatorView_) {
        activityindicatorView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityindicatorView_.bounds = CGRectMake(0, 0, 80, 80);
    }
    [self.view addSubview:activityindicatorView_];
    activityindicatorView_.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [activityindicatorView_ startAnimating];
}

- (void)hideActivityIndicator {
    if (activityindicatorView_ && [activityindicatorView_ superview]) {
        [activityindicatorView_ removeFromSuperview];
        //KD_RELEASE_SAFELY(activityindicatorView_);
    }
}

- (void)showActivityOnToolBar:(NSInteger)index {
    if ([actionMenuView_ isMenuItemInToolBar:index]) {
        KDMenuItem *menuItem = [actionMenuView_.menuItems objectAtIndex:index];
        UIView *acView = [[UIView alloc] initWithFrame:menuItem.customView.frame];
        UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [acView addSubview:act];
        acView.backgroundColor = [UIColor whiteColor];
        act.center = CGPointMake(acView.bounds.size.width * 0.5f, acView.bounds.size.height * 0.5f);
        [act startAnimating];
        //        [act release];
        acView.tag = KD_TAG_ACTIVITY_ACTIONVIEW+index;
        
        [actionMenuView_ addSubview:acView];
        //        [acView release];
    }else  {
        [self showActivityIndicator];
    }
}

- (void)removeActivityOnToolBar:(NSInteger)index {
    UIView *acView = [actionMenuView_ viewWithTag:KD_TAG_ACTIVITY_ACTIONVIEW+index];
    if(acView) {
        for(UIView *view in [acView subviews]) {
            if([view isKindOfClass:[UIActivityIndicatorView class]])
                [(UIActivityIndicatorView *)view stopAnimating];
        }
        
        [acView removeFromSuperview];
    }
    [self hideActivityIndicator];
}

- (void)showActivityAtRefresh {
    [self showActivityOnToolBar:6];
    
}

- (void)removeActivityAtRefresh {
    [self removeActivityOnToolBar:6];
}

- (KDStatusDataset *)commentDataset {
    if(!commentDataset_) {
        commentDataset_ = [[KDStatusDataset alloc] init];
    }
    return commentDataset_;
}

- (KDStatusDataset *)forwardDataset {
    if (!forwardDataset_) {
        forwardDataset_ = [[KDStatusDataset alloc] init];
    }
    return forwardDataset_;
}

#pragma mark -
#pragma mark - Notification Handler


//微博的属性（转发数，评论数，赞，收藏）修改后，此通知调用
- (void)statusAttrUpdate:(NSNotification *)notification {
    KDStatus *status = [[notification userInfo] objectForKey:@"status"];
    if (status) {
        if ([status_.statusId isEqualToString:status.statusId]) {
            status_.likedCount = status.likedCount;
            status_.liked = status.liked;
            status_.forwardsCount = status.forwardsCount;
            status_.commentsCount = status.commentsCount;
            status_.favorited = status.favorited;
            [self refreshCurrentStatus];
        }else if ([status_ hasForwardedStatus] && [status.statusId isEqualToString:status_.forwardedStatus.statusId]) {
            status_.forwardedStatus.likedCount = status.likedCount;
            status_.forwardedStatus.liked = status.liked;
            status_.forwardedStatus.forwardsCount = status.forwardsCount;
            status_.forwardedStatus.commentsCount = status.commentsCount;
            status_.forwardedStatus.favorited = status.favorited;
            [self refreshCurrentStatus];
        }
    }
}


- (void)goToTaskDetail:(NSNotification *)notification {
    NSString *taskId = [[notification userInfo] objectForKey:@"taskId"];
    if (taskId) {
        KDTaskDiscussViewController *discussViewController = [[KDTaskDiscussViewController alloc] initWithTaskId:taskId];
        [self.navigationController pushViewController:discussViewController animated:YES];
        //        [discussViewController release];
    }
}


- (void)shouldRefresh:(NSNotification *)notification {
    DLog(@"refresh....");
    KDStatus *status = [notification.userInfo objectForKey:@"status"];
    if (status_ == status) {
        [self refresh];
    }
}

- (void)shouldDelete:(NSNotification *)notification {
    //    KDStatus *status = [notification.userInfo objectForKey:@"status"];
    //    if (status_ == status) {
    //        [self destroyCurrentStatusSuccess];
    //    }
    
    NSArray *statues = [notification.userInfo objectForKey:@"status"];// retain];
    KDStatus *theStatus = nil;
    for (KDStatus *aStatus in statues) {
        if (aStatus == status_) {
            [self destroyCurrentStatusSuccess];
            //            [statues release];
            return;
        }else if ([aStatus isKindOfClass:[KDCommentStatus class]]) {
            if (self.commentDataset) {
                theStatus = [self.commentDataset statusById:aStatus.statusId];
                if (theStatus) {
                    [self.cellCache removeObjectForKey:theStatus.statusId];
                    [self.commentDataset removeStatus:theStatus];
                    
                }
            }
        }
    }
    [tableView_ reloadData];
    
    //    [statues release];
    
    
}

- (void)stautsUploadTaskFinished:(NSNotification *)notfication {
    
    KDStatusUploadTask *task = [notfication.userInfo objectForKey:@"task"];
    if (!task) {
        return;
    }
    [self fetchReplyAndForwardCountForStatus:status_];
    
    if ([task isKindOfClass:[KDStatusUploadTask class]]) {
        if (statusDetailViewControllerFlags_.showingComments != 1) {
            return;
        }
        
        KDStatus *originStatus = task.entity;
        if (!originStatus ||![originStatus isKindOfClass:[KDCommentStatus class]]) {
            return;
        }
        
        if ([task isKindOfClass:[KDStatusUploadTask class]]) {
            
            KDStatus *status = [self.commentDataset statusById:originStatus.statusId];
            if ([task isSuccess]) {
                if (status) {
                    [self.cellCache removeObjectForKey:status.statusId]; //把cellCache 删除，才能重新创建cell
                    [self.commentDataset replaceStatus:status withStatus:task.fetchedStatus]; //发送成功的status 替换原来的
                }
            }else { //失败
                if (status) {
                    [self.cellCache  removeObjectForKey:status.statusId];
                    [self.commentDataset mergeStatuses:@[originStatus] atHead:YES];
                }
                
            }
            [tableView_ reloadData];
        }
        
    } //微博的uploadtask
    else if ([task isKindOfClass:[KDLikeTask class]]) {
        [self freshLiked];
        
        pageCursorForLikers_ = 1;
        [self fetchLikersForStatus];
    }
    
    
}


- (void)postingStatus:(NSNotification *)notfication {
    KDStatus *status = [notfication.userInfo objectForKey:@"status"];
    if (statusDetailViewControllerFlags_.showingComments == 1 &&
        [status isKindOfClass:[KDCommentStatus class]]&&
        ([status.replyStatusId isEqualToString:status_.statusId]
         ||[[[(KDCommentStatus *)status status] statusId] isEqualToString:status_.statusId])) {
            //如果正在发送的status 回复的是当前的status 或者回复的是当前微博下得某条回复.
            
            [self.commentDataset  mergeStatuses:@[status] atHead:YES];
            [tableView_ reloadData];
        }
}


/*************************************Delegate Methods*************************************/
#pragma mark -
#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return sectionView_;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    if(statusDetailViewControllerFlags_.showingComments == 1)
        rows = [self.commentDataset count];
    else if(statusDetailViewControllerFlags_.showingComments == 0)
        rows = [self.forwardDataset count];
    else
        rows = self.likers.count;
    
    return rows + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rows = [self tableView:tableView_ numberOfRowsInSection:indexPath.section];
    if(indexPath.row == rows - 1) {
        CGFloat totalHeight = 0.0f;
        for(NSInteger row = 0 ; row < indexPath.row; row++) {
            totalHeight += [self tableView:tableView_ heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:indexPath.section]];
        }
        
        return MAX(self.view.frame.size.height - 30.0f - 44.0f - totalHeight, 0.0f);
    }
    
    if(statusDetailViewControllerFlags_.showingComments == 2) {
        return 60.0f;
    }
    
    //return cell.frame.size.height;
    KDStatus *status = nil;
    if(statusDetailViewControllerFlags_.showingComments == 1){
        // rows = [comments_ count];
        status = [self.commentDataset statusAtIndex:indexPath.row];
    }else {
        status = [self.forwardDataset statusAtIndex:indexPath.row];
    }
    
    return [KDCommentCellLayouter layouter:status constrainedWidth:tableView.bounds.size.width - 54].frame.size.height;
}

//static NSString *identifier = @"CommentCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rows = [self tableView:tableView_ numberOfRowsInSection:indexPath.section];
    if(indexPath.row == rows - 1) {
        UIView *backgroundView = nil;
        if(!placeHolderCell_) {
            placeHolderCell_ = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"placeHolder"];// autorelease];
            
            placeHolderCell_.selectionStyle = UITableViewCellSelectionStyleNone;
            placeHolderCell_.backgroundColor = [UIColor clearColor];
            
            // backgroundView = [UIView strokeTypeSeparatorBgView];
            // backgroundView =[[[UIImageView alloc] initWithImage:[UIImage stretchableImageWithImageName:@"status_detail_comment_cell_bg" resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5)]] autorelease];
            backgroundView = [[UIImageView alloc] init];
            backgroundView.backgroundColor = [UIColor kdBackgroundColor1];
            backgroundView.tag = 100;
            backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            backgroundView.frame = CGRectMake(0, 0, placeHolderCell_.bounds.size.width, 185);
            backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
            [placeHolderCell_ addSubview:backgroundView];
        }
        if (rows >1) {
            backgroundView = [placeHolderCell_ viewWithTag:100];
            if (backgroundView) {
                backgroundView.hidden = YES;
            }
        }
        
        [self showTipsOrNot];
        
        return placeHolderCell_;
        
    }
    
    
    if(statusDetailViewControllerFlags_.showingComments == 2) {
        //TODO:like cell
        static NSString *CellIdentifier = @"NetworkUserCell";
        
        KDNetworkUserCell* cell = (KDNetworkUserCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[KDNetworkUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;//autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero] ;//autorelease];
            selectBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            selectBgView.backgroundColor = RGBCOLOR(26, 133, 255);
            cell.selectedBackgroundView = selectBgView;
        }
        
        // Configure the cell...
        KDUser *user = [(KDLike *)[self.likers objectAtIndex:indexPath.row] user];
        cell.user=user;
        
        if(!tableView.dragging && !tableView.decelerating){
            if(!cell.avatarView.hasAvatar && !cell.avatarView.loadAvatar){
                [cell.avatarView setLoadAvatar:YES];
            }
        }
        
        return cell;
    }
    
    return [self tableView:tableView preparedCellForIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *) indexPath {
    if (1 == [self tableView:tableView_ numberOfRowsInSection:indexPath.section]) { // placeholerview 不配置
        UIView * backgroundView = [cell viewWithTag:100];
        if (backgroundView) {
            backgroundView.hidden = NO;
        }
        return ;
    }
    
    if (indexPath.row == ([self tableView:tableView_ numberOfRowsInSection:indexPath.section] - 1)) {
        //
        UIView * backgroundView = [cell viewWithTag:100];
        if (backgroundView) {
            backgroundView.hidden = YES;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView preparedCellForIndexPath:(NSIndexPath*)indexPath {
    KDStatus *rowData = nil;
    if(statusDetailViewControllerFlags_.showingComments == 1) {
        //rowData = [comments_ objectAtIndex:indexPath.row];
        rowData = [self.commentDataset statusAtIndex:indexPath.row];
    }else {
        //rowData = [forwards_ objectAtIndex:indexPath.row];
        rowData = [self.forwardDataset statusAtIndex:indexPath.row];
    }
    KDStatusCell *cell = [self cellForStatus:rowData];
    if(!tableView.dragging && !tableView.decelerating){
        [cell loadThumbanilsImage];
    }
    return cell;
}


- (KDStatusCell *)cellForStatus:(KDStatus *)status {
    KDStatusCell *cell = [self.cellCache objectForKey:status.statusId];
    if (!cell) {
        cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];// autorelease];
        
        cell.maskInsets = UIEdgeInsetsZero;
        KDUserAvatarView *avaterView = [KDUserAvatarView avatarView];
        
        avaterView.frame = CGRectMake(8, 10, 34, 34);
        [cell addSubview:avaterView];
        avaterView.avatarDataSource = status.author;
        if (!avaterView.loadAvatar && ![avaterView hasAvatar]) {
            [avaterView setLoadAvatar:YES];
        }
        avaterView.userInteractionEnabled = NO;
        
        KDCommentCellLayouter *layouter = [KDCommentCellLayouter layouter:status constrainedWidth:tableView_.bounds.size.width - 42];
        KDLayouterView * layouterView = [layouter view];
        
        //cell.backgroundColor = [UIColor clearColor];
        [cell addSubview:layouterView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        layouterView.layouter = layouter;
        CGRect frame = layouterView.frame;
        frame.origin.x = 42;
        layouterView.frame = frame;
        
        UIImageView  *background =[[UIImageView alloc] init];//[[[UIImageView alloc] initWithImage:[UIImage stretchableImageWithImageName:@"status_detail_comment_cell_bg" resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5)]] autorelease];
        background.backgroundColor = [UIColor kdBackgroundColor2];
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        cell.backgroundView = background;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];//autorelease];
        tap.delegate = self;
        [cell addGestureRecognizer:tap];
        
        [self.cellCache setObject:cell forKey:status.statusId cost:1];
        
    }
    return cell;
    
}


- (void)tapAction:(UITapGestureRecognizer *)tapGesture {
    if([tapGesture.view isKindOfClass:[KDStatusCell class]]) {
        KDStatusCell *cell = (KDStatusCell *)tapGesture.view;
        
        NSIndexPath *indexPath = [tableView_ indexPathForCell:cell];
        KDStatus *rowData = nil;
        if(statusDetailViewControllerFlags_.showingComments == 1) {
            if(indexPath.row < self.commentDataset.count) {
                rowData = [self.commentDataset statusAtIndex:indexPath.row];
            }
        }else {
            if(indexPath.row < self.forwardDataset.count) {
                rowData = [self.forwardDataset statusAtIndex:indexPath.row];
            }
        }
        
        
        if(rowData) {
            //            ProfileViewController *profile = [[[ProfileViewController alloc] initWithUser:rowData.author] autorelease];
            //            [self.navigationController pushViewController:profile animated:YES];
            [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:rowData.author sender:tapGesture.view];
        }
    }
}

#pragma mark - UIGestureRecognizer Delegate Method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:touch.view];
    if(location.x > 48) {
        return NO;
    }else {
        return YES;
    }
}

#pragma mark -
#pragma mark KDRefreshTableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if((statusDetailViewControllerFlags_.showingComments == 1 && indexPath.row == self.commentDataset.count) || (statusDetailViewControllerFlags_.showingComments == 0 && indexPath.row == self.forwardDataset.count)) return;
    
    if(statusDetailViewControllerFlags_.showingComments == 2) {
        if (indexPath.row >= [self.likers count]) {
            return;
        }
        KDUser *user = [(KDLike *)self.likers[indexPath.row] user];
        XTPersonDetailViewController *personDetailVC = [[XTPersonDetailViewController alloc] initWithUserId:user.userId];
        
        //        ProfileViewController *pvc = [[ProfileViewController alloc] initWithUser:user andSelectedIndex:2];
        [self.navigationController pushViewController:personDetailVC animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        return;
    }
    
    if(statusDetailViewControllerFlags_.showingComments == 1)
        selectedStatus_ = [self.commentDataset statusAtIndex:indexPath.row];
    else
        selectedStatus_ = [self.forwardDataset statusAtIndex:indexPath.row];
    
    
    [self clickedStatusCell];
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    if(statusDetailViewControllerFlags_.showingComments == 1)
        [self fetchCommentsForStatus];
    else if(statusDetailViewControllerFlags_.showingComments == 0) {
        [self fetchForwardsForStatus];
    }else {
        [self fetchLikersForStatus];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [tableView_ kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
    }
    [tableView_ kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
    
}

#pragma mark -
#pragma mark - KDStatusRelativeContentSectionView delegate methods
- (void)statusSectionView:(KDStatusRelativeContentSectionView *)sectionView clickedAtIndex:(NSUInteger)index {
    if(index == 0x00){
        statusDetailViewControllerFlags_.showingComments = 1;
    }else if(index == 0x01) {
        statusDetailViewControllerFlags_.showingComments = 0;
    }else {
        statusDetailViewControllerFlags_.showingComments = 2;
    }
    
    [self refreshKDRefreshTableViewSideView];
    
    [tableView_ reloadData];
    
    if(statusDetailViewControllerFlags_.showingComments == 1) {
        if(!commentDataset_ || [commentDataset_ count] == 0)
            [self fetchCommentsForStatus];
    }else if(statusDetailViewControllerFlags_.showingComments == 0) {
        if(!forwardDataset_ || [forwardDataset_ count] == 0)
            [self fetchForwardsForStatus];
    }else if(statusDetailViewControllerFlags_.showingComments == 2) {
        if(likers_.count == 0) {
            [self fetchLikersForStatus];
        }
    }
}

#pragma mark -
#pragma mark KDStatusDetailView Delegate Methods
- (void)update {
    [self statusUpdate];
}

//附件点击处理方法（响应“更多”）
- (void)statusDetailView:(KDStatusDetailView *)detailView clickedAttachmentForStatus:(KDStatus *)statusWithAttachments {
    KDAttachmentViewController *attachmentVC = [[KDAttachmentViewController alloc] initWithSource:statusWithAttachments];
    [self.navigationController pushViewController:attachmentVC animated:YES];
    //    [attachmentVC release];
}

//附件中某条具体的文档点击，直接打开对应文档。
- (void)statusDetailView:(KDStatusDetailView *)detailView clickedAttachment:(KDAttachment *)attachment {
    [KDDownload downloadsWithAttachemnts:@[attachment] Status:status_ finishBlock:^(NSArray *result) {
        KDDownload *download = (KDDownload *)[result objectAtIndex:0];
        KDProgressModalViewController *modal = [[KDProgressModalViewController alloc] initWithDownload:download];// autorelease];
        [self.navigationController pushViewController:modal animated:YES];
    }];
}

//点击了“新鲜人、公告、表扬、投票”等图片，比如“投票”就需要跳转到投票界面
- (void)statusDetailView:(KDStatusDetailView *)detailView clickedExtraMessageForStatus:(KDStatus *)statusWithExtraMessage {
    //目前只响应“投票”
    //if(!statusWithExtraMessage.extraMessage.isVote) return;
    if (statusWithExtraMessage.extraMessage.isVote) {
        NSString *voteId = statusWithExtraMessage.extraMessage.referenceId;
        NSLog(@"voteId in detailview= %@",voteId);
        KDVoteViewController *vvc = [[KDVoteViewController alloc] init];
        vvc.voteId = voteId;
        [self.navigationController pushViewController:vvc animated:YES];
        //        [vvc release];
    }
    //    }else if ([statusWithExtraMessage hasTask]) { //任务
    //        KDTaskDetailsViewController *taskDetailsVC = [[KDTaskDetailsViewController alloc] init];
    //        taskDetailsVC.status = statusWithExtraMessage;
    //        [self.navigationController pushViewController:taskDetailsVC animated:YES];
    //        [taskDetailsVC release];
    //    }
    
}

//点击了被“转发”微博中的“回复”按钮，需要跳转到被“转发”的微博的详情界面
- (void)statusDetailView:(KDStatusDetailView *)detailView clickedCommentButtonForStatus:(KDStatus *)forwardingStatus {
    KDStatusDetailViewController *detailVC = [[KDStatusDetailViewController alloc] initWithStatus:forwardingStatus fromCommentOrForward:YES] ;//autorelease];
    [self.navigationController pushViewController:detailVC animated:YES];
}

//点击了被“转发”微博中的“转发”按钮，需要跳转到被“转发”的微博的详情界面
- (void)statusDetailView:(KDStatusDetailView *)detailView clickedForwardButtonForStatus:(KDStatus *)forwardingStatus {
    KDStatusDetailViewController *detailVC = [[KDStatusDetailViewController alloc] initWithStatus:forwardingStatus fromCommentOrForward:NO] ;//autorelease];
    [self.navigationController pushViewController:detailVC animated:YES];
}

//点击了“图片”，包含了本条微博的图片和“转发”微博的图片
- (void)statusDetailView:(KDStatusDetailView *)detailView clickedPhotoRenderViewWithImageDataSources:(id<KDImageDataSource>) imageSources {
    if ([detailView.status hasVideo]) {
        KDVideoPlayerController *videoController = [[KDVideoPlayerController alloc] initWithNibName:nil bundle:nil];
        videoController.delegate = self;
        //videoController.weiboStatus = detailView.status;
        videoController.dataId = detailView.status.statusId;
        videoController.attachments = detailView.status.attachments;
        [self presentViewController:videoController animated:YES completion:nil];
        //        [videoController release];
    }else {
        imageDataSource_ = imageSources;
        NSMutableArray *photos = [NSMutableArray array];
        NSArray *thumbUrls  = [imageDataSource_ thumbnailImageURLs];
        NSArray *bigUrls    = [imageDataSource_ bigImageURLs];
        NSArray *noRawUrls  = [imageDataSource_ noRawURLs];
        for (int i = 0; i<bigUrls.count; i++) {
            // 替换为中等尺寸图片
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString:[bigUrls objectAtIndex:i]]; // 图片地址
            if (bigUrls.count == noRawUrls.count) {
                photo.originUrl = [NSURL URLWithString:[noRawUrls objectAtIndex:i]];//原图地址
            }
            if (thumbUrls.count == bigUrls.count) {
                
                //#pragma mark modified by Darren in 2014.6.12
                photo.placeholder = [[SDWebImageManager sharedManager] diskImageForURL:[NSURL URLWithString:[thumbUrls objectAtIndex:i]] options:SDWebImageScaleNone];
                //photo.thumbnailPictureUrl = [NSURL URLWithString:[thumbUrls objectAtIndex:i]];
                
                
            }
            
            KDImageSource *source = [imageDataSource_ getTimeLineImageSourceAtIndex:i];
            if (source.isGifImage) {
                photo.isGif = YES;
            }
            
            [photos addObject:photo];
            //            [photo release];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];////autorelease];
        browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        [browser show:self.view.window];
    }
    
}

- (void)statusDetailView:(KDStatusDetailView *)detailView clickedPraiseButtonForStatus:(KDStatus *)forwardingStatus {
    
}


- (void)didTapOnAvatar:(id)sender {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:self.status.author sender:self.view];
}
#pragma mark KDStatusCoreTextDelegate methods
//本组方法，用于响应博文中的@、话题、链接

//@
- (void)clickedUserWithUserName:(NSString *)userName {
    //    ProfileViewController *pvc = [[[ProfileViewController alloc] initWithUserName:userName] autorelease];
    //
    //    [self.navigationController pushViewController:pvc animated:YES];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewControllerByName:userName sender:self.view];
}

//话题
- (void)clickedTopicWithTopicName:(NSString *)topicName {
    KDTopic *topic = [[KDTopic alloc] init];// autorelease];
    topic.name = topicName;
    
    TrendStatusViewController *tsvc = [[TrendStatusViewController alloc] initWithTopic:topic];
    tsvc.topicStatus = self.status;
    
    [self.navigationController pushViewController:tsvc animated:YES];
    //    [tsvc release];
}

//链接
- (void)clickedURL:(NSString *)urlString {
    //    KDWeiboAppDelegate *appDelegate=[KDWeiboAppDelegate getAppDelegate];
    //    [appDelegate openWebView:urlString];
    if(![[urlString lowercaseString] hasPrefix:@"http://"])
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    KDWebViewController *webView = [[KDWebViewController alloc] initWithUrlString:urlString];
    webView.isOpenWithWB = YES;
    [self.navigationController pushViewController:webView animated:YES];
    //    [webView release];
}

- (void)thumbnailView:(KDThumbnailView2 *)thumbnailView didLoadThumbnail:(UIImage *)thumbnail {
    [thumbnailView loadThumbnailFromDisk];
}

- (void)didTapOnThumbnailView:(KDThumbnailView2 *)thumbnailView userInfo:(id)userInfo {
    imageDataSource_ = thumbnailView.imageDataSource;
    if (thumbnailView.hasVideo) {
        KDVideoPlayerController *videoController = [[KDVideoPlayerController alloc] initWithNibName:nil bundle:nil];
        videoController.delegate = self;
        videoController.weiboStatus = thumbnailView.status;
        [self presentViewController:videoController animated:YES completion:nil];
        //        [videoController release];
    } else {
        
        NSUInteger startImage = 0;
        NSArray *srcs = nil;
        if ([userInfo isKindOfClass:[NSArray class]]) {
            //
            if (((NSArray *)userInfo).count >1) {
                startImage  = [[((NSArray *)userInfo) objectAtIndex:0] intValue];
                srcs = [((NSArray *)userInfo) objectAtIndex:1];
            }
        }
        
        NSMutableArray *photos = [NSMutableArray array];
        NSArray *bigUrls    = [imageDataSource_ bigImageURLs];
        NSArray *noRawUrls  = [imageDataSource_ noRawURLs];
        for (int i = 0; i<bigUrls.count; i++) {
            // 替换为中等尺寸图片
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString:[bigUrls objectAtIndex:i]]; // 图片地址
            if (bigUrls.count == noRawUrls.count) {
                photo.originUrl = [NSURL URLWithString:[bigUrls objectAtIndex:i]];//原图地址
            }
            
            if (srcs.count == bigUrls.count ) {
                photo.srcImageView = [srcs objectAtIndex:i]; // 来源于哪个UIImageView
            }
            
            [photos addObject:photo];
            //            [photo release];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];// autorelease];
        browser.currentPhotoIndex = startImage; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        [browser show:self.view.window];
        //        [browser show];
    }
}

#pragma mark
#pragma mark KDVideoPlayerManager delegate

- (void)videoPlayFinished:(KDVideoPlayerManager *)player
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark KDMenuViewDelegate methods
- (void)menuView:(KDMenuView *)menuView configMenuButton:(UIButton *)button atIndex:(NSUInteger)index {
    //
    //    NSString *highlightedImageName = nil;
    //    switch (index) {
    //        case 0x00:
    //            highlightedImageName = @"tool_bar_comment_hl_v2.png";
    //            break;
    //        case 0x01:
    //            highlightedImageName = @"tool_bar_forward_hl_v2.png";
    //            break;
    //        case 0x02:
    //            highlightedImageName = @"tool_bar_task_hl.png";
    //            break;
    //        case 0x04:
    //            highlightedImageName = @"tool_bar_delete_hl_v2.png";
    //            break;
    //        case 0x05:
    //            highlightedImageName = @"tool_bar_favorited_hl_v2.png";
    //            break;
    //        case 0x06:
    //            highlightedImageName = @"tool_bar_refresh_hl_v2.png";
    //            break;
    //
    //        default:
    //            break;
    //    }
    //
    //    if(highlightedImageName){
    //        [button setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    //
    //    }
    //
    //    highlightedImageName = @"tool_bar_favorited_selected_v2.png";
    //    if(index == 0x05){
    //        [button setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateSelected];
    //
    //    }
    //    highlightedImageName = @"tool_bar_liked_selected";
    //    if (index == 0x03) {
    //         [button setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateSelected];
    //
    //    }
    NSDictionary *dic = [self.toolBarItems objectAtIndex:index];
    NSString *title = [dic objectForKey:@"title"];
    if ([title isEqualToString:ASLocalizedString(@"KDStatusDetailViewController_Like")]) {
        [button setImage:[UIImage imageNamed:@"status_detail_like_select"] forState:UIControlStateSelected];
    }
    
    [button setBackgroundImage:[UIImage imageNamed:@"todo_selected_bg.png"] forState:UIControlStateHighlighted];
    [button setTitleColor:MESSAGE_NAME_COLOR forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
}


/*
 *1、刷新；2、回复；3、转发；4、收藏；（5、赞；） 5（6）、删除（if my status）
 *v3.3 修改:0.回复 1.转发 2.任务 3.赞 4.删除 5.收藏 6.刷新
 *@brief 此版本暂时不做（赞）
 */
- (void)menuView:(KDMenuView *)menuView clickedMenuItemAtIndex:(NSInteger)index {
    //    BOOL isGroup = NO;
    //    if(status_.groupId && status_.groupId.length > 0) {
    //        isGroup = YES;
    //    }
    //
    //
    //    switch (index) {
    //        case 0x00:
    //            [self replyStatus];
    //            break;
    //        case 0x01:
    //            [self forwardStatus:status_];
    //            break;
    //        case 0x02:
    //            [self goToTaskCreate:status_ type:KDCreateTaskReferTypeStatus];
    //            break;
    //        case 0x03:
    //            [self toggleLiked];
    //            break;
    //        case 0x04:
    //            [self deleteCurrentStatus];
    //            break;
    //        case 0x05:
    //            [self toggleFavorite];
    //            break;
    //        case 0x06:
    //            [self refreshCurrentStatus];
    //            break;
    //        case 0x07:
    //            [self reportStatus];
    //            break;
    //        default:
    //            break;
    //    }
    NSDictionary *dic = [self.toolBarItems objectAtIndex:index];
    NSString *title = [dic objectForKey:@"title"];
    if ([title isEqualToString:ASLocalizedString(@"KDStatusDetailViewController_Forward")]) {
        [[KDDefaultViewControllerContext defaultViewControllerContext] showForwardViewController:status_ sender:self.view];
    }else if([title isEqualToString:ASLocalizedString(@"DraftTableViewCell_tips_4")]) {
        [[KDDefaultViewControllerContext defaultViewControllerContext] showCommentViewController:status_ commentedSatatus:nil delegate:self sender:self.view showOriginalStatus:YES];
        
    }else if ([title isEqualToString:ASLocalizedString(@"KDDefaultViewControllerContext_to_task")]) {
        [[KDDefaultViewControllerContext defaultViewControllerContext] showCreateTaskViewController:status_ type:KDCreateTaskReferTypeStatus sender:self.view];
    }else if ([title isEqualToString:ASLocalizedString(@"KDStatusDetailViewController_Like")]) {
        [[KDDefaultViewControllerContext defaultViewControllerContext] toggleLike:status_];
    }
}

- (void)reportStatus {
    IssuleViewController *ivc = [[IssuleViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
    ivc.text = [NSString stringWithFormat:ASLocalizedString(@"KDDefaultViewControllerContext_reason"), status_.text];
    [KDWeiboAppDelegate setExtendedLayout:ivc];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ivc] ;//autorelease];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)goToTaskCreate:(KDStatus *)status type:(KDCreateTaskReferType) type{
    KDCreateTaskViewController *taskVC = [[KDCreateTaskViewController alloc] init];
    taskVC.title = ASLocalizedString(@"KDDefaultViewControllerContext_create_task");
    taskVC.referObject = status;
    taskVC.referType = type;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:taskVC];
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:nav animated:YES completion:nil];
    }else {
        [self presentViewController:nav animated:YES completion:nil];
    }
    //    [nav release];
    //    [taskVC release];
}

#pragma mark -
#pragma mark UIAlertView Delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIActionSheetView delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case KDStatusDetailViewControllerActionSheetCommentHandles: //长按评论
        {
            if(selectedStatus_ != nil) {
                KDStatusDetailViewHandler *handler = [[self currentHandlers] objectAtIndex:buttonIndex];
                if(handler) {
                    if(handler.handlerType == KDStatusDetailViewHandlerProfile) {
                        KDUser *user = selectedStatus_.author;
                        [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:user sender:self.view];
                    }else if(handler.handlerType == KDStatusDetailViewHandlerReply) {
                        
                        [[KDDefaultViewControllerContext defaultViewControllerContext] showCommentViewController:status_ commentedSatatus:selectedStatus_ delegate:self sender:self.view];
                        
                    }else if(handler.handlerType == KDStatusDetailViewHandlerDelete) {
                        [self destroyComment];
                    }else if(handler.handlerType == KDStatusDetailViewHandlerCopy) {
                        [[UIPasteboard generalPasteboard] setString:selectedStatus_.text];
                    }
                    else if(handler.handlerType == KDStatusDetailViewHandlerTask) {
                        [self goToTaskCreate:selectedStatus_ type:KDCreateTaskReferTypeComment];
                    }
                }
            }
        }
            break;
        case KDStatusDetailViewControllerActionSheetForwardHandles:
        {
            KDStatusDetailViewHandler *handler = [[self currentHandlers] objectAtIndex:buttonIndex];
            
            if(handler) {
                if(handler.handlerType == KDStatusDetailViewHandlerReply){
                    [[KDDefaultViewControllerContext defaultViewControllerContext] showCommentViewController:selectedStatus_ commentedSatatus:nil delegate:self sender:self.view];
                }else if(handler.handlerType == KDStatusDetailViewHandlerForward) {
                    [self forwardStatus:selectedStatus_];
                }else if(handler.handlerType == KDStatusDetailViewHandlerDetail) {
                    KDStatusDetailViewController *detailViewController = [[KDStatusDetailViewController alloc] initWithStatus:selectedStatus_] ;//autorelease];
                    [self.navigationController pushViewController:detailViewController animated:YES];
                }
            }
        }
            break;
        case KDStatusDetailViewControllerActionSheetDeleteStatus:
        {
            //            if(actionSheet.destructiveButtonIndex == buttonIndex)
            //                [self destroyCurrentStatus];
        }
            break;
        case KDStatusDetailViewControllerActionSheetDelectComment:
        {
            if(actionSheet.destructiveButtonIndex == buttonIndex)
                [self destroySelectedComment];
        }
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark animation delegate method
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if([preViewController_ respondsToSelector:@selector(removeStatus:)]) {
        [preViewController_ performSelector:@selector(removeStatus:) withObject:status_];
    }
}



/*
 NSInteger commentsCount; // a amount the comments number for this status
 @property(nonatomic, assign) NSInteger forwardsCount; // a amount of the forwards number for this status
 @property(nonatomic, assign) NSInteger likedCount;
 */
#pragma mark - KVO
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"liked"]) {
//
//    }else if ([keyPath isEqualToString:@"commentsCount"]) {
//
//    }else if ([keyPath isEqualToString:@"forwardsCount"]) {
//
//    }else if ([keyPath isEqualToString:@"likedCount"]) {
//
//    }
//    [self refreshCurrentStatus];
//}
@end

