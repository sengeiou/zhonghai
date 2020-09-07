//
//  PostViewController.m
//  TwitterFon
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PostViewController.h"

#import "KDCommon.h"

#import "KDWeiboAppDelegate.h"
#import "DraftViewController.h"
#import "ProfileViewController2.h"

#import "KDNotificationView.h"

#import "KDWeiboServicesContext.h"
#import "KDDefaultViewControllerContext.h"
#import "KDUtility.h"
#import "KDDatabaseHelper.h"

#import "TwitterText.h"

#import "UIImage+Additions.h"
#import "NSDate+Additions.h"
#import "NSString+Additions.h"

#import "KDLocationView.h"
#import "KDLocationOptionViewController.h"
#import "KDLocationManager.h"
#import "KDLocationData.h"
#import "UIImage+Additions.h"
#import "KDPicturePickedPreviewViewController.h"

#import "KDImagePickerController.h"
#import "KDImagePostPreviewView.h"

#import "KDImageUploadTask.h"

#import "HPGrowingTextView.h"

#import "FriendsTimelineController.h"

#import "MBProgressHUD.h"

#import "KDGroupStatus.h"

#import "KDVideoPickerViewController.h"

#import "KDVideoCaptureManager.h"

#import "KDVideoPlayerManager.h"

#import "KDVideoPlayerController.h"

#import "KDAttachment.h"

#import "KDPostPhotoPreviewController.h"

#import "KDFrequentContactsPickViewController.h"

#import "KDErrorDisplayView.h"

#import "KDUploadTaskHelper.h"

#import "KDDMChatInputExtendView.h"

#import "KDUserAvatarView.h"
#import "KDStatusDetailView.h"
#import "UIButton+KDV6.h"
#import "KDGroup.h"

#import "KDSelectRangeViewController.h"

#define KD_USER_PROFILE_HEIGHT    44.0
#define KD_USER_AVATAR_SIZE       32.0
static CGFloat const selectViewHeight = 50.0;

#define KD_PICKED_IMAGE_LOCAL_THUMBNAIL_CACHE_NAME      @"_thumb"


@interface PostViewController ()<KDLocationOptionViewControllerDelegate, KDImagePickerControllerDelegate, KDImagePostPreviewViewDelegate, HPGrowingTextViewDelegate, KDVideoPickerViewDelegate, KDVideoPlayerManagerDelegate, KDPostPhotoPreviewDelegate, KDFrequentContactsPickViewControllerDelegate, KDRequestWrapperDelegate,KDDMChatInputExtendViewDelegate, KDStatusDetailViewDelegate, UIScrollViewDelegate>
{
    BOOL isExpressionViewShown;
}

@property (nonatomic, retain) HPGrowingTextView *textView;
@property (nonatomic, retain) KDPostActionMenuView *actionMenuView;

@property (nonatomic, retain) UIView *atFriendsContainerView;

@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, retain) NSMutableArray *pickedImageCachePath;

@property (nonatomic, retain) NSString *contentBackup;
@property (nonatomic, retain) KDLocationView *locationView;
@property (nonatomic, retain) NSArray *locationDataArray;
@property (nonatomic, retain) KDLocationData *currentLocationData;
@property (nonatomic, retain) KDLocationOptionViewController *locationOptionViewController;
@property (nonatomic, retain) KDImagePostPreviewView *imagePreviewView;
@property (nonatomic, retain) __block NSMutableArray *selectedImagesAssetUrl;
@property (nonatomic, retain) KDImagePickerController *imagePickerController;
@property (nonatomic, assign) BOOL photosChanged;
@property (nonatomic, retain) NSString *videoPath;
@property (nonatomic, retain) KDDMChatInputExtendView *extentView;
@property (nonatomic, retain) UILabel *wordLimitsLabel;
@property (nonatomic, assign) NSUInteger maxwordLimit;

@property (nonatomic, retain) UIScrollView *externalViewContainer;
@property (nonatomic, retain) UIView *externalView;
@property (nonatomic, retain) UIView *userProfilView;
@property (nonatomic, retain) KDUserAvatarView *avatarView;
@property (nonatomic, retain) UIButton *userNameBtn;
@property (nonatomic, retain) UILabel *sourceLabel;
@property (nonatomic, retain) KDStatusDetailView *statusDetailView;

@property (nonatomic, retain) UIView *selectRangeView;
@property (nonatomic, assign) CGFloat selectRangeViewHeight;

@property (nonatomic, strong) KDGroup *selectedGroup;

@end


@implementation PostViewController

@synthesize textView=textView_;
@synthesize actionMenuView=actionMenuView_;
@synthesize atFriendsContainerView=atFriendsContainerView_;

@synthesize operationQueue=operationQueue_;
@synthesize pickedImageCachePath=pickedImageCachePath_;
@synthesize contentBackup=contentBackup_;

@synthesize bLoadbyLongPress;

@synthesize draftViewController=draftViewController_;
@synthesize draft=draft_;
@synthesize locationView = locationView_;

@synthesize locationDataArray = locationDataArray_;
@synthesize currentLocationData = currentLocationData_;
@synthesize locationOptionViewController = locationOptionViewController_;
@synthesize extentView = extentView_;
@synthesize wordLimitsLabel = wordLimitsLabel_;

@synthesize externalViewContainer = externalViewContainer_;
@synthesize externalView = externalView_;
@synthesize userProfilView = userProfileView_;
@synthesize avatarView = avatarView_;
@synthesize userNameBtn = userNameBtn_;
@synthesize sourceLabel = sourceLabel_;
@synthesize statusDetailView = statusDetailView_;


NSString * const kKDFriendSendingWeiboNotification = @"KDFriendSendingWeiboNotification";
NSString * const kKDFriendSendedWeiboNotification = @"KDFriendSendedWeiboNotification";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        postViewControllerFlags_.initialized = 1;
        postViewControllerFlags_.imageFromUnsendDraft = 0;
        
        // if the content from a draft, and the thumbnail did generate before load view.
        // then present thumbnail after view did appear.
        postViewControllerFlags_.delayPresentThumbnail = 0;
        postViewControllerFlags_.viewDidUnload = 0;
        postViewControllerFlags_.didCancelPickImage = 0;
        
        textView_ = nil;
        actionMenuView_ = nil;
        atFriendsContainerView_ = nil;
        
        operationQueue_ = nil;
        pickedImageCachePath_ = nil;
        contentBackup_ = nil;
        
        bLoadbyLongPress = NO;
        
        draftViewController_ = nil;
        draft_ = nil;
        
        isExpressionViewShown = NO;
        hasAtFlag = NO;
        
        self.selectedImagesAssetUrl = [NSMutableArray array];
        
        self.maxwordLimit = KD_MAX_WEIBO_TEXT_LENGTH;
        self.selectRangeViewHeight = 0;
        
        // keyboard notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidSucess:) name:KDNotificationLocationSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFailed:) name:KDNotificationLocationFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidInit:) name:KDNotificationLocationInit object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidstart:) name:KDNotificationLocationStart object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSendingProgress:) name:@"kKDServiceStatusesProgressNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSendingProgress:) name:@"VideoProgress" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rangeUpdate:) name:@"RangeUpdated" object:nil];
    }
    
    return self;
}

- (void) loadView {
    
    UIView *aView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = aView;
    self.view.backgroundColor = [UIColor kdBackgroundColor2];//MESSAGE_BG_COLOR;
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressBg:)];
    press.minimumPressDuration = 0.5;
    press.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:press];

    
    
    self.externalViewContainer = [[UIScrollView alloc] initWithFrame:CGRectZero];// autorelease];
    self.externalViewContainer.backgroundColor = [UIColor clearColor];
    externalViewContainer_.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(externalViewContainerTap:)];// autorelease];
    [self.externalViewContainer addGestureRecognizer:tap];
    
    [self.view addSubview:externalViewContainer_];
    
    [self setupNavigationItems];
    
    // text edit view
    
    [self setupTextView];
    
    // action menu view
    
    [self setupWordLimitLabel];
    
    [self setupActionMenuView];
    
    [self setupLoactionView];
    
    //zgbin:屏蔽“转发” 20180402
    //回复是否转发或转发是否回复
//    [self setupExtentView];
    //zgbin:end
    
    // 发新微博可选择发送范围选择
    if (draft_.type == KDDraftTypeNewStatus) {
        self.selectRangeViewHeight = selectViewHeight;
        [self setUpSelectRangeView];
    } else {
        self.selectRangeViewHeight = 0;
    }
    
    [self.view bringSubviewToFront:wordLimitsLabel_];
}

- (void)externalViewContainerTap:(UITapGestureRecognizer *)gesture
{
    if([textView_ isFirstResponder]) {
        [textView_ resignFirstResponder];
    }
}

- (void)setDraft:(KDDraft *)draft {
    if (draft_ != draft) {
      
        draft_ = draft;// retain];
        if (draft_.groupId) {
            self.maxwordLimit = KD_MAX_WEIBO_TEXT_LENTH_IN_GROUP;
        }
    }
}

- (void)setOriginalStatus:(KDStatus *)originalStatus
{
    if(_originalStatus != originalStatus) {
//        [_originalStatus release];
        _originalStatus = originalStatus;// retain];
        
        [self setupOriginalStatusView];
    }
}

- (void)setAttachment:(KDAttachment *)attachment {
    if (_attachment != attachment) {
//        [_attachment release];
        _attachment = attachment;// retain];
    }
}

- (void)update
{
    [self setupOriginalStatusView];
}

- (void)setupOriginalStatusView {
    if(!userProfileView_) {
        userProfileView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kd_StatusBarAndNaviHeight, self.view.bounds.size.width - 20, 45.0f)];
        userProfileView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        userProfileView_.backgroundColor = [UIColor clearColor];
        
        avatarView_ = [KDUserAvatarView avatarView];// retain];
        avatarView_.frame = CGRectMake(12.0f, 10.0f, 34.0f, 34.0f);
        [userProfileView_ addSubview:avatarView_];
        
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
    
    avatarView_.avatarDataSource = _originalStatus.author;
    if(!avatarView_.hasAvatar)
        [avatarView_ setLoadAvatar:YES];
    
    [userNameBtn_ setTitle:_originalStatus.author.screenName forState:UIControlStateNormal];
    [userNameBtn_ sizeToFit];
    
    CGRect frame  = userNameBtn_.bounds;
    frame.size.width = fminf(frame.size.width, 180);
    frame.size.height = 20;
    frame.origin.x = CGRectGetMaxX(avatarView_.frame) + 9;
    frame.origin.y = CGRectGetMinY(avatarView_.frame)-2;
    userNameBtn_.frame = frame;
    
    
    sourceLabel_.text = [NSString stringWithFormat:ASLocalizedString(@"KDStatusDetailViewController_sourceLabel_text"),[_originalStatus createdAtDateAsString],_originalStatus.source];
    
    frame = sourceLabel_.frame;
    frame.origin.x =  CGRectGetMinX(userNameBtn_.frame);
    frame.origin.y = CGRectGetMaxY(userNameBtn_.frame) +5;
    sourceLabel_.frame = frame;
    
    if(!statusDetailView_) {
        statusDetailView_ = [[KDStatusDetailView alloc] initWithFrame:CGRectMake(0.0f, userProfileView_.frame.size.height, self.view.bounds.size.width -20, 0.0f)];
        statusDetailView_.delegate = self;
        statusDetailView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    statusDetailView_.status = _originalStatus;
    
    if(externalView_) {
        [externalView_ removeFromSuperview];
//        [externalView_ release];
    }
    
    externalView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, statusDetailView_.frame.size.height + userProfileView_.frame.size.height + 12)];
    externalView_.backgroundColor = [UIColor clearColor];
    frame = externalView_.bounds;
    frame.origin.y = 10;
    frame.origin.x = 10;
    frame.size.height -= 2;
    frame.size.width -= 20;
    
    UIView *background = [[UIView alloc] initWithFrame:frame];// autorelease];
    background.backgroundColor = [UIColor kdBackgroundColor2];
    CALayer * layer = [background layer];
    layer.borderColor = [UIColor kdBackgroundColor2].CGColor;
    layer.borderWidth = 0.5;
    
//    [externalView_ addSubview:background];
//    [background release];
    
    frame = userProfileView_.frame;
    frame.size.width = background.bounds.size.width;
    userProfileView_.frame = frame;
    frame = statusDetailView_.bounds;
    frame.origin.y = CGRectGetMaxY(userProfileView_.frame);
    frame.size.width = background.bounds.size.width;
    statusDetailView_.frame = frame;
    
    [background addSubview:userProfileView_];
    [background addSubview:statusDetailView_];
    
    [externalViewContainer_ addSubview:externalView_];
    externalViewContainer_.contentSize = externalView_.frame.size;
}

- (void)setupWordLimitLabel {
    
    // wordLimitsLabel_.frame = CGRectMake(self.bounds.size.width - 45.0, - self.bounds.size.height + 20.f, 40.0, 20.f);
    wordLimitsLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 55.0,  self.view.bounds.size.height , 50.0, 20.f)];
    wordLimitsLabel_.backgroundColor = [UIColor clearColor];
    wordLimitsLabel_.font = [UIFont systemFontOfSize:17.0];
    wordLimitsLabel_.textColor = MESSAGE_NAME_COLOR;
    wordLimitsLabel_.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:wordLimitsLabel_];
}

- (void)setupExtentView {
    
    //如果是小组的不能出现。
    if (self.draft && (((self.draft.type == KDDraftTypeCommentForComment||
                         self.draft.type == KDDraftTypeCommentForStatus)&& !self.draft.groupId)||
                       self.draft.type == KDDraftTypeForwardStatus)) {
        extentView_ = [[KDDMChatInputExtendView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, CGRectGetWidth(self.view.bounds), 39)];
        NSString *title = (self.draft.type == KDDraftTypeCommentForComment ||self.draft.type == KDDraftTypeCommentForStatus)?ASLocalizedString(@"PostViewController_title_weibo"):[NSString stringWithFormat:ASLocalizedString(@"PostViewController_title_replay"),self.draft.replyScreenName];
        extentView_.textLabel.text = title;
        extentView_.delegate = self;
        [self.view addSubview:extentView_];
    }
}

- (void)setUpSelectRangeView {
    self.selectRangeView = [[UIView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, self.view.bounds.size.width, self.selectRangeViewHeight)];// autorelease];
    self.selectRangeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.selectRangeView];
    
    if (self.isSelectRange) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectRangeViewTap:)];// autorelease];
        [self.selectRangeView addGestureRecognizer:tap];
    }
    
    if (self.selectedGroup) {
        draft_.groupId = self.selectedGroup.groupId;
        draft_.groupName = self.selectedGroup.name;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedGroup.profileImageURL]];
        UIImage *image = [UIImage imageWithData:data];
        draft_.groupImage = image;
    }
    
    UILabel *toLabel = [[UILabel alloc] init];// autorelease];
    toLabel.text = [NSString stringWithFormat:ASLocalizedString(@"PostViewController_send_to"),draft_.groupName ? draft_.groupName : ASLocalizedString(@"KDSignInSettingViewController_group_name")];
    toLabel.font = FS2;
    toLabel.textColor = MESSAGE_NAME_COLOR;
    [toLabel sizeToFit];
    [self.selectRangeView addSubview:toLabel];
    
    UIImageView *headImageView = [[UIImageView alloc] init];// autorelease];
    if (draft_.groupImage) {
        headImageView.image = draft_.groupImage;
    } else {
        headImageView.image = [UIImage imageNamed:@"sign_in_share_company"];
    }
    headImageView.layer.cornerRadius = 5;
    headImageView.layer.masksToBounds = YES;
    [self.selectRangeView addSubview:headImageView];
    
    UIImageView *accessoryImageView = [[UIImageView alloc] init];// autorelease];
    accessoryImageView.image = [UIImage imageNamed:self.isSelectRange ? @"profile_edit_narrow_v3" : @""];
    [self.selectRangeView addSubview:accessoryImageView];
    
    UIView *lineView = [[UIView alloc] init];// autorelease];
    lineView.alpha = 0.4;
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.selectRangeView addSubview:lineView];
    
    // 布局
    [toLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(toLabel.superview);
        make.leading.equalTo(toLabel.superview).with.offset(10);
        
    }];
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headImageView.superview);
        make.leading.equalTo(toLabel.trailing).with.offset(5);
        make.width.height.mas_equalTo(30);
    }];
    [accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(accessoryImageView.superview);
        make.trailing.equalTo(accessoryImageView.superview.trailing).with.offset(-10);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(20);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(lineView.superview);
        make.height.mas_equalTo(1);
    }];
}

- (void)setupTextView {
    HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    textView.backgroundColor = [UIColor kdBackgroundColor2];//MESSAGE_CT_COLOR;
    textView.internalTextView.backgroundColor = [UIColor kdBackgroundColor2];//MESSAGE_CT_COLOR;
    
//    textView.layer.borderColor = MESSAGE_LINE_COLOR.CGColor;
//    textView.layer.borderWidth = 0.5f;
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 100;
    
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView = textView;
//    [textView release];
    
    textView_.delegate = self;
    textView_.growingDelegate = self;
    textView_.font = [UIFont systemFontOfSize:18];
    
    [self.view addSubview:textView_];
    
    self.imagePreviewView.frame =  CGRectMake(0.0f, 0.f, self.view.bounds.size.width, 0.0);
    
    //    [self.view addSubview:self.imagePreviewView];
    
    if ([self.draft hasVideo]) {
        self.imagePreviewView.hidden = NO;
        self.videoPath = self.draft.videoPath;
        UIImage *image = [KDVideoCaptureManager thumbnailImageForVideo:[NSURL fileURLWithPath:self.videoPath] atTime:0.0];
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.videoPath error:nil];
        NSNumber *size = [attributes objectForKey:NSFileSize];
        [self.imagePreviewView setVideoThumbnail:image withSize:[NSString stringWithFormat:@"%dkb", size.intValue / 1024]];
        [self savePickedImage:image];
        self.textView.attacthView = self.imagePreviewView;
    }else if ([self.selectedImagesAssetUrl count] > 0) {
        self.imagePreviewView.hidden = NO;
        [self.imagePreviewView setShowAddedButton:[self showAddImageButton]];
        [self.imagePreviewView setAssetURLs:self.selectedImagesAssetUrl];
        self.textView.attacthView = self.imagePreviewView;
    }else if (self.fileDataModel != nil) {
        self.imagePreviewView.frame =  CGRectMake(0.0f, 0.f, self.view.bounds.size.width, 50.0);
        self.imagePreviewView.hidden = NO;
        self.imagePreviewView.fileDataModel = self.fileDataModel;
        self.textView.attacthView = self.imagePreviewView;
    }
    
    textRange.location = [textView_.text length];
    textRange.length = 0;
}

- (void)setupActionMenuView {
    KDPostActionMenuView *actionMenuView = [[KDPostActionMenuView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height-44.0, self.view.bounds.size.width, 44.0)];
    self.actionMenuView = actionMenuView;
//    [actionMenuView release];
    
    actionMenuView_.delegate = self;
    
    actionMenuView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:actionMenuView_];
}

- (void)setupNavigationItems
{
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:self.backBtnTitle];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];// autorelease];
    [backBtn addTarget:self action:@selector(cancelPostStatus:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[barButtonItem];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(0, 0, 35, 30);
    [sendBtn setTitle:ASLocalizedString(@"Global_Send")forState:UIControlStateNormal];
    sendBtn.titleLabel.font = FS5;
    [sendBtn setTitleColor:FC5 forState:UIControlStateNormal];
    [sendBtn setTitleColor:FC7 forState:UIControlStateHighlighted];
    [sendBtn setTitleColor:FC3 forState:UIControlStateDisabled];
    [sendBtn addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:sendBtn] ;//autorelease];
    self.navigationItem.rightBarButtonItems = @[rightItem];
    
//    self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(cancelPostStatus:)];
    
//    self.navigationItem.rightBarButtonItems = [KDCommon rightNavigationItemWithTitle:ASLocalizedString(@"Global_Send")target:self action:@selector(send:)];
}

- (void)selectRangeViewTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    KDSelectRangeViewController *selectRangVC = [[KDSelectRangeViewController alloc] init];// autorelease];
    [self.navigationController pushViewController:selectRangVC animated:YES];
}

- (void)pressBg:(UILongPressGestureRecognizer *)ges
{
    UIMenuController *copyController = [UIMenuController sharedMenuController];
    [copyController setTargetRect:self.textView.bounds inView:self.textView];
    [copyController setMenuVisible:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // app at initlization mode
    // view did receive memory wanring when try to take photo or pick photo
    // need put the content to the stage again.
    if (postViewControllerFlags_.initialized == 1 || postViewControllerFlags_.viewDidUnload == 1) {
        postViewControllerFlags_.initialized = 0;
        
        [self setPostViewContent];
        [self updateWordLimitsLabel];
    }
    
    if([textView_.internalTextView canBecomeFirstResponder]){
        [textView_.internalTextView becomeFirstResponder];
    }
    
    [self displayLoactonIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textView.internalTextView resignFirstResponder];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(bLoadbyLongPress && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        bLoadbyLongPress = NO;
        [self showImagePicker:YES];
    }
    
    // if user picked a photo and try to pick new one to replace it. and now, The image picker (take photo)
    // did appear on stage. then application got memory warning at same time, the post view controller will call viewDidUnload
    // And if user cancel take photo or pick image, put the previous image to stage again.
    if(postViewControllerFlags_.viewDidUnload == 1){
        if(contentBackup_ != nil){
            textView_.text = contentBackup_;
        }
    }
    
    postViewControllerFlags_.viewDidUnload = 0;
    
    //    [actionMenuView_ startVedioAnimation];
    
    if (extentView_) {
        [extentView_ setChecked:self.draft.doExtraCommentOrForward];
    }
    
}

- (void)adjustVisibleViewWithAnimated:(BOOL)animated show:(BOOL)show curve:(int)curve duration:(NSTimeInterval)duration keyboardHeight:(CGFloat)keyboardHeight {
    [UIView animateWithDuration:duration
                     animations:^{
                         CGRect rect = actionMenuView_.frame;
                         CGFloat offsetY = self.view.bounds.size.height - keyboardHeight - rect.size.height;
                         rect.origin.y = offsetY;
                         actionMenuView_.frame = rect;
                         
                         
                         rect = locationView_.frame;
                         rect.origin.y = self.actionMenuView.frame.origin.y - CGRectGetHeight(rect)-10;
                         locationView_.frame = rect;
                         
                         if (extentView_) {
                             rect = extentView_.frame;
                             offsetY = CGRectGetMinY(actionMenuView_.frame) - CGRectGetHeight(rect);
                             rect.origin.y = offsetY;
                             extentView_.frame = rect;
                             
                             rect = wordLimitsLabel_.frame;
                             rect.origin.y = offsetY + (CGRectGetHeight(extentView_.frame) - CGRectGetHeight(wordLimitsLabel_.frame)) * 0.5f;
                             wordLimitsLabel_.frame = rect;
                             
                             rect = locationView_.frame;
                             rect.origin.y = self.extentView.frame.origin.y - CGRectGetHeight(rect);
                             locationView_.frame = rect;
                         }else {
                             rect = wordLimitsLabel_.frame;
                             rect.origin.y = locationView_.frame.origin.y;
                             wordLimitsLabel_.frame = rect;
                         }
                         
                         rect = self.view.bounds;
//                         if(extentView_) {
//                             rect.size.height = CGRectGetMinY(extentView_.frame);
//                         }else {
//                             rect.size.height = CGRectGetMinY(locationView_.frame) + wordLimitsLabel_.frame.size.height + 5;
//                         }
//                         
//                         if(externalView_) {
//                             externalViewContainer_.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), MIN(CGRectGetHeight(externalView_.frame), rect.size.height * 0.5f - 5.0f));
//                             
//                             rect.origin.y = CGRectGetMaxY(externalViewContainer_.frame) + 5.0f;
//                             rect.size.height *= 0.5f;
//                             rect.size.height -= 5.0f;
//                         }
                         
                         rect.origin.x = 10.0f;
                         rect.origin.y = kd_StatusBarAndNaviHeight + self.selectRangeViewHeight;
                         rect.size.width -= 20.0f;
                         if(extentView_)
                             rect.size.height = ScreenFullHeight-kd_StatusBarAndNaviHeight-keyboardHeight-90 - self.selectRangeViewHeight - kd_BottomSafeAreaHeight;
                         else
                             rect.size.height = ScreenFullHeight-kd_StatusBarAndNaviHeight-keyboardHeight-50 - self.selectRangeViewHeight - kd_BottomSafeAreaHeight;
                         
                         textView_.frame = rect;
                         textView_.contentSize = rect.size;
                         
                         
                         if (keyboardHeight <= 0) {
                             [textView_ setMaxHeight:4000];
                             textView_.isScrollable = NO;
                         } else {
                             [textView_ setMaxHeight:rect.size.height];
                             textView_.isScrollable = YES;
                         }
                         
                         rect = self.externalViewContainer.frame;
                         rect.origin.y = kd_StatusBarAndNaviHeight + self.selectRangeViewHeight;
                         rect.size.height -= self.selectRangeViewHeight;
                         self.externalViewContainer.frame = rect;
                     }];
}

- (void)postContentsEnabled:(BOOL)enabled {
    ((UIButton *)self.navigationItem.rightBarButtonItem.customView).enabled = enabled;
    //修正iOS7下微博一直可发送bug
    [[self.navigationItem.rightBarButtonItems lastObject] setEnabled:enabled];
}

- (void)setPickPhotoMenuButtonItemHidden:(BOOL)hidden {
    [actionMenuView_ menuButtonItemHidden:hidden atIndex:0x01];
}

- (void)setLocationMenuButtonItemHidden:(BOOL)hidden {
    [actionMenuView_ menuButtonItemHidden:hidden atIndex:0x00];
}

- (void)setVideoMenuButtonItemHidden:(BOOL)hidden {
    [actionMenuView_ menuButtonItemHidden:hidden atIndex:0x02];
}

- (void)cancelPostStatus:(UIButton *)btn {
    if([textView_.internalTextView isFirstResponder]) {
        [textView_.internalTextView resignFirstResponder];
    }
    
    if([self canSaveAsDraft]) {
        
        if (isAboveiOS8) {
            UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *save = [UIAlertAction actionWithTitle:ASLocalizedString(@"PostViewController_Save_Draft") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                draft_.sending = NO;
                [self saveAsDraft];
                [self _showNotificationViewDidSaveDraft];
                [self dismiss];
            }];
            UIAlertAction *noSave = [UIAlertAction actionWithTitle:ASLocalizedString(@"PostViewController_NoSave") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self removeDraftFlags];
                [self dismiss];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIAlertActionStyleCancel handler:nil];
            [sheet addAction:save];
            [sheet addAction:noSave];
            [sheet addAction:cancel];
            [self presentViewController:sheet animated:YES completion:nil];
        } else {
            UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil];
            as.tag = 2012;
            
            [as addButtonWithTitle:ASLocalizedString(@"PostViewController_Save_Draft")];
            [as addButtonWithTitle:ASLocalizedString(@"PostViewController_NoSave")];
            [as addButtonWithTitle:ASLocalizedString(@"Global_Cancel")];
            as.cancelButtonIndex = [as numberOfButtons] - 1;
            
            [as showInView:self.view];
        }
        
    } else {
        [self removeDraftFlags];
        
        [self dismiss];
    }
}

- (NSMutableArray *)pickedImageCachePath
{
    if (!pickedImageCachePath_) {
        pickedImageCachePath_ = [[NSMutableArray alloc] init];
    }
    return pickedImageCachePath_;
}

- (KDImagePostPreviewView *)imagePreviewView
{
    if (!_imagePreviewView) {
        _imagePreviewView = [[KDImagePostPreviewView alloc] init];
        _imagePreviewView.userInteractionEnabled = YES;
        _imagePreviewView.delegate = self;
        _imagePreviewView.hidden = YES;
    }
    return _imagePreviewView;
}
#pragma mark - 发送微博btn
- (void)send:(UIButton *)btn {
    if(draft_.type == KDDraftTypeForwardStatus) {
        if (![textView_ hasText]) {
            textView_.text = ASLocalizedString(@"DraftTableViewCell_tips_3");
        }
    }
    
    textView_.text = [self trimLastNewlineCharacterSet];
    
    if (![textView_ hasText] && [self.selectedImagesAssetUrl count] <= 0 && !self.videoPath){
        return;
    }
    
    
    if ((draft_.type == KDDraftTypeNewStatus || draft_.type == KDDraftTypeCommentForComment || draft_.type == KDDraftTypeCommentForStatus || draft_.type == KDDraftTypeShareSign) && ![textView_ hasText] && self.videoPath) {
        draft_.content = ASLocalizedString(@"PostViewController_Share_Video");
        textView_.text = ASLocalizedString(@"PostViewController_Share_Video");
    }else if ((draft_.type == KDDraftTypeNewStatus || draft_.type == KDDraftTypeCommentForComment || draft_.type == KDDraftTypeCommentForStatus  || draft_.type == KDDraftTypeShareSign) && ![textView_ hasText] && !self.videoPath && [self.pickedImageCachePath count] > 0 ) {
        draft_.content = ASLocalizedString(@"KDDMMessageDAOImpl_share_picture");
        textView_.text = ASLocalizedString(@"KDDMMessageDAOImpl_share_picture");
    }
    
    if(self.selectedImagesAssetUrl.count > 0){
        draft_.assetURLs = self.selectedImagesAssetUrl;
    }
    if (self.videoPath.length > 0) {
        draft_.videoPath = self.videoPath;
        draft_.assetURLs = self.pickedImageCachePath;
    }else if (self.videoPath.length <= 0 && self.selectedImagesAssetUrl.count <= 0){
        draft_.videoPath = nil;
        draft_.assetURLs = nil;
        [self removeLocalCachedVideo];
        [self removeLocalCachedPickImage];
    }
    
    NSString *text = textView_.text;
    draft_.content = text;
    
    KDStatus *status = [draft_ sendingStatus:self.pickedImageCachePath videoPath:self.videoPath];
    
    if (_photosChanged) {
        [draft_ resetUploadFlag];
    }
    if (draft_.saved) {
        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
            id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
            if (![status isGroup]) {
                [statusDAO removeStatusWithId:status.statusId database:fmdb];
            }else {
                [statusDAO removeGroupStatusWithId:status.statusId database:fmdb];
            }
            
            id<KDAttachmentDAO> attachmentDAO = [[KDWeiboDAOManager globalWeiboDAOManager] attachmentDAO];
            [attachmentDAO removeAttachmentsForObjectId:status.statusId database:fmdb];
            
            id<KDCompositeImageSourceDAO> imageSourceDAO = [[KDWeiboDAOManager globalWeiboDAOManager] compositeImageSourceDAO];
            [imageSourceDAO removeCompositeImageSourceWithEntityId:status.statusId database:fmdb];
        }completionBlock:nil];
    }
    if (self.attachment) {
        status.attachments = @[self.attachment];
    }
    
    //获得uploadTask对象
    KDStatusUploadTask *task = [KDStatusUploadTask taskByDraft:draft_ status:status];
    [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:task entityId:status.statusId];
    
    
    //saved draft before send
    
    [self dismiss];
    
}


//纯保存，与 SaveAsDraft 不同
- (void)saveDraft {
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
        
        if (draft_.saved) {
            [draft_ realMask];
            [draftDAO updateDraft:draft_ database:fmdb];
            
        } else {
            [draftDAO saveDraft:draft_ database:fmdb];
        }
        
        return nil;
        
    } completionBlock:nil];
}

- (void)cacheSendedImage:(KDStatus *)status
{
    int imageIndex = 0;
    
    for (NSString *path in self.pickedImageCachePath) {
        if (status.compositeImageSource.bigImageURLs.count <= imageIndex || status.compositeImageSource.bigImageURLs.count <= imageIndex || status.compositeImageSource.bigImageURLs.count <=imageIndex) {
            break;
        }
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];// autorelease];
        
        NSData *data = [image asJPEGDataWithQuality:1.0f];
        
        [[KDCache sharedCache] storeImageData:data forURL:[status.compositeImageSource.bigImageURLs objectAtIndex:imageIndex] imageType:KDCacheImageTypePreview];
        
        [[KDCache sharedCache] storeImageData:data forURL:[status.compositeImageSource.bigImageURLs objectAtIndex:imageIndex] imageType:KDCacheImageTypeOrigin];
        [[KDCache sharedCache] storeImageData:data forURL:[status.compositeImageSource.bigImageURLs objectAtIndex:imageIndex] imageType:KDCacheImageTypePreviewBlur];
        
        UIImage *thumbnail = [image generateThumbnailWithSize:[KDImageSize defaultMiddleImageSize].size];
        
        data = [thumbnail asJPEGDataWithQuality:0.5];
        [[KDCache sharedCache] storeImageData:data forURL:[status.compositeImageSource.thumbnailImageURLs objectAtIndex:imageIndex] imageType:KDCacheImageTypePreview];
        
        UIImage *middle = [image generateThumbnailWithSize:[KDImageSize defaultMiddleImageSize].size];
        
        data = [middle asJPEGDataWithQuality:0.75];
        [[KDCache sharedCache] storeImageData:data forURL:[status.compositeImageSource.middleImageURLs objectAtIndex:imageIndex] imageType:KDCacheImageTypeMiddle];
        
        imageIndex++;
    }
}

- (void)showPhotoActionOptions {
    
    [self.textView resignFirstResponder];
    
    if (isAboveiOS8) {
        UIAlertController *sheetVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        __weak __typeof(self) weakSelf = self;
        UIAlertAction *camera = [UIAlertAction actionWithTitle:ASLocalizedString(@"KDDMChatInputView_tak_photo") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (weakSelf.pickedImageCachePath.count < 9) {
                [weakSelf showImagePicker:YES];
            }else {
                UIWindow *keyWindow = [[UIApplication sharedApplication].windows objectAtIndex:1];
                [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"PostViewController_Alert")inView:keyWindow];
            }
            
        }];
        UIAlertAction *photo = [UIAlertAction actionWithTitle:ASLocalizedString(@"PostViewController_Choose_Photo") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf showImagePicker:NO];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIAlertActionStyleCancel handler:nil];
        if (!self.videoPath) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [sheetVC addAction:camera];
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                [sheetVC addAction:photo];
            }
        }
        [sheetVC addAction:cancel];
        [self presentViewController:sheetVC animated:YES completion:nil];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        actionSheet.tag = 2011;
        
        NSInteger idx = 0;
        
        if (!self.videoPath) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [actionSheet addButtonWithTitle:ASLocalizedString(@"KDDMChatInputView_tak_photo")];
                idx++;
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                [actionSheet addButtonWithTitle:ASLocalizedString(@"PostViewController_Choose_Photo")];
                idx++;
            }
            
        }
        
        [actionSheet addButtonWithTitle:ASLocalizedString(@"Global_Cancel")];
        
        actionSheet.cancelButtonIndex = idx;
        
        [actionSheet showInView:self.view];
    }
}

- (void)atFriend {
    KDFrequentContactsPickViewController *fvc = [[KDFrequentContactsPickViewController alloc] initWithType:KDFrequentContactsType_At];// autorelease];
    fvc.delegate = self;
    
    [self.navigationController pushViewController:fvc animated:YES];
}

- (void)importPopularTopic {
    KDTrendEditorViewController *tevc = [[KDTrendEditorViewController alloc] initWithNibName:nil bundle:nil];
    tevc.delegate = self;
    
    [self.navigationController pushViewController:tevc animated:YES];
//    [tevc release];
}

- (void)switchExpressionView {
    if(!expressionInputView_) {
        
        expressionInputView_ = [[KDExpressionInputView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 216.0f)];
        expressionInputView_.delegate = self;
        [expressionInputView_ setSendButtonShown:NO];
        
        [self.view addSubview:expressionInputView_];
    }
    
    if([textView_.internalTextView isFirstResponder]) {
        [textView_.internalTextView resignFirstResponder];
    }else {
        [textView_.internalTextView becomeFirstResponder];
    }
}

- (void)saveAsDraft {
    draft_.content = [self trimLastNewlineCharacterSet];
    
    if ((draft_.type == KDDraftTypeNewStatus || draft_.type == KDDraftTypeCommentForComment || draft_.type == KDDraftTypeCommentForStatus) && ![textView_ hasText] && self.videoPath) {
        draft_.content = ASLocalizedString(@"PostViewController_Share_Video");
    }else if ((draft_.type == KDDraftTypeNewStatus || draft_.type == KDDraftTypeCommentForComment || draft_.type == KDDraftTypeCommentForStatus) && ![textView_ hasText] && !self.videoPath && [self.pickedImageCachePath count] > 0) {
        draft_.content = ASLocalizedString(@"KDDMMessageDAOImpl_share_picture");
    }
    
    if(self.selectedImagesAssetUrl.count > 0){
        draft_.assetURLs = self.selectedImagesAssetUrl;
    }
    
    if (self.videoPath.length > 0) {
        draft_.videoPath = self.videoPath;
        draft_.assetURLs = self.pickedImageCachePath;
    }else if (self.videoPath.length <= 0 && self.selectedImagesAssetUrl.count <= 0){
        draft_.videoPath = nil;
        draft_.assetURLs = nil;
        [self removeLocalCachedVideo];
        [self removeLocalCachedPickImage];
    }
    
    
    
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
        id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
        
        if (draft_.saved) {
            [draft_ realMask];
            [draftDAO updateDraft:draft_ database:fmdb];
            
        } else {
            [draftDAO saveDraft:draft_ database:fmdb];
        }
        
        return nil;
        
    } completionBlock:nil];
    
    if(draftViewController_ != nil){
        [self removeDraftFlags];
        
        [draftViewController_ didSaveDraftToDatabase:draft_];
        
    }else {
        UIViewController *vc = [[KDDefaultViewControllerContext defaultViewControllerContext] topViewController];
        if([vc isMemberOfClass:[ProfileViewController2 class]]){
            [(ProfileViewController2 *)vc shouldUpdateQuickLinkMenuTitle];
        }
    }
    
    //[self dismiss];
}

- (BOOL)canSaveAsDraft {
    return (draftViewController_ || [textView_ hasText] || self.pickedImageCachePath.count > 0) ? YES : NO;
}

- (void)_showNotificationViewDidSaveDraft {
    
    [[KDNotificationView defaultMessageNotificationView] showInView:self.view.window
                                                            message:NSLocalizedString(@"SAVE_AS_DRAFT_SUCCESS", @"")
                                                               type:KDNotificationViewTypeNormal];
}

//需要计算的文字
- (NSString *)stringTobeCounted {
    NSString *result = [self trimLastNewlineCharacterSet];
    //    if(draft_ && draft_.address ){
    //        if (result) {
    //            result =[result stringByAddLocationInfo:draft_.address
    //                                         coordinate:draft_.coordinate];
    //        }
    //       //result = result stringByAppendingString:[result ]
    //    }
    return result;
    
}
- (void)updateWordLimitsLabel {
    BOOL sendable = NO;
    
    int remainingCount = [TwitterText remainingCharacterCount:[self stringTobeCounted] inMaxCount:(int)self.maxwordLimit];
    if (remainingCount == self.maxwordLimit) {
        // forward status can not with any text
        if (draft_.type == KDDraftTypeForwardStatus) {
            sendable = YES;
            
        } else {
            sendable = (self.pickedImageCachePath.count > 0) ? YES : NO;
        }
        
    } else if (remainingCount < 0) {
        sendable = NO;
        
    }else {
        sendable = YES;
    }
    
    [self postContentsEnabled:sendable];
    
    wordLimitsLabel_.textColor = (remainingCount < 0) ? [UIColor redColor] :[UIColor colorWithRed:155.0f/255 green:155.0f/255 blue:155.0f/255 alpha:1.0f];
    wordLimitsLabel_.text = [NSString stringWithFormat:@"%d", remainingCount];
}

- (void)appendText:(NSString *)text {
    if(text == nil) return;
    
    if(postViewControllerFlags_.viewDidUnload == 1){
        // current view controller did receieve memory warning
        // and text view did destoried. So append the text to tempoary variable
        
        self.contentBackup = [NSString stringWithFormat:@"%@%@", (contentBackup_ != nil) ? contentBackup_ : @"", text];
        return;
    }
    
    // append text to current text input cursor
    NSMutableString *body = [NSMutableString string];
    BOOL tail = YES;
    NSUInteger idx = 0;
    NSUInteger location = NSNotFound;
    if([textView_ hasText]){
        [body appendString:textView_.text];
        
        NSRange range = textView_.selectedRange;
        if(range.location != NSNotFound && range.location < [body length]){
            tail = NO;
            idx = location = range.location;
        }
    }
    
    if(tail){
        [body appendString:text];
        
    }else {
        [body insertString:text atIndex:idx];
        location += [text length];
    }
    
    textView_.text = body;
    if(location != NSNotFound){
        textView_.selectedRange = NSMakeRange(location, 0);
    }
    
    [self updateWordLimitsLabel];
}

- (void)setPostViewContent {
    NSString *title = nil;
    BOOL hiddenImagePicker = YES;
    BOOL hiddenLocation = YES;
    BOOL hiddenVideoPicker = YES;
    
    if (draft_.type == KDDraftTypeNewStatus || draft_.type == KDDraftTypeShareSign) {
        title = ASLocalizedString(@"PostViewController_Edit_weibo");
        hiddenImagePicker = NO;
        hiddenLocation = NO;
        hiddenVideoPicker = NO;
        textView_.text = draft_.content;
        
    } else if(draft_.type == KDDraftTypeForwardStatus){
        title = ASLocalizedString(@"DraftTableViewCell_tips_3");
        textView_.text = draft_.content;
        textView_.selectedRange = NSMakeRange(0, 0);
        
    } else if(draft_.type == KDDraftTypeCommentForStatus || draft_.type == KDDraftTypeCommentForComment) {
        title = ASLocalizedString(@"DraftTableViewCell_tips_4");
        textView_.text = draft_.content;
        hiddenImagePicker = NO;
        hiddenVideoPicker = NO;
    }
    
    self.title = title;
    [self setPickPhotoMenuButtonItemHidden:hiddenImagePicker];
    [self setLocationMenuButtonItemHidden:hiddenLocation];
    [self setVideoMenuButtonItemHidden:hiddenVideoPicker];
}

// this method use for resend draft
- (void)setPickedImage:(NSArray *)imagePaths {
    
    self.selectedImagesAssetUrl = [NSMutableArray arrayWithArray:imagePaths];
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    
    for (NSString *url in imagePaths) {
        
        [assetLibrary assetForURL:[NSURL URLWithString:url] resultBlock:^(ALAsset *asset)  {
            UIImage *image =[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            [self willSavePickedImage:image];
        }failureBlock:^(NSError *error) {
            DLog(@"error=%@",error);
        }];
        
    }
//    [assetLibrary release];
    
}

// this method use for resend draft
- (void)setVideoThumbnail:(NSArray *)imagePaths {
    
    
}

- (void)saveThumbnailImage:(UIImage *)image {
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //    [self generateThumbnail:image];
    
//    [pool release];
}

- (void)removeDraftFlags {
    if(draft_.saved){
        [draft_ setProperty:nil forKey:kKDDraftBlockedPropertyKey];
    }else {
        [self removeLocalCachedPickImage];
        [self removeLocalCachedVideo];
    }
}

- (void)dismiss {
    [actionMenuView_ explicitlyStopVedioAnimation];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (KDImagePickerController *)imagePickerController
{
    if (!_imagePickerController) {
        _imagePickerController  = [[KDImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsMultipleSelection = YES;
        _imagePickerController.maximumNumberOfSelection = 9;
        _imagePickerController.limitsMaximumNumberOfSelection = YES;
    }
    return _imagePickerController;
}


//
// Photo Uploading
//
- (void)showImagePicker:(BOOL)hasCamera {
    [self.textView.internalTextView resignFirstResponder];
    if (hasCamera) { //弹出拍照ViewController
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.delegate = self;
        picker.allowsEditing = NO;
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
//        [picker release];
    } else { //弹出照片选择ViewController
        self.imagePickerController.showAssetView = YES;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.imagePickerController];
        self.imagePickerController.selectedAssetUrls = self.selectedImagesAssetUrl;
        
        [self presentViewController:navigationController animated:YES completion:nil];
//        [navigationController release];
    }
}

- (void)takeVideo
{
    NSString *file = [NSString stringWithFormat:@"__Video__%f.mp4", [NSDate timeIntervalSinceReferenceDate]];
    
    NSString *outputPath = [[KDUtility defaultUtility] searchDirectory:KDDownloadVideosTempDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
    
    outputPath = [outputPath stringByAppendingPathComponent:file];
    
    KDVideoPickerViewController *videoController = [[KDVideoPickerViewController alloc] initWithVideoPath:outputPath];
    videoController.delegate = self;
    [self presentViewController:videoController animated:YES completion:nil];
//    [videoController release];
    
}

- (void)displayLoactonIfNeeded {
    UIButton *btn = [actionMenuView_ menuButtonItemAtIndex:0];
    if (draft_.address && [draft_.address length] >0) {
        btn.selected = YES;
        //[self setupLoactionView];
        [self showLocationView];
        [self.locationView setAddrText:[draft_ address]];
    }else {
        btn.selected = NO;
        [self disablesLocaiton];
    }
}


- (void)showLocationView {
    locationView_.hidden = NO;
    //[locationView_ startLocating];
}

- (void)hideLocationView {
    locationView_.hidden = YES;
}

- (void)setupLoactionView {
    if(locationView_ == nil) {
        locationView_ = [[KDLocationView alloc] initWithFrame:CGRectMake(12, self.actionMenuView.frame.origin.y - 40.f, 265, 27)];
        locationView_.userInteractionEnabled = YES;
        UITapGestureRecognizer *rgzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationLabelTapped:)];
        [locationView_ addGestureRecognizer:rgzr];
//        [rgzr release];
        [self.view addSubview:locationView_];
        
    }
}

- (BOOL)canGoToLocationOption {
    return (currentLocationData_ !=nil && locationDataArray_!= nil);
}

- (void)enablesLocation {
    //[self setupLoactionView];
    [self showLocationView];
    //[locationView_ startLocating];
    //[[KDLocationManager globalLocationManager] setDelegate:self];
    [[KDLocationManager globalLocationManager] setLocationType:KDLocationTypeNormal];
    [[KDLocationManager globalLocationManager] startLocating];
    
}

- (void)disablesLocaiton {
    [self hideLocationView];
    [[KDLocationManager globalLocationManager]disableLocating];
    self.currentLocationData = nil;
}

- (void)setCurrentLocationData:(KDLocationData *)currentLocationData {
    if (currentLocationData_ != currentLocationData) {
//        [currentLocationData_ release];
        currentLocationData_ = currentLocationData;// retain];
        if (currentLocationData_) {
            draft_.coordinate = currentLocationData.coordinate;
            draft_.address = currentLocationData.name;
            if (locationView_) {
                [self.locationView setAddrText:draft_.address];
            }
        }else {
            draft_.address = nil;
        }
        [self updateWordLimitsLabel];
    }
}

- (void)updateSendingProgress:(NSNotification *)nofitifation
{
    KDWeiboAppDelegate *app = [KDWeiboAppDelegate getAppDelegate];
    MTStatusBarOverlay *overlay = [app getOverlay];
    if([draft_ hasVideo]){
        KDRequestProgressMonitor *progressMonitor = [nofitifation.userInfo objectForKey:@"progressMonitor"];
        int percent = [progressMonitor finishedPercent] * 100;
        if ([draft_ hasVideo] && percent > 0) {
            [overlay postMessage:[NSString stringWithFormat:ASLocalizedString(@"PostViewController_Video_Upload"), percent] animated:NO];
        }
    }else {
        NSDictionary *info = nofitifation.object;
        NSNumber *progress = [info objectForKey:@"progress"];
        KDDraft *draft = [info objectForKey:@"draft"];
        if([draft hasImages] && ![draft hasVideo]) {
            [overlay postMessage:[NSString stringWithFormat:ASLocalizedString(@"PostViewController_Picture_Upload"), (int)(progress.floatValue * 100)] animated:NO];
        }
    }
}

#pragma mark -
#pragma KDRequestWrapperDelegate methods

- (void)requestWrapper:(KDRequestWrapper *)requestWrapper request:(ASIHTTPRequest *)request progressMonitor:(KDRequestProgressMonitor *)progressMonitor {
    if([draft_ hasVideo]){
        float percent = [progressMonitor finishedPercent];
        
        KDWeiboAppDelegate *app = [KDWeiboAppDelegate getAppDelegate];
        MTStatusBarOverlay *overlay = [app getOverlay];
        if ([draft_ hasVideo]) {
            [overlay postMessage:[NSString stringWithFormat:ASLocalizedString(@"PostViewController_Video_Upload"), (int)(percent * 100)] animated:NO];
        }else if([draft_ hasImages]) {
            [overlay postMessage:[NSString stringWithFormat:ASLocalizedString(@"PostViewController_Picture_Upload"), (int)(percent * 100)] animated:NO];
        }
        
    }
}


/////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark  UITapGestureRecognizer action  method
- (void)locationLabelTapped:(UITapGestureRecognizer *)rgzr {
    NSLog(@"tapped:");
    if ([self canGoToLocationOption]) {
        //if (locationOptionViewController_ == nil) {
        locationOptionViewController_ = [[KDLocationOptionViewController alloc] init];
//            locationOptionViewController_.mapView = [[KDWeiboAppDelegate getAppDelegate] mapView];
        locationOptionViewController_.delegate = self;
        //}
        locationOptionViewController_.optionsArray = self.locationDataArray;
        locationOptionViewController_.locationData = self.currentLocationData;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:locationOptionViewController_];
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [self presentViewController:nav animated:YES completion:nil];
            
        }else {
            [self presentViewController:nav animated:YES completion:nil];
        }
//        [nav release];
    }
    
}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark KDPostActionMenuView delegate method
- (void)postActionMenuView:(KDPostActionMenuView *)postActionMenuView clickOnMenuItem:(UIButton *)menuItem {
    NSUInteger idx = [postActionMenuView.menuItems indexOfObject:menuItem];
    if (0x00 == idx) {
        //
        if (menuItem.selected) {
            [self enablesLocation];
            //[self startLocating];
        }else {
            [self disablesLocaiton];
        }
    }else if(0x01 == idx){
        if (!([self.pickedImageCachePath count] > 0 && self.videoPath) && self.fileDataModel == nil) {
            // pick photo
            [self showPhotoActionOptions];
        }
        menuItem.selected = self.videoPath.length <= 0 && [self.pickedImageCachePath count] > 0 && self.fileDataModel == nil;
    }else if(0x02 == idx){ //拍摄
        if (!([self.pickedImageCachePath count] > 0) && self.fileDataModel == nil) {
            // take Video
            [self takeVideo];
        }
        menuItem.selected = self.videoPath.length > 0 && self.fileDataModel == nil;
    }else if(0x03 == idx){
        // at friend
        [self atFriend];
    }else if(0x04 == idx) {
        // import popular topic
        [self importPopularTopic];
    }else if(0x05 == idx) { // 表情
        [self switchExpressionView];
    }
}


#pragma mark -
#pragma mark KDTrendEditorViewController delegate method

- (void)trendEditorViewController:(KDTrendEditorViewController *)tevc didPickTopicText:(NSString *)topicText {
    [self appendText:topicText];
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark The keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    rect = [self.view convertRect:rect toView:nil];
    
    if(isExpressionViewShown) {
        isExpressionViewShown = NO;
        [UIView animateWithDuration:0.25 animations:^(void){
            expressionInputView_.center = CGPointMake(expressionInputView_.center.x, expressionInputView_.center.y + expressionInputView_.frame.size.height);
        }];
    }
    
    // animation
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [self adjustVisibleViewWithAnimated:YES show:YES curve:[animationCurve intValue] duration:[duration doubleValue] keyboardHeight:rect.size.height];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // animation
    NSDictionary *userInfo = [notification userInfo];
    
    if(!isExpressionViewShown) {
        isExpressionViewShown = YES;
        [UIView animateWithDuration:0.25 animations:^(void){
            expressionInputView_.center = CGPointMake(expressionInputView_.center.x, expressionInputView_.center.y - expressionInputView_.frame.size.height);
        }];
    }
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [self adjustVisibleViewWithAnimated:YES show:NO curve:[animationCurve intValue] duration:[duration doubleValue] keyboardHeight:expressionInputView_.frame.size.height];
}

#pragma mark -
#pragma mark Location notification
/////////////////////////////////////////////////////////////////////////////////////
- (void)locationDidSucess:(NSNotification *)notifcation {
    DLog(@"notificationSucess received");
    NSDictionary *info = notifcation.userInfo;
    NSArray *array = [info objectForKey:@"locationArray"];
    self.locationDataArray = array;
    self.currentLocationData = [array objectAtIndex:1];
}

- (void)locationDidFailed:(NSNotification *)notifcation {
    [self.locationView showErrowMessage];
}

//locationInit
- (void)locationDidInit:(NSNotification *)notifcation {
    [self.locationView showInitMessag];
}
- (void)locationDidstart:(NSNotification *)notifcation {
    [self.locationView showStartMessage];
}

- (void)rangeUpdate:(NSNotification *)notification  {
    KDGroup *selectGroup = notification.object;
    if (selectGroup) {
        self.selectedGroup = selectGroup;
        
        // 刷新界面
        [self.selectRangeView removeFromSuperview];
        [self setUpSelectRangeView];
    }
}

#pragma mark -
#pragma mark UIActionSheet delegate methods

//去掉清除照片逻辑 王松 2013-10-25

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (as.tag == 2011) {
        if (as.cancelButtonIndex == buttonIndex){
            return;
            
        }
        
        NSString *title = [as buttonTitleAtIndex:buttonIndex];
        
        if ([title isEqualToString:ASLocalizedString(@"拍照")]) { //拍照
            if (self.pickedImageCachePath.count < 9) {
                [self showImagePicker:YES];
            }else {
                UIWindow *keyWindow = [[UIApplication sharedApplication].windows objectAtIndex:1];
                [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"PostViewController_Alert")inView:keyWindow];
            }
        } else {  //选择照片
            [self showImagePicker:NO];
        }
        
    } else if(as.tag == 2012) {
        if(0x00 == buttonIndex){
            draft_.sending = NO;
            [self saveAsDraft];
            [self _showNotificationViewDidSaveDraft];
            [self dismiss];
        }else if (0x01 == buttonIndex) {
            [self removeDraftFlags];
            
            [self dismiss];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIImagePickerController delegate methods

- (void)imagePickerController:(KDImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([imagePickerController isKindOfClass:[UIImagePickerController class]]) {
        UIImagePickerController *picker = (UIImagePickerController *)imagePickerController;
        CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
        if(UTTypeConformsTo(mediaType, kUTTypeImage)){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                UIWindow *keyWindow = [[UIApplication sharedApplication].windows objectAtIndex:1];
                [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init]; //将获取的照片存入相册
                [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
                    [self.selectedImagesAssetUrl addObject:[NSString stringWithFormat:@"%@", assetURL]];
                    self.imagePreviewView.hidden = NO;
                    [self.imagePreviewView setShowAddedButton:[self showAddImageButton]];
                    [self.imagePreviewView setAssetURLs:_selectedImagesAssetUrl];
                    self.textView.attacthView = self.imagePreviewView;
                    [self savePickedImage:image];
                    [self updateWordLimitsLabel];
                    //KD_RELEASE_SAFELY(_imagePickerController);
                    [MBProgressHUD hideAllHUDsForView:keyWindow animated:YES];
                    [actionMenuView_ setImageButtonHighlighted:YES];
                }];
                //KD_RELEASE_SAFELY(library);
            }
        }
    } else {
        [self removeLocalCachedPickImage];
        if(imagePickerController.allowsMultipleSelection) {
            [self handelImages:(NSArray *)info];
        }
    }
    _photosChanged = YES;
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)handelImages:(NSArray *)info
{
    [self.selectedImagesAssetUrl removeAllObjects];
    if (info.count > 0) {
        self.imagePreviewView.hidden = NO;
        [actionMenuView_ setImageButtonHighlighted:YES];
        
        for (NSDictionary *dict in info) {
            NSString *assetURL = [NSString stringWithFormat:@"%@", [dict objectForKey:@"UIImagePickerControllerReferenceURL"]];
            [self savePickedImage:[dict objectForKey:@"UIImagePickerControllerOriginalImage"]];
            [self.selectedImagesAssetUrl addObject:assetURL];
        }
        [self.imagePreviewView setShowAddedButton:[self showAddImageButton]];
        [self.imagePreviewView setAssetURLs:self.selectedImagesAssetUrl];
        self.textView.attacthView = self.imagePreviewView;
        [self updateWordLimitsLabel];
    }else {
        self.textView.attacthView = nil;
    }
}

- (BOOL)showAddImageButton
{
    return [self.selectedImagesAssetUrl count] < 9;
}

- (void)imagePickerControllerDidCancel:(KDImagePickerController *)picker {
    postViewControllerFlags_.didCancelPickImage = 1;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)willSavePickedImage:(UIImage *)image{
    if(operationQueue_ == nil){
        operationQueue_ = [[NSOperationQueue alloc] init];
    }
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(savePickedImage:) object:image];
    [operationQueue_ addOperation:operation];
//    [operation release];
    
    if([operationQueue_ isSuspended])
        [operationQueue_ setSuspended:NO];
}

- (NSString *)pickedImageLocalThumbnailCachePath:(NSString *)imagePath {
    return [imagePath stringByAppendingString:KD_PICKED_IMAGE_LOCAL_THUMBNAIL_CACHE_NAME];
}

- (void)savePickedImage:(UIImage *)image {
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *tempPath = [[KDUtility defaultUtility] searchDirectory:KDApplicationTemporaryDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
    
    
    NSString *filename = [[NSDate date] formatWithFormatter:KD_DATE_ISO_8601_LONG_NUMERIC_FORMATTER];
    filename = [filename stringByAppendingFormat:@"_%@", [NSString randomStringWithWide:6]];
    NSString *cachePath = [tempPath stringByAppendingPathComponent:filename];
    [self.pickedImageCachePath addObject:cachePath];
    
    // original image
    //长图发送模糊bug 8370
//    CGSize previewSize = CGSizeMake(800.0f, 600.0f);
//    if(image.size.width > previewSize.width || image.size.height > previewSize.height){
//        image = [image scaleToSize:previewSize type:KDImageScaleTypeFill];
//    }
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
    if ([self isCompressed:data]) {
        data = UIImageJPEGRepresentation(image, 0.75);
    }
    
    [[NSFileManager defaultManager] createFileAtPath:cachePath contents:data attributes:nil];
    
    //
    NSDictionary *callbackInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES], @"created",
                                  [NSNumber numberWithBool:NO], @"showedThumbnail", nil];
    
    [self performSelectorOnMainThread:@selector(didSavePickedImageWithInfo:) withObject:callbackInfo waitUntilDone:[NSThread isMainThread]];
    
//    [pool release];
}

- (BOOL)isCompressed:(NSData *)data
{
    float size = data.length / 1024.;
    return size > 200.f;
}


- (void)removeLocalCachedPickImage {
    
    for (NSString *path in self.pickedImageCachePath) {
        
        NSString *thumbnailPath = [self pickedImageLocalThumbnailCachePath:path];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]){
            [[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:NULL];
        }
    }
    
    [self.pickedImageCachePath removeAllObjects];
}

- (void)removeLocalCachedPickImageNotIn:(NSArray *)notRemoved {
    
    NSMutableSet *preSet = [NSMutableSet setWithArray:self.pickedImageCachePath];
    NSSet *notSet = [NSSet setWithArray:notRemoved];
    [preSet minusSet:notSet];
    
    NSArray *toRemoved = [preSet allObjects];
    
    for (NSString *path in toRemoved) {
        
        NSString *thumbnailPath = [self pickedImageLocalThumbnailCachePath:path];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]){
            [[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:NULL];
        }
    }
}

- (void)removeLocalCachedVideo {
    
    if (self.videoPath) {
        if([[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]){
            [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:nil];
        }
    }
    
    self.videoPath = nil;
}

- (void)didSavePickedImageWithInfo:(NSDictionary *)info {
    if([operationQueue_ operationCount] == 0){
        //KD_RELEASE_SAFELY(operationQueue_);
    }
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark - KDExpressionInputViewDelegate Methods
- (void)expressionInputView:(KDExpressionInputView *)inputView didTapExpression:(NSString *)expressionCode {
    if(caret.location != NSNotFound) {
        textView_.text = [textView_.text stringByReplacingCharactersInRange:caret withString:expressionCode];
        caret.location = caret.location + expressionCode.length;
    }else {
        textView_.text = [textView_.text stringByAppendingString:expressionCode];
    }
    
    [self updateWordLimitsLabel];
}

- (void)didTapKeyBoardInExpressionInputView:(KDExpressionInputView *)inputView {
    [self switchExpressionView];
}

- (void)didTapSendInExpressionInputView:(KDExpressionInputView *)inputView {
    [self send:nil];
}

- (void)didTapDeleteInExpressionInputView:(KDExpressionInputView *)inputView {
    if(!textView_.text || textView_.text.length == 0 || caret.location == 0) return;
    
    NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    NSArray *matches = [topicExpression matchesInString:textView_.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, textView_.text.length)];
    
    if(caret.location != NSNotFound) {
        for(NSTextCheckingResult *result in matches) {
            NSRange range = result.range;
            if(range.location + range.length == caret.location) {
                textView_.text = [textView_.text stringByReplacingCharactersInRange:range withString:@""];
                caret.location = range.location;
                [self updateWordLimitsLabel];
                return;
            }
        }
        
        textView_.text = [textView_.text stringByReplacingCharactersInRange:NSMakeRange(--caret.location, 1.0f) withString:@""];
        [self updateWordLimitsLabel];
    }else {
        NSTextCheckingResult *lastMatch = [matches lastObject];
        if(lastMatch.range.location + lastMatch.range.length == textView_.text.length) {
            textView_.text = [textView_.text stringByReplacingCharactersInRange:lastMatch.range withString:@""];
            [self updateWordLimitsLabel];
            return;
        }else {
            textView_.text = [textView_.text substringToIndex:textView_.text.length - 1];
            [self updateWordLimitsLabel];
        }
    }
}

#pragma mark -
#pragma mark UITextView delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (expressionInputView_ && expressionInputView_.superview) {
        [actionMenuView_ setExpressButtonHighlighted:YES];
    }
    [self.textView resignFirstResponder];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    [self updateWordLimitsLabel];
    NSString *currentStirng = growingTextView.text;
    if(currentStirng.length <= 0){
        return;
    }
    NSString *strLast = [growingTextView.text substringWithRange:NSMakeRange(growingTextView.text.length - 1, 1)];
    if ([strLast isEqualToString:@"@"] && !hasAtFlag) {
        // 进入 @某人 选择界面
        hasAtFlag = YES;
        [self atFriend];
    }else{
        hasAtFlag = NO;
    }
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView {
    caret = textView_.selectedRange;
    
    return YES;
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    [actionMenuView_ setExpressButtonHighlighted:NO];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@""]) {
        if(!textView_.text || textView_.text.length == 0 || caret.location == 0) return YES;
        
        caret = textView_.selectedRange;
        
        NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionAnchorsMatchLines error:NULL];
        NSArray *matches = [topicExpression matchesInString:textView_.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, textView_.text.length)];
        
        if(caret.location != NSNotFound) {
            for(NSTextCheckingResult *result in matches) {
                NSRange range = result.range;
                if(range.location + range.length == caret.location) {
                    textView_.text = [textView_.text stringByReplacingCharactersInRange:range withString:@""];
                    caret.location = range.location;
                    textView_.selectedRange = caret;
                    return NO;
                }
            }
            
            return YES;
        }else {
            NSTextCheckingResult *lastMatch = [matches lastObject];
            if(lastMatch.range.location + lastMatch.range.length == textView_.text.length) {
                textView_.text = [textView_.text stringByReplacingCharactersInRange:lastMatch.range withString:@""];
                return NO;
            }else {
                textView_.text = [textView_.text substringToIndex:textView_.text.length - 1];
            }
            return NO;
        }
    }
    
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////

//2013.10.9  去掉mentionPickerViewcontroller 代理，tan yingqi
//#pragma mark -
//#pragma mark KDMentionPickerViewController delegate methods
//
//- (void)mentionPickerViewController:(KDMentionPickerViewController *)mpvc pickedUsernames:(NSArray *)usernames {
//    NSMutableString *text = [NSMutableString string];
//    if (usernames != nil && [usernames count] > 0) {
//        for (NSString *username in usernames) {
//            [text appendFormat:@"@%@ ", username];
//        }
//
//        [self appendText:text];
//    }
//}

#pragma mark -
#pragma mark KDLocationOptionViewController delegate methods
- (void)determineLocation:(KDLocationData *)locationData viewController:(KDLocationOptionViewController *)viewController  beginTimeInterval:(NSTimeInterval)beginTimeInterval {
    self.currentLocationData = locationData;
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteCurrentLocationData {
    self.currentLocationData = nil;
}

#pragma mark -
#pragma mark KDFrequentContactsPickViewController delegate methods
- (void)frequentContactsPickViewController:(KDFrequentContactsPickViewController *)fcpvc pickedUsers:(NSArray *)users {
    if(!users || users.count == 0) return;
    
    NSMutableString *text = [NSMutableString string];
    for(KDUser *user in users) {
        if(user.username) {
                NSString *strLast = [self.textView.text substringWithRange:NSMakeRange(self.textView.text.length - 1, 1)];
                if ([strLast isEqualToString:@"@"]) {
                    if(text.length == 0){
                        [text appendFormat:@"%@ ", user.username];
                    }else{
                        [text appendFormat:@"@%@ ", user.username];
                    }
                }else{
                    [text appendFormat:@"@%@ ", user.username];
                }
            }
    }
    
    if(text) {
        [self appendText:text];
        hasAtFlag = NO;
    }
}

-(void)cancelContactsPickViewController
{
    hasAtFlag = YES;
}

#pragma mark -
#pragma mark KDImagePostPreviewView delegate methods
- (void)imagePostPreview:(KDImagePostPreviewView *)imagePostPreview didTapAtIndex:(NSUInteger)index
{
    UITextView *textView = self.textView.internalTextView;
    if ([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }else {
        KDPostPhotoPreviewController *photoPreviewCtl = [[KDPostPhotoPreviewController alloc] initWithNibName:nil bundle:nil];
        photoPreviewCtl.currentIndex = index;
        photoPreviewCtl.delegate = self;
        photoPreviewCtl.cachedImageURLs = self.pickedImageCachePath;
        photoPreviewCtl.cachedAssetURLs = self.selectedImagesAssetUrl;
        [self presentViewController:photoPreviewCtl animated:YES completion:nil];
//        [photoPreviewCtl release];
    }
    
}

- (void)imagePostPreview:(KDImagePostPreviewView *)imagePostPreview didTapAddedButton:(BOOL)tap
{
    [self showImagePicker:NO];
}

- (void)videoThumbnailDidTapped
{
    KDVideoPlayerController *videoController = [[KDVideoPlayerController alloc] initWithNibName:nil bundle:nil];
    videoController.delegate = self;
    videoController.localFileURL = self.videoPath;
    if ([self respondsToSelector:@selector(presentModalViewController:animated:completion:)]) {
        [self presentViewController:videoController animated:YES completion:^{
        }];
    }else {
        [self presentViewController:videoController animated:YES completion:nil];
    }
//    [videoController release];
}

- (void)deleteButtonClicked
{
    [actionMenuView_ setVideoHighlighted:NO];
    if (!draftViewController_) {
        [self removeLocalCachedVideo];
        [self removeLocalCachedPickImage];
    }else {
        self.videoPath = nil;
        [self.pickedImageCachePath removeAllObjects];
    }
    [self updateWordLimitsLabel];
}

- (void)deleteFileClicked {
    self.fileDataModel = nil;
    self.imagePreviewView.fileDataModel = nil;
    self.attachment = nil;
    
}

#pragma mark
#pragma mark HPGrowingTextView delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    
}

#pragma mark
#pragma mark KDVideoCaptureManager delegate
- (void)videoCaptureFinished:(BOOL)finish filePath:(NSString *)filePath{
    if (finish) {
        self.videoPath = filePath;
        UIImage *image = [KDVideoCaptureManager thumbnailImageForVideo:[NSURL fileURLWithPath:filePath] atTime:0.0];
        
        [self.imagePreviewView setVideoThumbnail:image withSize:[self videoSize]];
        self.imagePreviewView.hidden = NO;
        self.textView.attacthView = self.imagePreviewView;
        [self savePickedImage:image];
        [actionMenuView_ setVideoHighlighted:YES];
    } else { //Cancel
        self.imagePreviewView.hidden = YES;
        self.videoPath = filePath;
        [self removeLocalCachedVideo];
        [self removeLocalCachedPickImage];
    }
    [self updateWordLimitsLabel];
    [self dismissViewControllerAnimated:YES completion:nil];
    [textView_ becomeFirstResponder];
}

- (NSString *)videoSize
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.videoPath error:nil];
    NSNumber *size = [attributes objectForKey:NSFileSize];
    NSString *result = @"";
    if (size.intValue / 1024 >= 1024) {
        result = [NSString stringWithFormat:@"%.2fMB", size.floatValue / 1024 / 1024];
    }else {
        result = [NSString stringWithFormat:@"%dKB", (int)size.intValue / 1024];
    }
    return result;
}


#pragma markb
#pragma mark KDDMChatInputExtendViewDelegate

- (void)checkButtonTapped:(id)sender {
    self.draft.doExtraCommentOrForward = self.extentView.checked;
}

#pragma markb
#pragma mark KDPlayer Delegate
- (void)videoPlayFinished:(KDVideoPlayerManager *)player
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark postphotopreview delegate
- (void)postPhotoPreview:(KDPostPhotoPreviewController *)preview done:(BOOL)done userInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (done) {
        _photosChanged = YES;
        [self handlePreviewResult:info];
    }
}

- (void)handlePreviewResult:(NSDictionary *)info
{
    NSArray *cacheAssetURLs = [info objectForKey:@"CachedAssetURLs"];
    NSArray *cacheImageURLs = [info objectForKey:@"CachedImageURLs"];
    
    if ([cacheAssetURLs count] > 0) {
        [self removeLocalCachedPickImageNotIn:cacheImageURLs];
        [self.selectedImagesAssetUrl removeAllObjects];
        [self.selectedImagesAssetUrl addObjectsFromArray:cacheAssetURLs];
        [self.imagePreviewView setShowAddedButton:[self showAddImageButton]];
        [self.imagePreviewView setAssetURLs:self.selectedImagesAssetUrl];
        [self.pickedImageCachePath removeAllObjects];
        [self.pickedImageCachePath addObjectsFromArray:cacheImageURLs];
    }else {
        [self.selectedImagesAssetUrl removeAllObjects];
        [actionMenuView_ setImageButtonHighlighted:NO];
        [self removeLocalCachedPickImage];
        self.imagePreviewView.hidden = YES;
    }
    [self updateWordLimitsLabel];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    if([textView_ hasText]){
        self.contentBackup = [textView_ text];
    }
    
    //KD_RELEASE_SAFELY(textView_);
    //KD_RELEASE_SAFELY(actionMenuView_);
    
    //KD_RELEASE_SAFELY(atFriendsContainerView_);
    //KD_RELEASE_SAFELY(locationView_);
    
    postViewControllerFlags_.viewDidUnload = 1;
}
//去掉末尾回车
- (NSString *)trimLastNewlineCharacterSet
{
    NSString *text = [textView_.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange range = [textView_.text rangeOfString:text];
    if (range.location != NSNotFound) {
        text = [textView_.text substringToIndex:range.location + range.length];
    }
    return text;
}

/*
 *this view will dismiss when begin to send, but not dealloc;while the send action completed,call this method(dealloc).
 *caz use block, this methods may be called from a secondary thread.Oops, UIKit can't call from secondary thread.
 *
 *error message:
 *     bool _WebTryThreadLock(bool), 0xbca6290: Tried to obtain the web lock from a thread other than the main thread or the web thread.
 *                                              This may be a result of calling to UIKit from a secondary thread. Crashing now...
 */
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationInit object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationStart object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kKDServiceStatusesProgressNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VideoProgress" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RangeUpdated" object:nil];
    //KDNotificationLocationInit
    
    // clear cached images
    [self removeLocalCachedPickImage];
    
    //KD_RELEASE_SAFELY(expressionInputView_);
    
    //KD_RELEASE_SAFELY(draftViewController_);
    
    if(operationQueue_ != nil){
        [operationQueue_ cancelAllOperations];
//        [operationQueue_ release];
        operationQueue_ = nil;
    }
    
    //KD_RELEASE_SAFELY(pickedImageCachePath_);
    //KD_RELEASE_SAFELY(contentBackup_);
    
    //KD_RELEASE_SAFELY(textView_);
    //KD_RELEASE_SAFELY(actionMenuView_);
    
    //KD_RELEASE_SAFELY(atFriendsContainerView_);
    //KD_RELEASE_SAFELY(draft_);
    //KD_RELEASE_SAFELY(locationView_);
    //KD_RELEASE_SAFELY(currentLocationData_);
    //KD_RELEASE_SAFELY(locationDataArray_);
    //KD_RELEASE_SAFELY(locationOptionViewController_);
    //KD_RELEASE_SAFELY(_imagePreviewView);
    //KD_RELEASE_SAFELY(_selectedImagesAssetUrl);
    //KD_RELEASE_SAFELY(_videoPath);
    //KD_RELEASE_SAFELY(_imagePickerController);
    //KD_RELEASE_SAFELY(extentView_);
    //KD_RELEASE_SAFELY(wordLimitsLabel_);
    
    //KD_RELEASE_SAFELY(externalViewContainer_);
    //KD_RELEASE_SAFELY(externalView_);
    //KD_RELEASE_SAFELY(userProfileView_);
    //KD_RELEASE_SAFELY(userNameBtn_);
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(sourceLabel_);
    //KD_RELEASE_SAFELY(statusDetailView_);
    //KD_RELEASE_SAFELY(_selectRangeView);
    //KD_RELEASE_SAFELY(_attachment);
    //KD_RELEASE_SAFELY(_fileDataModel);
    //[super dealloc];
}

@end

