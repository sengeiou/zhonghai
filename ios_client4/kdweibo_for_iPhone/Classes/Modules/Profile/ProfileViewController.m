//
//  UserDetailViewController.m
//  TwitterFon
//
//  Created by kaz on 11/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ProfileViewController.h"
#import "TrendStatusViewController.h"

#import "KDNotificationView.h"
//#import "KDUserProfileQuickLinkButton.h"
#import "KDErrorDisplayView.h"

#import "KDRequestDispatcher.h"
#import "KDWeiboServicesContext.h"
#import "KDDefaultViewControllerContext.h"
#import "KDDatabaseHelper.h"

#import "UIViewController+Navigation.h"
#import "ResourceManager.h"
#import "KDManagerContext.h"
#import "KDDMConversationViewController.h"
#import "KDABPersonActionHelper.h"
#import "KDManagerContext.h"
#import "MPFoldTransition.h"
#import "KDProfileTabItem.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

@interface ProfileViewController ()

@property(nonatomic,retain) NSString * userName;
@property (nonatomic, copy) NSString * userId;
@property(nonatomic, assign) BOOL isStartUserNetLoad;

@property (nonatomic, retain) MBProgressHUD  *activityView;

- (void)clickedMenuAtIndex:(NSInteger)index load:(BOOL)load;

@end


@implementation ProfileViewController
@synthesize user;
@synthesize friendController,fanController,blogController,detailController,trendsController;
@synthesize userId = _userId;
@synthesize userName = userName_;
@synthesize isStartUserNetLoad = isStartUserNetLoad_;
@synthesize activityView = activityView_;


- (id)initWithUser:(KDUser*)aUser {
    self = [super init];
    if (self) {
        self.user = aUser;
        _segmentIndex = 2;
    }
    
	return self;
}

- (id)initWithUser:(KDUser *)aUser andSelectedIndex:(NSUInteger)index {
    self = [self initWithUser:aUser];
    if(self) {
        _segmentIndex = (int)index;
    }
    
    return self;
}

- (id)initWithUserId:(NSString *)userId {
    self = [super init];
    if(self) {
        _viewFlags.initWithUserId = 1;
        _userId = [userId copy];
    }
    
    return self;
}

- (id)initWithUserId:(NSString *)userId andSelectedIndex:(NSUInteger)index {
    self = [self initWithUserId:userId];
    if(self) {
        _segmentIndex = (int)index;
    }
    
    return self;
}

- (id)initWithUserName:(NSString *)userName {
    self = [super init];
    if (self) {
        userName_ = userName ;//retain];
        _viewFlags.initWithUserName = 1;
        _segmentIndex = 2;
    }
    
    return self;
}

- (id)initWithUserName:(NSString *)userName andSelectedIndex:(NSUInteger)index {
    self = [self initWithUserName:userName];
    if(self) {
        _segmentIndex = (int)index;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateSomeViewInfo];
    
    self.navigationItem.title = ASLocalizedString(@"ProfileViewController_navigationItem_title");
    
    CGRect bounds = self.view.bounds;
    CGRect frame = CGRectZero;
    
    // top header view
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - ([self isBigScreen] ? 0 : 10), bounds.size.width, 223 - ([self isBigScreen] ? 0 : 10))] ;//autorelease];
    headerView.backgroundColor = [UIColor clearColor];
    
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:headerView];
    
    //add user profile bg view
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_profile_bg_v3.png"]];
    bgImageView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(headerView.frame), 145.0f - ([self isBigScreen] ? 0 : 10));
    [headerView addSubview:bgImageView];
//    [bgImageView release];
    
    // User profile view
    avatarView_ = [[KDAnimationAvatarView alloc] initWithFrame:CGRectMake(26.5f, 27.0f, 90.0f, 90.0f) andNeedHighLight:NO];
    [avatarView_ changeAvatarImageTo:[UIImage imageNamed:@"user_avatar_placeholder_v3.png"] animation:NO];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOnUserAvatar:)];
    [avatarView_ addGestureRecognizer:tap];
//    [tap release];

    
    userNameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(149.0f, 31.0f, 160.0f, 18.0f)];
    userNameLabel_.textColor = [UIColor whiteColor];
    userNameLabel_.backgroundColor = [UIColor clearColor];
    userNameLabel_.font = [UIFont boldSystemFontOfSize:16.0f];
    userNameLabel_.text = user.screenName;
    
    departmentLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(userNameLabel_.frame.origin.x, CGRectGetMaxY(userNameLabel_.frame) + 5.0f, 160.0f, 15.0f)];
    departmentLabel_.font = [UIFont systemFontOfSize:15.0f];
    departmentLabel_.backgroundColor = [UIColor clearColor];
    departmentLabel_.textColor = [UIColor whiteColor];
    departmentLabel_.text = user.department;
    
    jobLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(userNameLabel_.frame), CGRectGetMaxY(departmentLabel_.frame) + 5.0f, 160.0f, 15.0f)];
    jobLabel_.font = [UIFont systemFontOfSize:13.0f];
    jobLabel_.backgroundColor = [UIColor clearColor];
    jobLabel_.textColor = [UIColor whiteColor];
    jobLabel_.text = user.jobTitle ? user.jobTitle : @"";
    
    [headerView addSubview:avatarView_];
//    [avatarView_ release];
    [headerView addSubview:userNameLabel_];
//    [userNameLabel_ release];
    [headerView addSubview:departmentLabel_];
//    [departmentLabel_ release];
    [headerView addSubview:jobLabel_];
//    [jobLabel_ release];
    
    loadView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];// /autorelease];
    loadView.frame = CGRectMake(148,16,24,24);
    [self.view addSubview:loadView];
    
    [self setupRightView];
    
    [self setupUserProfileMenuView];
    
    frame = CGRectMake(0.0, CGRectGetMaxY(headerView.frame), bounds.size.width, bounds.size.height - CGRectGetMaxY(headerView.frame));
    
    // friends
    self.friendController = [[NetworkUserController alloc] initWithNibName:nil bundle:nil] ;//autorelease];
    friendController.isFollowee = YES;
    friendController.view.frame = frame;
    
    friendController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:friendController.view];
    
    // followers
    self.fanController = [[NetworkUserController alloc ]initWithNibName:nil bundle:nil];// autorelease];
    fanController.isFollowee = NO;
    fanController.view.frame = frame;
    
    fanController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:fanController.view];
    
    self.blogController = [[BlogViewController alloc] initWithNibName:nil  bundle:nil];// autorelease];
    blogController.view.frame = frame;
    
    blogController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:blogController.view];
    
    
    if([self shouldShowContact]) {
        self.detailController = [[KDABPersonDetailsViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
        detailController.view.frame = frame;
        detailController.actionHelper.viewController = self;
        detailController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:detailController.view];
    }else {
        self.trendsController = [[KDTrendsViewController alloc] initWithTrendsType:KDTrendsViewControllerTypeJoined];// autorelease];
        trendsController.view.frame = frame;
        
        trendsController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:trendsController.view];
    }
    
    
    //set the controllers user
    [self upDateControllersUser];
}

- (BOOL)isCompany {
    return [[KDManagerContext globalManagerContext].communityManager isCompanyDomain];
}

- (BOOL)shouldShowContact {
    return ([[KDManagerContext globalManagerContext].communityManager isCompanyDomain] || [[KDWeiboAppDelegate getAppDelegate] isInTeam]) && !user.isTeamUser;
}

- (void)more {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(user.profileImageUrl) {
        [avatarView_ setAvatarImageURL:user.profileImageUrl];
    }
    
    if (!isStartUserNetLoad_) {
        isStartUserNetLoad_ = YES;
        
        [self clickedMenuAtIndex:_segmentIndex load:YES];
        
        [self loadUser];
        [self showActivityView];
    }
}

- (void)updateSomeViewInfo {
    ownInfo = [[KDManagerContext globalManagerContext].userManager isCurrentUserId:user.userId];
    
    [self applyAttributes];
    [loadView startAnimating];
}

- (BOOL)isBigScreen {
    return (CGRectGetHeight(self.view.frame) > 480.0f);
}

- (void)setupRightView {
    // friendship button
    UIImage *friendImage = [UIImage imageNamed:@"user_profile_follow_btn_bg_v3"];
    friendImage = [friendImage stretchableImageWithLeftCapWidth:friendImage.size.width * 0.5f topCapHeight:friendImage.size.height * 0.5f];
    
    UIImage *dmImage = [UIImage imageNamed:@"user_profile_dm_btn_bg_v3"];
    dmImage = [dmImage stretchableImageWithLeftCapWidth:dmImage.size.width * 0.5f topCapHeight:dmImage.size.height * 0.5f];
    
    friendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [friendButton setBackgroundImage:friendImage forState:UIControlStateNormal];
    [friendButton addTarget:self action:@selector(friendButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [friendButton setTitle:ASLocalizedString(@"ProfileViewController_Unfollow")forState:UIControlStateNormal];
    [friendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    friendButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    friendButton.frame = CGRectMake(150.0f, 100.0f, 72.0f, 28.0f);
    
    [headerView addSubview:friendButton];
    [self freshFollowButton];
    
    // direct message button
    dmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dmButton setBackgroundImage:dmImage forState:UIControlStateNormal];
    [dmButton setTitle:ASLocalizedString(@"发短邮")forState:UIControlStateNormal];
    dmButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [dmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [dmButton addTarget:self action:@selector(dmButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    dmButton.frame = CGRectMake(CGRectGetMaxX(friendButton.frame) + 12.0f, CGRectGetMinY(friendButton.frame), CGRectGetWidth(friendButton.frame), CGRectGetHeight(friendButton.frame));
    
    [headerView addSubview:dmButton];
    
    [self upDateFriendButtonHidden];
}

///给用户发短邮
- (void)dmButtonPress:(id)sender {
    __block KDUser *curUser = [KDManagerContext globalManagerContext].userManager.currentUser;
    if(curUser == nil) {
        [KDDatabaseHelper inDatabase:^id(FMDatabase *fmdb){
            id<KDUserDAO> userDAO = [KDWeiboDAOManager globalWeiboDAOManager].userDAO;
            NSString *curUserId = [KDManagerContext globalManagerContext].userManager.currentUserId;
            
            return [userDAO queryUserWithId:curUserId database:fmdb];
        }completionBlock:^(id result) {
            curUser = (KDUser *)result;
        }];
    }
    
    KDDMConversationViewController *con = [[KDDMConversationViewController alloc] initWithParticipants:[NSArray arrayWithObjects:curUser, self.user, nil]];// autorelease];
    [self.navigationController pushViewController:con animated:YES];
}


///关注用户或者取消关注
- (void)friendButtonPress:(id)sender {
    [loadView startAnimating];
    friendButton.enabled = NO;
    
    if (following) {
        [self destoryFriendship];

	} else {		
        [self createFriendship];
	}
}


//点击头像响应事件
- (void)clickedOnUserAvatar:(UIGestureRecognizer *)gesture {
    if([user hasImageSource]){

        NSString *url = [user bigImageURL];
        MJPhoto *photo = [[MJPhoto alloc] init];// autorelease];
        photo.url = [NSURL URLWithString:url];
        photo.placeholder = [[SDWebImageManager sharedManager] diskImageForURL:[NSURL URLWithString:url]];
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init] ;//autorelease];
        browser.currentPhotoIndex = 0;
        browser.photos = [NSArray arrayWithObject:photo];
        [browser show];

    }
}

- (void)upDateControllersUser
{
    if (user) {
        if (friendController) {
            friendController.owerUser = user;  
        }
        
        if (fanController) {
            fanController.owerUser = user;  
        }
        
        if (blogController) {
            blogController.user = user;  
        }
        
        if (trendsController) {
            trendsController.user = user;
        }
        
        if(detailController) {
            detailController.userId = user.userId;
        }
    }
}

- (void)upDateFriendButtonHidden
{
    friendButton.hidden=ownInfo;
    dmButton.hidden = ownInfo;
}

- (void)updateInfo {
    [avatarView_ setAvatarImageURL:self.user.profileImageUrl];
    userNameLabel_.text = self.user.screenName;
    
    if([[KDManagerContext globalManagerContext].communityManager isCompanyDomain]) {
        departmentLabel_.text = self.user.department;
    }
    else {
        departmentLabel_.text = self.user.companyName;
    }
    
    jobLabel_.text = self.user.jobTitle ? self.user.jobTitle : @"";
}

- (KDProfileTabItem *)itemWithName:(NSString *)itemName value:(NSString *)val tag:(NSInteger)tag {
    KDProfileTabItem *item = [[KDProfileTabItem alloc] initWithFrame:CGRectZero];
    
    item.value = val;
    item.name = itemName;
    item.tag = tag;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
    [item addGestureRecognizer:tap];
//   /  [tap release];
    
    return item ;//autorelease];
}

- (void) setupUserProfileMenuView {
    
    if(tabItems_ == nil) {
        tabItems_  = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    [tabItems_ removeAllObjects];
    
    NSString *value = nil;
    //关注
    value = [NSString stringWithFormat:@"%ld", (long)user.friendsCount];
    [tabItems_ addObject:[self itemWithName:NSLocalizedString(@"FRIENDSHIPS", @"") value:value tag:0x00]];
    //粉丝
    value = [NSString stringWithFormat:@"%ld", (long)user.followersCount];
    [tabItems_ addObject:[self itemWithName:NSLocalizedString(@"FOLLOWERS", @"") value:value tag:0x01]];
    //微博
    value = [NSString stringWithFormat:@"%ld", (long)user.statusesCount];
    [tabItems_ addObject:[self itemWithName:NSLocalizedString(@"STATUSES", @"") value:value tag:0x02]];
    //联系方式
    if([self shouldShowContact]) {
        [tabItems_ addObject:[self itemWithName:NSLocalizedString(@"CONTACT", @"") value:nil tag:0x03]];
    }else {
        value = [NSString stringWithFormat:@"%ld", (long)user.topicsCount];
        [tabItems_ addObject:[self itemWithName:NSLocalizedString(@"TOPIC", @"") value:value tag:0x03]];
    }
    
    CGFloat offsetY = 145.0f - ([self isBigScreen] ? 0 : 10);
    CGFloat itemWidth = CGRectGetWidth(headerView.frame) * 0.25f;
    for(NSInteger index = 0; index < 4; index++) {
        KDProfileTabItem *item = [tabItems_ objectAtIndex:index];
        [headerView addSubview:item];
        item.frame = CGRectMake(index * itemWidth , offsetY, itemWidth, 50.0f);
        
        if(index != 0) {
            UIView *vSeperator = [[UIView alloc] initWithFrame:CGRectMake(index * itemWidth, offsetY, 1.0f, 50.0f)];
            vSeperator.backgroundColor = RGBCOLOR(203, 203, 203);
            [headerView addSubview:vSeperator];
//            [vSeperator release];
        }
    }
    
    UIView *tipInfo = [[UIView alloc] initWithFrame:CGRectMake(0.0f, offsetY + 50.0f, CGRectGetWidth(headerView.frame), CGRectGetHeight(headerView.frame) - offsetY - 50.0f)];
    tipInfo.backgroundColor = RGBCOLOR(237, 237, 237);
    currentTabItemInfoLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, CGRectGetWidth(tipInfo.frame) - 24.0f, CGRectGetHeight(tipInfo.frame))];
    currentTabItemInfoLabel_.backgroundColor = [UIColor clearColor];
    currentTabItemInfoLabel_.textColor = RGBCOLOR(109, 109, 109);
    currentTabItemInfoLabel_.font = [UIFont systemFontOfSize:13.0f];
    [tipInfo addSubview:currentTabItemInfoLabel_];
//    [currentTabItemInfoLabel_ release];
    [headerView addSubview:tipInfo];
//    [tipInfo release];
    
    UIView *hSeperator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, offsetY + 50.0f, CGRectGetWidth(headerView.frame), 1.0f)];
    hSeperator.backgroundColor = RGBCOLOR(203, 203, 203);
    [headerView addSubview:hSeperator];
//    [hSeperator release];
}

- (void)clickedMenuAtIndex:(NSInteger)index load:(BOOL)load {
    KDProfileTabItem *oldItem = (KDProfileTabItem *)[tabItems_ objectAtIndex:_segmentIndex];
    [oldItem setSelected:NO];
    
    _segmentIndex = (int)index;
    
    KDProfileTabItem *newItem = (KDProfileTabItem *)[tabItems_ objectAtIndex:index];
    [newItem setSelected:YES];
    if(index != 3) {
        currentTabItemInfoLabel_.text = [NSString stringWithFormat:@"%@(%@)", newItem.name, newItem.value];
    }else {
        currentTabItemInfoLabel_.text = newItem.name;
    }
    
    BOOL shoudLoad = (load && user != nil) ? YES : NO;
    
    switch (index) {
        case 0x00:
        {
            if (shoudLoad) {
                [friendController loadUserData];
            }
            [self.view bringSubviewToFront:friendController.view];
            
            break;
        }
            
        case 0x01:
        {
            if (shoudLoad) {
                [fanController loadUserData];
            }
            [self.view bringSubviewToFront:fanController.view];
            
            break;
        }
            
        case 0x02:
        {
            if (shoudLoad) {
                [blogController loadUserData];
            }
            [self.view bringSubviewToFront:blogController.view];
            
            break;
        }
            
        case 0x03:
        {
            if([self shouldShowContact]) {
                if (shoudLoad) {
                    [detailController loadPersonAddressBookInfo];
                }
                [self.view bringSubviewToFront:detailController.view];
            }else {
                if (shoudLoad) {
                    [trendsController loadUserData];
                }
                [self.view bringSubviewToFront:trendsController.view];
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (void)itemTapped:(UITapGestureRecognizer *)tapGesture {
    NSInteger tag = tapGesture.view.tag;
    
    [self clickedMenuAtIndex:tag load:YES];
}

- (void) showActivityView {
    if(activityView_ == nil) {
      
        self.activityView = [[MBProgressHUD alloc] initWithView:self.view];// autorelease];
        [self.view addSubview:activityView_];
          activityView_.completionBlock = ^(){
          if ([activityView_ superview]) {
                [activityView_ removeFromSuperview];
            }
            
            //KD_RELEASE_SAFELY(activityView_);
        };
        activityView_.labelText = NSLocalizedString(@"LOADING_USER_INFO", @"");

        [activityView_ show:YES];
    }
}

- (void) hidenActivityView {
    if (activityView_) {
        [activityView_ hide:YES];
    }    
}

//TODO:rebuild
- (void)loadUser {
    __block ProfileViewController *pvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [pvc hidenActivityView];
        if (results != nil) {
            pvc.user = results;
            
            [pvc upDateControllersUser];
            
            [pvc updateInfo];
            
            [pvc updateSomeViewInfo];
            
            [pvc upDateFriendButtonHidden];
            
            if (ownInfo) {
                // make the weak reference point to nil
                dmButton = nil;
                friendButton = nil;
                
                [pvc loadTrendsCount];
                
            } else {
                [pvc checkFriendship];
            }
            
            // update current user
            [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                [userDAO saveUser:(KDUser *)results database:fmdb];
                
                return nil;
                
            } completionBlock:nil];
            
        } else {
            if (![response isCancelled]) {
                NSString *errorMessage = nil;
                NSDictionary *jsonObject = [response responseAsJSONObject];
                if (jsonObject != nil) {
                    NSString *status = [jsonObject stringForKey:@"message"];
                    NSRange range = [status rangeOfString:@"user id or screen_name not found"];
                    if (range.location != NSNotFound) {
                        errorMessage = NSLocalizedString(ASLocalizedString(@"ProfileViewController_NoUser"), @"");
                    }
                }
                
                if(errorMessage == nil){
                    errorMessage = NSLocalizedString(ASLocalizedString(@"ProfileViewController_Data_Err"), @"");
                }
                
                [pvc showNotificationMessage:errorMessage showOnPreviousView:YES];
                [pvc.navigationController popViewControllerAnimated:YES];
            }
        }
        
        // release current view controller
//        [pvc release];
    };
    
    KDQuery *query = [KDQuery query];
    
    NSString *actionPath = @"/users/:show";

    if(_viewFlags.initWithUserId == 1) {
        [query setParameter:@"id" stringValue:_userId];
        [query setProperty:_userId forKey:@"userId"];
        actionPath = @"/users/:showById";
    }else if(_viewFlags.initWithUserName == 1) {
        [query setParameter:@"screen_name" stringValue:userName_];
    }else {
        [query setParameter:@"user_id" stringValue:user.userId];
    }
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
}

//TODO: rebuild
- (void)loadTrendsCount {
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:user.userId];
    
    __block ProfileViewController *pvc = self ;//retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                (pvc -> user).topicsCount = [(NSNumber *)results integerValue];
                
                [pvc applyAttributes];
                [pvc clickedMenuAtIndex:pvc->_segmentIndex load:YES];
            }
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:pvc.view.window];
            }
        }
        
        [pvc -> loadView stopAnimating];
        
        // release current view controller
//        [pvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/users/:followedTopicNumber" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)_handleFriendshipResponse:(KDResponseWrapper *)response withResults:(id)results {
    if([response isValidResponse]) {
        if (results != nil) {
            self.user = results;
            
            [self applyAttributes];
            following = !following;
            
            [self freshFollowButton];
            
            // update current user info into database
            [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                [userDAO saveUser:user database:fmdb];
                
                return nil;
                
            } completionBlock:nil];
        }
    } else {
        if (![response isCancelled]) {
            [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:self.view.window];
        }
    }
    
    friendButton.enabled = YES;
    [loadView stopAnimating];
}

- (void)createFriendship {
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:user.userId];
    
    __block ProfileViewController *pvc = self ;//retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [pvc _handleFriendshipResponse:response withResults:results];
        
        // release current view controller
//        [pvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/friendships/:create" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)destoryFriendship {
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:user.userId];
    
    __block ProfileViewController *pvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [pvc _handleFriendshipResponse:response withResults:results];
        
        // release current view controller
//        [pvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/friendships/:destroy" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)checkFriendship {
    NSString *currentUserId = [KDManagerContext globalManagerContext].userManager.currentUserId;
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"user_a" stringValue:currentUserId]
            setParameter:@"user_b" stringValue:user.userId];
    
    __block ProfileViewController *pvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                pvc -> following = [(NSNumber *)results boolValue];
                [pvc freshFollowButton];
                
                [pvc loadTrendsCount];
            }
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:pvc.view.window];
            }
            
            [pvc -> loadView stopAnimating];
        }
        
        // release current view controller
//        [pvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/friendships/:exists" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)showNotificationMessage:(NSString *)message showOnPreviousView:(BOOL)showOnPrevious {
    UIView *baseOnView = nil;
    if (showOnPrevious) {
        NSArray *viewControllers = [self.navigationController viewControllers];
        NSUInteger count = [viewControllers count];
        if (count >= 2) {
            UIViewController *previous = [viewControllers objectAtIndex:(count - 2)];
            baseOnView = previous.view;
            
        }else {
            baseOnView = self.view.window;
        }
        
    } else {
        baseOnView = self.view;
    }
    
    [[KDNotificationView defaultMessageNotificationView] showInView:baseOnView
                                                            message:message
                                                               type:KDNotificationViewTypeNormal];
}

//刷新FriendShip的图片
- (void)freshFollowButton {
	[friendButton setTitle:(following ? ASLocalizedString(@"ProfileViewController_Unfollow"): ASLocalizedString(@"ProfileViewController_Follow")) forState:UIControlStateNormal];
}


-(NSString *)getUserNumber:(int)segmentIndex
{
    int number=0;
    switch (segmentIndex) {
        case 0:
            number= (int)user.friendsCount;
            break;
        case 1:
            number=(int)user.followersCount;
            break;
        case 2:
            number=(int)user.statusesCount;
            break;
        case 3:
            number=(int) user.topicsCount;
            break;
            
        default:
            break;
    }
    return  [NSString stringWithFormat:@"%d",number];;
}

- (void)applyAttributes {
    KDProfileTabItem *item = (KDProfileTabItem *)[tabItems_ objectAtIndex:0x00];
    [item setValue:[NSString stringWithFormat:@"%ld", (long)user.friendsCount]];
    
    item = (KDProfileTabItem *)[tabItems_ objectAtIndex:0x01];
    [item setValue:[NSString stringWithFormat:@"%ld", (long)user.followersCount]];
    
    item = (KDProfileTabItem *)[tabItems_ objectAtIndex:0x02];
    [item setValue:[NSString stringWithFormat:@"%ld", (long)user.statusesCount]];
    // topic count
    if(![self shouldShowContact]) {
        item = (KDProfileTabItem *)[tabItems_ objectAtIndex:0x03];
        [item setValue:[NSString stringWithFormat:@"%ld", (long)user.topicsCount]];
    }
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - KDMenuViewDelegate Methods
- (void)menuView:(KDMenuView *)menuView clickedMenuItemAtIndex:(NSInteger)index {
    
}

- (void)menuView:(KDMenuView *)menuView configMenuButton:(UIButton *)button atIndex:(NSUInteger)index {
    button.backgroundColor = [UIColor orangeColor];
}

//////////////////////////////////////////////////////////////////////

// Override (UIViewController category)
- (void)viewControllerWillDismiss {
    [friendController viewControllerWillDismiss];
    [fanController viewControllerWillDismiss];
    [blogController viewControllerWillDismiss];
    [detailController viewControllerWillDismiss];
        
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (void)viewDidUnload {
    //KD_RELEASE_SAFELY(activityView_);
    
    [super viewDidUnload];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(blogController);
    //KD_RELEASE_SAFELY(fanController);
    //KD_RELEASE_SAFELY(detailController);
    //KD_RELEASE_SAFELY(friendController);
    //KD_RELEASE_SAFELY(trendsController);
    
    //KD_RELEASE_SAFELY(user);
    //KD_RELEASE_SAFELY(_userId);
    //KD_RELEASE_SAFELY(userName_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(tabItems_);

    //[super dealloc];
}

@end
