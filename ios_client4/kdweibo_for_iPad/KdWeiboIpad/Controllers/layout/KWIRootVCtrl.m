//
//  KWIRootVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/20/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIRootVCtrl.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"
#import "UIImage+Additions.h"
#import "iToast.h"
#import "SBJson.h"

#import "NSError+KWIExt.h"
#import "UIDevice+KWIExt.h"
#import "SCPLocalKVStorage.h"

#import "KWIGlobal.h"
#import "KWIHomeTLVCtrl.h"


#import "KWIRPanelVCtrl.h"
#import "KWIStatusCell.h"
#import "KWIPostVCtrl.h"
#import "KWICommentMPCell.h"
#import "KWISigninVCtrl.h"

#import "KWIWelcomeVCtrl.h"
#import "KWITutorialCardV.h"
#import "KWISettingsVCtrl.h"
#import "KWISettingsNavCtrl.h"
#import "KWINetworkBannerV.h"
#import "KWISearchVCtrl.h"
#import "KWIPeopleVCtrl.h"
#import "KWITutorialVCtrl.h"
#import "KWITutorialNetworkV.h"
#import "KWIStatusVCtrl.h"
#import "EGOPhotoViewController.h"


#import "KDCommonHeader.h"
#import "KDMentionMeStatusViewController.h"
#import "KDCommentToMeViewController.h"
#import "KDDMThreadViewController.h"
#import "KDGroupViewController.h"
#import "KDGroupStatusViewController.h"
#import "KDCompanyStatusViewController.h"
#import "KDFriendStatusViewController.h"
#import "KDDocumentPreviewViewController.h"

#import "KWIAppDelegate.h"
#import "KDCommentStatus.h"

typedef enum {
    ButtonName_Avatar = 0x00,
    ButtonName_Home,
    ButtonName_Mention,
    ButtonName_Comment,
    ButtonName_Message,
    ButtonName_Group,
    ButtonName_Search
}ButtonName;

@interface KWIRootVCtrl ()<KDUnreadListener> {
    
    CGRect rightPanelOrigntFrame;
    struct {
        int viewDidAppeared;
    }_flags;
 
}

@property (retain, nonatomic) IBOutlet UIView *tierZero;
// @property (retain, nonatomic) IBOutlet UIView *tierOne;
@property (retain, nonatomic) IBOutlet UIImageView *avatarV;
//@property (retain, nonatomic) IBOutlet UILabel *usernameV;
@property (retain, nonatomic) IBOutlet UIButton *hometlBtn;
@property (retain, nonatomic) IBOutlet UIButton *mentionsBtn;
@property (retain, nonatomic) IBOutlet UIButton *repliesBtn;
@property (retain, nonatomic) IBOutlet UIButton *messagesBtn;
@property (retain, nonatomic) IBOutlet UIButton *groupLsBtn;
@property (retain, nonatomic) IBOutlet UIButton *searchBtn;
@property (retain, nonatomic) IBOutlet UIImageView *badgeBgV;
@property (retain, nonatomic) IBOutlet UILabel *badgeCountV;

@property (retain, nonatomic) IBOutlet UIView *mpanelCtnV;
@property (retain, nonatomic) IBOutlet UIView *rpanelCtnV;

@property (retain, nonatomic) IBOutlet UIView *leftNavBar;

@property (retain, nonatomic) KWIHomeTLVCtrl *hometlVCtrl;

@property (nonatomic, retain) KDGroupStatusViewController *groupStatusViewController;
@property (retain, nonatomic) KWISearchVCtrl *searchVCtrl;
@property (retain, nonatomic) KWIPeopleVCtrl *profileVCtrl;

@property (retain, nonatomic) KWIRPanelVCtrl *rpanelVCtrl;

@property (retain, nonatomic) KWIPostVCtrl *postVCtrl;
@property (retain, nonatomic) IBOutlet UIImageView *mpanelShadowV;

@property (retain, nonatomic) KWIWelcomeVCtrl *welcomePanel;

@property (nonatomic, retain) KDMentionMeStatusViewController *mentionMeStatusViewController;
@property (nonatomic, retain) KDCommentToMeViewController *commentToMeViewController;
@property (nonatomic, retain) KDDMThreadViewController *dmThreadViewController;
@property (nonatomic, retain) KDGroupViewController *groupViewCotroller;
@property (nonatomic, retain) KDDocumentPreviewViewController *toBeFullScreenedVC;

@end

@implementation KWIRootVCtrl
{
    //KWITierOneVCtrl *_hometlTierVCtrl;
    //KWITierOneVCtrl *_repliesTierVCtrl;
    //KWITierOneVCtrl *_messagesTierVCtrl;
    
    UIViewController *_curMpanelVCtrl;
    //CGRect _mpanelFrame;
    //CGRect _mpanelStandbyFrame;
    
    NSArray *_networks;
    UIView *_t0mask;
    IBOutlet UIView *_t1v;
    IBOutlet UIImageView *_rpanelBgV;
    
    IBOutlet UIScrollView *_networkLsV;    
    IBOutlet UIImageView *_mNavBgV;
    
    IBOutlet UIButton *_newFollowerCountV;
    IBOutlet UIButton *_homeTLCountV;    
    IBOutlet UIButton *_mentionsTLCountV;    
    IBOutlet UIButton *_repliesTLCountV;
    IBOutlet UIButton *_msgTLCountV;
    IBOutlet UIButton *_groupTLCountV;
    NSTimer *_fetchUnreadTimer;
    
    ButtonName currentButton;
}

@synthesize tierZero;
// @synthesize tierOne;
@synthesize avatarV;
//@synthesize usernameV;
@synthesize hometlBtn;
@synthesize mentionsBtn;
@synthesize repliesBtn;
@synthesize messagesBtn;
@synthesize groupLsBtn;
@synthesize searchBtn = _searchBtn;
@synthesize badgeBgV;
@synthesize badgeCountV;
@synthesize mpanelCtnV;
@synthesize rpanelCtnV;
@synthesize hometlVCtrl = _hometlVCtrl;
@synthesize rpanelVCtrl = _rpanelVCtrl;
@synthesize postVCtrl = _postVCtrl;
@synthesize mpanelShadowV;
@synthesize welcomePanel = _welcomePanel;
@synthesize searchVCtrl = _searchVCtrl;
@synthesize profileVCtrl = _profileVCtrl;

@synthesize mentionMeStatusViewController = mentionMeStatusViewController_;
@synthesize commentToMeViewController = commentToMeViewController_;
@synthesize dmThreadViewController = dmThreadViewController_;
@synthesize groupViewCotroller = groupViewCotroller_;
@synthesize groupStatusViewController = groupStatusViewController_;
@synthesize toBeFullScreenedVC = toBeFullScreenedVC_;

#pragma mark - memory life cycle
+ (KWIRootVCtrl *)vctrl
{
    return [[[self alloc] initWithNibName:self.description bundle:nil] autorelease];
}

+ (KWIRootVCtrl *)curInst
{
    UINavigationController *rootVC = (UINavigationController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    UIViewController *curVC = rootVC.topViewController;
    if ([curVC isMemberOfClass:self.class]) {
        return (KWIRootVCtrl *)curVC;
    } else {
        return nil;
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc addObserver:self
                selector:@selector(_handleShowVCtrl:)
                    name:@"KWIStatusVCtrl.show"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_handleShowVCtrl:)
                    name:@"KWIPeopleVCtrl.show"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_handleShowVCtrl:)
                    name:@"KWITrendStreamVCtrl.show"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_handleShowVCtrl:)
                    name:@"KWIConversationVCtrl.show"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_handleShowVCtrl:)
                    name:@"KWIGroupInfVCtrl.show"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_handleShowVCtrl:)
                    name:@"documentList.show"
                  object:nil];

        [dnc addObserver:self
                selector:@selector(_onComment:)
                    name:@"KWStatus.addComment"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onComment:)
                    name:@"KWComment.addComment"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onRepost:)
                    name:@"KWStatus.repost"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onWebVShow:)
                    name:@"KWIWebVCtrl.show"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onNewThread:)
                    name:@"KWThread.new"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onNewMention:)
                    name:@"KWStatus.newMention"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onAvatarChanged:)
                    name:@"KWUser.avatarChanged"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onShowGroupStream:)
                    name:@"GroupStatusViewController.show"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onBadgeCountChange:)
                    name:@"badgeCountChange"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onNetworkSelected:)
                    name:@"KWNetwork.selected"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onRPanelEmpty:)
                    name:@"KWIRPanelVCtrl.empty"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onNetworkShowList:)
                    name:@"KWNetwork.showList"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onTotalUnreadCountChanged:)
                    name:@"totalUnreadCountChanged"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onshowPhotos:)
                    name:@"KWIShowPhotos"
                  object:nil];
        KDUnreadManager *unreadManager = [[KDManagerContext globalManagerContext] unreadManager];
        [unreadManager addUnreadListener:self];
        
        _flags.viewDidAppeared = 0;
      
        

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[KDManagerContext globalManagerContext ] unreadManager] removeUnreadListener:self];
    
    [_hometlVCtrl release];
    [_rpanelVCtrl release];
    [_postVCtrl release];
    [_welcomePanel release];
    [_profileVCtrl release];
    
    //[usernameV release];
    [groupLsBtn release];
    [badgeBgV release];
    [badgeCountV release];
    
    [_networkLsV release];
    [_searchBtn release];
    [_t1v release];
    [_rpanelBgV release];
    [_mNavBgV release];
    [_newFollowerCountV release];
    [_homeTLCountV release];
    [_mentionsTLCountV release];
    [_groupTLCountV release];
    [_repliesTLCountV release];
    [_fetchUnreadTimer invalidate];
    [_fetchUnreadTimer release];
    [_msgTLCountV release];
     KD_RELEASE_SAFELY(groupViewCotroller_);
     KD_RELEASE_SAFELY(toBeFullScreenedVC_);
    [_leftNavBar release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib. 
     self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"rootVBg.png"]];
    self.navigationController.navigationBarHidden = YES;
    self.mpanelCtnV.layer.cornerRadius = 20;
    self.mpanelCtnV.layer.masksToBounds = YES;
    [self _configBgVForCurrentOrientation];
    
    currentButton = ButtonName_Home;
    
    
    [self homeBtnTapped:self.hometlBtn];
  
     self.welcomePanel = [KWIWelcomeVCtrl vctrlInBounds:self.rpanelCtnV.bounds];
     self.welcomePanel.view.hidden = [UIDevice isPortrait];
     [self.rpanelCtnV addSubview:self.welcomePanel.view];
    
    
    //avatarv
    UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onAvatarTapped:)] autorelease];
    [self.avatarV addGestureRecognizer:tgr];
    
    KDUser *user = [[[KDManagerContext globalManagerContext] userManager] currentUser];
    
    if(user) {
        [self.avatarV setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    }else {
        [self updateCurrentUserInfo];
    }
    
    //初始化badge
    [self initBadgeValue];
}

- (void)initBadgeValue {
    [self unreadManager:[[KDManagerContext globalManagerContext] unreadManager] didChangeUnread:nil];
}


- (void)updateCurrentUserInfo {
    NSString *userId = [[[KDManagerContext globalManagerContext] userManager] currentUserId];
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:userId];
    
    __block KWIRootVCtrl *rvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results != nil) {
                KDUser *user = results;
                [self.avatarV setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
                [[KDManagerContext globalManagerContext] userManager].currentUser = user;
                [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                    id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                    [userDAO saveUser:(KDUser *)results database:fmdb];
                    
                    return nil;
                    
                } completionBlock:nil];
            }

        }else {
            if(![response isCancelled]) {
                [[iToast makeText:[[response responseDiagnosis] networkErrorMessage]] show];
            }
                
        }
        
        // release current view controller
        [rvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:show" query:query
                                 configBlock:nil completionBlock:completionBlock];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"wiewWillAppear....");
    //[self adjustUIWithOrientation];
    
    // To Do
    

    if (![[[KDSession globalSession] getPropertyForKey:@"had_tutorial_v1.0.0_presented" fromMemoryCache:YES] boolValue]) {
               if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
                    [self presentViewController:[KWITutorialVCtrl vctrl] animated:YES completion:nil];
               } else {
                    [self presentModalViewController:[KWITutorialVCtrl vctrl] animated:YES];
                }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     DLog(@"viewDidAppear....");
    //初次更新社区title
    if(_flags.viewDidAppeared == 0) {
        _flags.viewDidAppeared = 1;
        KDCommunity *community = [[[KDManagerContext globalManagerContext] communityManager] currentCommunity];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWNetwork.changed" object:self userInfo:[NSDictionary dictionaryWithObject:community forKey:@"network"]];
    }
 
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setTierZero:nil];
    [self setHometlBtn:nil];
    [self setRepliesBtn:nil];
    [self setMessagesBtn:nil];
    [self setMpanelCtnV:nil];
    [self setRpanelCtnV:nil];    
    
    [self setAvatarV:nil];
    [self setMpanelShadowV:nil];
    [self setMentionsBtn:nil];
    [self setGroupLsBtn:nil];
    [self setBadgeBgV:nil];
    [self setBadgeCountV:nil];
    [_networkLsV release];
    _networkLsV = nil;
    [self setSearchBtn:nil];
    [_t1v release];
    _t1v = nil;
    [_rpanelBgV release];
    _rpanelBgV = nil;
    [_mNavBgV release];
    _mNavBgV = nil;
    [_newFollowerCountV release];
    _newFollowerCountV = nil;
    [_homeTLCountV release];
    _homeTLCountV = nil;
    [_mentionsTLCountV release];
    _mentionsTLCountV = nil;
    [_groupTLCountV release];
    _groupTLCountV = nil;
    [_repliesTLCountV release];
    _repliesTLCountV = nil;
    [_msgTLCountV release];
    _msgTLCountV = nil;
    [self setLeftNavBar:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


- (void)_onshowPhotos:(NSNotification *)notification  {
    
    NSDictionary *userInfo = [notification userInfo];
    
    KDCompositeImageSource *imageSource = [userInfo objectForKey:@"compoisteImageSource"];
    
    EGOPhotoViewController *fullImgVC = [[EGOPhotoViewController alloc] initwithCompositeImageDataSource:imageSource];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:fullImgVC];
    [fullImgVC release];
    KWIRootVCtrl *rootVC = [KWIRootVCtrl curInst];
    if ([rootVC respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [rootVC presentViewController:navVC animated:YES completion:nil];
    } else {
        [rootVC presentModalViewController:navVC animated:YES];
    }
    [navVC release];
}


- (void)onRemoveViewController:(UIViewController *)controller animaion:(BOOL)animation {

    if (self.rpanelVCtrl) {
        if ([self.rpanelVCtrl rootCardVCtrl] == controller) {
            [self _onRPanelEmptyViewController:animation];
        }
        else  if([self.rpanelVCtrl topCardVCtrl] == controller){
            [self.rpanelVCtrl removePage:controller animation:animation];
            //[self.rpanelVCtrl popViewController:animation ];
        }
    }
}


- (void)displayToBeFullScreendVC {
    
   UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:toBeFullScreenedVC_];
    //nav.navigationBar.translucent = YES;
    //nav.navigationBar.tintColor = [UIColor blackColor];
    nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(fullScreendone:)];
    
    UIBarButtonItem *minBtn = [[UIBarButtonItem alloc] initWithTitle:@"最小化" style:UIBarButtonItemStylePlain target:self action:@selector(minButtontapped:)];
    //toBeFullScreenedVC_.navigationItem.rightBarButtonItem = doneButton;
    if ([toBeFullScreenedVC_.navigationItem respondsToSelector:@selector(rightBarButtonItems)]) {

        UIBarButtonItem *openAsBtn =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"other_way_open_btn"] style:UIBarButtonItemStylePlain target:toBeFullScreenedVC_ action:@selector(openOtherWay:)];
        toBeFullScreenedVC_.navigationItem.rightBarButtonItems = @[doneButton,openAsBtn,minBtn];
        [openAsBtn release];
    }else {
        toBeFullScreenedVC_.navigationItem.rightBarButtonItem = doneButton;
        toBeFullScreenedVC_.navigationItem.leftBarButtonItem = minBtn;
    }
    
    [doneButton release];
    [minBtn release];
    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentModalViewController:nav animated:YES];
    }else {
        [self presentModalViewController:nav animated:YES];
    }
    [nav release];
}

//全屏

- (void)fullScreening:(UIViewController *)controller {
    self.toBeFullScreenedVC = (KDDocumentPreviewViewController *)controller;
    
    [self onRemoveViewController:controller animaion:NO];
    
    
    [toBeFullScreenedVC_ shouldFullScreened:YES];
    //此处延迟，防止 controller.view 比 displayTobefullScreenedVc 慢执行.
    // [self performSelector:@selector(displayToBeFullScreendVC) withObject:nil afterDelay:0.1];
    [self displayToBeFullScreendVC];
  
}


- (void)fullScreendone:(id)sender {
      [toBeFullScreenedVC_ shouldFullScreened:NO];
    
      [self performSelector:@selector(closefullScreen) withObject:nil afterDelay:0.0];
  
}

- (void)closefullScreen {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else {
        [self dismissModalViewControllerAnimated:YES];
    }
}
- (void)minWindows {
   
    [self closefullScreen];
    [self _pushVCtrlInRPanel:toBeFullScreenedVC_ animated:NO];
}

- (void)minButtontapped:(id)sender {
    [toBeFullScreenedVC_ shouldFullScreened:NO];
    [toBeFullScreenedVC_ replaceTootViewControllerOfNavgationCongtroller];
    [toBeFullScreenedVC_.navigationController setViewControllers:nil];
    [self performSelector:@selector(minWindows) withObject:nil afterDelay:0.0];
    
}

#pragma mark - logic
- (void)_configFrame4MPanelV:(UIView *)view
{
    CGRect frame = self.mpanelCtnV.bounds;
    frame.size.width -= 27;
    frame.origin.x += 20;
    view.frame = frame;
}

//显示在左边
- (void)_showVCtrlInMPanel:(UIViewController *)vctrl
{
    self.mpanelShadowV.hidden = NO;
    
    //移除右边挡板
    if (self.rpanelVCtrl) {
        [self.rpanelVCtrl.view removeFromSuperview];
        self.rpanelVCtrl = nil;
        [self _onRPanelEmpty:nil];
    }
    
    if (nil != _curMpanelVCtrl) {
        UIViewController *_cur = _curMpanelVCtrl;        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             //_cur.view.frame = _mpanelStandbyFrame;
                             _cur.view.alpha = 0;
                         } 
                         completion:^(BOOL finished){
                             _cur.view.hidden = YES;
                             //[_cur.view removeFromSuperview];
                         }];
    }
    
    //vctrl.view.frame = _mpanelStandbyFrame;
    vctrl.view.hidden = NO;
    vctrl.view.alpha = 0;
    [self.mpanelCtnV addSubview:vctrl.view];
    [UIView animateWithDuration:0.3 
                          delay:0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         //vctrl.view.frame = _mpanelFrame;
                         vctrl.view.alpha = 1;
                     } 
                     completion:nil];
    _curMpanelVCtrl = vctrl;
    
//    UITableView *tbv = [(KWIMPanelVCtrl *)vctrl tableView];
//    [tbv deselectRowAtIndexPath:[tbv indexPathForSelectedRow] animated:NO];
}

- (void)_switchMNavBtn:(UIButton *)btn
{
    self.hometlBtn.selected = (btn == self.hometlBtn);
    self.mentionsBtn.selected = (btn == self.mentionsBtn);
    self.repliesBtn.selected = (btn == self.repliesBtn);
    self.messagesBtn.selected = (btn == self.messagesBtn);
    self.groupLsBtn.selected = (btn == self.groupLsBtn);
    self.searchBtn.selected = (btn == self.searchBtn);
}

//用新的板和原来的板交换 
- (void)_replaceVCtrlInRPanel:(UIViewController *)vctrl animated:(BOOL)animated
{
    DLog(@"replaceVCtrlInRP");
    // click status in mpanel toggles card stack in rpanel
    BOOL shouldEmpty = NO;
    if (self.rpanelVCtrl) { //如果右板的当前的内容和需要展示的内容是相同的,就推出当前右板.
        UIViewController *curRootCard = [self.rpanelVCtrl rootCardVCtrl];
        if (vctrl!= curRootCard) {
            SEL dataSel = NSSelectorFromString(@"data");
            
            if (vctrl && [vctrl respondsToSelector:dataSel] && curRootCard &&
                [curRootCard respondsToSelector:dataSel]) {
                id curData = [curRootCard performSelector:dataSel];
                id newData = [vctrl performSelector:dataSel];
                SEL idSel = NSSelectorFromString(@"id_");
                
                if ([curData respondsToSelector:idSel] && [newData respondsToSelector:idSel]) {
                    NSString *curId = [curData performSelector:idSel];
                    NSString *newId = [newData performSelector:idSel];
                    if ([curId isEqualToString:newId]) {
                        shouldEmpty = YES;
                    }
                }
            }
        } //
        else {
            shouldEmpty = YES;
        }
       
    }
    
    [self.rpanelVCtrl remove];
    if (shouldEmpty) {
        
        [self performSelector:@selector(_onRPanelEmpty:) withObject:nil afterDelay:0.66f];
        return;
    }
    
    self.rpanelVCtrl = [KWIRPanelVCtrl rpanelWithFrame:self.rpanelCtnV.bounds rootVCtrl:vctrl animated:animated];
    [self.rpanelCtnV addSubview:self.rpanelVCtrl.view];
    
    if ([UIDevice isPortrait]) {
        [_t1v bringSubviewToFront:self.rpanelCtnV];
    }
}

- (void)_pushVCtrlInRPanel:(UIViewController *)vctrl animated:(BOOL) animated
{
   
    if (self.rpanelVCtrl) {
    
        [self.rpanelVCtrl pushViewControllerToRPanelVCtrol:vctrl animated:animated];
    } else {
        [self _replaceVCtrlInRPanel:vctrl animated:animated];
    }
}

- (IBAction)_postBtnTapped:(id)sender 
{
    if (nil == self.postVCtrl) {
        self.postVCtrl = [KWIPostVCtrl vctrl];
        [self.view addSubview:self.postVCtrl.view];
    }
    
    if ([_curMpanelVCtrl isKindOfClass:[KDGroupStatusViewController class]]) {
        KDGroup *group = [(KDGroupStatusViewController *)_curMpanelVCtrl group];
        [self.postVCtrl newStatusWithGroup:group];
    } else {
        [self.postVCtrl newStatus];
    }
}

- (void)_configBadge:(NSUInteger)count
{
    if (0 == count) {
        self.badgeBgV.hidden = YES;
        self.badgeCountV.hidden = YES;
    } else {
        self.badgeBgV.hidden = NO;
        self.badgeCountV.hidden = NO;
        self.badgeCountV.text = [NSString stringWithFormat:@"%d", count];
    }
}


- (void)adjustUIWithOrientation {
     if(self.rpanelCtnV) {
      if ([UIDevice isPortrait] ) {
        [_t1v bringSubviewToFront:self.rpanelCtnV];
      }else {
        [_t1v insertSubview:self.rpanelCtnV atIndex:1];
      }
    }
    self.welcomePanel.view.hidden = [UIDevice isPortrait];
    [self _configBgVForCurrentOrientation];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    DLog(@"willRoteToInterFaceOrientation....");
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && self.rpanelVCtrl) {
        [_t1v bringSubviewToFront:self.rpanelCtnV];
    }        
    
    
    self.welcomePanel.view.hidden = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    
    
    // some view controllers must place their willRotateToInterfaceOrientation logic after rootVCtrl.
    // some views has logic on willRotateToInterfaceOrientation but dont have this method 
    // so trigger custom notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UIInterfaceOrientationWillChange" 
                                                        object:nil 
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:duration], @"duration", [NSNumber numberWithBool:UIInterfaceOrientationIsPortrait(toInterfaceOrientation)], @"isPortrait", nil]];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    DLog(@"didRotateFromInterfaceOrientation....");
    if (![UIDevice isPortrait]) {
        [_t1v insertSubview:self.rpanelCtnV atIndex:1];        
    } 
    
    [self _configBgVForCurrentOrientation];
    // some view controllers must place their didRotateFromInterfaceOrientation logic after rootVCtrl.
    // some views has logic on didRotateFromInterfaceOrientation but dont have this method 
    // so trigger custom notification
 
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UIInterfaceOrientationChanged" object:nil];
}

- (void)_configBgVForCurrentOrientation
{    
    if ([UIDevice isPortrait]) {
        _mNavBgV.image = [UIImage imageNamed:@"mNavBgP.png"];
    } else {
        _mNavBgV.image = [UIImage imageNamed:@"mNavBg.png"];
    }
}

//- (void)_configNetworkList
//{
//    [_networkLsV.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    unsigned int i = 0;
//    for (KWNetwork *network in _networks) {
//        KWNetwork *curNetWork = [KDWeiboCore sharedKDWeiboCore].currentNetWork;
//        if(!((curNetWork == nil && network.isCompany) || [curNetWork.id_ isEqualToString:network.id_])){
//            
//            KWINetworkBannerV *view = [KWINetworkBannerV viewWithNetwork:network];
//            CGRect frame = view.frame;
//            frame.origin.x = 160 * i + 30;
//            frame.origin.y = 28;
//            view.frame = frame;
//            //[self.view insertSubview:view atIndex:0];
//            [_networkLsV addSubview:view];
//            
//            i++;
//        }
//    }
//    
//    CGSize ctnSize = _networkLsV.frame.size;
//    UIView *lastV = [_networkLsV.subviews lastObject];
//    ctnSize.width = CGRectGetMaxX(lastV.frame) + 50;
//    _networkLsV.contentSize = ctnSize;
//}


#pragma mark - event handlers

- (void)unreadManager:(KDUnreadManager *)unreadManager didChangeUnread:(KDUnread *)unread {
    KDUnread *theUnread = unreadManager.unread;
    if ([self.hometlVCtrl isPublic]) {
        [self _configCountV:_homeTLCountV withNum:@(theUnread.publicStatuses)];
    }else {
        [self _configCountV:_homeTLCountV withNum:@(theUnread.friendsStatuses)];
    }
    
    [self _configCountV:_mentionsTLCountV withNum:@(theUnread.mentions)];
    [self _configCountV:_repliesTLCountV withNum:@(theUnread.comments)];
    [self _configCountV:_msgTLCountV withNum:@(theUnread.directMessages)];
    [self _configCountV:_newFollowerCountV withNum:@(theUnread.followers)];
    [self _configCountV:_groupTLCountV withNum:@(theUnread.groupsAllUnreadCount)];


    
    
}
- (void)_handleShowVCtrl:(NSNotification *)notification{
    if (![[[KDSession globalSession] getPropertyForKey:@"had_tutorial_card_v1.0.0_presented" fromMemoryCache:YES] boolValue]) {
        
        [self.view addSubview:[KWITutorialCardV view]];
        
       [[KDSession globalSession] saveProperty:@(YES) forKey:@"had_tutorial_card_v1.0.0_presented" storeToMemoryCache:YES];
    }
    
    if([self.rpanelVCtrl isAnimating]) return;
    
    UIViewController *vctrl = [notification.userInfo objectForKey:@"vctrl"];
    
    if([vctrl isKindOfClass:[KWIPeopleVCtrl class]]) {
        UIViewController *top = [self.rpanelVCtrl topCardVCtrl];
        
        if(top && [top isKindOfClass:[KWIPeopleVCtrl class]]) {
            if([[(KWIPeopleVCtrl *)top userId] isEqualToString:[(KWIPeopleVCtrl *)vctrl userId]])
                return;
        }
    }
    
    static NSArray *viewsInMPanel;
    if (nil == viewsInMPanel) {
        viewsInMPanel = [[NSArray arrayWithObjects: [KDFriendStatusViewController class],[KDCompanyStatusViewController class],[KDCommentToMeViewController class],[KDMentionMeStatusViewController class],[KDGroupStatusViewController class],
                          [KWISearchVCtrl class],
            KWIStatusCell.class, KDDMThreadViewController.class, KWICommentMPCell.class, nil] retain];
    }
    
    if ([viewsInMPanel containsObject:[notification.userInfo objectForKey:@"from"]]) {
   
        [self _replaceVCtrlInRPanel:vctrl animated:YES];
    } else {
   
        [self _pushVCtrlInRPanel:vctrl animated:YES];
    }
}

- (void)_onComment:(NSNotification *)note
{
    if (nil == self.postVCtrl) {
        self.postVCtrl = [KWIPostVCtrl vctrl];
        [self.view addSubview:self.postVCtrl.view];
    }
    
    if ([@"KWStatus.addComment" isEqualToString:note.name]) { //回复微博
        KDStatus *status = [note.userInfo objectForKey:@"status"];
        [self.postVCtrl replyStatus:status];
    } else {// 回复回复
        KDCommentStatus *comment = [note.userInfo objectForKey:@"comment"];
       KDStatus *status = comment.status;
        
        [self.postVCtrl replyComment:comment status:status];
    }
}

- (void)_onRepost:(NSNotification *)note
{
    if (nil == self.postVCtrl) {
        self.postVCtrl = [KWIPostVCtrl vctrl];
        [self.view addSubview:self.postVCtrl.view];
    }
    
    [self.postVCtrl repostStatus:[note.userInfo objectForKey:@"status"]];
}

- (void)_onWebVShow:(NSNotification *)note
{
    UIViewController *vctrl = note.object;
    [self presentModalViewController:vctrl animated:YES];
}

- (void)_onNewThread:(NSNotification *)note
{
    [self messagesBtnTapped:self.messagesBtn];    
   // [self.messagestlVCtrl newMessage:[note.userInfo objectForKey:@"to"]];
    [self.dmThreadViewController newMessage:[note.userInfo objectForKey:@"to"]];
}

- (void)_onNewMention:(NSNotification *)note
{
    if (nil == self.postVCtrl) {
        self.postVCtrl = [KWIPostVCtrl vctrl];
        [self.view addSubview:self.postVCtrl.view];
    }
    
    KDUser *user = [note.userInfo objectForKey:@"user"];
    [self.postVCtrl newMention:user];
}

- (void)_onAvatarChanged:(NSNotification *)note
{
   // KWEngine *api = [KWEngine sharedEngine];
    KDUserManager *userManager = [[KDManagerContext globalManagerContext] userManager];
    KDUser *user = [userManager currentUser];
    [self.avatarV setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
}

- (void)_onShowGroupStream:(NSNotification *)note
{
    self.groupStatusViewController = [note.userInfo objectForKey:@"vctrl"];
    [self _configFrame4MPanelV:self.groupStatusViewController.view];
    
    [self _showVCtrlInMPanel:self.groupStatusViewController];
}

- (void)_onBadgeCountChange:(NSNotification *)note {
    NSNumber *count = [note.userInfo objectForKey:@"count"];
    [self _configBadge:count.intValue];
}


- (void)configCommunityList {
    KDCommunityManager *manager = [[KDManagerContext globalManagerContext] communityManager];
    NSArray *communitys = [manager joinedCommunities];
    //release  first
    NSArray *subViews = [_networkLsV subviews];
    if (subViews && [subViews count] >0) {
        //subViews
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    NSInteger i = 0;
    for (KDCommunity *community in communitys) {
        if (![community.communityId isEqualToString:[manager currentCommunity].communityId]) {
            KWINetworkBannerV *view = [KWINetworkBannerV viewWithNetwork:community];
            CGRect frame = view.frame;
            frame.origin.x = 160 * i + 30;
            frame.origin.y = 28;
            view.frame = frame;
            [_networkLsV addSubview:view];
            i++;
        }
      
    }
    CGSize ctnSize = _networkLsV.frame.size;
        UIView *lastV = [_networkLsV.subviews lastObject];
        ctnSize.width = CGRectGetMaxX(lastV.frame) + 50;
        _networkLsV.contentSize = ctnSize;
    
}
- (void)_onNetworkShowList:(NSNotification *)note {
    [self configCommunityList];
    [self openCommunityListView];
    
}

- (void)openCommunityListView {
    DLog(@"open CommunityList.....");
    CGRect defFrame = self.tierZero.frame;
    CGRect downFrame = defFrame;
    downFrame.origin.y = 200;
    
    _t0mask = [[[UIView alloc] initWithFrame:self.tierZero.bounds] autorelease];
    [self.tierZero addSubview:_t0mask];
    UITapGestureRecognizer *maskTgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onT0maskTapped:)] autorelease];
    [_t0mask addGestureRecognizer:maskTgr];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.tierZero.frame = downFrame;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
 
}

//收起社区选择
- (void)closeCommunityListView {
    CGRect defFrame = self.tierZero.frame;
    defFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.tierZero.frame = defFrame;
                     }
                     completion:^(BOOL finished) {
                         [_t0mask removeFromSuperview];
                         _t0mask = nil;
                     }];

    
}
- (void)_onNetworkSelected:(NSNotification *)note
{

        KDCommunity *community = (KDCommunity *)[note.userInfo objectForKey:@"network"];
        if (community == nil) {
             return;
         }
        KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
        [communityManager connectToCommunity:community];

        [[KWIAppDelegate getAppDelegate] postInit:YES];
    
        [self closeCommunityListView];
        
        [_curMpanelVCtrl.view removeFromSuperview];
        self.hometlVCtrl = nil;
       // self.messagestlVCtrl = nil;
        self.dmThreadViewController = nil;
    
        self.searchVCtrl = nil;
        self.postVCtrl = nil;
        self.profileVCtrl = nil;
        self.mentionMeStatusViewController = nil;
        self.commentToMeViewController = nil;
        self.groupViewCotroller = nil;
    
    // To Do
        //[self.welcomePanel.view removeFromSuperview];
        //self.welcomePanel = [KWIWelcomeVCtrl vctrlInBounds:self.rpanelCtnV.bounds];
        //[self.rpanelCtnV addSubview:self.welcomePanel.view];
        if ([UIDevice isPortrait]) {
            self.welcomePanel.view.hidden = YES;
        } else {
            self.welcomePanel.view.hidden = NO;
        }
        
        [self homeBtnTapped:self.hometlBtn];

      
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"KWNetwork.changed" object:self userInfo:[NSDictionary dictionaryWithObject:community forKey:@"network"]];
    
    //[self _configNetworkList];
}

- (void)_onRPanelEmpty:(NSNotification *)note
{
    [self _onRPanelEmptyViewController:NO];
}

- (void)_onRPanelEmptyViewController:(BOOL)animation {
    if (self.rpanelVCtrl) {
        float interval = animation?0.6:0;
        [UIView animateWithDuration:interval animations:^{
          CGRect frame = self.rpanelVCtrl.view.frame;
            frame.origin.x = CGRectGetMaxX(frame);
            self.rpanelVCtrl.view.frame = frame;
        } completion:^(BOOL finish) {
            [self.rpanelVCtrl.view removeFromSuperview];
            
            // hold ref by a tmp and release later, to avoid releasing during an anim
            UIViewController *tmp = [self.rpanelVCtrl retain];
            self.rpanelVCtrl = nil;
            [tmp performSelector:@selector(release) withObject:nil afterDelay:0.5];
            
           
        }];
       
    }
    
    if ([UIDevice isPortrait]) {
        [_t1v insertSubview:self.rpanelCtnV atIndex:1];
    } else {
        self.welcomePanel.view.hidden = NO;
    }
}
- (void)_onTotalUnreadCountChanged:(NSNotification *)note
{
    NSNumber *num = [note.userInfo objectForKey:@"count"];
    if (num) {
        [self _configCountV:_groupTLCountV withNum:num];
    }
}

#pragma mark - UI event handlers
- (IBAction)homeBtnTapped:(id)sender 
{
    if (nil == self.hometlVCtrl) {
        self.hometlVCtrl = [[[KWIHomeTLVCtrl alloc] init] autorelease];
        [self _configFrame4MPanelV:self.hometlVCtrl.view];
    }
    
    if (_curMpanelVCtrl != self.hometlVCtrl) {
        [self _switchMNavBtn:sender];
        [self _showVCtrlInMPanel:self.hometlVCtrl];
    }
    if(currentButton == ButtonName_Home)
    {
        [self.hometlVCtrl refreshStatus];
    }
        //[self.hometlVCtrl scrollToTop];
    else{
        currentButton = ButtonName_Home;
    }
}

- (IBAction)_mentionsBtnTapped:(id)sender
{    
    if (nil == mentionMeStatusViewController_) {
        mentionMeStatusViewController_ = [[KDMentionMeStatusViewController alloc] init] ;
        [self _configFrame4MPanelV:mentionMeStatusViewController_.view];
    }
    
    if (_curMpanelVCtrl != mentionMeStatusViewController_) {        
        [self _switchMNavBtn:sender];
        [self _showVCtrlInMPanel:mentionMeStatusViewController_];
    }    
    
    if(currentButton == ButtonName_Mention)
        //[self.mentiontlVCtrl scrollToTop];
    {
    
    }
    else
        currentButton = ButtonName_Mention;
}

- (IBAction)repliesBtnTapped:(id)sender 
{
    if (nil == commentToMeViewController_) {
        commentToMeViewController_ = [[KDCommentToMeViewController alloc] init];
        [self _configFrame4MPanelV:commentToMeViewController_.view];
    }
    
    if (_curMpanelVCtrl != commentToMeViewController_) {
        [self _switchMNavBtn:sender];
        [self _showVCtrlInMPanel:commentToMeViewController_];
    }
    
    if(currentButton == ButtonName_Comment)
        //[self.commenttlVCtrl scrollToTop];
    {
        
    }
    else
        currentButton = ButtonName_Comment;
}

- (IBAction)messagesBtnTapped:(id)sender 
{
//    if (nil == self.messagestlVCtrl) {
//        self.messagestlVCtrl = [[[KWIMessageTLVCtrl alloc] init] autorelease];
//        [self _configFrame4MPanelV:self.messagestlVCtrl.view];
//    }
        if (nil == dmThreadViewController_) {
            dmThreadViewController_= [[KDDMThreadViewController alloc] init];
            [self _configFrame4MPanelV:dmThreadViewController_.view];
       }

    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"badgeCountChange" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"count"]];
    
//    if (_curMpanelVCtrl != self.messagestlVCtrl) {
//        [self _switchMNavBtn:sender];
//        [self _showVCtrlInMPanel:self.messagestlVCtrl];
//    }
        if (_curMpanelVCtrl != dmThreadViewController_) {
            [self _switchMNavBtn:sender];
            [self _showVCtrlInMPanel:dmThreadViewController_];
        }
    
    if(currentButton == ButtonName_Message)
    {
        
    }
        //[self.messagestlVCtrl refresh];
    else
        
        currentButton = ButtonName_Message;
}

- (IBAction)_onGroupBtnTapped:(id)sender 
{
//    if (nil == self.groupLsVCtrl) {
//        self.groupLsVCtrl = [KWIGroupLsVCtrl vctrl];
//    }
//    
//    // tap group btn don't eliminate unread counts on each group
//    //_groupTLCountV.hidden = YES;
//    currentButton = ButtonName_Group;
//    
//    if (_curMpanelVCtrl != self.groupLsVCtrl) {
//        [self _switchMNavBtn:sender];
//        [self _showVCtrlInMPanel:self.groupLsVCtrl];
//    }
        if (nil == groupViewCotroller_) {
            groupViewCotroller_ = [[KDGroupViewController alloc] init];
            //[self _configFrame4MPanelV:groupViewCotroller_.view];
        }
    
        // tap group btn don't eliminate unread counts on each group
        //_groupTLCountV.hidden = YES;
        currentButton = ButtonName_Group;
    
        if (_curMpanelVCtrl != groupViewCotroller_) {
            [self _switchMNavBtn:sender];
            [self _showVCtrlInMPanel:groupViewCotroller_];
        }

}

- (IBAction)_onSearchBtnTapped:(id)sender 
{
    if (nil == self.searchVCtrl) {
        self.searchVCtrl = [KWISearchVCtrl vctrl];
        [self _configFrame4MPanelV:self.searchVCtrl.view];
    }
    
    if (_curMpanelVCtrl != self.searchVCtrl) {
        [self _switchMNavBtn:sender];
        [self _showVCtrlInMPanel:self.searchVCtrl];
    }
    
    currentButton = ButtonName_Search;
}

- (IBAction)_onSettingsBtnTapped:(id)sender 
{
    KWISettingsVCtrl *settingsVCtrl = [KWISettingsVCtrl vctrl];
    KWISettingsNavCtrl *navVCtrl = [KWISettingsNavCtrl navCtrlWithRoot:settingsVCtrl];    
    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:navVCtrl animated:YES completion:nil];
    } else {
        [self presentModalViewController:navVCtrl animated:YES];
    }
}

- (void)_onAvatarTapped:(UITapGestureRecognizer *)tgr
{
    if (nil == self.profileVCtrl) {
        self.profileVCtrl = [KWIPeopleVCtrl vctrlForProfile];
        [self _configFrame4MPanelV:self.profileVCtrl.view];
    }    
    
    if (_curMpanelVCtrl != self.profileVCtrl) {
        [self _switchMNavBtn:nil];
        [self _showVCtrlInMPanel:self.profileVCtrl];
    }
    
   // [[KDWeiboCore sharedKDWeiboCore].unread setFreshFollowers:0];
    currentButton = ButtonName_Avatar;
}

- (void)_onT0maskTapped:(UITapGestureRecognizer *)tgr
{
    
    [self closeCommunityListView];
//    CGRect defFrame = self.tierZero.frame;
//    defFrame.origin.y = 0;
//    
//    [UIView animateWithDuration:0.2
//                          delay:0
//                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
//                         self.tierZero.frame = defFrame;
//                     } 
//                     completion:^(BOOL finished) {
//                         [_t0mask removeFromSuperview];
//                         _t0mask = nil;
//                     }];
}

- (void)_configCountV:(UIButton *)countV withNum:(NSNumber *)num
{
    if (num.intValue) {        
        UIImage *img = nil;
        if (10 > num.intValue) {
            [countV setTitle:num.stringValue forState:UIControlStateNormal];
            img = [UIImage imageNamed:@"mNavCountIco_1d.png"];
        } else if (100 > num.intValue) {
            [countV setTitle:num.stringValue forState:UIControlStateNormal];
            img = [UIImage imageNamed:@"mNavCountIco_2d.png"];
        } else {
            [countV setTitle:@"99+" forState:UIControlStateNormal];
            img = [UIImage imageNamed:@"mNavCountIco_3d.png"];
        }
        
        [countV setBackgroundImage:img forState:UIControlStateNormal];
        
        CGRect frm = countV.frame;
        frm.size = img.size;
        countV.frame = frm;
        
        countV.layer.shadowColor = [UIColor blackColor].CGColor;
        countV.layer.shadowOpacity = 0.7;
        countV.layer.shadowOffset = CGSizeMake(4, 4);
        
        countV.hidden = NO;
    } else {
        countV.hidden = YES;
    }
}

- (void)_onTutorialVTapped:(UIGestureRecognizer *)gr
{
    [gr.view removeFromSuperview];
}

- (void)showCommunitySelectionTutroial {
        //if (![[SCPLocalKVStorage objectForKey:@"had_tutorial_network_v1.0.0_presented"] boolValue]) {
    if (![[[KDSession globalSession] getPropertyForKey:@"had_tutorial_network_v1.0.0_presented" fromMemoryCache:YES] boolValue]){
                    KWITutorialNetworkV *tnv = [KWITutorialNetworkV view];
                        [self.view addSubview:tnv];
                        [[KDSession globalSession] saveProperty:@(YES) forKey:@"had_tutorial_network_v1.0.0_presented" storeToMemoryCache:YES];
                   }
    
}
//- (void)kdWeiboCore:(KDWeiboCore *)core didFinishLoadFor:(id)delegate withError:(NSError *)error userInfo:(NSDictionary *)userInfo {
//    assert(delegate == self);
//    
//    dispatch_block_t block = ^ {
//        if(userInfo && [[userInfo objectForKey:@"Tag"] integerValue] == 1) {
//            KWUser *user = [[KDWeiboCore sharedKDWeiboCore] currentUser];
//            UIScreen *screen = [UIScreen mainScreen];
//            NSURL *avatarUrl = [NSURL URLWithString:user.profile_image_url];
//            if (768 < screen.currentMode.size.width) {
//                if (avatarUrl.query) {
//                    if (NSNotFound == [avatarUrl.query rangeOfString:@"spec="].location) {
//                        avatarUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@&spec=180", user.profile_image_url]];
//                    } else {
//                        NSRegularExpression *regx= [NSRegularExpression regularExpressionWithPattern:@"spec=\\d+" options:0 error:nil];
//                        NSMutableArray *matched = [NSMutableArray arrayWithCapacity:1];
//                        [regx enumerateMatchesInString:user.profile_image_url
//                                               options:0
//                                                 range:NSMakeRange(0, user.profile_image_url.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//                                                     [matched addObject:[user.profile_image_url substringWithRange:result.range]];
//                                                 }];
//                        // this loop will run only once though
//                        for (NSString *specStr in matched) {
//                            avatarUrl = [NSURL URLWithString:[user.profile_image_url stringByReplacingOccurrencesOfString:specStr withString:@"spec=180"]];
//                        }
//                    }
//                } else {
//                    avatarUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?spec=180", user.profile_image_url]];
//                }
//            }
//            [self.avatarV setImageWithURL:avatarUrl];
//        } else if(userInfo && [[userInfo objectForKey:@"Tag"] integerValue] == 2) {
//            
//            if(!error) {
//                _networks = [[KDWeiboCore sharedKDWeiboCore] netWorkList];
//                unsigned int i = 0;
//                BOOL gotCompany = NO;
//                for (KWNetwork *network in _networks) {
//                    KWNetwork *curNetWork = [KDWeiboCore sharedKDWeiboCore].currentNetWork;
//                    
//                    if(!((curNetWork == nil && network.isCompany) || [curNetWork.id_ isEqualToString:network.id_])) {
//                        KWINetworkBannerV *view = [KWINetworkBannerV viewWithNetwork:network];
//                        CGRect frame = view.frame;
//                        frame.origin.x = 160 * i + 30;
//                        frame.origin.y = 28;
//                        view.frame = frame;
//                        [_networkLsV addSubview:view];
//                        
//                        i++;
//                    }
//                    
//                    if (network.isCompany) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWNetwork.changed" object:self userInfo:[NSDictionary dictionaryWithObject:network forKey:@"network"]];
//                        gotCompany = YES;
//                    }
//                }
//                
//                if (!gotCompany) {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWNetwork.changed" object:self userInfo:[NSDictionary dictionaryWithObject:[_networks objectAtIndex:0] forKey:@"network"]];
//                }
//                
//                CGSize ctnSize = _networkLsV.frame.size;
//                UIView *lastV = [_networkLsV.subviews lastObject];
//                ctnSize.width = CGRectGetMaxX(lastV.frame) + 50;
//                _networkLsV.contentSize = ctnSize;
//                
//                if (![[SCPLocalKVStorage objectForKey:@"had_tutorial_network_v1.0.0_presented"] boolValue]) {
//                    KWITutorialNetworkV *tnv = [KWITutorialNetworkV view];
//                    [self.view addSubview:tnv];
//                    [SCPLocalKVStorage setObject:[NSNumber numberWithBool:YES] forKey:@"had_tutorial_network_v1.0.0_presented"];
//                }
//            } else {
//                //TODO:错误处理
//            }
//        }
//    };
//
//    dispatch_async(dispatch_get_main_queue(), block);
//}

@end
