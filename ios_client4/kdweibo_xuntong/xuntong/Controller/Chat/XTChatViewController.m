
//
//  ChatViewController.m
//  ContactsLite
//
//  Created by Gil on 12-11-27.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "XTChatViewController.h"
#import "XTChatDetailViewController.h"
#import "NSObject+SBJSON.h"
#import "MBProgressHUD.h"
#import "ContactClient.h"
#import "PersonDataModel.h"
#import "RecordListDataModel.h"
#import "ContactConfig.h"
#import "ContactUtils.h"
#import "BOSAudioPlayer.h"
#import "ContactLoginDataModel.h"
#import "RecordDataModel.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "NeedUpdateDataModel.h"
#import "BubbleTableViewCell.h"
#import "UIButton+XT.h"
#import "UIImage+XT.h"
#import "NSString+Scheme.h"
#import "XTSetting.h"
#import "XTDeleteService.h"
#import "XTCloudClient.h"
#import "FileModel.h"
#import "XTmenuModel.h"
#import "XTMenuEachModel.h"
#import "XTFileUtils.h"
#import <OHAttributedLabel/NSAttributedString+Attributes.h>
#import "KDExpressionLabel.h"
#import "RecordDataModel.h"
#import "KDWebViewController.h"
#import "PersonSimpleDataModel.h"
#import "XTPersonDetailViewController.h"
#import "BOSConfig.h"
#import "XTImageUtil.h"
#import "KDImagePickerController.h"
#import "KDMessageHandler.h"
#import "ContactUtils.h"
#import "amrFileCodec.h"
#import "KDExpressionInputView.h"
#import "TrendStatusViewController.h"
#import "NSDictionary+Additions.h"
#import "KDTodoListViewController.h"
#import "KDChooseContentCollectionViewController.h"
#import "KDCreateTaskViewController.h"
#import "NJKScrollFullScreen.h"
#import "XTChatSearchViewController.h"
#import "KDExpressionManager.h"
#import "MJPhotoBrowser.h"
#import "XTChatBannerView.h"
#import "KDChatInputBoardView.h"
#import "KDApplicationQueryAppsHelper.h"
#import "KDVoiceTimer.h"
#import "KDMultiVoiceViewController.h"

#import "MWPhotoBrowser.h"
#import "UIImage+fixOrientation.h"
#import "UIColor+KDAddition.h"
#import "NSString+Additions.h"
#import "SZTextView.h"
#import "KDLineMaker.h"
#import "KDPubAccDetailViewController.h"
#import <objc/runtime.h>

#import "KDMultipartyCallBannerView.h"
#import "KDAgoraSDKManager.h"
#import "MBProgressHUD+Add.h"
#import "XTChatUnreadCollectionView.h"
#import "KDNotificationView.h"
#import "XTWbClient.h"
#import "NSString+DZCategory.h"
#import "KDSendViewController.h"
#import "KDWaterMarkAddHelper.h"
#import "KDNetworkDisconnectView.h"
#import "KDReachabilityManager.h"
#import "WechatShortVideoController.h"
#import "KDVideoUploadTask.h"
#import "SCPlayer.h"
#import "KDVideoPlayerManager.h"
#import "SCVideoPlayerView.h"
#import "KDDownload.h"
#import "KDDownloadManager.h"
#import "KDAttachment.h"
#import "KDMediaMessageHandler.h"
#import "NSDate+Additions.h"
#import "NSDate+DZCategory.h"
#import "UIViewController+DZCategory.h"
#import "KDForwardChooseViewController.h"
#import "NSDate+DZCategory.h"
#import "XTChatViewController+ForwardMsg.h"
#import "KDImageEditorViewController.h"
#import "NSObject+KDSafeObject.h"
#import "KDCameraViewController.h"
#import "KDUserHelper.h"
#import "SimplePersonListDataModel.h"

#define CHART_VIEW_TOOL_BAR_HEIGHT  44.0f
#define RECORD_START_DELAY 0.1
#define RECORD_STOP_DELAY 0.5
#define RECORDS_PAGE 100
#define REFRESH_HEADER_HEIGHT 30.0f
#define KEYBOARD_MOVE_TIME 0.25
#define InputBoardHeight 216      //输入面板高度
#define EmojiBoardHeight 186.0

#define TextView_Min_Height 34.0
#define TextView_Max_Height 95.0

#define kFileTransPublicAccountID   @"XT-0060b6fb-b5e9-4764-a36d-e3be66276586"

#define kTextViewBoarderColorNotrac 0x9971cf
#define kTextViewBoarderColorImportant 0x01D386
#define kTextViewBoarderColorNormal 0xCFCFCF


typedef enum _ChangeBtnTag{
    ChangeBtnTagSpeech,
    ChangeBtnTagText
}ChangeBtnTag;

typedef enum : NSUInteger {
    BubbleTableScrollNotifyType = 1,//@提及
    BubbleTableScrollChatBannerViewButtonConfirmPressedType,
    BubbleTableScrollNewMessagePressed,
    BubbleTableScrollReply
} BubbleTableScrollType;

typedef void (^QueryMessageCompletionBlock) (int count);


@interface XTChatViewController () <KDImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, KDExpressionInputViewDelegate, XTSelectPersonsViewDelegate, NJKScrollFullscreenDelegate, XTChatSearchViewControllerDelegate, XTChatBannerViewDelegate, XTModifyGroupNameViewControllerDelegate, MWPhotoBrowserDelegate,KDSendViewControllerDeleagate,WechatShortVideoDelegate,KDVideoPlayerManagerDelegate,KDMarkBottomBannerDelegate, KKImageEditorDelegate, KDCameraViewControllerDelegate>
{
    UIPanGestureRecognizer *_panrecognizer;
    dispatch_queue_t _dbReadQueue;
    
    // @功能底部view
    XTSelectPersonsView *selectPersonsView;
    
    // 记录文本框最后输入的一个string
    NSString *_lastString;
    // 记录文本框当前的string
    NSString *_currentString;
    
    BOOL _pushingToChooseVC; // 正在跳转到@选人页面， 防止重复push
    
    NJKScrollFullScreen *_scrollProxy;
    
    __weak UIView *_topView;
    BOOL _isAnimation;
//    NSString *_cancelMsgId ;//为保存消息回撤请求完成后删除本地消息使用
//    BubbleTableViewCell *_cancelMsgCell ;//为保存消息回撤请求完成后刷新页面
    UIImageView *_backImageView;
    SCPlayer *_player;
}

//分页
@property(nonatomic, strong) UIActivityIndicatorView *lastPageIndicatorView;
@property(nonatomic, strong) UIActivityIndicatorView *nextPageIndicatorView;

////表格数据
//@property (nonatomic, strong) NSMutableArray *recordsList;
//@property (nonatomic, strong) NSMutableArray *bubbleArray;

//分页
@property (nonatomic,assign) int limitSatrt;
@property (nonatomic,assign) BOOL hasLastPage;
@property (nonatomic,assign) BOOL isLoading;
//@property (nonatomic,strong) UIActivityIndicatorView *lastPageIndicatorView;
@property (nonatomic,strong) UIActivityIndicatorView *menuIndicatorView;

@property (nonatomic,assign) CGFloat lastContentSizeHeight;
@property (nonatomic,copy) NSString *publicMenu;
@property (nonatomic,copy) NSString *titleText;

//文件
@property (nonatomic,strong) XTCloudClient *cloudClient;
@property (nonatomic,assign) BOOL isFilePicture;

// 红点
@property(nonatomic, strong) UIImageView *imageViewPlusMenuRedFlag;
// 原图发送
@property(nonatomic, assign) BOOL bSendOriginal;

// 快捷发送图片
@property(nonatomic, strong) MWPhotoBrowser *mwbrowser;
@property(nonatomic, strong) NSMutableArray *photos;
@property(nonatomic, strong) NSMutableArray *thumbs;
@property(nonatomic, strong) NSString *strMostRecentPhotoURL;
@property(nonatomic, strong) UIView *viewLastPhoto;
@property(nonatomic, assign) BOOL bShouldShowViewLastPhoto;
@property(nonatomic, assign) BOOL bShowingViewLastPhoto;
@property(nonatomic, assign) BOOL bShownViewLastPhoto;

//HUD
@property (nonatomic, strong) MBProgressHUD *progressHud;

@property (nonatomic, strong) ContactClient *sendMessageClient;

@property (nonatomic, strong) KDExpressionInputView *expressionInputView;
@property (nonatomic, strong) KDExpressionInputView *notraceExpressionInputView;

// 记录文本框文本
@property (nonatomic, strong) NSMutableString *content;

//覆盖在contentView 上的view 仅供响应事件用
@property (nonatomic, strong)UIView *touchView;

@property (nonatomic,strong)NSMutableArray *toolbarBtnsArray;  //存放一级菜单

@property (nonatomic, strong) XTChatBannerView *bannerView;
//@property (nonatomic, assign) BOOL bFirstEnter;

/**
 *   是否发送的是表情
 */
@property (nonatomic, assign) BOOL isSendingEmoji;

@property (nonatomic, strong) XTChatSearchViewController *searchViewController;

@property (nonatomic, strong) UIView *mainView;

@property (strong, nonatomic) NSMutableDictionary *serviceClients;
@property(nonatomic, strong) KDChatInputBoardView *boardView;

//多人语音
@property(nonatomic ,strong) KDVoiceTimer *multiVoiceTimer;
//@property(nonatomic, strong) UIButton *multiVoiceWindow;

@property (nonatomic, assign) NSInteger mentionTotal;
@property (nonatomic, strong) KDMultipartyCallBannerView *multipartyCallBannerView;



//跳转
@property (nonatomic, strong) BubbleDataInternal *scrollBubbleDataInternal;//需要跳转的气泡数据
@property (nonatomic, assign) BOOL scrollBubbleDataInternalExistInDB;//跳转气泡数据是否在数据库中存在
@property (nonatomic, assign) BOOL scrollToDBdata;//跳转到数据库数据Row
@property (nonatomic, strong) NSMutableArray *forwardFileClients;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, retain) KDLocationOptionViewController *locationOptionViewController;

@property (nonatomic, strong) KDMultiVoiceViewController *flagMultiVoceController;

// 消息分页临时变量
@property (nonatomic, strong) NSString *latestMsgId; // 本地最新的msg id
@property (nonatomic, strong) NSString *oldestMsgId; // 本地最旧的msg id
@property (nonatomic, strong) NSString *latestMsgSendTime; // 本地最新的msg sendTime
@property (nonatomic, strong) NSString *oldestMsgSendTime; // 本地最旧的msg id

@property (nonatomic, strong) NSString *lastMsgSendTime; // msgList接口more机制的防御"用同一个msgId反复请求msgList"的死循环
@property (nonatomic, strong) NSString *fetchOldToMsgId;


/**
 *  消息分页相关
 */
@property (nonatomic, strong) ContactClient *msgListClient;
@property(nonatomic, copy) void (^blockMsgListClient)(BOOL succ, NSDictionary *dictData);
@property(nonatomic, assign) BOOL bLoadingLock; //  处理并发
@property (nonatomic, strong) UILabel *pullDownLabel;
@property (nonatomic, strong) UILabel *pullUpLabel;
@property(nonatomic, assign) BOOL bNoMoreOldPagings; // old方向拉倒最好一页
@property (nonatomic, copy) void(^blockRecursiveGetMoreMessagesOld)(BOOL, BOOL, void(^)());
@property (nonatomic, copy) void(^blockRecursiveGetMoreMessagesNew)(BOOL, BOOL, void(^)());

@property (nonatomic, copy) void(^blockRecursiveGetGroupUser)(BOOL, SimplePersonListDataModel *personListData, void(^)());

@property (nonatomic, assign) BOOL bFirstFetch;


//网络连接断开提示
@property (nonatomic, strong) KDNetworkDisconnectView *networkDisconnectView;
@property (nonatomic, strong) ContactClient *mCallClient;
@property (nonatomic, strong) ContactClient *queryGroupInfoClient;

@property (nonatomic, strong) NSMutableArray *shortVideoUrl;
@property (nonatomic, strong) NSMutableArray *shortVideoIDs;
@property (nonatomic, assign) BOOL success;

@property (nonatomic, copy) void(^blockRecursiveShortVideoSuccess)(BOOL, void(^)());


@property (nonatomic, strong) UILabel *playTimeLabel;
@property (nonatomic, assign) NSInteger videoDuration;
@property (nonatomic, strong) KDMarkBottomBanner *markBanner;

@property (nonatomic, assign) BOOL jumpSuccess;
// 语音消息最后10s倒计时
@property(nonatomic, assign) NSInteger totalTime;
@property (nonatomic, strong) NSTimer *countdownTimer;


@property (nonatomic, strong) MCloudClient *chatAppClientCloud;
@property (nonatomic, assign) BOOL isDissolveGroup;

@property (nonatomic, weak) XTChatDetailViewController *chatDetailVC;


@property (nonatomic, strong) KDUserHelper *userHelper;


@property (nonatomic, assign) NSUInteger localUpdateScore;//本地最新score
//@property (nonatomic, strong) RecordDataModel  *latestRecordData; //最新的会话消息

//录音
-(void)prepareToRecord;
-(void)startRecord;
-(void)realStartRecord;
-(void)endRecord;
-(void)cancelRecord;
//网络
- (void)recordTimeline;
- (void)getRecordsFromDataBaseOnePage:(QueryMessageCompletionBlock)completionBlock;
- (void)getRecordsFromDataBaseAlreadyLoaded:(QueryMessageCompletionBlock)completionBlock;



@property (nonatomic, strong) UIButton *buttonGrayFilter;//回复模式时界面蒙层
@end

@implementation XTChatViewController
@synthesize noticeview;

@synthesize locationDataArray = _locationDataArray;
@synthesize currentLocationData = _currentLocationData;
@synthesize locationOptionViewController = locationOptionViewController_;

- (id)init
{
    self = [super init];
    if (self) {
        _shouldChangeTextField = YES;
        
        _limitSatrt = 0;
        _recordsList = [[NSMutableArray alloc] init];
        _cloudClient = [[XTCloudClient alloc] init];
        _isSendingFile = NO;
        _isForward = NO;
        _isAnimation = NO;
        _serviceClients = [[NSMutableDictionary alloc]init];
        _shortVideoUrl = [[NSMutableArray alloc]init];
        _shortVideoIDs = [[NSMutableArray alloc]init];
        _success = NO;
    }
    return self;
}

- (id)initWithGroup:(GroupDataModel *)group pubAccount:(PubAccountDataModel *)pubAccount mode:(ChatMode)mode
{
    self = [self init];
    if (self) {
        // Custom initialization
        BOSAssert(group, @"group is nil.");
        
        _group = group;
        
        if (group.menu.length > 0) {
            _issending=NO;
            self.ispublic = YES;
        }
        
        if ([group.groupId rangeOfString:@"XT"].location !=NSNotFound)
        {
            self.ispublic = YES;
        }
        
        [self reloadMenuData:group];
        
        self.detailPerson.personId = group.groupId;
        
        self.pubAccount = pubAccount;
        self.chatMode = mode;
        
        if(pubAccount)
        {
            ((PersonSimpleDataModel *)[_group.participant firstObject]).state = pubAccount.state;
        }
        self.iUnreadMessageCount = group.unreadCount;
    }
    return self;
}

-(id)initWithParticipant:(PersonSimpleDataModel *)participant
{
    if([participant isPublicAccount]||[participant.personId rangeOfString:@"XT"].location !=NSNotFound)
    {
        //add by lee 禅道 819
        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicGroupWithPublicPersonId:participant.personId];
        if (group == nil) {
            group = [[GroupDataModel alloc] initWithParticipant:participant];
            group.groupType = GroupTypePublic;
            group.groupName = participant.personName;
            group.menu = participant.menu;
            self.ispublic = YES;
        }
        
        //添加成员列表
        if([group.participant indexOfObject:participant] == NSNotFound)
            [group.participant addObject:participant];
        
        //强制给它赋值
        if (participant.menu.length > 0 && !(group.menu.length > 0)) {
            group.menu = participant.menu;
        }
        return [self initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
    } else {
        
        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:participant];
        if (group == nil) {
            group = [[GroupDataModel alloc] initWithParticipant:participant];
            group.groupType = GroupTypeDouble;
            group.groupName = participant.personName;
            group.partnerType = participant.partnerType;
            self.ispublic = NO;
        }
        return [self initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
    }
}
//
//-(id)initWithParticipant2:(PersonSimpleDataModel *)participant
//{
//    if([participant isPublicAccount]||[participant.personId rangeOfString:@"XT"].location !=NSNotFound)
//    {
//        //add by lee 禅道 819
//        //NSString *groupID = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupIdWithPublicPersonId:participant.personId];
//        //填坑，bugid：1168
//        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPersonForPublic:participant];;//[[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:groupID];
//        if (group == nil) {
//            group = [[GroupDataModel alloc] initWithParticipant:participant];
//            group.groupType = GroupTypePublic;
//            group.groupName = participant.personName;
//            group.menu = participant.menu;
//            self.ispublic = YES;
//        }
//        return [self initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
//    } else {
//        
//        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:participant];
//        if (group == nil) {
//            group = [[GroupDataModel alloc] initWithParticipant:participant];
//            group.groupType = GroupTypeDouble;
//            group.groupName = participant.personName;
//            group.partnerType = participant.partnerType;
//            self.ispublic = NO;
//        }
//        return [self initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
//    }
//}
-(id)initWithPubAccount:(PubAccountDataModel *)pubAccount
{
//    PersonSimpleDataModel *participant = [[PersonSimpleDataModel alloc] init];
//    participant.personId = pubAccount.publicId;
//    participant.personName = pubAccount.name;
//    participant.photoUrl = pubAccount.photoUrl;
//    participant.status = 11;
    PersonSimpleDataModel *participant = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicAccountWithId:pubAccount.publicId];
    
    GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPersonForPublic:participant];
    if (group.menu.length == 0 && participant.menu.length > 0) {
        group.menu = participant.menu;
    }
    if (group == nil) {
        group = [[GroupDataModel alloc] initWithParticipant:participant];
        group.groupType = GroupTypePublic;
        group.groupName = participant.personName;
        group.menu = participant.menu;
    }
    
    return [self initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
}
- (void)loadView{
    [super loadView];
    
    CGRect frame = self.view.bounds;
//    frame.size.height -= kd_BottomSafeAreaHeight;
    self.mainView = [[UIView alloc] initWithFrame:frame];
    self.mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationStyle:KDNavigationStyleNormal];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KDGroupIDNotification" object:self userInfo:@{@"groupId":self.group.groupId}];
    
    [KDChatNotraceManager sharedInstance].chatVC = self;
    
    self.bFirstFetch = YES;
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    if ([self.group.participant count] == 1) {
        PersonSimpleDataModel *person = [self.group.participant firstObject];
        if ([person.personId isEqualToString:@"XT-10000"]) {
            [KDEventAnalysis event:event_feedback_open];
        }
    }
    
    if (self.group.groupType == GroupTypeDouble) {
        [KDEventAnalysis event:event_session_open attributes:@{label_session_open_type : label_session_open_type_single}];
    }
    else if (self.group.groupType == GroupTypeMany) {
        [KDEventAnalysis event:event_session_open attributes:@{label_session_open_type : label_session_open_type_multi}];
    }
    else if (self.group.groupType == GroupTypePublic || self.group.groupType == GroupTypeTodo) {
        //[KDEventAnalysis event:event_session_open attributes:@{label_session_open_type : label_session_open_type_pubacc}];
    }
    
    _dbReadQueue = dispatch_queue_create("com.recordtimeline.queue", NULL);
    
    [self setupChatTitle];
//    NSString *title = nil;
//    if (self.group.groupType == GroupTypeMany) {
//        title = [self getMutiChatGroupTitle];
//    } else {
//        title = self.group.groupName;
//    }
//    
//    self.title = title;
//    self.titleText = title;
    
    [self setupRightNavigationItem];
    
    CGFloat toolBarHeight = CHART_VIEW_TOOL_BAR_HEIGHT;
    if (![self.group chatAvailable]) {
        toolBarHeight = 0.0;
    }
    
    
    self.bubbleTableStartHeight = Height(self.mainView.frame) - toolBarHeight;
    self.bubbleTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, -3, ScreenFullWidth, self.bubbleTableStartHeight -5) style:UITableViewStylePlain];
    self.bubbleTable.backgroundColor = [UIColor kdBackgroundColor1];
    self.bubbleTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.bubbleTable.delegate = self;
    self.bubbleTable.dataSource = self;
    [self.mainView addSubview:self.bubbleTable];

    self.bubbleTable.estimatedRowHeight = 0;
    self.bubbleTable.estimatedSectionFooterHeight = 0;
    self.bubbleTable.estimatedSectionHeaderHeight = 0;
    
    [self.mainView addSubview:self.networkDisconnectView];
    
    // 下拉加载菊花
    UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bubbleTable.bounds.size.width, REFRESH_HEADER_HEIGHT)];
    footLabel.backgroundColor = [UIColor clearColor];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.center = CGPointMake(footLabel.bounds.size.width / 2, footLabel.bounds.size.height / 2);
    indicatorView.hidesWhenStopped = YES;
    self.lastPageIndicatorView = indicatorView;
    [footLabel addSubview:indicatorView];
    self.bubbleTable.tableHeaderView = footLabel;
    self.pullDownLabel = footLabel;
    // 上拉加载菊花
    UILabel *labelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bubbleTable.bounds.size.width, REFRESH_HEADER_HEIGHT)];
    labelBottom.backgroundColor = [UIColor clearColor];
    UIActivityIndicatorView *bottomIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    bottomIndicatorView.center = CGPointMake(labelBottom.bounds.size.width / 2, labelBottom.bounds.size.height / 2);
    bottomIndicatorView.hidesWhenStopped = YES;
    self.nextPageIndicatorView = bottomIndicatorView;
    [labelBottom addSubview:bottomIndicatorView];
    self.bubbleTable.tableFooterView = labelBottom;
    self.pullUpLabel = labelBottom;
    
    
    PersonSimpleDataModel *person = [self.group.participant firstObject];
    if ([[BOSSetting sharedSetting] openWaterMark:([person isPublicAccount]||_chatMode == ChatPublicMode)?WaterMarkTypPublicAndLightApp:WaterMarkTypeConversation]) {
        CGRect frame = CGRectMake(0, 0, ScreenFullWidth, self.mainView.frame.size.height);
        [KDWaterMarkAddHelper coverOnView:self.mainView withFrame:frame];
    }
    else {
        [KDWaterMarkAddHelper removeWaterMarkFromView:self.mainView];
    }
    

    if (_group.isNewGroup) {
        UIImage *guideImg = [UIImage imageNamed:@"dm_btn_qiming"];
        UIButton *guideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [guideButton setTitle:ASLocalizedString(@"XTChatViewController_Name")forState:UIControlStateNormal];
        [guideButton setImage:guideImg forState:UIControlStateNormal];
        [guideButton addTarget:self action:@selector(toEditGroupName:) forControlEvents:UIControlEventTouchUpInside];
        guideButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        guideButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        guideButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [guideButton setTitleColor:MESSAGE_NAME_COLOR forState:UIControlStateNormal];
        CGSize size = [guideButton.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15.f] forWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByWordWrapping];
        [guideButton setTitleEdgeInsets:UIEdgeInsetsMake(70 / 2.f - size.height * 0.5f, ((CGRectGetWidth(self.bubbleTable.bounds) - size.width) / 2 - guideImg.size.width), 0, 0)];
        [guideButton setImageEdgeInsets:UIEdgeInsetsMake((70 - guideImg.size.height) * 0.5f, (CGRectGetWidth(self.bubbleTable.bounds) - guideImg.size.width) * 0.5f, 0, 0)];
        guideButton.frame = CGRectMake(0, 0, self.bubbleTable.bounds.size.width, 70.f);
        self.bubbleTable.tableHeaderView = guideButton;
    }
    
    self.toolbarImageViewStartY = Height(self.mainView.frame) - toolBarHeight;
    self.toolbarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.toolbarImageViewStartY, ScreenFullWidth, toolBarHeight)];
    self.toolbarImageView.userInteractionEnabled = YES;
    self.toolbarImageView.backgroundColor = [UIColor whiteColor];
    //    self.toolbarImageView.image = [XTImageUtil chatToolBarBackgroundImage];
    self.toolbarMenuview = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.toolbarImageViewStartY , ScreenFullWidth, toolBarHeight)];
    self.toolbarMenuview.userInteractionEnabled = YES;
    self.toolbarMenuview.backgroundColor = [UIColor whiteColor];
    //    self.toolbarMenuview.image = [XTImageUtil chatToolBarBackgroundImage];
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.frame = CGRectMake(7, 8, 28, 28);
    changeBtn.tag = [XTSetting sharedSetting].defaultChatKeyboardType == XTChatKeyboardText ? ChangeBtnTagSpeech : ChangeBtnTagText;
    
    
    [changeBtn setBackgroundImage:[XTImageUtil chatToolBarChangeBtnImageWithTag:(int) changeBtn.tag state:UIControlStateNormal] forState:UIControlStateNormal];
    [changeBtn setBackgroundImage:[XTImageUtil chatToolBarChangeBtnImageWithTag:(int) changeBtn.tag state:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [changeBtn addTarget:self action:@selector(changeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.changeButton = changeBtn;
    self.keyboardShow = NO;
    [self.toolbarImageView addSubview:changeBtn];
    
    
    
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordBtn setFrame:CGRectMake(MaxX(self.changeButton.frame) + 8, 5, ScreenFullWidth - 123, 34)];
    [recordBtn addTarget:self action:@selector(recordTouchDown:) forControlEvents:UIControlEventTouchDown];
    [recordBtn addTarget:self action:@selector(recordTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn addTarget:self action:@selector(recordTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [recordBtn addTarget:self action:@selector(recordTouchDragEnger:) forControlEvents:UIControlEventTouchDragEnter];
    [recordBtn addTarget:self action:@selector(recordTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [recordBtn setBackgroundImage:[[UIImage imageNamed:@"message_btn_speak_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]forState:UIControlStateNormal];
    
    [recordBtn setBackgroundImage:[[UIImage imageNamed:@"message_btn_speak_press"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]forState:UIControlStateHighlighted];

    [recordBtn.layer setCornerRadius:4.0];
    [recordBtn setTitle:ASLocalizedString(@"XTChatViewController_Speak")forState:UIControlStateNormal];
    [recordBtn setTitleColor:FC1 forState:UIControlStateNormal];
    [recordBtn.titleLabel setFont:FS6];
    [recordBtn setHidden:[XTSetting sharedSetting].defaultChatKeyboardType == XTChatKeyboardText];
    self.recordButton = recordBtn;
    [self.toolbarImageView addSubview:recordBtn];
    
    self.contentView = [[SZTextView alloc] initWithFrame:CGRectMake(MaxX(self.changeButton.frame) + 8, 5, ScreenFullWidth - 123, 34)];
    self.contentView.tintColor = FC5;
    self.contentView.layer.cornerRadius = 17.0;
    self.contentView.layer.borderWidth = 1.0;
    self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
    //    self.contentView.textAlignment = UIControlContentVerticalAlignmentCenter;
    self.contentView.hidden = [XTSetting sharedSetting].defaultChatKeyboardType == XTChatKeyboardSpeech;
    self.contentView.backgroundColor = [UIColor kdBackgroundColor1];
    self.contentView.font = FS4;
    self.contentView.textColor = FC1;
    self.contentView.returnKeyType = UIReturnKeySend;
    self.contentView.enablesReturnKeyAutomatically = NO;
    self.contentView.textContainerInset = UIEdgeInsetsMake(self.contentView.textContainerInset.top, 8, self.contentView.textContainerInset.bottom, 8);
    [self.toolbarImageView addSubview:self.contentView];
    
    _touchView = [[UIView alloc] initWithFrame:self.contentView.frame];
    _touchView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.toolbarImageView addSubview:_touchView];
    
    _touchView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGestureRecogizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapped:)];
    [_touchView addGestureRecognizer:tapGestureRecogizer];
    _touchView.hidden = YES;
    
    [self.contentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    
    
    //    UIView *textTouchView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    //    textTouchView.backgroundColor = [UIColor clearColor];
    
    //表情按钮
    UIButton *emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    emojiBtn.frame = CGRectMake(MaxX(self.recordButton.frame) + 8, 8, 28.0, 28.0);
    [emojiBtn setBackgroundImage:[UIImage imageNamed:@"message_btn_smile_normal"] forState:UIControlStateNormal];
    [emojiBtn setBackgroundImage:[UIImage imageNamed:@"message_btn_smile_press"] forState:UIControlStateHighlighted];
    
    //    [emojiBtn setBackgroundImage:[XTImageUtil chatToolBarEmojiBtnImageWithState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [emojiBtn addTarget:self action:@selector(emojiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.emojiButton = emojiBtn;
    [self.toolbarImageView addSubview:emojiBtn];
    
    //加号按钮
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(MaxX(self.emojiButton.frame) + 8, 8, 28.0, 28.0);
    [addBtn setBackgroundImage:[UIImage imageNamed:@"message_btn_add_normal"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"message_btn_add_press"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.addButton = addBtn;
    [self.toolbarImageView addSubview:addBtn];
    
    self.imageViewPlusMenuRedFlag = [[UIImageView alloc] initWithFrame:CGRectMake(18, -3, 12, 12)];
    self.imageViewPlusMenuRedFlag.image = [UIImage imageNamed:@"red_badge_bg"];
    [addBtn addSubview:self.imageViewPlusMenuRedFlag];
    self.imageViewPlusMenuRedFlag.hidden = [[NSUserDefaults standardUserDefaults] boolForKey:kChatPlusMenuRedFlag];
    
    //回复模式的蒙层
    [self.mainView addSubview:self.buttonGrayFilter];

    self.ismenushow = false;
//    if ([self.group.participantIds count] == 1)
//    {
        if (self.menuarray.count > 0)
        {
            self.ismenushow = true;
        }
//    }
   
    
    if(self.ismenushow) {
        changeBtn.frame = CGRectMake(50, 8.0, 28.0, 28.0);
        [recordBtn setFrame:CGRectMake(self.changeButton.frame.origin.x + self.changeButton.frame.size.width + 8, (toolBarHeight - 35) / 2,  ScreenFullWidth - 123 - 8 - 44, 35.0)];
        self.contentView.frame = CGRectMake(self.changeButton.frame.origin.x + self.changeButton.frame.size.width + 8, (toolBarHeight - TextView_Min_Height) / 2, ScreenFullWidth - 123 - 8 - 44, TextView_Min_Height);
        self.toolbarImageView.frame = CGRectMake(0.0, self.toolbarImageViewStartY + 200, ScreenFullWidth, toolBarHeight);
        self.toolbarMenuview.frame = CGRectMake(0.0, self.toolbarImageViewStartY, ScreenFullWidth, toolBarHeight);
        _menukeyboard = YES;
        [self createInputBoard];
        self.toolbarImageView.alpha = 0.0;
        self.toolbarMenuview.alpha = 1.0;
        [self menuboardshow];
        
        
        noticeview = [[UIView alloc] initWithFrame:CGRectMake((ScreenFullWidth-100)/2.0, ScreenFullHeight, 100, 30)];
        noticeview.backgroundColor=[UIColor lightGrayColor];
        noticeview.alpha=0;
        noticeview.layer.cornerRadius=10;
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = CGPointMake(20, 20);
        indicatorView.hidesWhenStopped = YES;
        self.menuIndicatorView = indicatorView;
        [noticeview addSubview:indicatorView];
        [self.menuIndicatorView startAnimating];
        
        UILabel*lab=[[UILabel alloc]initWithFrame:CGRectMake(40, 10, 70, 20)];
        [noticeview addSubview:lab];
        lab.backgroundColor=[UIColor clearColor];
        lab.textColor=[UIColor whiteColor];
        lab.font=[UIFont systemFontOfSize:14];
        lab.text=ASLocalizedString(@"XTChatViewController_GetInfo");
        //        lab.textColor=BOSCOLORWITHRGBA(0x7A7A7A, 1.0);
        [self.mainView addSubview:self.toolbarMenuview];
    }
    else
    {
        [self createInputBoard];
        [self.view addSubview:self.viewLastPhoto];
        [self checkLastPhoto:NO];
        
        //插件输入面板(照片、拍照、文件、表情等）
        self.toolbarImageView.frame = CGRectMake(0.0, self.toolbarImageViewStartY, ScreenFullWidth, toolBarHeight);
        
        
        noticeview = [[UIView alloc] initWithFrame:CGRectMake((ScreenFullWidth-100)/2.0, ScreenFullHeight, 100, 30)];
        noticeview.backgroundColor = [UIColor lightGrayColor];
        noticeview.alpha = 0;
        noticeview.layer.cornerRadius = 10;
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = CGPointMake(20, 20);
        indicatorView.hidesWhenStopped = YES;
        self.menuIndicatorView = indicatorView;
        [noticeview addSubview:indicatorView];
        [self.menuIndicatorView startAnimating];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 70, 20)];
        [noticeview addSubview:lab];
        lab.backgroundColor = [UIColor clearColor];
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont systemFontOfSize:14];
        lab.text = ASLocalizedString(@"XTChatViewController_GetInfo");

    }
    
    if ([self.group chatAvailable] || self.chatMode == ChatPublicMode) {
        self.toolbarImageView.hidden = NO;
        self.toolbarMenuview.hidden = NO;
    }else{
        self.toolbarImageView.hidden = YES;
        self.toolbarMenuview.hidden = YES;
    }
    [self.toolbarMenuview addSubview:[KDLineMaker lineWithOrigin:CGPointMake(0, 0)]];
    [self.toolbarImageView addSubview:[KDLineMaker lineWithOrigin:CGPointMake(0, 0)]];
    
    [self.mainView addSubview:noticeview];
    
    //    [self.mainView addSubview:self.toolbarMenuview];
    [self.mainView addSubview:self.toolbarImageView];
    _isRecording = NO;
    
    
    if (![[KDReachabilityManager sharedManager] isReachable] ) {
        [self showNetworkDisconnetView];
    }
    
    // 若收到的是推送，先更新一下组信息
    if (self.group.isRemoteMsg) {
        [[KDWeiboAppDelegate getAppDelegate].timelineViewController getGroupList];
        self.group.isRemoteMsg = NO;
        [KDWeiboAppDelegate getAppDelegate].timelineViewController.pushGroup = self.group;
    }
    
    //add
#pragma mark RELOAD
    [self loadOnePageAtViewDidLoad];
    
    
    if (![_group isPublicGroup]) {
        
        _scrollProxy = [[NJKScrollFullScreen alloc] initWithForwardTarget:self]; // UIScrollViewDelegate and UITableViewDelegate methods proxy to ViewController
        
        self.bubbleTable.delegate = (id)_scrollProxy; // cast for surpress incompatible warnings
        
        _scrollProxy.delegate = self;
        
        if (self.bSearchingMode)
        {
            self.searchViewController = [[XTChatSearchViewController alloc] init];
            self.searchViewController.controller = self;
            self.searchViewController.group = _group;
            self.searchViewController.chatMode = _chatMode;
            [self.view addSubview:_searchViewController.topView];
            _topView = _searchViewController.topView;
            _topView.frame = CGRectMake(0, kd_StatusBarAndNaviHeight, CGRectGetWidth(_topView.frame), CGRectGetHeight(_topView.frame));
//            _bubbleTable.contentInset = UIEdgeInsetsMake(CGRectGetHeight(_topView.frame), 0, 0, 0);
        }
    }
    
    [_group addObserver:self forKeyPath:@"groupName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    //    _bubbleTable.contentInset = UIEdgeInsetsMake(_topView.bounds.size.height, 0, 0, 0);
    
    //显示引导页   --- alanwong
    //    if ([self shouldShowGuideView]) {
    //        [self showGuideView];
    //    }
    
    
    [self.view addSubview:self.bannerView];
    [self.mainView addSubview:self.multipartyCallBannerView];
    self.bannerView.hidden = YES;
    
    [self.mainView addSubview:self.markBanner];
    self.markBanner.frame = CGRectMake(0, - 104, self.mainView.frame.size.width, 44);
    
    //add
    //第一次进入聊天
    NSString *userFirstTimeIntoChatRoom = [[NSUserDefaults standardUserDefaults] objectForKey:kDUserFirstTimeIntoChatRoom];
    if ([userFirstTimeIntoChatRoom isKindOfClass:[NSNull class]] || !userFirstTimeIntoChatRoom || ![userFirstTimeIntoChatRoom isEqualToString:@"Yes"]) {
        if ( self.group.groupType == GroupTypeDouble ||  self.group.groupType == GroupTypeMany) {
            [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:kDUserFirstTimeIntoChatRoom];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self performSelector:@selector(addBtnClick:) withObject:nil afterDelay:0.2];
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(multiVoiceDidReceived:) name:@"multiVoice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoNewMultiVoiceView:) name:@"gotoNewMultiVoiceView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgReadUpdate:) name:@"msgReadUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadChatGroupApplist:) name:@"reLoadApplist" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AgoraCallViewAnswer:) name:@"AgoraCallViewAnswer" object:nil];
    
    
    [self.view addSubview:self.buttonUnreadMessage];
    
    [self.noticeController addBoxInView:self.mainView];
    
    if([_group isPublicGroup])
    {
        if(_group.participant.firstObject)
        {
            PersonSimpleDataModel *person = _group.participant.firstObject;
            //打开公共号统计埋点
            KDQuery *query = [KDQuery query];
            [query setParameter:@"pub_id" stringValue:person.personId];
            [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/event/:pubOpen" query:query
                                         configBlock:nil completionBlock:^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
                                             
                                             if(results)
                                             {
                                             }
                                         }];
        }
    }
    __weak XTChatViewController *selfInBlock = self;
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification                                                     object:nil  queue:mainQueue  usingBlock:^(NSNotification *note) {
        if (selfInBlock.inputBoardShow)
            [selfInBlock performSelector:@selector(checkLastPhoto:) withObject:@(YES) afterDelay:0.5];
        else
            [selfInBlock performSelector:@selector(checkLastPhoto:) withObject:nil afterDelay:0.5];
    }];
    
    [self noticeOnViewDidload:self.noticeController];
}

- (void)setupChatTitle
{
    NSString *title = nil;
    if (self.group.groupType == GroupTypeMany) {
        title = [self getMutiChatGroupTitle];
    } else {
        title = self.group.groupName;
    }
    
    self.title = title;
    self.titleText = title;
}
- (KDNoticeController *)noticeController {
    if (!_noticeController) {
        _noticeController = [KDNoticeController new];
        _noticeController.delegate = self;
        _noticeController.dataSource = self;
    }
    return _noticeController;
}

-(UIImage *)addText:(UIImage *)img text:(NSString *)text1
{
    //get image width and height
    int w = self.mainView.frame.size.width;
    int h = self.mainView.frame.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.13);
    CGContextRotateCTM(context, -1 * M_PI_4 );
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.13);
    CGFloat x = h *2 /3;
    CGFloat y = h /5;
    CGFloat offSetX = h /3 ;
    CGFloat offSetWidth = [self sizeWithString:text1 font:[UIFont fontWithName:@"Helvetica" size:14]].width;
    if (offSetWidth < 120) {
        offSetWidth  = 120;
    }
    
    // Prepare font
    CGFloat s = 25;
    CTFontRef ctfont = CTFontCreateWithName(CFSTR("Helvetica"), s, NULL);
    CGColorRef ctColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.13] CGColor];
    
    // Create an attributed string
    for (int i = 0; i< 4 ; i ++ )
    {
        CFStringRef keys[] = { kCTFontAttributeName,kCTForegroundColorAttributeName };
        CFTypeRef values[] = { ctfont,ctColor};
        CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
                                                  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFStringRef ctStr = CFStringCreateWithCString(nil, [text1 UTF8String], kCFStringEncodingUTF8);
        CFAttributedStringRef attrString = CFAttributedStringCreate(NULL,ctStr, attr);
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextSetTextPosition(context, -1 * x , y + offSetX/2 + i * offSetX);
        CTLineDraw(line, context);
        CGContextSetTextPosition(context,  -1 * x + offSetWidth  , y  +  i * offSetX);
        CTLineDraw(line, context);
        CGContextSetTextPosition(context,-1 * x + 2 * offSetWidth , y + offSetX/2 +  i * offSetX);
        CTLineDraw(line, context);
        CGContextSetTextPosition(context, -1 * x + 3 * offSetWidth , y + i * offSetX);
        CTLineDraw(line, context);
        CGContextSetTextPosition(context, -1 * x + 4 * offSetWidth , y + offSetX/2 + i * offSetX);
        CTLineDraw(line, context);
        
        CFRelease(line);
        CFRelease(attrString);
        CFRelease(ctStr);
        CFRelease(attr);
    }
    
    // Clean up
    CFRelease(ctfont);
    
    //Create image ref from the context
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
    
    
    
    
    
    //    //get image width and height
    //    int w = self.mainView.frame.size.width;
    //    int h = self.mainView.frame.size.height;
    //    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //    //create a graphic context with CGBitmapContextCreate
    //    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    //    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    //    CGContextSetRGBFillColor(context, 0, 0, 0, 0.13);
    //    char* text = (char *)[text1 cStringUsingEncoding:NSUTF8StringEncoding];
    //    CGContextRotateCTM(context, -1 * M_PI_4 );
    //    CGContextSelectFont(context, "Helvetica", 25, kCGEncodingMacRoman);
    //    CGContextSetTextDrawingMode(context, kCGTextFill);
    //    CGContextSetRGBFillColor(context, 0, 0, 0, 0.13);
    //    CGFloat x = h *2 /3;
    //    CGFloat y = h /5;
    //    CGFloat offSetX = h /3 ;
    //    CGFloat offSetWidth = [self sizeWithString:text1 font:[UIFont fontWithName:@"Helvetica" size:14]].width;
    //    if (offSetWidth < 120) {
    //        offSetWidth  = 120;
    //    }
    //    for (int i = 0; i< 4 ; i ++ ) {
    //        CGContextShowTextAtPoint(context, -1 * x , y + offSetX/2 + i * offSetX , text, strlen(text));
    //        CGContextShowTextAtPoint(context, -1 * x + offSetWidth  , y  +  i * offSetX, text, strlen(text));
    //        CGContextShowTextAtPoint(context, -1 * x + 2 * offSetWidth , y + offSetX/2 +  i * offSetX, text, strlen(text));
    //        CGContextShowTextAtPoint(context, -1 * x + 3 * offSetWidth , y + i * offSetX, text, strlen(text));
    //        CGContextShowTextAtPoint(context, -1 * x + 4 * offSetWidth , y + offSetX/2 + i * offSetX, text, strlen(text));
    //    }
    //    //Create image ref from the context
    //    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    //    CGContextRelease(context);
    //
    //    CGColorSpaceRelease(colorSpace);
    //    return [UIImage imageWithCGImage:imageMasked];
}
// 定义成方法方便多个label调用 增加代码的复用性
- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(ScreenFullWidth, 8000)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: font}//传人的字体字典
                                       context:nil];
    
    return rect.size;
}
- (EmojiModal *)createModalWithName:(NSString *)strName
                          imageName:(NSString *)strImageName
{
    EmojiModal *modal = [EmojiModal new];
    modal.strName = strName;
    modal.strImageName = strImageName;
    return modal;
}



- (UIView *)touchView {
    if (!_touchView) {
        _touchView = [[UIView alloc] initWithFrame:self.contentView.frame];
        _touchView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.toolbarImageView addSubview:_touchView];
        
        _touchView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGestureRecogizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapped:)];
        [_touchView addGestureRecognizer:tapGestureRecogizer];
    }
    return _touchView;
}



-(void)menuboardshow
{
    
    for (UIView *view in self.toolbarMenuview.subviews)
    {
        [view removeFromSuperview];
    }
    if (_toolbarBtnsArray)
    {
        for (UIButton *btn in self.toolbarBtnsArray)
        {
            [btn removeObserver:self forKeyPath:@"selected"];
        }
        self.toolbarBtnsArray = nil;
    }
    [self.personimage removeFromSuperview];
    [self.personimage removeObserver:self forKeyPath:@"frame"];
    self.personimage = nil;
    [self.itimage removeFromSuperview];
    self.itimage = nil;
    [self.otherimage removeFromSuperview];
    self.otherimage = nil;
    self.menufirst = nil;
    self.menusecond = nil;
    self.menuthird = nil;
    
    UILabel *keybtnline = [[UILabel alloc] initWithFrame:CGRectMake(38.5, 11.5, 0.5, 21)];
    [self.toolbarImageView addSubview:keybtnline];
    keybtnline.backgroundColor = [UIColor kdDividingLineColor];
    //    UILabel *keybtnrightline = [[UILabel alloc] initWithFrame:CGRectMake(39, 11.5, 0.5, 48)];
    //    [self.toolbarImageView addSubview:keybtnrightline];
    //    keybtnrightline.backgroundColor = [UIColor kdDividingLineColor];;
    
    UIButton *keybtnintoolbar = [UIButton buttonWithType:UIButtonTypeCustom];
    keybtnintoolbar.frame = CGRectMake(8, 11.5, 20, 21);
    keybtnintoolbar.tag = 1000;
    [keybtnintoolbar setImage:[UIImage imageNamed:@"message_btn_menu_normal"] forState:UIControlStateNormal];
    [keybtnintoolbar setImage:[UIImage imageNamed:@"message_btn_menu_press"] forState:UIControlStateHighlighted];
    
    [keybtnintoolbar addTarget:self action:@selector(menu:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarImageView addSubview:keybtnintoolbar];
    [self.toolbarBtnsArray addObject:keybtnintoolbar];
    [keybtnintoolbar addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.keyBoardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.keyBoardBtn.frame = CGRectMake(8, 11.5, 20, 21);
    self.keyBoardBtn.tag = 1000;
    [self.keyBoardBtn setImage:[UIImage imageNamed:@"message_btn_keyboard_normal_official"] forState:UIControlStateNormal];
    [self.keyBoardBtn setImage:[UIImage imageNamed:@"message_btn_keyboard_press_official"] forState:UIControlStateHighlighted];
    
    [self.keyBoardBtn addTarget:self action:@selector(menu:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarMenuview addSubview:self.keyBoardBtn];
    self.menufirst = [[NSMutableArray alloc] init];
    self.menusecond = [[NSMutableArray alloc] init];
    self.menuthird = [[NSMutableArray alloc] init];
    
    int width = (ScreenFullWidth - 36) / self.menuarray.count;
    for (int i = 0; i < self.menuarray.count; i++)
    {
        XTmenuModel *record = [self.menuarray objectAtIndex:i];
        UIButton *personserverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        personserverBtn.frame = CGRectMake(39 + width * i, 1, width, 44);
        personserverBtn.tag = 1001 + i;
        [personserverBtn addTarget:self action:@selector(menu:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbarMenuview addSubview:personserverBtn];
        [self.toolbarBtnsArray addObject:personserverBtn];
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(39 + width * i, 0, width, 44)];
        lab.text = record.name;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.backgroundColor = [UIColor clearColor];
        lab.textColor = FC1;
        [self.toolbarMenuview addSubview:lab];
        lab.font = FS4;
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(38.5 + width * i, 11.5, 0.5, 21)];
        [self.toolbarMenuview addSubview:line];
        line.backgroundColor = [UIColor kdDividingLineColor];
        //        UILabel *rightline = [[UILabel alloc] initWithFrame:CGRectMake(39 + width * i, 11.5, 0.5, 48)];
        //        [self.toolbarMenuview addSubview:rightline];
        //        rightline.backgroundColor = [UIColor kdDividingLineColor];
        NSMutableArray *t_array = [[NSMutableArray alloc] init];
        UIImage *img = [UIImage imageNamed:@"message_bg_list"];
        img = [img stretchableImageWithLeftCapWidth:5 topCapHeight:20];
        
        
        void (^blockThreeLines)() = ^
        {
            CGRect labelRect = [record.name
                                boundingRectWithSize:lab.frame.size
                                options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{
                                             NSFontAttributeName : FS4
                                             }
                                context:nil];
            AddX(lab.frame, 4);
            
            UIImageView *imageViewThreeLines = [[UIImageView alloc] initWithFrame:CGRectMake(Width(lab.frame)/2 - Width(labelRect)/2 - 9, 19, 8, 5)];
            imageViewThreeLines.image = [UIImage imageNamed:@"message_tip_situation"];
            [personserverBtn addSubview:imageViewThreeLines];
            
        };
        
        if (i == 0)
        {
            if ([record.type isEqualToString:@"click"])
            {
                
            }
            else if ([record.type isEqualToString:@"menu"])
            {
                blockThreeLines();
                for (id each in record.sub)
                {
                    XTMenuEachModel *t_record = [[XTMenuEachModel alloc] initWithDictionary:each];
                    [t_array addObject:t_record];
                }
                
                self.menufirst = t_array;
                self.personimage = [[UIImageView alloc] init];
                self.personimage.userInteractionEnabled = YES;
                
                NSInteger menuItemCount = [self.menufirst count]; //如果为0 我们也显示
                if (menuItemCount == 0)
                {
                    menuItemCount = 1;
                }
                
                self.personimage.frame = CGRectMake(40, ScreenFullHeight + Adjust_Offset_Xcode5, 113, 8 + menuItemCount * 44);
                self.personimage.image = img;
                self.personimage.hidden = YES;
                [self.personimage addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
                [self.mainView addSubview:self.personimage];
                [self.view bringSubviewToFront:self.personimage];
                
                for (int i = 0; i < self.menufirst.count; i++)
                {
                    XTMenuEachModel *each = [self.menufirst objectAtIndex:i];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(0, 44 * i, 113, 44);
                    [self.personimage addSubview:btn];
                    [btn addTarget:self action:@selector(serveraction:) forControlEvents:UIControlEventTouchUpInside];
                    btn.tag = 100 + i;
                    
                    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 44 * i, 113, 44)];
                    lab.text = each.name;
                    lab.textAlignment = NSTextAlignmentCenter;
                    lab.backgroundColor = [UIColor clearColor];
                    lab.textColor = FC1;
                    lab.font = FS4;
                    [self.personimage addSubview:lab];
                    
                    if (i > 0)
                    {
                        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(3+8, 44 * i - 0.5, 107-16, 0.5)];
                        [self.personimage addSubview:line];
                        line.backgroundColor = BOSCOLORWITHRGBA(0xCFCFCF, 1.0);
                        //                        UILabel *rightline = [[UILabel alloc] initWithFrame:CGRectMake(3, 44 * i, 107, 0.5)];
                        //                        [self.personimage addSubview:rightline];
                        //                        rightline.backgroundColor = BOSCOLORWITHRGBA(0xFFFFFF, 1.0);
                    }
                }
                
            }
            else if ([record.type isEqualToString:@"view"])
            {
                
            }
        }
        if (i == 1)
        {
            if ([record.type isEqualToString:@"click"])
            {
                
            }
            else if ([record.type isEqualToString:@"menu"])
            {
                blockThreeLines();
                for (id each in record.sub)
                {
                    XTMenuEachModel *t_record = [[XTMenuEachModel alloc] initWithDictionary:each];
                    [t_array addObject:t_record];
                }
                self.menusecond = t_array;
                self.itimage = [[UIImageView alloc] init];
                self.itimage.userInteractionEnabled = YES;
                
                NSInteger menuItemCount = [self.menusecond count]; //如果为0 我们也显示
                if (menuItemCount == 0) {
                    menuItemCount = 1;
                }
                self.itimage.frame = CGRectMake(130, ScreenFullHeight + Adjust_Offset_Xcode5, 113, 8 + menuItemCount * 44);
                self.itimage.image = img;
                self.itimage.hidden = YES;
                [self.mainView addSubview:self.itimage];
                [self.view bringSubviewToFront:self.itimage];
                
                for (int i = 0; i < self.menusecond.count; i++)
                {
                    XTMenuEachModel *each = [self.menusecond objectAtIndex:i];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(0, 44 * i, 113, 44);
                    [self.itimage addSubview:btn];
                    [btn addTarget:self action:@selector(serveraction:) forControlEvents:UIControlEventTouchUpInside];
                    btn.tag = 200 + i;
                    
                    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 44 * i, 113, 44)];
                    lab.text = each.name;
                    lab.textAlignment = NSTextAlignmentCenter;
                    lab.backgroundColor = [UIColor clearColor];
                    lab.textColor = FC1;
                    lab.font = FS4;
                    [self.itimage addSubview:lab];
                    
                    if (i > 0)
                    {
                        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(3+8, 44 * i - 0.5, 107-16, 0.5)];
                        [self.itimage addSubview:line];
                        line.backgroundColor = [UIColor kdDividingLineColor];
                        //                        UILabel *rightline = [[UILabel alloc] initWithFrame:CGRectMake(3, 40 * i, 107, 0.5)];
                        //                        [self.itimage addSubview:rightline];
                        //                        rightline.backgroundColor = BOSCOLORWITHRGBA(0xFFFFFF, 1.0);
                    }
                }
                
            }
            else if ([record.type isEqualToString:@"view"])
            {
                
            }
        }
        if (i == 2)
        {
            if ([record.type isEqualToString:@"click"])
            {
                
            } else if ([record.type isEqualToString:@"menu"])
            {
                
                blockThreeLines();
                
                for (id each in record.sub)
                {
                    XTMenuEachModel *t_record = [[XTMenuEachModel alloc] initWithDictionary:each];
                    [t_array addObject:t_record];
                }
                self.menuthird = t_array;
                self.otherimage = [[UIImageView alloc] init];
                self.otherimage.userInteractionEnabled = YES;
                NSInteger menuItemCount = [self.menuthird count];
                if (menuItemCount == 0)
                {
                    menuItemCount = 1;
                }
                self.otherimage.frame = CGRectMake(204, ScreenFullHeight + Adjust_Offset_Xcode5, 113, 8 + menuItemCount * 44);
                self.otherimage.image = img;
                self.otherimage.hidden = YES;
                [self.mainView addSubview:self.otherimage];
                [self.view bringSubviewToFront:self.otherimage];
                
                for (int i = 0; i < self.menuthird.count; i++)
                {
                    XTMenuEachModel *each = [self.menuthird objectAtIndex:i];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(0, 44 * i, 113, 44);
                    [self.otherimage addSubview:btn];
                    [btn addTarget:self action:@selector(serveraction:) forControlEvents:UIControlEventTouchUpInside];
                    btn.tag = 300 + i;
                    
                    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 44 * i, 113, 44)];
                    lab.text = each.name;
                    lab.textAlignment = NSTextAlignmentCenter;
                    lab.backgroundColor = [UIColor clearColor];
                    lab.textColor = FC1;
                    lab.font = FS4;
                    [self.otherimage addSubview:lab];
                    
                    if (i > 0)
                    {
                        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(3+8, 44 * i - 0.5, 107-16, 0.5)];
                        [self.otherimage addSubview:line];
                        line.backgroundColor = [UIColor kdDividingLineColor];
                        //                        UILabel *rightline = [[UILabel alloc] initWithFrame:CGRectMake(3, 40 * i, 107, 0.5)];
                        //                        [self.otherimage addSubview:rightline];
                        //                        rightline.backgroundColor = BOSCOLORWITHRGBA(0xFFFFFF, 1.0);
                    }
                }
            }
            else if ([record.type isEqualToString:@"view"])
            {
                
            }
        }        //监听selected 来处理的二级菜单的显示和隐藏
        [personserverBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

/**
 *  MARK: 新表情更改
 */
- (KDExpressionInputView *)expressionInputView {
    if(!_expressionInputView) {
        
        EmojiModal *modal0 = [self createModalWithName:ASLocalizedString(@"默认")imageName:@"smile"];
        EmojiModal *modal1 = [self createModalWithName:ASLocalizedString(@"小裸")imageName:@"xiaoluo"];
        EmojiModal *modal2 = [self createModalWithName:@"Yuki" imageName:@"yuki"];
        
        _expressionInputView = [[KDExpressionInputView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 216.0f)];
        _expressionInputView.delegate = self;
        
        // 新表情三套隐藏了两套 以后版本再上
        _expressionInputView.arrayEmojiModals = @[modal0, modal1,modal2 ];//, modal3];
        
        
    }
    return _expressionInputView;
}

// 新表情更改,无痕模式
- (KDExpressionInputView *)notraceExpressionInputView
{
    if (!_notraceExpressionInputView)
    {
        EmojiModal *modal0 = [self createModalWithName:@"默认" imageName:@"smile"];
        _notraceExpressionInputView = [[KDExpressionInputView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 216.0f)];
        _notraceExpressionInputView.delegate = self;
        _notraceExpressionInputView.arrayEmojiModals = @[modal0];
    }
    return _notraceExpressionInputView;
}
- (void)createInputBoard
{
    //照片等面板
    self.inputBoardStartY = Height(self.view.frame);
    self.inputBoardBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.inputBoardStartY, ScreenFullWidth, InputBoardHeight)];
    self.inputBoardBGView.image = [[UIImage imageNamed:@"InputBoard_Backgroud"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 10, 4, 20)];
    self.inputBoardBGView.backgroundColor = [UIColor redColor];
    self.inputBoardBGView.userInteractionEnabled = YES;
    self.inputBoardShow = NO;
    [self.mainView addSubview:self.inputBoardBGView];
    [self.inputBoardBGView addSubview:self.boardView];
    //Photo Button
}
// 新加号面板
- (KDChatInputBoardView *)boardView
{
    if (!_boardView)
    {
        NSMutableArray *mArrayModals = [NSMutableArray new];
        KDChatInputBoardModal *(^modalFactory)(NSString *, UIImage *, NSString *,BOOL, id) = ^(NSString *strTitle, UIImage *image, NSString *picUrl, BOOL bShouldHideNewFlag, id block)
        {
            KDChatInputBoardModal *modal = [KDChatInputBoardModal new];
            modal.strTitle = strTitle;
            modal.image = image;
            modal.picUrl = picUrl;
            modal.block = block;
            modal.bShouldHideNewFlag = bShouldHideNewFlag;
            return modal;
        };
        
        __weak XTChatViewController *weakself = self;
        
        
        if(self.messageMode == KDChatMessageModeNotrace)
        {
            [mArrayModals addObject:modalFactory(ASLocalizedString(@"XTChatViewController_Notrace_Picture"), [UIImage imageNamed:@"inbox_btn_picture_normal"], nil, YES, ^
                                                 {
                                                     [weakself toImagePicker:1];
                                                     [weakself hideViewLastPhoto];
                                                     if (weakself.messageMode != KDChatMessageModeNotrace) {
                                                         [weakself changeMessageModeTo:KDChatMessageModeNone];
                                                     }
                                                 })];
            
            [mArrayModals addObject:modalFactory(ASLocalizedString(@"XTChatViewController_Notrace_Camera"), [UIImage imageNamed:@"inbox_btn_camera_normal"], nil, YES, ^
                                                 {
//                                                     [weakself toImagePicker:0];
                                                     [weakself toCamera];
                                                     [weakself hideViewLastPhoto];
                                                     if (weakself.messageMode != KDChatMessageModeNotrace) {
                                                         [weakself changeMessageModeTo:KDChatMessageModeNone];
                                                     }
                                                 })];
            
            [mArrayModals addObject:modalFactory(ASLocalizedString(@"XTChatViewController_Notrace_Cancel"), [UIImage imageNamed:@"inbox_btn_traceless_out_normal"], nil, YES, ^
                                                 {
                                                     [weakself changeMessageModeTo:KDChatMessageModeNone];
                                                 })];
        }
        else
        {
        
            [mArrayModals addObject:modalFactory(ASLocalizedString(@"KDEvent_Picture"), [UIImage imageNamed:@"inbox_btn_picture_normal"], nil, YES, ^
                                                 {
                                                     [weakself toImagePicker:1];
                                                     [weakself hideViewLastPhoto];
                                                     [weakself changeMessageModeTo:KDChatMessageModeNone];
                                                 })];
            [mArrayModals addObject:modalFactory(ASLocalizedString(@"KDDMChatInputView_tak_photo"), [UIImage imageNamed:@"inbox_btn_camera_normal"], nil, YES, ^
                                                 {
//                                                     [weakself toImagePicker:0];
                                                     [weakself toCamera];
                                                     [weakself hideViewLastPhoto];
                                                     [weakself changeMessageModeTo:KDChatMessageModeNone];
                                                 })];
            [mArrayModals addObject:modalFactory(ASLocalizedString(@"KDDMChatInputView_tak_shortVideo"), [UIImage imageNamed:@"icon_video"], nil, YES, ^
                                                 {
                                                    [weakself shortVideo];
                                                 })];
            
            [mArrayModals addObject:modalFactory(ASLocalizedString(@"Chat_send_file"), [UIImage imageNamed:@"inbox_btn_document_normal"], nil, YES, ^
                                                 {
                                                     weakself.isSendingFile = YES;
                                                     XTMyFilesViewController *fileListVC = [[XTMyFilesViewController alloc] init];
                                                     fileListVC.hidesBottomBarWhenPushed = YES;
                                                     fileListVC.delegate = weakself;
                                                     fileListVC.fromType = 0;
                                                     [weakself.navigationController pushViewController:fileListVC animated:YES];
                                                     [weakself hideViewLastPhoto];
                                                     [weakself changeMessageModeTo:KDChatMessageModeNone];
                                                 })];
            if (self.group.groupType == GroupTypeMany)
            {
                [mArrayModals addObject:modalFactory(ASLocalizedString(@"XTChatViewController_Mention"), [UIImage imageNamed:@"inbox_btn_mention_normal"], nil, YES, ^
                                                     {
                                                         
                                                         // 进入 @某人 选择界面
                                                         [weakself gotoChooseContentPerson];
                                                         
                                                         //                                                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kChatPlusMenuNewFlagAt];
                                                         
                                                     })];
            }
            
            PersonSimpleDataModel *person = [_group.participant firstObject];
            //文件传输助手不需要多人语音及定位
            if (![person.personId isEqualToString:kFilePersonId]) {
                
                if(self.group.groupType == GroupTypeMany || self.group.groupType == GroupTypeDouble)
                {
                    if ([[KDApplicationQueryAppsHelper shareHelper]getGroupTalkStatus])
                    {
                        [mArrayModals addObject:modalFactory(ASLocalizedString(@"XTChatViewController_VoicMeeting"), [UIImage imageNamed:@"inbox_btn_voicemeeting_normal"], nil, YES, ^
                                                             {
                                                                 if (self.group.groupType == GroupTypeDouble) {
                                                                     
                                                                     UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:ASLocalizedString(@"XTChateViewController_agoraVoice") preferredStyle:UIAlertControllerStyleAlert];
                                                                     
                                                                     UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                                         [alertVC dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                                                                     [alertVC addAction:actionSure];
                                                                     
                                                                     [self.navigationController presentViewController:alertVC animated:YES completion:nil];
                                                                     return;
                                                                 }
                                                                 // 直接发起
                                                                 //add
                                                                 [KDEventAnalysis event: event_dialog_plus_voice_conference];
                                                                 [KDEventAnalysis eventCountly: event_dialog_plus_voice_conference];
                                                                 [weakself goToMultiVoice];
                                                                 [weakself changeMessageModeTo:KDChatMessageModeNone];
                                                                 
                                                             })];
                    }
                }
                [mArrayModals addObject:modalFactory(ASLocalizedString(@"XTChatViewController_Tip_4"), [UIImage imageNamed:@"inbox_btn_sign_normal"], nil, YES, ^
                                                     {
                                                         
                                                         // 进入 发送位置界面
                                                         [weakself adressBtnClick];
                                                         [weakself changeMessageModeTo:KDChatMessageModeNone];
                                                         
                                                         //                                                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kChatPlusMenuNewFlagAt];
                                                         
                                                     })];
                
            }
            //无痕消息
            if(self.group.groupType == GroupTypeDouble)
            {
                [mArrayModals addObject:modalFactory(ASLocalizedString(@"XTChatViewController_Notrace_Msg"), [UIImage imageNamed:@"inbox_btn_traceless_normal"], nil, YES, ^
                                                     {
                                                         [weakself changeMessageModeTo:KDChatMessageModeNotrace];
                                                     })];
            }
            
            // 轻应用菜单
            if ([BOSSetting sharedSetting].chatGroupAPPArr.count > 0 && (self.group.groupType == GroupTypeDouble || self.group.groupType == GroupTypeMany)) {
                [[BOSSetting sharedSetting].chatGroupAPPArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *groupTitle = safeString([obj objectForKey:@"groupTitle"]); // 设置的群应用的title
                    NSString *url = safeString([obj objectForKey:@"url"]);
                    NSString *picUrl = safeString([obj objectForKey:@"picUrl"]);
                    NSString *titleBgColor = safeString([obj objectForKey:@"titleBgColor"]);
                    NSString *titlePbColor = safeString([obj objectForKey:@"titlePbColor"]);
                    NSString *title = safeString([obj objectForKey:@"title"]); // 轻应用默认的title
                    NSString *appId = safeString([obj objectForKey:@"appId"]);
                    
                    if (url.length > 0) {
                        UserDataModel *user = [BOSConfig sharedConfig].user;
                        if ([url rangeOfString:@"?"].location !=NSNotFound) {
                            url = [url stringByAppendingString:[NSString stringWithFormat:@"&groupId=%@&userId=%@&openId=%@&eid=%@",weakself.group.groupId, user.userId, user.openId, user.eid]];
                        }else
                        {
                            url = [url stringByAppendingString:[NSString stringWithFormat:@"?groupId=%@&userId=%@&openId=%@&eid=%@",weakself.group.groupId, user.userId, user.openId, user.eid]];
                        }
                        [mArrayModals addObject:modalFactory(groupTitle.length>0?groupTitle:title, nil, picUrl, YES, ^{
                            KDWebViewController *applightWebVC = [[KDWebViewController alloc] initWithUrlString:url appId:appId];
                            applightWebVC.groupAppURL = url;
                            applightWebVC.hidesBottomBarWhenPushed = YES;
                            applightWebVC.isLightApp = YES;
                            
                            if(titleBgColor.length == 0)
                            {
                                applightWebVC.naviTitle = title;
                                [weakself.navigationController pushViewController:applightWebVC animated:YES];
                            }
                            else
                            {
                                __weak __typeof(applightWebVC) weak_webvc = applightWebVC;
                                applightWebVC.getLightAppBlock = ^() {
                                    if(weak_webvc && !weak_webvc.bPushed){
                                        weak_webvc.color4NavBg = titleBgColor;
                                        weak_webvc.color4processBg = titlePbColor;
                                        weak_webvc.naviTitle = title;
                                        [weakself.navigationController pushViewController:weak_webvc animated:YES];
                                    }
                                };
                            }
                            
                        })];
                    }
                    
                }];
            }
            
        }
        _boardView = [[KDChatInputBoardView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, InputBoardHeight) modals:mArrayModals];
    }
    return _boardView;
}
// 开启重要消息模式
- (void)openImportantMode
{
    self.bImportantMessageMode = YES;
    self.contentView.layer.borderColor = BOSCOLORWITHRGBA(0x01D386, 1.0).CGColor;

}

// 关闭重要消息模式
- (void)closeImportantMode
{

    self.bImportantMessageMode = NO;
    self.contentView.layer.borderColor = BOSCOLORWITHRGBA(0xCFCFCF, 1.0).CGColor;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //进行转发
    [self forwardMessagesToGroup];
    
    if (_group && [_group.participant count]> 0 && [[[_group.participant firstObject] personId] isEqualToString:kFileTransPublicAccountID]) {
        [self addBtnClick:nil];
    }
    
    if (self.bGoMultiVoiceAfterCreateGroup) {
        [self goToMultiVoice];
        self.bGoMultiVoiceAfterCreateGroup = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.bFirstEnter = YES;
    
    //扫码加群回来取不到title问题
    [self setupChatTitle];
    if(self.group.partnerType == 1)
        [self setupTitleView];
    
    self.contentView.delegate = self;
    
    NSArray *recogs = [self.view gestureRecognizers];
    
    //TODO:这里没有起作用
    for(UIGestureRecognizer *recog in recogs) {
        if([recog isKindOfClass:[UIPanGestureRecognizer class]]) {
            recog.delegate = self;
            [recog addTarget:self action:@selector(panGestureRecognizer:)];
            _panrecognizer = (UIPanGestureRecognizer *)recog;
        }
    }
    
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    
    if(!self.isMovingToParentViewController)
    {
        [self setNavigationStyle:KDNavigationStyleNormal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageUnreadCount:) name:@"messageUnreadCount" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //文件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDidFinishedCollect:) name:Notify_CollectFile object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forwardMessage:) name:Notify_ForwardMessage object:nil];
    if (self.chatMode == ChatPrivateMode) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdate:) name:@"needUpdate" object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdate:) name:@"pubNeedUpdate" object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speechAudioPlayOver:) name:kNotifyAudioFinishPlaying object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatSearchFileClick:) name:@"chatSearchFileClick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(agoraStopMyCallNotification:)
                                                 name:KDAgoraStopMyCallNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(agoraStopMyCallNotification:)
                                                 name:KDAgoraMessageQuitChannelNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadShortVideoFail:) name:@"downloadShortVideoFileFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExitGroupNotification:) name:KDHasExitGroupNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasMsgDelDidReceive:) name:@"updatePublicChatMessageList" object:nil];
    [KDWeiboAppDelegate getAppDelegate].activeChatViewController = self;
    
    if ((self.isSendingImage || self.isSendingFile)) {
//        [self reloadTable:0];
        [self reloadTable:(int)self.bubbleArray.count];
    }
    self.isSendingImage = NO;
    self.isSendingFile = NO;
    
    NSString *title = nil;
    if (self.group.groupType == GroupTypeMany) {
        title = [self getMutiChatGroupTitle];
    } else {
        title = self.group.groupName;
    }
    self.navigationItem.title = title;
    
    
    
    // @功能底部view
    if (selectPersonsView) {
        selectPersonsView = nil;
    }
    
    selectPersonsView = [[XTSelectPersonsView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(self.navigationController.view.frame) - 44.0f - 44.0f, self.view.frame.size.width, 44.0)];
    selectPersonsView.hidden = YES;
    
    
    if(!self.multiselecting)
        [self setupLeftNavigationItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //显示圆点的逻辑
    [self multiVoiceShowLogic];
    //不一定需要,先留着 by carl
    //[self reloadTable:(int)self.bubbleArray.count];
    
    if (![_group isPublicGroup])
    {
        if (self.bSearchingMode)
        {
            
            UIButton *button = [UIButton new];
            button.tag = 2;
            [self.searchViewController itemClick:button];
        }
        
    }
    //BUG 1130
    NSString *personId = [self.group.participantIds firstObject];
    PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPersonWithPersonId:personId];
    if (person != nil) {
//        if ([self.group.participantIds count] < 1 || ([self.group.participantIds count] == 1 && [[BOSConfig sharedConfig].user.userId isEqualToString:person.personId]) ){
         if (self.group.userCount < 2){
            if (![person.personId isEqualToString:@"XT-10000"]) {
                
                UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
                
                KDNotificationView *notificationView = [KDNotificationView defaultMessageNotificationView];
                [notificationView showInView:keyWindow
                                     message:ASLocalizedString(@"XTChatViewController_Tip_7")type:KDNotificationViewTypeNormal];
                self.toolbarImageView.hidden = YES;
                self.toolbarMenuview.hidden = YES;
            }
        }
        else if([self.group chatAvailable])
        {
            self.toolbarImageView.hidden = NO;
            self.toolbarMenuview.hidden = NO;
        }
        
    }
    if (self.isDissolveGroup) {
        [self resetTableFrameAndHideInputBoard];
    }
    
    [self updateSilencedStatus];
    _pushingToChooseVC = NO;
    
    // bug 10795
    if (self.menuarray.count > 0)
    {
        if (self.ismenushow) {
            [self hideInputBoard];
            [self.contentView resignFirstResponder];
            self.toolbarImageView.alpha=0.0;
            self.toolbarMenuview.alpha=1.0;
            self.toolbarImageView.frame =CGRectMake(0.0, self.toolbarImageViewStartY+200, ScreenFullWidth, self.toolbarImageView.frame.size.height);
            self.toolbarMenuview.frame =CGRectMake(0.0, self.toolbarImageViewStartY, ScreenFullWidth, 49);
            [self menuboardshow];
        }
    }
}

- (void)downloadShortVideoFail:(NSNotification *)noti {
    NSError *error = noti.object;
    if (error) {
        [self downloadFileFailWithError:error];
    }
}

- (void)onWillEnterForeground:(NSNotification *)noti {
    if(self.inputBoardShow)
        [self checkLastPhoto:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.jumpSuccess = NO;
    
     [self hideMarkBanner];
    if (self.bShownViewLastPhoto) {
        [self hideViewLastPhoto];
    }
    
    [self.contentView setDelegate:nil];
    
    if (_browser) {
        [_browser hide];
    }
    
    // 是否进入的是@选人界面
    BOOL pushToChooseVC = [self.navigationController.topViewController class] == [KDChooseContentCollectionViewController class];
    
    // 进@某人不收键盘, 除此之外收键盘
    if (!self.contentView.hidden && !pushToChooseVC) {
        [self.contentView resignFirstResponder];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAgoraStopMyCallNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAgoraMessageQuitChannelNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notify_CollectFile object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notify_ForwardMessage object:nil];
    if (self.chatMode == ChatPrivateMode) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"needUpdate" object:nil];
        [[XTDataBaseDao sharedDatabaseDaoInstance] updateGroupListWithGroup:self.group withPublicId:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pubNeedUpdate" object:nil];
        [[XTDataBaseDao sharedDatabaseDaoInstance] updateGroupListWithGroup:self.group withPublicId:self.pubAccount.publicId];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyAudioFinishPlaying object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadShortVideoFileFail" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageUnreadCount" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updatePublicChatMessageList" object:nil];
    
    //公共号订阅后会导致无法调用
    //[KDWeiboAppDelegate getAppDelegate].activeChatViewController = nil;
    
    if ([BOSAudioPlayer sharedAudioPlayer].isPlaying) {
        [[BOSAudioPlayer sharedAudioPlayer] stopPlay];
    }
    
    // 更新/删除 草稿
    if (self.contentView.text.length > 0 && !_pushingToChooseVC) {
        [self updateDraft:self.contentView.text];
    }
    else if(self.contentView.text.length > 0)
    {
        
    }
    else {
        [self removeDraft];
    }
    
    if (_searchViewController.view.superview) {
        self.bSearchingMode = NO;
        [_searchViewController dismissChatSearchView];
        [self chatSearchViewWillDismiss];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self hideInputBoard];
    
    if (self.socialShareSheet) {
        [self.socialShareSheet hideSheet];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    if (_shouldChangeTextField == NO)
    {
        return;
    }
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
    
    CGRect bubbleTableFrame = self.bubbleTable.frame;
    CGRect toolBarViewFrame = self.toolbarImageView.frame;
    CGRect inputBoardFrame = self.inputBoardBGView.frame;
    //键盘缩下
    if (keyboardBounds.origin.y == ScreenFullHeight)
    {
        if (!self.inputBoardShow)
        {
            bubbleTableFrame.size.height = self.bubbleTableStartHeight;
            toolBarViewFrame.origin.y = self.toolbarImageViewStartY;
            inputBoardFrame.origin.y = self.inputBoardStartY;
        }
        else
        {
            bubbleTableFrame.size.height = self.bubbleTableStartHeight - InputBoardHeight;
            toolBarViewFrame.origin.y = self.toolbarImageViewStartY - InputBoardHeight;
            //恢复输入板高度
            inputBoardFrame.origin.y = self.inputBoardStartY - InputBoardHeight;
        }
        self.keyboardShow = NO;
    }
    //键盘升起
    else
    {
        bubbleTableFrame.size.height = self.bubbleTableStartHeight - keyboardBounds.size.height;
        toolBarViewFrame.origin.y = self.toolbarImageViewStartY - keyboardBounds.size.height;
        if (!self.inputBoardShow)
        {
            self.inputBoardShow = YES;
            inputBoardFrame.origin.y = self.inputBoardStartY - InputBoardHeight;
        }
        else
        {
            //隐藏空白
            inputBoardFrame.origin.y = self.inputBoardStartY - keyboardBounds.size.height;
        }
        self.keyboardShow = YES;
        [self hideViewLastPhoto];
    }
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         
                         [weakSelf.bubbleTable setFrame:bubbleTableFrame];
                         [weakSelf scrollRow:[weakSelf.bubbleArray count] - 1 animated:NO];
                         [weakSelf.toolbarImageView setFrame:toolBarViewFrame];
                         [weakSelf.inputBoardBGView setFrame:inputBoardFrame];
                     }
                     completion:nil];
}


- (void)showInputBoard
{
    self.inputBoardShow = YES;
    CGRect toolBarViewFrame = self.toolbarImageView.frame;
    CGRect bubbleTableFrame = self.bubbleTable.frame;
    CGRect inputBoardFrame = self.inputBoardBGView.frame;
    toolBarViewFrame.origin.y = self.toolbarImageViewStartY - InputBoardHeight;
    bubbleTableFrame.size.height = self.bubbleTableStartHeight - InputBoardHeight;
    inputBoardFrame.origin.y = self.inputBoardStartY - InputBoardHeight;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         weakSelf.bubbleTable.frame = bubbleTableFrame;
                         [weakSelf scrollRow:[weakSelf.bubbleArray count] - 1 animated:NO];
                         weakSelf.toolbarImageView.frame = toolBarViewFrame;
                         weakSelf.inputBoardBGView.frame = inputBoardFrame;
                     }
                     completion:nil];
    
    [self showViewLastPhoto];
}

- (void)hideInputBoard
{
    self.inputBoardShow = NO;
    CGRect toolBarViewFrame = self.toolbarImageView.frame;
    CGRect bubbleTableFrame = self.bubbleTable.frame;
    CGRect inputBoardFrame = self.inputBoardBGView.frame;
    toolBarViewFrame.origin.y = self.toolbarImageViewStartY;
    bubbleTableFrame.size.height = self.bubbleTableStartHeight;
    inputBoardFrame.origin.y = self.inputBoardStartY;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         weakSelf.toolbarImageView.frame = toolBarViewFrame;
                         weakSelf.bubbleTable.frame = bubbleTableFrame;
                         weakSelf.inputBoardBGView.frame = inputBoardFrame;
                     }
                     completion:nil];
    [self hideViewLastPhoto];
    
    
    if (self.messageMode == KDChatMessageModeReply)
        [self changeMessageModeTo:KDChatMessageModeNone];
    
    [self.contentView resignFirstResponder];
}

- (void)showEmojiBoard
{
    self.emojiBoardShow = YES;
    if (self.messageMode == KDChatMessageModeNotrace) {
        _contentView.inputView = [self notraceExpressionInputView];
    } else {
        _contentView.inputView = [self expressionInputView];
    }
    [_contentView becomeFirstResponder];
}

- (void)hideEmojiBoard
{
    self.emojiBoardShow = NO;
    [_contentView resignFirstResponder];
    _contentView.inputView = nil;
}

-(void)needUpdate:(NSNotification *)notification
{
    [self fetchNewMessages];
}

-(void)setGroup:(GroupDataModel *)group
{
    if (_group != group) {
        
        if (_group.isNewGroup) {
            group.isNewGroup = YES;
        }
        
        if (_group) {
            [_group removeObserver:self forKeyPath:@"groupName"];
        }
        
        [group addObserver:self forKeyPath:@"groupName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        
        _group = group;
        [self reloadMenuData:group];
        [self updateViews];
        [self groupListChangedFunction];
        
        [self updateSilencedStatus];
        
        self.noticeController.dataSource = self;
        self.noticeController.delegate = self;
        [self noticeOnGroupChange:self.noticeController];
        
        if(self.chatDetailVC)
            self.chatDetailVC.group = _group;
    }
}

-(void)reloadMenuData:(GroupDataModel *)group
{
    //以publicaccount的menu为准
    if (_ispublic && [group.participant count] == 1) {
        PersonSimpleDataModel *person = [group.participant firstObject];
        if ([person isPublicAccount]) {
            PersonDataModel *pubacc = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicPersonSimple:person.personId];
            if (pubacc && pubacc.menu.length > 0) {
                group.menu = pubacc.menu;
            }
        }
    }
    
    if (group.menu.length > 0) {
        self.menuarray = [[NSMutableArray alloc]init];
        
        NSMutableArray *t_array = [[NSMutableArray alloc] init];
        NSData*data=[group.menu dataUsingEncoding:NSUTF8StringEncoding];
        id obj=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        for (id each in obj) {
            XTmenuModel *t_record = [[XTmenuModel alloc] initWithDictionary:each];
            NSMutableArray *array = [NSMutableArray arrayWithArray:t_record.sub];
            
            for (int idx = 0; idx < [t_record.sub count]; idx++) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:array[idx]];
                NSString *url = [dic objectForKey:@"url"];
                if(url && [url rangeOfString:@"#"].location != NSNotFound){
                    url = [url  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [dic setObject:url forKey:@"url"];
                }
                array[idx] = dic;
            }
            
            t_record.sub = array;
            if(t_record.url && ![t_record.url isEqualToString:@""]){
                t_record.url = [t_record.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            [t_array addObject:t_record];
        }
        self.menuarray = t_array;
    }
}

-(void)updateViews
{
    //BUG 1160 放到这里显示好一点
    PersonSimpleDataModel *person = [self.group.participant firstObject];
//    if ([self.group.participantIds count] < 1 || ([self.group.participantIds count] == 1 && [[BOSConfig sharedConfig].currentUser.personId isEqualToString:person.personId]) ){
    if (self.group.userCount < 2) {

        if (![person.personId isEqualToString:@"XT-10000"]) {
            
            UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
            
            KDNotificationView *notificationView = [KDNotificationView defaultMessageNotificationView];
            [notificationView showInView:keyWindow
                                 message:ASLocalizedString(@"XTChatViewController_Tip_7")type:KDNotificationViewTypeNormal];
        }
    }
    
    
    if (_group.groupType != GroupTypeMany)
    {
        self.title = _group.groupName;
    }
    else
    {
        //        self.title = [NSString stringWithFormat:@"%@(%lu)", _group.groupName, (unsigned long) ([_group.participant count] + 1)];
        self.title = [self getMutiChatGroupTitle];
    }
    
    [self setupRightNavigationItem];
    
    CGRect rect = self.bubbleTable.frame;
    
    
    if ([self.group chatAvailable])
    {
        if (self.toolbarImageView.hidden)
        {
            self.toolbarImageView.hidden = NO;
            self.toolbarMenuview.hidden = NO;
            self.bubbleTableStartHeight = Height(self.mainView.frame) - Height(self.toolbarImageView.frame);
            rect.size.height = self.bubbleTableStartHeight;
            self.bubbleTable.frame = rect;
            [self.view bringSubviewToFront:self.toolbarImageView];
        }
    }
    else
    {
        // 被提出
        if (!self.toolbarImageView.hidden)
        {
            self.toolbarImageView.hidden = YES;
            self.toolbarMenuview.hidden = YES;
            if ([self.contentView isFirstResponder])
            {
                [self.contentView resignFirstResponder];
            }
            self.bubbleTableStartHeight = Height(self.mainView.frame);
            rect.size.height = self.bubbleTableStartHeight;
            self.bubbleTable.frame = rect;
            
            [self hideInputBoard];
        }
    }
    if (self.menuarray.count > 0)
    {
        [self menuboardshow];
    }
    
}

#pragma mark button action

-(void)changeBtnClick:(id)sender
{
    UIButton *changeBtn = (UIButton *)sender;
    if (changeBtn.tag == ChangeBtnTagText) {
        
        changeBtn.tag = ChangeBtnTagSpeech;
        self.recordButton.hidden = YES;
        self.contentView.hidden = NO;
        self.keyboardShow = YES;
        
        float textViewHeightSpace = self.contentView.bounds.size.height - TextView_Min_Height;
        if (textViewHeightSpace > 0) {
            //还原回去
            CGRect bubbleTableFrame = self.bubbleTable.frame;
            bubbleTableFrame.size.height -= textViewHeightSpace;
            self.bubbleTableStartHeight -= textViewHeightSpace;
            self.bubbleTable.frame = bubbleTableFrame;
            
            CGRect toolBarFrame = self.toolbarImageView.frame;
            toolBarFrame.size.height += textViewHeightSpace;
            toolBarFrame.origin.y -= textViewHeightSpace;
            self.toolbarImageViewStartY -= textViewHeightSpace;
            self.toolbarImageView.frame = toolBarFrame;
        }
        
        [self.contentView becomeFirstResponder];
        
        [XTSetting sharedSetting].defaultChatKeyboardType = XTChatKeyboardText;
        
    }else{
        
        changeBtn.tag = ChangeBtnTagText;
        self.recordButton.hidden = NO;
        self.contentView.hidden = YES;
        [self.contentView resignFirstResponder];
        self.keyboardShow = NO;
        [self hideInputBoard];
        [self hideEmojiBoard];
        
        float textViewHeightSpace = self.contentView.bounds.size.height - TextView_Min_Height;
        if (textViewHeightSpace > 0) {
            //还原回去
            CGRect bubbleTableFrame = self.bubbleTable.frame;
            bubbleTableFrame.size.height += textViewHeightSpace;
            self.bubbleTableStartHeight += textViewHeightSpace;
            self.bubbleTable.frame = bubbleTableFrame;
            
            CGRect toolBarFrame = self.toolbarImageView.frame;
            toolBarFrame.size.height -= textViewHeightSpace;
            toolBarFrame.origin.y += textViewHeightSpace;
            self.toolbarImageViewStartY += textViewHeightSpace;
            self.toolbarImageView.frame = toolBarFrame;
        }
        
        [self.contentView resignFirstResponder];
        //        [UIView animateWithDuration:KEYBOARD_MOVE_TIME animations:^{
        //            [self.contentView resignFirstResponder];
        //            [self moveDownToolbarAndInputBoard];
        //        }];
        [XTSetting sharedSetting].defaultChatKeyboardType = XTChatKeyboardSpeech;
        
    }
    [[XTSetting sharedSetting] saveSetting];
    
    [changeBtn setBackgroundImage:[XTImageUtil chatToolBarChangeBtnImageWithTag:(int)changeBtn.tag state:UIControlStateNormal] forState:UIControlStateNormal];
    [changeBtn setBackgroundImage:[XTImageUtil chatToolBarChangeBtnImageWithTag:(int)changeBtn.tag state:UIControlStateHighlighted] forState:UIControlStateHighlighted];
}

- (void)photoBtnClick:(id)sender
{
    self.isFilePicture = NO;
    [self toImagePicker:1];
    [self hideViewLastPhoto];
}

- (void)cameraBtnClick:(id)sender
{
//    [self toImagePicker:0];
    [self toCamera];
    
    
    [self hideViewLastPhoto];
}

- (void)toCamera {
    KDCameraViewController *cameraVC = [KDCameraViewController new];
    cameraVC.delegate = self;
    [self.navigationController presentViewController:cameraVC animated:YES completion:nil];
}

- (void)fileBtnClick:(id)sender
{
    XTMyFilesViewController *fileListVC = [[XTMyFilesViewController alloc] init];
    fileListVC.hidesBottomBarWhenPushed = YES;
    fileListVC.delegate = self;
    fileListVC.fromType = 0;
    [self.navigationController pushViewController:fileListVC animated:YES];
    [self hideViewLastPhoto];
    [self changeMessageModeTo:KDChatMessageModeNone];
}

-(void)voiceBtnClick:(id) sender
{
    //    BOOL hadSession = [[[KDApplicationQueryAppsHelper shareHelper] multiVoiceTimer] agoraUid] != 0;
    //    BOOL isTheSameGroup = [self.group.groupId isEqualToString:[[[KDApplicationQueryAppsHelper shareHelper] multiVoiceTimer] groupId]];
    //
    //    if (hadSession && !isTheSameGroup)
    //    {
    //        [[KDApplicationQueryAppsHelper shareHelper] showAlreadyHaveMultiVoiceAlert];
    //    }
    //    else if (hadSession && isTheSameGroup)
    //    {
    //        [[KDApplicationQueryAppsHelper shareHelper] buildMultiVoiceTimerWithGroupId:self.group.groupId GroupName:self.group.groupName];
    //        [[KDApplicationQueryAppsHelper shareHelper] startMultiVoiceTimer];
    //
    //        KDMultiVoiceViewController *multi = [[KDMultiVoiceViewController alloc]initWithGroupName:self.group.groupName];
    //        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:multi];
    //        [self presentViewController:navi animated:YES completion:nil];
    //    }
    //    else
    //    {
    //        [[KDApplicationQueryAppsHelper shareHelper] joinMultiVoiceSession];
    //        KDMultiVoiceViewController *multi = [[KDMultiVoiceViewController alloc]initWithGroupName:self.group.groupName];
    //        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:multi];
    //        [self presentViewController:navi animated:YES completion:nil];
    //    }
    //    [self hideViewLastPhoto];
}

- (void)emojiBtnClick:(id)sender
{
    if (!self.emojiBoardShow) {
        if (self.keyboardShow) {
            [self.contentView resignFirstResponder];
        }
        [self showEmojiBoard];
        if (self.changeButton.tag == ChangeBtnTagText) {
            [self changeBtnClick:self.changeButton];
        }
        [[XTSetting sharedSetting] saveSetting];
        self.inputBoardShow = NO;
    } else {
        //        if (self.keyboardShow) {
        //            [self.contentView resignFirstResponder];
        //            [self showEmojiBoard];
        //        } else {
        //            [self.contentView becomeFirstResponder];
        //            self.emojiBoardShow = NO;
        //        }
        [self hideEmojiBoard];
        [_contentView becomeFirstResponder];
    }
}

#pragma mark 快捷发送图片

- (UIView *)viewLastPhoto {
    if (!_viewLastPhoto) {
        _viewLastPhoto = [[UIView alloc] init];
        _viewLastPhoto.frame = CGRectMake(0, 0, 58, 90);
        _viewLastPhoto.backgroundColor = [UIColor clearColor];
        _viewLastPhoto.alpha = 0;
        UIImageView *imageViewBG = [[UIImageView alloc] initWithFrame:_viewLastPhoto.frame];
        imageViewBG.image = [UIImage imageNamed:@"chat_plus_menu_kuang"];
        [_viewLastPhoto addSubview:imageViewBG];
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(4, 3, _viewLastPhoto.frame.size.width - 3, 27)];
        labelTitle.backgroundColor = [UIColor clearColor];
        labelTitle.numberOfLines = 0;
        labelTitle.text = ASLocalizedString(@"XTChatViewController_Tip_8");
        labelTitle.font = [UIFont systemFontOfSize:10];
        [_viewLastPhoto addSubview:labelTitle];
        UIImageView *imageViewPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(3, 30, 52, 52)];
        imageViewPhoto.backgroundColor = [UIColor darkGrayColor];
        imageViewPhoto.layer.cornerRadius = 3;
        imageViewPhoto.tag = 1020;
        imageViewPhoto.contentMode = UIViewContentModeScaleAspectFill;
        imageViewPhoto.clipsToBounds = YES;
        imageViewPhoto.layer.borderWidth = 0.5;
        imageViewPhoto.layer.borderColor = [UIColor KDGrayColor].CGColor;
        [_viewLastPhoto addSubview:imageViewPhoto];
        UIButton *button = [[UIButton alloc] initWithFrame:_viewLastPhoto.frame];
        [button addTarget:self action:@selector(buttonLastPhotoPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_viewLastPhoto addSubview:button];
    }
    return _viewLastPhoto;
}

- (BOOL)bShowingViewLastPhoto {
    return self.viewLastPhoto.alpha == 1;
}

- (void)showViewLastPhoto {
    if (!self.bShouldShowViewLastPhoto) {
        return;
    }
    if (self.bShowingViewLastPhoto) {
        return;
    }
    __weak __typeof(self) weakSelf = self;
    SetY(self.viewLastPhoto.frame, self.toolbarImageView.frame.origin.y - self.viewLastPhoto.frame.size.height);
    SetX(self.viewLastPhoto.frame, ScreenFullWidth - self.viewLastPhoto.frame.size.width - 4);
    [UIView animateWithDuration:.25 animations:^{
        weakSelf.viewLastPhoto.alpha = 1;
    }];
    self.bShownViewLastPhoto = YES;
    [self performSelector:@selector(hideViewLastPhoto) withObject:nil afterDelay:10];
}


- (void)hideViewLastPhoto {
    [self saveStatesOfLastPhoto];
    if (!self.bShowingViewLastPhoto) {
        return;
    }
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:.25 animations:^{
        weakSelf.viewLastPhoto.alpha = 0;
    }];
}
#pragma mark - 语音会议跳转
- (void)goToMultiVoice
{
    if(![[KDApplicationQueryAppsHelper shareHelper]getGroupTalkStatus] && [self.group chatAvailable])
    {
        return;
    }
    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    BOOL hasCallIng = agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel;
    BOOL isSameGroup = NO;
    if(hasCallIng && [self.group.groupId isEqualToString:agoraSDKManager.currentGroupDataModel.groupId])
    {
        isSameGroup = YES;
    }
    
    if(hasCallIng && !isSameGroup)
    {//不同的已存在的会议
        [[KDAgoraSDKManager sharedAgoraSDKManager] showAlreadyHaveMultiVoiceAlertWithGroup:self.group controller:self];
    }else if(hasCallIng && isSameGroup)
    {//同一会议
        KDMultiVoiceViewController *multiVoceController = [[KDMultiVoiceViewController alloc] init];
        multiVoceController.groupDataModel = self.group;
        multiVoceController.desController = self;
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:multiVoceController];
        [self presentViewController:navi animated:YES completion:nil];
    }else{
        //判断当前组是否已开始多人会话
        if(self.group.mCallStatus == 1)
        {
            //已开通会议  则直接加入会议 二次校验
            if(!self.queryGroupInfoClient)
            {
                self.queryGroupInfoClient = [[ContactClient alloc] initWithTarget:self action:@selector(queryGroupInfoClientDidReceive3:result:)];
            }
            [self.queryGroupInfoClient queryGroupInfoWithGroupId:self.group.groupId];
            return;
        }else{
   
            if (self.mCallClient == nil) {
                self.mCallClient = [[ContactClient alloc]initWithTarget:self action:@selector(startOrStopMyCallWithGroupIdDidReceived:result:)];
            }
            [self.mCallClient startOrStopMyCallWithGroupId:self.group.groupId status:1 channelId:nil];
        }

        
        
    }
    
}
static const char startOrStopGroupResultKey;
- (void)startOrStopMyCallWithGroupIdDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    KDAgoraSDKManager *agoraManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    if(!result)
    {
//        KDAgoraSDKManager *agoraManager = [KDAgoraSDKManager sharedAgoraSDKManager];
        if(agoraManager.agoraPersonsChangeBlock)
        {
            agoraManager.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_createChannelFailued,nil,nil,nil);
        }        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:result.error?result.error : ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_36")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alert show];
        return;
    }
    if(result.success)
    {
        self.group.param = result.data;
        self.group.mCallStatus = [result.data[@"mcallStatus"] integerValue];
        self.group.mCallCreator = result.data[@"mcallCreator"];
 
        //开启一个会议
        KDMultiVoiceViewController *multiVoceController = [[KDMultiVoiceViewController alloc] init];
        multiVoceController.groupDataModel = self.group;
        multiVoceController.desController = self;
        agoraManager.currentGroupDataModel = nil;
        
        if(agoraManager.agoraModelArray)
        {
            [agoraManager.agoraModelArray removeAllObjects];
        }
        multiVoceController.isCreatMyCall = YES;
        
        RTRootNavigationController *navi = [[RTRootNavigationController alloc]initWithRootViewController:multiVoceController];
        [self presentViewController:navi animated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraCreateMyCallNotification object:self userInfo:@{@"result":@(YES),@"param":result.data}];
    }else if(!result.success){
        if(result.errorCode == 101)
        {
            id data = result.data;
            if(data && ![data isKindOfClass:[NSNull class]])
            {
                NSDictionary *dataDict = (NSDictionary *)data;
                NSString *groupId = dataDict[@"groupId"];
                NSString *channelId = dataDict[@"channelId"];
                if(groupId && ![groupId isEqualToString:self.group.groupId] && channelId)
                {
                    GroupDataModel *groupDataModel = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:groupId];
                    if(groupDataModel)
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:ASLocalizedString(@"KDAgoraSDKManager_Tip_8"),groupDataModel ? groupDataModel.groupName : @"当前"] delegate:self cancelButtonTitle:ASLocalizedString(@"KDAgoraSDKManager_Tip_9")otherButtonTitles:ASLocalizedString(@"KDApplicationQueryAppsHelper_no"), nil];
                        alert.tag = KDstartGroupTalkAlertTag;
                        objc_setAssociatedObject(alert, &startOrStopGroupResultKey, dataDict, OBJC_ASSOCIATION_RETAIN);
                        [alert show];
                        return;
                    }
                }
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraCreateMyCallNotification object:self userInfo:@{@"result":@(NO)}];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:result.error?result.error : ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_36")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alert show];
    }
}


- (void)addBtnClick:(id)sender
{
    if (_fromTimeLie) {
        _fromTimeLie = NO;
    }else
    {
        //add
        [KDEventAnalysis event: event_dialog_plus_count];
        [KDEventAnalysis eventCountly: event_dialog_plus_count];
    }
    
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kChatPlusMenuRedFlag];
    self.imageViewPlusMenuRedFlag.hidden = YES;
    if (!self.inputBoardShow)
    {
        if (self.keyboardShow)
        {
            [self.contentView resignFirstResponder];
        }
        
        if (self.emojiBoardShow)
        {
            [self hideEmojiBoard];
        }
        UIButton *changeBtn = self.changeButton;
        changeBtn.tag = ChangeBtnTagSpeech;
        self.recordButton.hidden = YES;
        self.contentView.hidden = NO;
        [[XTSetting sharedSetting] saveSetting];
        [changeBtn setBackgroundImage:[XTImageUtil chatToolBarChangeBtnImageWithTag:(int) changeBtn.tag state:UIControlStateNormal] forState:UIControlStateNormal];
        [changeBtn setBackgroundImage:[XTImageUtil chatToolBarChangeBtnImageWithTag:(int) changeBtn.tag state:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [self showInputBoard];
    }
    else
    {
        if (!self.keyboardShow)
        {
            [self.contentView becomeFirstResponder];
        }
        else
        {
            [self.contentView resignFirstResponder];
            //[self showViewLastPhoto];
        }
    }
}

- (void)buttonLastPhotoPressed:(UIButton *)button {
    [KDEventAnalysis event:event_session_send_image_by_shortcut];
    [self buttonPreviewPressed];
    [self hideViewLastPhoto];
}

- (void)checkLastPhoto:(BOOL)showViewLastPhoto {
    __weak __typeof(self) weakSelf = self;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            @autoreleasepool {
                // The end of the enumeration is signaled by asset == nil.
                if (alAsset) {
                    ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                    // 获取最新照片的拍摄时间
                    NSDate *myDate = [alAsset valueForProperty:ALAssetPropertyDate];
                    NSDate *dateCurrent = [NSDate date];
                    NSTimeInterval diff = [dateCurrent timeIntervalSinceDate:myDate];
                    if (fabs(diff) <= 60) {
                        NSString *strOldURL = [[NSUserDefaults standardUserDefaults] objectForKey:kMostRecentPhoto];
                        if ([[NSString stringWithFormat:@"%@", representation.url] isEqualToString:strOldURL]) {
                            weakSelf.bShouldShowViewLastPhoto = NO;
                        } else {
                            weakSelf.bShouldShowViewLastPhoto = YES;
                        }
                        UIImageOrientation orientation = UIImageOrientationUp;
                        NSNumber *orientationValue = [alAsset valueForProperty:@"ALAssetPropertyOrientation"];
                        if (orientationValue != nil) {
                            orientation = [orientationValue intValue];
                        }
                        CGFloat scale = 1;
                        UIImage *image = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                                             scale:scale orientation:orientation];
                        UIImageView *imageView = (UIImageView *) [weakSelf.viewLastPhoto viewWithTag:1020];
                        imageView.image = image;
                        MWPhoto *photo = [MWPhoto photoWithImage:image];
                        photo.photoURL = representation.url;
                        MWPhoto *thumbnailPhoto = [MWPhoto photoWithImage:[UIImage imageWithCGImage:alAsset.thumbnail]];
                        thumbnailPhoto.photoURL = representation.url;
                        
                        [weakSelf.photos setArray:@[photo]];
                        [weakSelf.thumbs setArray:@[thumbnailPhoto]];
                        weakSelf.strMostRecentPhotoURL = [NSString stringWithFormat:@"%@", representation.url];
                        if (showViewLastPhoto) {
                            [weakSelf performSelectorOnMainThread:@selector(showViewLastPhoto) withObject:nil waitUntilDone:YES];
                        }
                        *stop = YES;
                        *innerStop = YES;
                    }
                }
            }
        }];
    }                    failureBlock:^(NSError *error) {
    }];
}

- (void)saveStatesOfLastPhoto {
    if (!self.bShownViewLastPhoto) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.strMostRecentPhotoURL forKey:kMostRecentPhoto];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.bShouldShowViewLastPhoto = NO;
}


- (void)knownBtnClick:(id)sender
{
    [self hudWasHidden:self.progressHud];
}


- (void)toEditGroupName:(id)sender{
    
    XTModifyGroupNameViewController *modifyViewController = [[XTModifyGroupNameViewController alloc] initWithGroup:self.group];
    modifyViewController.delegate = self;
    modifyViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:modifyViewController animated:YES];
}

#pragma mark -- 自定义返回按钮
- (void)setupLeftNavigationItem {
    //自定义回退的button
    //    UIImage *image = [UIImage imageNamed:@"navigationItem_back"];
    //    UIImage *highlightImage = [UIImage imageNamed:@"navigationItem_back_hl"];
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [button addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    //    [button setImage:image forState:UIControlStateNormal];
    //    [button setImage:highlightImage forState:UIControlStateHighlighted];
    //    [button sizeToFit];
    
    
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [backBtn sizeToFit];
    
    [backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    //    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
    //                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
    //                                       target:nil action:nil];
    //    float width = kLeftNegativeSpacerWidth;
    //    negativeSpacer.width = width;
    self.navigationItem.leftBarButtonItems = @[barButtonItem];
    
}

- (void)goBack:(UIButton *)backButton {
    _scrollProxy.delegate = nil;
    _scrollProxy = nil;
    
    self.bubbleTable.delegate = nil;
    self.bubbleTable.dataSource = nil;
    self.bubbleTable = nil;
    
    [[KDApplicationQueryAppsHelper shareHelper] cancelMultiVoiceTimer];
    
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //    [_requestClient cancelRequest];
    [KDWeiboAppDelegate getAppDelegate].activeChatViewController = nil;
}

- (void)setupRightNavigationItem
{
    if (self.isHistory || self.bSearchingMode) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        self.detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (self.group.groupType == GroupTypeMany) {
            [self.detailButton setImage:[UIImage imageNamed:@"message_btn_people_normal"] forState:UIControlStateNormal];
            [self.detailButton setImage:[UIImage imageNamed:@"message_btn_people_press"] forState:UIControlStateHighlighted];
        } else {
            [self.detailButton setImage:[UIImage imageNamed:@"message_btn_person_normal"] forState:UIControlStateNormal];
            [self.detailButton setImage:[UIImage imageNamed:@"message_btn_person_press"] forState:UIControlStateHighlighted];
        }
        
        [self.detailButton addTarget:self action:@selector(detail:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *noticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([self.noticeController isBoxShowing]) {
            [noticeButton setImage:[UIImage imageNamed:@"nav_btn_notice_focus_normal"] forState:UIControlStateNormal];
            [noticeButton setImage:[UIImage imageNamed:@"nav_btn_notice_focus_press"] forState:UIControlStateHighlighted];
        } else {
            [noticeButton setImage:[UIImage imageNamed:@"nav_btn_notice_normal"] forState:UIControlStateNormal];
            [noticeButton setImage:[UIImage imageNamed:@"nav_btn_notice_press"] forState:UIControlStateHighlighted];
        }
        [noticeButton addTarget:self action:@selector(onNoticeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        PersonSimpleDataModel *person = [self.group.participant firstObject];
      
        //如果是公共号 则在公共号表里查询，为了某些特殊字段，比如state  bug12131。
        if ([self.group isPublicGroup]) {
            person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicPersonSimple:person.personId];
            if (person) {
                self.group.participant[0] = person;
            }
        }
        if (([self.group actionAvailable] || ([self.group isPublicGroup] && ([self.group chatAvailable] || person.state == 2))) && self.chatMode != ChatPublicMode) {
            if (self.group.groupType == GroupTypeMany && self.group.chatAvailable) {
                
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
                view.backgroundColor = [UIColor clearColor];
                
                self.detailButton.frame = CGRectMake(40, 0, 40, 44);
                self.detailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [self.detailButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, - 8 * ScreenFullWidth/375.0)];
                [view addSubview:self.detailButton];
                
                noticeButton.frame = CGRectMake(0, 0, 40, 44);
                noticeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [noticeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, - 15 * ScreenFullWidth/375.0)];
                [view addSubview:noticeButton];
                
                UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
                self.navigationItem.rightBarButtonItem = rightBarButtonItem;
            } else {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
                view.backgroundColor = [UIColor clearColor];
                
                self.detailButton.frame = CGRectMake(0, 0, 44, 44);
                self.detailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                [self.detailButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5 * ScreenFullWidth / 375.0)];
                
                UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.detailButton];
                self.navigationItem.rightBarButtonItem = rightBarButtonItem;
            }
        }else{
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}


#pragma mark - 多人语音方法
- (void)multiVoiceShowLogic
{
    if ([[KDApplicationQueryAppsHelper shareHelper] getGroupTalkStatus])   //检测当前工作圈是否开启了多人语音的开关
    {
        if ([self.group chatAvailable])
        {
            KDAgoraSDKManager *agoraManager = [KDAgoraSDKManager sharedAgoraSDKManager];
            if(self.group.mCallStatus != 0)
            {
                [self showMultiBannerView];
            }else if(agoraManager.isUserLogin && agoraManager.currentGroupDataModel && [agoraManager.currentGroupDataModel.groupId isEqualToString:self.group.groupId])
            {
                [self showMultiBannerView];
            }else {
                [self hideMultiBannerView];
            }
        }
    }
}

-(void)addMultiVoiceToView
{
    //    if (self.multiVoiceWindow.superview == nil)   //已经加上了就不再添加
    //    {
    //        self.multiVoiceWindow = [UIButton buttonWithType:UIButtonTypeCustom];
    //        [self.multiVoiceWindow setBackgroundColor:[UIColor clearColor]];
    //        [self.multiVoiceWindow setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 8 - 60, 100, 60, 60)];
    //        [self.multiVoiceWindow setImage:[UIImage imageNamed:@"yuyin_beta_ios.png"] forState:UIControlStateNormal];
    //        [self.multiVoiceWindow addTarget:self action:@selector(goToMultiVoiceController:) forControlEvents:UIControlEventTouchUpInside];
    //        [self.view addSubview:self.multiVoiceWindow];
    //    }
    [self showMultiBannerView];
}

-(void)removeMultiVoiceFromView
{
    //    [self.multiVoiceWindow removeFromSuperview];
    //    self.multiVoiceWindow = nil;
    [self hideMultiBannerView];
}

-(void)goToMultiVoiceController:(UIButton *)sender
{
    
    [self voiceBtnClick:nil];
}

//会话已经存在的时候接受一个通知，进入到一个新的会话组
-(void)gotoNewMultiVoiceView:(NSNotification *)sender
{
    //    [[KDApplicationQueryAppsHelper shareHelper] joinMultiVoiceSession];
    //    KDMultiVoiceViewController *multi = [[KDMultiVoiceViewController alloc]initWithGroupName:self.group.groupName];
    //    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:multi];
    //    [self presentViewController:navi animated:YES completion:nil];
}

-(void)multiVoiceDidReceived:(NSNotification *)sender
{
    //需要判断确实发生改变的时候personIds的Id的数量来确定是添加还是移除
    BOOL showOrNot = [[[KDApplicationQueryAppsHelper shareHelper] multiVoiceTimer] count] > 0;
    
    if (showOrNot)
    {
        //加入button
        [self addMultiVoiceToView];
    }
    else
    {
        //移除button
        [self removeMultiVoiceFromView];
    }
}



#pragma mark - XTModifyGroupNameViewControllerDelegate

- (void)modifyGroupNameDidFinish:(XTModifyGroupNameViewController *)controller groupName:(NSString *)groupName
{
    self.group.groupName = groupName;
}
// send
- (void)sendWithRecord:(RecordDataModel *)record
{
    [self sendWithRecord:record image:nil];
}

- (void)sendWithRecord:(RecordDataModel *)record image:(UIImage *)image
{
    __block RecordDataModel *sendRecord = record;
    
    if (sendRecord.msgType != MessageTypeSpeech && sendRecord.msgType != MessageTypeText && sendRecord.msgType != MessageTypePicture  && sendRecord.msgType != MessageTypeFile && sendRecord.msgType != MessageTypeLocation && sendRecord.msgType != MessageTypeShortVideo && sendRecord.msgType != MessageTypeNotrace && sendRecord.msgType != MessageTypeCombineForward && sendRecord.msgType != MessageTypeShareNews && sendRecord.msgType != MessageTypeNews) {
        return;
    }
    
    if ([self.group.participant count] == 1) {
        PersonSimpleDataModel *person = [self.group.participant firstObject];
        if ([person.personId isEqualToString:@"XT-10000"]) {
            [KDEventAnalysis event:event_feedback_submit];
        }
    }
    
    NSString *toUserId = @"";
    //1267 公共号消息回复无toUserId
    //if ([@"" isEqualToString:self.group.groupId]) {
    if ([self.group.participant count] > 0) {
        toUserId = ((PersonSimpleDataModel *)[self.group.participant objectAtIndex:0]).personId;
    }
    //}
    
    KDMessageModel *message = [[KDMessageModel alloc] init];
    message.groupId = self.group.groupId;
    message.toUserId = toUserId;
    message.content = sendRecord.content;
    message.publicId = self.pubAccount.publicId;
    message.messageType = sendRecord.msgType;
    message.messageLength = sendRecord.msgLen;
    message.clientMessageId = sendRecord.msgId;
    message.translateId = sendRecord.translateMsgId;
    message.param = sendRecord.param.paramString;
//    message.transmit = sendRecord.translateMsgId? YES:NO;
    
    NSString *umengMsgLabel = label_msg_send_messageType_text;
    switch (sendRecord.msgType) {
        case MessageTypeText:
            umengMsgLabel = label_msg_send_messageType_text;
            break;
        case MessageTypePicture:
            
        {
            //名称以及后缀
            message.paramObj = sendRecord.param.paramObject;
            
            
            umengMsgLabel = label_msg_send_messageType_picture;
            
            UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord canTransmitUrl] imageScale:self.isSendingEmoji ? SDWebImageScaleNone : SDWebImageScalePreView]];
            
            //找不到SDWebImageScalePreView尺寸时找找SDWebImageScaleNone，呵呵
            if(!image)
                image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord canTransmitUrl] imageScale:SDWebImageScaleNone]];;
            
            
            NSData *picData = nil;
            if (image) {
                picData = self.isSendingEmoji ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, all_chat_send_photo_compress_ratio);
                if (!self.isSendingEmoji && self.bSendOriginal) {
                    picData =UIImageJPEGRepresentation(image, 1.f);
                    message.isOriginalPic = @"1";
                }
                
                if(!self.isSendingEmoji && self.forwardDM)
                {
                    //转发时按传过来的照片不压缩
                    picData =UIImageJPEGRepresentation(image, 1.f);
                    self.forwardDM = nil;
                }
            }
            else {
                UIImage *image1 = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord originalPictureUrl] imageScale:SDWebImageScalePreView]];
                if (image1) {
                    picData = UIImageJPEGRepresentation(image, all_chat_send_photo_compress_ratio);
                }
            }
            
            //带有fileid直接转发
            MessageShareTextOrImageDataModel *paramObj = message.paramObj;
            if(paramObj.fileId.length  == 0)
                message.sendData = [ContactUtils XOR80:picData];
        }
            break;
        case MessageTypeSpeech:
        {
            umengMsgLabel = label_msg_send_messageType_speech;
            NSString *filePath = [sendRecord xtFilePath];
            if (filePath == nil) {
                NSData *cafData=[NSData dataWithContentsOfFile:[ContactUtils recordFilePath]];
                message.sendData = [ContactUtils XOR80:EncodeWAVEToAMR(cafData,1,16)];
                
                //写入临时数据
                filePath = [[ContactUtils recordFilePathWithGroupId:sendRecord.groupId] stringByAppendingFormat:@"/%@%@",sendRecord.msgId,XTFileExt];
                [message.sendData writeToFile:filePath atomically:YES];
                
                //删除record_temp.caf
                [[NSFileManager defaultManager] removeItemAtPath:[ContactUtils recordFilePath] error:nil];
            }else{
                message.sendData = [NSData dataWithContentsOfFile:filePath];
            }
        }
            break;
        case MessageTypeFile:
        {
            umengMsgLabel = label_msg_send_messageType_file;
            if ([sendRecord.strEmojiType isEqualToString:@"original"]) {
                umengMsgLabel = label_msg_send_messageType_expression;
            }
        }
            break;
        case MessageTypeLocation:
        {
            if (!image) {
                image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord originalPictureUrl] imageScale:SDWebImageScaleNone]];
                //                [[SDImageCache sharedImageCache] storeImage:self.currentLocationData.selfIMG forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord originalPictureUrl] imageScale:SDWebImageScaleNone]];
                //                //找不到SDWebImageScalePreView尺寸时找找SDWebImageScaleNone，呵呵
                //                if(!image)
                //                    image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord canTransmitUrl] imageScale:SDWebImageScaleNone]];;
            }
            NSData *picData = UIImageJPEGRepresentation(image, all_chat_send_photo_compress_ratio);
            
            //名称以及后缀
            message.paramObj = sendRecord.param.paramObject;
            MessageTypeLocationDataModel *paramObj = message.paramObj;
            // 有file_id就转发
            if (paramObj.file_id.length == 0) {
                message.sendData = [ContactUtils XOR80:picData];
            }
        }
            break;
        case MessageTypeShortVideo:
        {
            //名称以及后缀
            message.paramObj = sendRecord.param.paramObject;
//            if (!image) {
//                image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord originalPictureUrl] imageScale:SDWebImageScaleNone]];
//            }
//            NSData *picData = UIImageJPEGRepresentation(image, all_chat_send_photo_compress_ratio);
//            
//            message.sendData = [ContactUtils XOR80:picData];
        }
            break;
        case MessageTypeNotrace:
        {
            message.paramObj = sendRecord.param.paramObject;
            
            if (sendRecord.param != nil && [sendRecord.param.paramObject isKindOfClass:[MessageNotraceDataModel class]]) {
                MessageNotraceDataModel *model = (MessageNotraceDataModel *)sendRecord.param.paramObject;
                
                if (model.msgType == MessageTypePicture) {
                    umengMsgLabel = label_msg_send_messageType_picture;
                    
                    NSData *imageData = UIImageJPEGRepresentation(image, all_chat_send_photo_compress_ratio);
                    
                    if (!imageData) {
                        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[[sendRecord bigPictureUrl] absoluteString]];
                        NSData *picData = nil;
                        
                        if (image) {
                            picData = self.isSendingEmoji ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, 1);
                        }
                        
                        if (picData) {
                            message.sendData = [ContactUtils XOR80:picData];
                        }
                    }
                    else {
                        message.sendData = [ContactUtils XOR80:imageData];
                    }
                }
            }
        }
            break;
        case MessageTypeCombineForward:
        {
            message.paramObj = sendRecord.param.paramObject;
        }
            break;

        default:
        {
            message.paramObj = sendRecord.param.paramObject;
        }
            break;
    }
    
    [KDEventAnalysis event:event_msg_send attributes:@{label_msg_send_messageType: umengMsgLabel}];
    
    [[XTDataBaseDao sharedDatabaseDaoInstance] insertRecord:sendRecord toUserId:toUserId needUpdateGroup:YES publicId:self.chatMode == ChatPrivateMode ? nil : self.pubAccount.publicId];
    
    __weak XTChatViewController *weakSelf = self;
    [[KDMessageHandler messageHandler] sendMessage:message chatMode:self.chatMode block:^(KDMessageModel *message, BOSResultDataModel *result) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (result.success) {
            //解决sendRecord跟recordsList中的对象不一致导致的界面显示发送成功缓慢
            NSUInteger index = [weakSelf.recordsList indexOfObject:sendRecord];
            if(index<weakSelf.recordsList.count)
                sendRecord = weakSelf.recordsList[index];

            SendDataModel *sendResult = [[SendDataModel alloc] initWithDictionary:result.data];
            if (sendRecord.msgType == MessageTypeSpeech) {
                NSString *filePath = nil;
                if (sendRecord.msgType == MessageTypeSpeech) {
                    filePath = [[ContactUtils recordFilePathWithGroupId:sendResult.groupId] stringByAppendingFormat:@"/%@%@",sendResult.msgId,XTFileExt];
                }
                
                //写入数据
                [message.sendData writeToFile:filePath atomically:YES];
                
                //如果存在临时数据，则删除之
                NSString *filePath2 = [sendRecord xtFilePath];
                if (filePath2 != nil) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath2 error:nil];
                }
            }
            else if(sendRecord.msgType == MessageTypePicture || sendRecord.msgType == MessageTypeLocation || sendRecord.msgType == MessageTypeShortVideo || sendRecord.msgType == MessageTypeNotrace)
            {
                
                //保存fileid
                if(result.data)
                {
                    if(sendRecord.msgType == MessageTypeLocation)
                    {
                        MessageParamDataModel *param = (MessageParamDataModel *)sendRecord.param;
                        MessageTypeLocationDataModel *paramObj =(MessageTypeLocationDataModel *)param.paramObject;
                        
                        MessageParamDataModel *tempParam = [[MessageParamDataModel alloc] initWithDictionary:result.data type:MessageTypeLocation];
                        MessageTypeLocationDataModel *tempParamObj = (MessageTypeLocationDataModel *)tempParam.paramObject;
                        tempParamObj.address = paramObj.address;
                        tempParamObj.longitude = paramObj.longitude;
                        tempParamObj.latitude = paramObj.latitude;
                        
                        //组装一下param数据
                        NSDictionary *dic = @{@"fileId":tempParamObj.file_id,@"addressName":tempParamObj.address,@"latitude":@(tempParamObj.latitude),@"longitude":@(tempParamObj.longitude)};
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                        tempParam.paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                        sendRecord.param = tempParam;
                    }else if(sendRecord.msgType == MessageTypeShortVideo)
                    {
                        MessageParamDataModel *param = (MessageParamDataModel *)sendRecord.param;
                        MessageTypeShortVideoDataModel *paramObj =(MessageTypeShortVideoDataModel *)param.paramObject;
                        
                        MessageParamDataModel *tempParam = [[MessageParamDataModel alloc] initWithDictionary:result.data type:MessageTypeShortVideo];
                        MessageTypeShortVideoDataModel *tempParamObj = (MessageTypeShortVideoDataModel *)tempParam.paramObject;
                        tempParamObj.file_id = paramObj.file_id;
                        tempParamObj.videoThumbnail = paramObj.videoThumbnail;
                        tempParamObj.size = paramObj.size;
                        tempParamObj.videoTimeLength = paramObj.videoTimeLength;
                        tempParamObj.videoUrl = paramObj.videoUrl;
                        tempParamObj.name = paramObj.name;
                        tempParamObj.ext = paramObj.ext;
                        
                        //组装一下param数据
                        NSDictionary *dic = @{@"fileId":tempParamObj.file_id,@"videoThumbnail":tempParamObj.videoThumbnail,@"size":tempParamObj.size,@"videoTimeLength":tempParamObj.videoTimeLength,@"name":tempParamObj.name,@"ext":tempParamObj.ext,@"videoUrl":tempParamObj.videoUrl};
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                        tempParam.paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        sendRecord.param = tempParam;

                    }
                    else if(sendRecord.msgType == MessageTypeNotrace)
                    {
                        MessageParamDataModel *param = (MessageParamDataModel *)sendRecord.param;
                        MessageNotraceDataModel *paramObj =(MessageNotraceDataModel *)param.paramObject;
                        
                        MessageParamDataModel *tempParam = [[MessageParamDataModel alloc] initWithDictionary:result.data type:MessageTypeNotrace];
                        MessageNotraceDataModel *tempParamObj = (MessageNotraceDataModel *)tempParam.paramObject;
                        tempParamObj.content = paramObj.content;
                        tempParamObj.msgType = paramObj.msgType;
                        tempParamObj.ext = paramObj.ext;
                        
                        //组装一下param数据
                        NSDictionary *dic = @{@"fileId":tempParamObj.file_id,@"msgType":@(tempParamObj.msgType),@"content":tempParamObj.content,@"ext":tempParamObj.ext};
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                        tempParam.paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        sendRecord.param = tempParam;
                    }
                    else
                    {
                        MessageParamDataModel *param = (MessageParamDataModel *)sendRecord.param;
                        MessageShareTextOrImageDataModel *paramObj =(MessageShareTextOrImageDataModel *)param.paramObject;
                        MessageParamDataModel *tempParam = [[MessageParamDataModel alloc] initWithDictionary:result.data type:MessageTypePicture];
                        MessageShareTextOrImageDataModel *tempParamObj = (MessageShareTextOrImageDataModel *)tempParam.paramObject;
                        tempParamObj.name = paramObj.name;
                        tempParamObj.ext = paramObj.ext;
                        
                        //组装一下param数据
                        NSDictionary *dic = @{@"fileId":tempParamObj.fileId,@"name":tempParamObj.name.length==0?@"":tempParamObj.name,@"ext":tempParamObj.ext.length==0?@"":tempParamObj.ext};
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                        tempParam.paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        sendRecord.param = tempParam;
                    }
                    
                }
            }
            else if(sendRecord.msgType == MessageTypeFile )
            {
                MessageParamDataModel *param = (MessageParamDataModel *)sendRecord.param;
                MessageFileDataModel *paramObj =(MessageFileDataModel *)param.paramObject;
                NSString *fileId = paramObj.file_id;
                
                XTWbClient *forwardFileClient = [[XTWbClient alloc] initWithTarget:weakSelf action:@selector(forwardFileDidReceive:result:)];
                if(!weakSelf.forwardFileClients)
                    weakSelf.forwardFileClients = [NSMutableArray array];
                [weakSelf.forwardFileClients addObject:forwardFileClient];
                NSString *threadId = sendRecord.fromUserId;
                if(!threadId)
                    threadId = weakSelf.group.groupId;
                [forwardFileClient makeDocWhenForwardDocWithFileId:fileId
                                                         networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId
                                                          threadId:weakSelf.group.groupId
                                                    targetThreadId:weakSelf.group.groupId
                                                         messageId:nil];
            }
            
            //入数据库
            if ([[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordWithMsgId:sendRecord.msgId]) {
                
                //解决sendRecord跟recordsList中的对象不一致导致的界面显示发送成功缓慢
                NSUInteger index = [weakSelf.recordsList indexOfObject:sendRecord];
                if(index<weakSelf.recordsList.count)
                    sendRecord = weakSelf.recordsList[index];
                
                [sendRecord setGroupId:sendResult.groupId];
                [sendRecord setSendTime:sendResult.sendTime];
                [sendRecord setMsgRequestState:MessageRequestStateSuccess];
                
                if (sendRecord.msgType == MessageTypePicture || sendRecord.msgType == MessageTypeLocation) {
                    NSString *thumbnailPictureUrl = [[sendRecord thumbnailPictureUrl] absoluteString];
                    NSString *bigPictureUrl = [[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord originalPictureUrl] imageScale:SDWebImageScalePreView];
                    
                    [sendRecord setMsgId:sendResult.msgId];
                    sendRecord.groupId = sendRecord.groupId;
                    
                    [[SDImageCache sharedImageCache] queryDiskCacheForKey:thumbnailPictureUrl done:^(UIImage *image, SDImageCacheType cacheType) {
                        [[SDImageCache sharedImageCache] storeImage:image forKey:[[sendRecord thumbnailPictureUrl] absoluteString] ];
                        [[SDImageCache sharedImageCache] removeImageForKey:thumbnailPictureUrl];
                    }];
                    [[SDImageCache sharedImageCache] queryDiskCacheForKey:bigPictureUrl done:^(UIImage *image, SDImageCacheType cacheType) {
                        [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord originalPictureUrl] imageScale:SDWebImageScalePreView]];
                        [[SDImageCache sharedImageCache] removeImageForKey:bigPictureUrl];
                    }];
                }
                else {
                    [sendRecord setMsgId:sendResult.msgId];
                    sendRecord.groupId = sendRecord.groupId;
                }
                
                
                [[XTDataBaseDao sharedDatabaseDaoInstance] insertRecord:sendRecord toUserId:@"" needUpdateGroup:YES publicId:weakSelf.chatMode == ChatPrivateMode ? nil : weakSelf.pubAccount.publicId];
                NSLog(@"###############after%@",[[NSDate date]dz_stringValue]);
                NSDictionary *dic = result.data;
                if (dic) {
                    NSNumber *unreadUserCount = [dic objectForKey:@"unreadUserCount"];
                    
                    if ([unreadUserCount intValue] > 0) {
                        sendRecord.msgUnreadCount = [unreadUserCount integerValue];
                        NSString *msgId = [dic objectForKey:@"msgId"];
                        sendRecord.msgUnreadCount = [unreadUserCount integerValue];
                         [[XTDataBaseDao sharedDatabaseDaoInstance] insertMessageUnreadStateWithGroupId:weakSelf.group.groupId MsgId:msgId UnreadCount:unreadUserCount];
                    }
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                AudioServicesPlaySystemSound(1004);
            });
        }else {
            
            if (sendRecord.msgType == MessageTypeSpeech) {
                NSString *filePath = [sendRecord xtFilePath];
                if (filePath == nil) {
                    filePath = [[ContactUtils recordTempFilePath] stringByAppendingFormat:@"/%@%@", sendRecord.msgId, XTFileExt];
                    //写入临时数据
                    [message.sendData writeToFile:filePath atomically:YES];
                }
            }
            
            sendRecord.msgRequestState = MessageRequestStateFailue;
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertRecord:sendRecord toUserId:toUserId needUpdateGroup:YES publicId:weakSelf.chatMode == ChatPrivateMode ? nil : weakSelf.pubAccount.publicId];
            
            if([result.error isEqualToString:ASLocalizedString(@"对方未激活！")])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"IssuleViewController_tips_3") message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil, nil];
                    [alert show];
                });
            } else {
                if (result.error != nil && ![result isKindOfClass:[NSNull class]] && result.error.length != 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (isAboveiOS8) {
                            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:result.error preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                            }];
                            [alertVC addAction:actionSure];
                            [self presentViewController:alertVC animated:YES completion:nil];
                        } else {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    });
                }
                
            }
        }
                

        dispatch_async(dispatch_get_main_queue(), ^{
        
            //解决sendRecord跟recordsList中的对象不一致导致的界面显示发送成功缓慢
            NSUInteger index = [weakSelf.recordsList indexOfObject:sendRecord];
            if(index < weakSelf.recordsList.count)
                sendRecord = weakSelf.recordsList[index];
            
            int row = (int)[weakSelf rowOfTableView:sendRecord.msgId];
            if (row >= 0 && row < weakSelf.bubbleArray.count) {
                BubbleTableViewCell *cell = (BubbleTableViewCell *)[weakSelf.bubbleTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
                [cell setDataInternal:weakSelf.bubbleArray[row]];
            }
          });   
        });
    }];
    
    [self reloadData];
    [self scrollToBottomAnimated:NO];
    [self changeTextViewFrame:self.contentView];
}

-(void)forwardFileDidReceive:(XTWbClient *)client result:(BOSResultDataModel *)result
{
    [self.forwardFileClients removeObject:client];
    client = nil;
}

//将URL后面的参数转换成字典
-(NSMutableDictionary *)translateURLParamToDictionary:(NSString *)urlStr
{
    NSRange range = [urlStr rangeOfString:@"?"];
    //获取参数列表
    NSString *propertys = [urlStr substringFromIndex:(int)(range.location+1)];
    NSArray *subArray = [propertys componentsSeparatedByString:@"&"];
    //把subArray转换为字典
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:4];
    for(int j = 0 ; j < subArray.count; j++)
    {
        //在通过=拆分键和值
        NSArray *dicArray = [subArray[j] componentsSeparatedByString:@"="];
        //给字典加入元素
        [tempDic setObject:dicArray[1] forKey:dicArray[0]];
    }
    
    return tempDic;
}


- (NSInteger)rowOfTableView:(NSString *)recordId
{
    NSInteger count = self.bubbleArray.count-1;
    for (NSInteger i = count;i>=0;i--) {
        BubbleDataInternal *model = self.bubbleArray[i];
        if ([model.record.msgId isEqual:recordId]) {
            return i;
        }
    }
    return -1;
}

- (void)sendBtnClick:(id)sender
{
    NSString *text = self.contentView.text;
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        return;
    }
    
    
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:_group.groupId];
    [sendRecord setMsgType:MessageTypeText];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setContent:self.contentView.text];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setNickname:ASLocalizedString(@"XTChatViewController_Tip_9")];
    [sendRecord setMsgLen:(int)self.contentView.text.length];
    [_recordsList addObject:sendRecord];
    [self sendWithRecord:sendRecord];
    
    self.contentView.text = nil;
    
    [self changeTextViewFrame:self.contentView];
}

- (void)detail:(id)sender
{
    //add
    [KDEventAnalysis event: event_dialog_group_detail];
    [KDEventAnalysis eventCountly: event_dialog_group_detail];
    PersonSimpleDataModel *person = [self.group.participant firstObject];
//    PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPersonWithPersonId:personId];
    if ([person isPublicAccount])
    {
        KDPubAccDetailViewController *pubAccDetail =[[KDPubAccDetailViewController alloc] initWithPubAcct:person andGroup:self.group];
        pubAccDetail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pubAccDetail animated:YES];
        //        XTPersonDetailViewController*personDetail=[[XTPersonDetailViewController alloc]initWithSimplePerson:person with:YES];
        //        personDetail.hidesBottomBarWhenPushed = YES;
        //        [self.navigationController pushViewController:personDetail animated:YES];
    }else
    {
        XTChatDetailViewController *chatDetail = [[XTChatDetailViewController alloc] initWithGroup:self.group];
        chatDetail.hidesBottomBarWhenPushed = YES;
        chatDetail.chatViewController = self;
        [self.navigationController pushViewController:chatDetail animated:YES];
        self.chatDetailVC = chatDetail;
    }
}

- (UITapGestureRecognizer *)noticeBoxTapGesture {
    if (!_noticeBoxTapGesture) {
        _noticeBoxTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noticeHandleTapGesture)];
    }
    return _noticeBoxTapGesture;
}

- (void)noticeHandleTapGesture {
    [self noticeHandleTap:self.noticeController];
}

- (void)onNoticeButtonPressed {
    //add
    [KDEventAnalysis event: event_dialog_group_announcement];
    [KDEventAnalysis eventCountly: event_dialog_group_announcement];
    [self noticeButtonPressed:self.noticeController];
}

#pragma mark - record button
-(void)AgoraCallViewAnswer:(NSNotification *)notification
{
    [self.recordingView setVolume:0];
    self.isRecordCancel = YES;
    _isCancelRecording = YES;
    [self endRecord];
    [self cancelRecord];
}


- (void)recordTouchDown:(id)sender
{
    //录音时停止播放
    [[BOSAudioPlayer sharedAudioPlayer] stopPlay];
    
    __block BOOL permitRecordFlag = YES;
    //    if(isAboveiOS7) {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        permitRecordFlag = granted;
    }];
    //    }
    if(!permitRecordFlag)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"XTChatViewController_Tip_10")message:[NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_11"),KD_APPNAME]delegate:nil cancelButtonTitle:ASLocalizedString(@"XTChatViewController_Tip_12")otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //将按钮设为不可点
    self.toolbarImageView.userInteractionEnabled = NO;
    //显示等待框
    if (self.recordingHud == nil) {
        self.recordingHud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.mainView addSubview:self.recordingHud];
    }
    if (self.recordingView == nil) {
        self.recordingView = [[XTRecorderView alloc] initWithFrame:CGRectMake(0.0, 0.0, 330/2, 282/2)];
    }
    self.recordingHud.customView = self.recordingView;
    self.recordingHud.margin = 0.0f;
    self.recordingHud.mode = MBProgressHUDModeCustomView;
    self.recordingHud.color = [UIColor clearColor];
    [self.recordingHud show:YES];
    
    [self.recordingView setState:RecorderStateRecording];
    [self startRecord];//开始录音
}

- (void)showRecordingView
{
    [self.recordingView setState:RecorderStateRecording];
}

- (void)showDelSendView
{
    [self.recordingView setState:RecorderStateRecordCancel];
}

- (void)recordTouchUpInside:(id)sender
{
    //add
    [KDEventAnalysis event:event_dialog_hold_speak];
    [KDEventAnalysis eventCountly:event_dialog_hold_speak];
    UIButton *btn = (UIButton *) sender;
    if (btn.isHighlighted)
    {
        [btn setHighlighted:NO];
    }
    
    [self.recordingView setVolume:0];
    if ([NSDate timeIntervalSinceReferenceDate] - _recordStartTime < RECORD_START_DELAY) {
        //取消录音
        _isCancelRecording = YES;
    }
    else
    {
        //延迟停止录音
        [NSTimer scheduledTimerWithTimeInterval:RECORD_STOP_DELAY target:self selector:@selector(endRecord) userInfo:nil repeats:NO];
    }
    self.isRecordCancel = NO;
    
}

- (void)recordTouchUpOutside:(id)sender
{
    [self changeMessageModeTo:KDChatMessageModeNone];
    [self.recordingView setVolume:0];
    self.isRecordCancel = YES;
    if ([NSDate timeIntervalSinceReferenceDate] - _recordStartTime < RECORD_START_DELAY)
    {
        //取消录音
        _isCancelRecording = YES;
    }
    else
    {
        //延迟停止录音
        [NSTimer scheduledTimerWithTimeInterval:RECORD_STOP_DELAY target:self selector:@selector(endRecord) userInfo:nil repeats:NO];
    }
    
}

- (void)recordTouchDragEnger:(id)sender
{
    [self showRecordingView];
}

- (void)recordTouchDragExit:(id)sender
{
    [self showDelSendView];
}

- (ContactClient *)sendMessageClient
{
    if (!_sendMessageClient) {
        _sendMessageClient = [[ContactClient alloc] initWithTarget:self action:nil];
    }
    return _sendMessageClient;
}

#pragma mark - BOSAudioRecorderDelegate

-(void)bosAudioRecorderDidFinishRecording:(BOSAudioRecorder *)recorder successfully:(BOOL)success
{
    BOSINFO(@"bosAudioRecorderDidFinishRecording");
    [self cancelRecord];
    
    if(!success) return ;
    
    if (_realRecordSeconds < 0.5) {
        _realRecordSeconds = 0;
        [[NSFileManager defaultManager] removeItemAtPath:[ContactUtils recordFilePath] error:nil];
        return;
    }
    
    if(self.isRecordCancel == NO){
        
        RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
        [sendRecord setGroupId:_group.groupId];
        [sendRecord setMsgType:MessageTypeSpeech];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
        [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
        [sendRecord setStatus:MessageStatusRead];
        [sendRecord setMsgLen:_recordSeconds];
        [sendRecord setMsgRequestState:MessageRequestStateRequesting];
        [sendRecord setMsgId:[ContactUtils uuid]];
        [sendRecord setMsgDirection:MessageDirectionRight];
        [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
        [sendRecord setContent:ASLocalizedString(@"KDPublicTopCell_Voice")];
        [_recordsList addObject:sendRecord];
        
        
        [self sendWithRecord:sendRecord];
    }
}

-(void)bosAudioRecorderEncodeErrorDidOccur:(BOSAudioRecorder *)recorder error:(NSError *)error
{
    BOSERROR(@"Record Error:%@",[error localizedDescription]);
    _realRecordSeconds = 0;
}

-(void)bosAudioRecorderReceivedRecording:(BOSAudioRecorder *)recorder peakPower:(float)peakPower averagePower:(float)averagePower currentTime:(float)currentTime
{
    _realRecordSeconds = currentTime;
    if (currentTime > _recordSeconds) {
        _recordSeconds = ceilf(currentTime);
    }
    [self.recordingView setVolume:peakPower];
}

#pragma mark - Net Methods


- (void)reloadTable:(int)recordCount
{
    __weak XTChatViewController *selfInBlock = self;
    [self getRecordsFromDataBaseAlreadyLoaded:^(int count) {
        if(selfInBlock.navigationController == nil)
            return ;
        CGPoint lastContentOffset = selfInBlock.bubbleTable.contentOffset;
        BOOL scrollToLast = (lastContentOffset.y > selfInBlock.bubbleTable.contentSize.height - selfInBlock.bubbleTable.bounds.size.height - 300);
        [selfInBlock reloadData];
        if (scrollToLast) {
            [selfInBlock scrollRow:[selfInBlock.bubbleArray count] - 1 animated:NO];
        } else {
            [selfInBlock.bubbleTable setContentOffset:lastContentOffset animated:NO];
        }
        if (!selfInBlock.hasLastPage && ![_group isNewGroup]) {
            selfInBlock.bubbleTable.tableHeaderView = nil;
        }
        [selfInBlock goUpdateBannerView];
        
    }];
    [self sending];
}

- (void)getRecordsFromDataBaseOnePage:(QueryMessageCompletionBlock)completionBlock
{
    __weak XTChatViewController *selfInBlock = self;
    dispatch_async(_dbReadQueue, ^{
        
        NSString *personId = nil;
        if ([selfInBlock.group.participant count] > 0) {
            PersonSimpleDataModel *participant = [selfInBlock.group.participant objectAtIndex:0];
            personId = participant.personId;
        }
        
        NSArray *records = nil;
        if (selfInBlock.chatMode == ChatPrivateMode) {
            records = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecordWithGroupId:selfInBlock.group.groupId toUserId:personId publicId:nil page:selfInBlock.limitSatrt count:RECORDS_PAGE];
        }else{
            records = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecordWithGroupId:selfInBlock.group.groupId toUserId:@"" publicId:selfInBlock.pubAccount.publicId page:selfInBlock.limitSatrt count:RECORDS_PAGE];
        }
        if ([records count] == RECORDS_PAGE) {
            selfInBlock.hasLastPage = YES;
        } else {
            selfInBlock.hasLastPage = NO;
        }
        for (int i = 0; i < [records count]; i++) {
            [selfInBlock.recordsList insertObject:[records objectAtIndex:i] atIndex:0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock((int)[records count]);
        });
    });
    
}

- (void)getRecordsFromDataBaseAlreadyLoaded:(QueryMessageCompletionBlock)completionBlock
{
    __weak XTChatViewController *selfInBlock = self;
    dispatch_async(_dbReadQueue, ^{
        
        NSString *personId = nil;
        if ([selfInBlock.group.participant count] > 0) {
            PersonSimpleDataModel *participant = [selfInBlock.group.participant objectAtIndex:0];
            personId = participant.personId;
        }
        NSArray *records = nil;
        if (selfInBlock.chatMode == ChatPrivateMode) {
            records = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecordWithGroupId:selfInBlock.group.groupId toUserId:personId publicId:nil page:0 count:selfInBlock.limitSatrt + RECORDS_PAGE];
        }else{
            records = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecordWithGroupId:selfInBlock.group.groupId toUserId:@"" publicId:selfInBlock.pubAccount.publicId page:0 count:selfInBlock.limitSatrt + RECORDS_PAGE];
        }
        if ([records count] == selfInBlock.limitSatrt + RECORDS_PAGE) {
            selfInBlock.hasLastPage = YES;
        } else {
            selfInBlock.hasLastPage = NO;
        }
        [selfInBlock.recordsList removeAllObjects];
        for (int i = 0; i < [records count]; i++) {
            [selfInBlock.recordsList insertObject:[records objectAtIndex:i] atIndex:0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock((int)[records count]);
        });
    });
}

#pragma mark - record

-(void)prepareToRecord
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        //        BOSERROR(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        //        BOSERROR(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof(audioRouteOverride),&audioRouteOverride);
    
    if (_audioRecoder == nil) {
        _audioRecoder = [[BOSAudioRecorder alloc] init];
        _audioRecoder.delegate = self;
    }
}

-(void)startRecord
{
    
    _recordStartTime = [NSDate timeIntervalSinceReferenceDate];
    _isCancelRecording = NO;
    _recordSeconds = 0;
    [NSTimer scheduledTimerWithTimeInterval:RECORD_START_DELAY target:self selector:@selector(realStartRecord) userInfo:nil repeats:NO];
}

- (void)realStartRecord
{
    if (_isCancelRecording)
    {
        [KDPopup showHUDToast:ASLocalizedString(@"XTChatViewController_Tip_13") ];
//        self.recordingHud.margin = 20.0;
//        self.recordingHud.mode = MBProgressHUDModeText;
//        self.recordingHud.detailsLabelText = ASLocalizedString(@"XTChatViewController_Tip_13");
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(cancelRecord) userInfo:nil repeats:NO];
        return;
    }
    
    if (_isRecording == NO)
    {
        [self prepareToRecord];
        
        //最多录音180秒
        _isRecording = [_audioRecoder startRecordForDuration:179.5];
        self.totalTime = 179;
        self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
        if (_isRecording == NO)
        {
            [self cancelRecord];
        }
    }
}

- (void)countdown {
    if (!_isCancelRecording) {
        if (self.totalTime < 11 && self.totalTime > 0 ) {
            self.recordingView.counting = YES;
            self.recordingView.countdownLabel.text = [NSString stringWithFormat:@"%zi", (long)self.totalTime];
        } else if (self.totalTime < 1){
            self.recordingView.counting = NO;
            [self.countdownTimer invalidate];
            self.totalTime = 179;
            self.recordingView.countdownLabel.text = @"";
        }
    } else {
        self.recordingView.counting = NO;
        [self.countdownTimer invalidate];
        self.totalTime = 179;
        self.recordingView.countdownLabel.text = @"";
    }
    
    self.totalTime --;
}

-(void)cancelRecord
{
    self.toolbarImageView.userInteractionEnabled = YES;
    
    if (self.recordingHud) {
        [self.recordingHud removeFromSuperview];
        self.recordingHud = nil;
    }
    _isCancelRecording = YES;
}

- (void)endRecord
{
    if (_isRecording) {
        _isRecording = NO;
        [_audioRecoder stopRecord];
    }
    _isCancelRecording = YES;
}

#pragma mark - Search
-(void)scrollRowByRecord:(RecordDataModel *)recordData
{
    int index = (int)[self indexOfRecordList:recordData];
    if (index <= 0){
        index = 1;
        self.progressHud.labelText = ASLocalizedString(@"RefreshTableFootView_Loading");
        self.progressHud.mode = MBProgressHUDModeIndeterminate;
        self.progressHud.margin = 30;
        self.progressHud.dimBackground = NO;
        [self.progressHud show:YES];
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *array = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecordWithGroupId:recordData.groupId toUserId:nil sendTime:recordData.sendTime count:0];
            if(weakSelf.recordsList){
                [weakSelf.recordsList removeAllObjects];
            }
            [weakSelf.recordsList addObjectsFromArray:array];
            weakSelf.limitSatrt = (int)[array count] - 10;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadData];
                [weakSelf.progressHud hide:YES];
            });
        });
        
    }
    [self scrollRow:index animated:NO];
}

-(NSInteger)indexOfRecordList:(RecordDataModel *)record
{
    int index = 0;
    for(int i = 0; i < [self.recordsList count]; i++){
        RecordDataModel *model = [self.recordsList objectAtIndex:i];
        if ([record.msgId isEqual:model.msgId]) {
            index = i+1;
            break;
        }
    }
    return index;
}

#pragma mark - TableView

- (void)updateData
{
    NSMutableArray *tempBubbleArray = [self getMultiselectArray];
    
    // Cleaning up old data
    self.bubbleArray = nil;
    
    //临时生成一个数组，避免占用_recordsList
    NSMutableArray *tempRecordList = [NSMutableArray arrayWithArray:_recordsList];

    // Loading new data
    NSUInteger count = [tempRecordList count];
    if (count > 0)
    {
        self.bubbleArray = [[NSMutableArray alloc] init];
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSDateFormatter *dateFormatter2Date = [[NSDateFormatter alloc]init];
        [dateFormatter2Date setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        for (int i = 0; i < count; i++)
        {
            RecordDataModel *record = [tempRecordList objectAtIndex:i];
            BubbleDataInternal *dataInternal = [[BubbleDataInternal alloc] initWithRecord:record andGroup:self.group andChatMode:self.chatMode];
            if(dataInternal == nil)
                continue;
            
            //消息时间显示逻辑
            {
                dataInternal.header = nil;
                NSDate *time = [dateFormatter2Date dateFromString:dataInternal.record.sendTime];
                if(dataInternal.record.msgType == MessageTypeCancel && dataInternal.record.content.length == 0)
                {
                    //无痕消息销毁不显示时间
                }
                else
                {
                    // 原逻辑
                    if ([time timeIntervalSinceDate:last] > 300)
                    {
                        dataInternal.header = self.group.groupType == GroupTypeTodo ? [ContactUtils formatDateString:dataInternal.record.sendTime] : [ContactUtils xtDateFormatter:dataInternal.record.sendTime];
                        dataInternal.cellHeight += 35;
                        last = time;
                    }
                }
            }
            
            
            //更新一下新数据的多选字段
            {
                dataInternal.checkMode = -1;
                if(self.multiselecting)
                {
                    BOOL isExist = NO;
                    for(NSInteger i =0;i<tempBubbleArray.count;i++)
                    {
                        BubbleDataInternal *oldData = tempBubbleArray[i];
                        if([oldData.record.msgId isEqualToString:dataInternal.record.msgId])
                        {
                            dataInternal.checkMode = oldData.checkMode;
                            dataInternal.muliteSelectMode = oldData.muliteSelectMode;
                            isExist = YES;
                            break;
                        }
                    }
                    
                    //新加载的数据初始化一下数据
                    if(!isExist)
                    {
                        if(self.multiselecting)
                            dataInternal.checkMode = 0;
                        else
                            dataInternal.checkMode = -1;
                        
                        dataInternal.muliteSelectMode = self.multiseSelctMode;
                    }
                }
            }
            
            [self.bubbleArray addObject:dataInternal];
            
            
            //跳转气泡
            if (self.strScrollToMsgId && dataInternal.record.msgId)
            {
                if ([self.strScrollToMsgId isEqualToString:dataInternal.record.msgId])
                {
                    _scrollBubbleDataInternal = dataInternal;
                    
                    _scrollBubbleDataInternal.scrollToIndexRow = self.bubbleArray.count - 1;
                    
                    _scrollBubbleDataInternalExistInDB = YES;
                }
            }
            
        }
        
    }
    
    tempBubbleArray = nil;
}



#pragma mark - 数据刷新 -

- (void)reloadData
{
    [self updateData];
    [self.bubbleTable reloadData];
//    if (!_scrollToDBdata && _scrollBubbleDataInternalExistInDB)
//    {
//        [self scrollToMsgId:self.strScrollToMsgId ScrollType:BubbleTableScrollNotifyType];
//    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bubbleArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BubbleDataInternal *dataInternal = [self.bubbleArray objectAtIndex:indexPath.row];
    return dataInternal.cellHeight;
}

- (NSMutableArray *)mArrayNotifyRecords
{
    if (!_mArrayNotifyRecords) {
        _mArrayNotifyRecords = [NSMutableArray new];
    }
    return _mArrayNotifyRecords;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BubbleDataInternal *dataInternal = [self.bubbleArray objectAtIndex:indexPath.row];
    
    //    NSLog(@"!!!%@",[tableView indexPathsForVisibleRows]);
    // 如果cell是可见的 并且 没有显示_过_ 并且 是一个通知类型（例如@提及）的话，则设置其为已读，并更改数据库。
    if([[tableView indexPathsForVisibleRows] containsObject:indexPath] && !dataInternal.bDisplayed && dataInternal.record.iNotifyType != 0 && dataInternal.record.status == 0)// &&  !self.bFirstEnter)
    {
        dataInternal.bDisplayed = YES;
        [[XTDataBaseDao sharedDatabaseDaoInstance] updateNotifyRecordStatusWithMsgId:dataInternal.record.msgId groupId:dataInternal.group.groupId];
        
        [self updateBannerView];
        
    }
    
    if ([[tableView indexPathsForVisibleRows] containsObject:indexPath] && !dataInternal.bDisplayed && [dataInternal.record.msgId isEqualToString:self.strFirstUnreadMessageMsgId])
    {
        [self hideUnreadMessageButton];
    }
    dataInternal.bDisplayed = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"tblBubbleCell";
    
    NSLog(@"%@",self.bubbleArray);
    
    BubbleDataInternal *dataInternal = [self.bubbleArray objectAtIndex:indexPath.row];
    
    BubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_%@_%d", cellId, dataInternal.record.msgId,dataInternal.record.msgDirection]];
    if (cell == nil)
    {
        cell = [[BubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@_%@_%d", cellId, dataInternal.record.msgId,dataInternal.record.msgDirection]];
    }
    if(!self.multiselecting)
        dataInternal.checkMode = -1;
    
    //706新增 里面只有发送者的头像，名字信息，为了调人员失败的时候不影响人员展示 706
    if (dataInternal.record.fromUserName.length > 0 && dataInternal.record.fromUserPhoto.length > 0) {
        PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc]init];
        person.personName = dataInternal.record.fromUserName;
        person.photoUrl = dataInternal.record.fromUserPhoto;
        cell.tempPerson = person;
    }
    cell.msgDeleteDelegate = self;
    cell.chatViewController = self;
    cell.dataInternal = dataInternal;
    cell.row_index = indexPath.row;
    //    cell.backgroundColor = BOSCOLORWITHRGBA(0xf2f4f8, 1.0);
    cell.backgroundColor = [UIColor clearColor];
    
   
    
    if ([self getMutiChatGroupParticipantCount] >= 3 && ![cell.headerView.person.orgId isEqualToString:[BOSConfig sharedConfig].user.orgId]) {
        cell.departmentLabel.hidden = NO;
    } else {
        cell.departmentLabel.hidden = YES;
    }
    
    return cell;
}

- (void)speechAudioPlayOver:(NSNotification *)note
{
    BubbleTableViewCell * curSpeechCell = [note.userInfo objectForKey:kKeyCurSpeechCell];
    BOOL lastUnReadSpeechCell = YES;
    if(curSpeechCell && curSpeechCell.isSpeechFirstRead)
    {
        BubbleTableViewCell *nextSpeechCell = [self findNextUnReadSpeechCell:curSpeechCell];
        if(nextSpeechCell)
        {
            lastUnReadSpeechCell = NO;
            [nextSpeechCell manuStartPlayAudio];
        }
    }
    if(lastUnReadSpeechCell)
        [[BOSAudioPlayer sharedAudioPlayer] disableAudioSession];
}

-(void)chatSearchFileClick:(NSNotification *)note
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self.searchViewController dismissChatSearchView];
    
    RecordDataModel *model = [note object];
    if(model != nil && [model isKindOfClass:[RecordDataModel class]]){
//        [self scrollRowByRecord: model];
//        __weak UINavigationController *nav = self.navigationController;
//        [nav popToRootViewControllerAnimated:YES completion:^(BOOL finished) {
//            NSString *uri = [NSString stringWithFormat:@"cloudhub://chat?groupId=%@&msgId=%@",model.groupId,model.msgId];
//            [KDSchema openWithUrl:uri controller:nav.topViewController];
//        }];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        NSString *uri = [NSString stringWithFormat:@"cloudhub://chat?groupId=%@&msgId=%@",model.groupId,model.msgId];
        [KDSchema openWithUrl:uri controller:self.navigationController.topViewController];
    }
    
}

- (BubbleTableViewCell *)findNextUnReadSpeechCell:(BubbleTableViewCell*)cell
{
    int row = (int)[self.bubbleTable indexPathForCell:cell].row;
    for(int i = row + 1; i < [self.bubbleArray count]; i++)
    {
        BubbleDataInternal *dataInternal = [self.bubbleArray objectAtIndex:i];
        if(dataInternal.record.msgType == MessageTypeSpeech && dataInternal.record.status == MessageStatusUnread)
        {
            return (BubbleTableViewCell *)[self.bubbleTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    return nil;
}

- (void)scrollRow:(NSInteger)row animated:(BOOL)animated
{
    if ([self.bubbleArray count] == 0 || row < 0 || row > [self.bubbleArray count] - 1) {
        return;
    }
    [self.bubbleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.contentView) {
        return;
    }
    
    if (self.contentView.hidden == NO && [self.contentView isFirstResponder]) {
        [self.contentView resignFirstResponder];
        self.keyboardShow = NO;
    }
    if (self.ismenushow) {
        //        self.otherimage.frame=CGRectMake(204, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
        //        self.itimage.frame=CGRectMake(130, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
        //        self.personimage.frame=CGRectMake(40, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
        //取消所有底部menu 的选择
        [self cancelAllToolbarMenuSelection];
    }
    if(!self.multiselecting)
        [self hideInputBoard];
    self.emojiBoardShow = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.contentView) {
        return;
    }
    
    //滑动到顶部
    BOOL load = NO;//scrollView.contentOffset.y == -_bubbleTable.contentInset.top;
    if (@available(iOS 11.0, *)) {
        load = scrollView.contentOffset.y == -_bubbleTable.adjustedContentInset.top;
    } else {
        load = scrollView.contentOffset.y == -_bubbleTable.contentInset.top;
    }
    
    if (load) {
        [self startLoading];
        return ;
    }
    
    //滑动到底部,以后再优化这个
    //    if(_bubbleTable.contentOffset.y == _bubbleTable.contentSize.height - _bubbleTable.frame.size.height || _bubbleTable.contentSize.height<_bubbleTable.frame.size.height){
    //        NSLog(@"scroll to the end");
    //    }
}


#pragma mark - KDExpressionInputViewDelegate Methods
- (void)expressionInputView:(KDExpressionInputView *)inputView didTapExpression:(NSString *)expressionCode {
    /**
     *  MARK: 新表情更改
     */
    if (inputView.iSelectedEmojiIndex == 0) // 小黄脸表情 默认的, 转换成文本
    {
        UITextRange *caret = _contentView.selectedTextRange;
        NSString *strFull = [_contentView.text stringByAppendingString:expressionCode];
        if (self.messageMode != KDChatMessageModeNotrace) {
            [_contentView replaceRange:caret withText:expressionCode];
        } else {
            if (strFull.length <= [[KDChatNotraceManager sharedInstance] maxWordsLength]) {
                [_contentView replaceRange:caret withText:expressionCode];
            }
        }
    }
    else  if (inputView.iSelectedEmojiIndex == 1)// 大表情
    {
        
        // TODO: 改成走附件接口
        if (inputView.iSelectedEmojiIndex == 1) //小裸
            [self sendEmojiFileWithExpressionCode:expressionCode expresstionType:KDExpresstionTypeXiaoluo];
        
        // TODO: 扩展
    }
    else // 大表情
    {
        
        // TODO: 改成走附件接口
        if (inputView.iSelectedEmojiIndex == 2) //Yuki
            [self sendEmojiFileWithExpressionCode:expressionCode expresstionType:KDExpresstionTypeYuki];
        
        // TODO: 扩展
    }
    
}


- (void)didTapKeyBoardInExpressionInputView:(KDExpressionInputView *)inputView {
    //    [self switchExpressionView];
}

- (void)didTapDeleteInExpressionInputView:(KDExpressionInputView *)inputView {
    UITextRange *caret = _contentView.selectedTextRange;
    NSRange selectRange = _contentView.selectedRange;
    if(!_contentView.text || _contentView.text.length == 0 || selectRange.location == 0 || selectRange.location == NSNotFound) return;
    
    NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    NSArray *matches = [topicExpression matchesInString:_contentView.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, selectRange.location + selectRange.length)];
    
    if(caret) {
        for(NSTextCheckingResult *result in matches) {
            NSRange range = result.range;
            if(range.location + range.length == _contentView.selectedRange.location) {
                UITextPosition *end = [_contentView positionFromPosition:caret.start offset:-(range.length)];
                UITextRange *replaceRange = [_contentView textRangeFromPosition:caret.start toPosition:end];
                [_contentView replaceRange:replaceRange withText:@""];
                return;
            }
        }
    }
    
    //delete character
    UITextPosition *end = [_contentView positionFromPosition:caret.start offset:-1];
    UITextRange *delRange = [_contentView textRangeFromPosition:caret.start toPosition:end];
    [_contentView replaceRange:delRange withText:@""];
}

- (void)didTapSendInExpressionInputView:(KDExpressionInputView *)inputView
{
    [self sendMessageWithTextView:self.contentView replacementText:@"\n"];
}

#pragma mark - invite


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == KDstartGroupTalkAlertTag)
    {
        if(buttonIndex == 1)
        {
            //关闭
            
            NSDictionary *dataDict = objc_getAssociatedObject(alertView, &startOrStopGroupResultKey);
            if(dataDict)
            {
                [self hideMultiBannerView];
                NSString *groupId = dataDict[@"groupId"];
                NSString *channlId = dataDict[@"channelId"];
                NSString *mcallCreator = dataDict[@"mcallCreator"];
                id mCallStartTime = dataDict[@"mcallStartTime"];
                long long startTime = 0;
                if(mCallStartTime && ![mCallStartTime isKindOfClass:[NSNull class]])
                {
                    startTime = [mCallStartTime longLongValue];
                }
                [[KDAgoraSDKManager sharedAgoraSDKManager] stopExitedGroupTalkWithGroupId:groupId mstatus:0 channelId:channlId mcallCreator:mcallCreator callStartTime:startTime newGroupId:self.group.groupId] ;
                
            }
        }else{
            KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
            if(agoraSDKManager.agoraPersonsChangeBlock)
            {
                agoraSDKManager.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_needExitChannel,nil,nil,nil);
            }
        }
        return;
    }
}






#pragma mark - UIActionSheetDelegete

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1)
    {
        NSLog(@"%ld",(long)buttonIndex);
        switch (buttonIndex)
        {
            case 0:
            {
                // 直接发起
                [KDEventAnalysis event:event_Voicon_first];
                [self goToMultiVoice];
            }
                break;
                
            case 1:
            {
                // 预约会议
                
                [KDEventAnalysis event:event_Voicon_book];
                KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:@"" appId:LightAppId_Appointment];
                webVC.title = ASLocalizedString(@"XTChatViewController_Tip_3");
                __weak __typeof(self) weakSelf = self;
                
                webVC.blockEditURL = ^(NSString *strURL)
                {
                    return [strURL stringByAppendingFormat:@"&groupId=%@&type=1",weakSelf.group.groupId];
                };
                webVC.hidesBottomBarWhenPushed = YES;
                //                self.webViewController = webVC;
                //                __weak __typeof(webVC) weakWebVC = webVC;
                //                webVC.getLightAppBlock = ^() {
                //                    [weakSelf.navigationController pushViewController:weakWebVC animated:YES];
                //                };
            }
                break;
                
            default:
                break;
        }
        return;
    }
    
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        [self toImagePicker:buttonIndex];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
-(void)toImagePicker:(NSInteger)buttonIndex
{
    //按钮不右移
    //    if (isAboveiOS7) {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NoChangeNavigationItemPosition"];
    //    }
    
    if (buttonIndex == 0) {
        
        AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied)
        {
            UIAlertController * alertC = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:ASLocalizedString(@"JSBridge_Tip_14"),KD_APPNAME] preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertC animated:YES completion:nil];
            UIAlertAction * action = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertC addAction:action];
            return;
        }
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }else{
        KDImagePickerController *picker = [[KDImagePickerController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
        picker.allowsMultipleSelection = YES;
        picker.maximumNumberOfSelection = 9;
        picker.minimumNumberOfSelection = 1;
        picker.limitsMaximumNumberOfSelection = YES;
        picker.limitsMinimumNumberOfSelection = YES;
        picker.isFromXTChat = YES;
        picker.delegate = self;
        picker.filterType = KDImagePickerFilterTypeAllAssets;
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}

#pragma mark - UIImagePickerControllerDelegate

//返回一個等比縮放的image
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height*scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

-(void)imagePickerController:(KDImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.isSendingImage) {
        return;
    }
    if ([picker isKindOfClass:[KDImagePickerController class]]) {
        self.bSendOriginal = picker.bSendOriginal;
    }
    self.isSendingImage = YES;
    
    __weak XTChatViewController *selfInBlock = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [selfInBlock handlePicker:picker withInfo:info];
        
        selfInBlock.isSendingImage = NO;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)handlePicker:(KDImagePickerController *)picker withInfo:(NSDictionary *)info {
    
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
        if(UTTypeConformsTo(mediaType, kUTTypeImage)){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSURL *libUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
            if(libUrl)
                [self handleImage:image savedPhotosAlbum:YES withLibUrl:libUrl.absoluteString];
            else
            {
                [picker dismissViewControllerAnimated:YES completion:^{
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                }];
                [self goToImageEditorWithImage:image];
                
                //                NSString *name = [NSString stringWithFormat:@"%@%ld",[UIDevice currentDevice].name,(long)[[NSDate date] timeIntervalSince1970]];
                //                NSString *libUrlStr = [NSString stringWithFormat:@"?id=%@&ext=PNG",[name MD5DigestKey]];
                //                [self handleImage:image savedPhotosAlbum:YES withLibUrl:libUrlStr];
            }
        }
    } else {
        NSArray *infoArr = (NSArray *)info;
        if (picker.bCameraSource && [infoArr isKindOfClass:[NSArray class]] && infoArr.count == 1) {
            [picker dismissViewControllerAnimated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }];
            NSDictionary *dic = [infoArr firstObject];
            UIImage *image = [dic objectForKey:@"UIImagePickerControllerOriginalImage"];
            [self goToImageEditorWithImage:image];
        } else {
            if(picker.allowsMultipleSelection) {
                [self handleImages:infoArr];
            }
        }
    }
    
}

- (void)imagePickerController:(KDImagePickerController *)imagePickerController didSeletedEditImage:(UIImage *)image {
    if (!image) {
        return;
    }
    
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
    
    [self goToImageEditorWithImage:image];
}

- (void)handleImage:(UIImage *)image savedPhotosAlbum:(BOOL)savedPhotosAlbum withLibUrl:(NSString *)libUrl
{
    if (!image) {
        return;
    }
    
    //image 原图
    //largeImage 大图（发送至服务端的）
    //thumbnailImage 缩略图（缓存至本地的）
    
    //大图处理
    UIImage *largeImage = image;
    NSData *data = nil;
    float width = 640.0;
    float height = 1096.0;
    if (self.bSendOriginal) {
        data = UIImageJPEGRepresentation(largeImage,1.f);
        //        data = UIImagePNGRepresentation(image);
        largeImage = [UIImage imageWithData:data];
        largeImage = [largeImage fixOrientation];
    }
    else {
        if (largeImage.size.width > width || largeImage.size.height > height) {
            float scaleSize = width / largeImage.size.width > height / largeImage.size.height ? height / largeImage.size.height : width / largeImage.size.width;
            largeImage = [self scaleImage:largeImage toScale:scaleSize];
        }
        data = UIImageJPEGRepresentation(largeImage, 0.5);
        largeImage = [UIImage imageWithData:data];
    }
    if (savedPhotosAlbum) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImageWriteToSavedPhotosAlbum(largeImage, nil, nil, NULL);
        });
    }
    
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:_group.groupId];
    [sendRecord setMsgType:MessageTypePicture];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setMsgLen:(int)[data length]];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setMsgDirection:MessageDirectionRight];
    [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
    [sendRecord setContent:ASLocalizedString(@"KDPublicTopCell_Pic")];
    
    //add by fang
    if (!libUrl) {
        NSString *name = [NSString stringWithFormat:@"%@%ld",[UIDevice currentDevice].name,(long)[[NSDate date] timeIntervalSince1970]];
        libUrl = [NSString stringWithFormat:@"?id=%@&ext=PNG",[name MD5DigestKey]];
    }
    NSMutableDictionary *paramDic = [self translateURLParamToDictionary:libUrl];
    NSString *name = [paramDic objectForKey:@"id"];
    NSString *ext = [paramDic objectForKey:@"ext"];
    if(name && ext)
    {
        MessageShareTextOrImageDataModel *paramObj = [[MessageShareTextOrImageDataModel alloc] init];
        paramObj.name = name;
        paramObj.ext = ext;
        
        MessageParamDataModel *messageParam = [[MessageParamDataModel alloc] init];
        messageParam.type = MessageTypePicture;
        messageParam.paramObject = paramObj;
        
        [sendRecord setParam:messageParam];
    }
    
    // 注入无痕消息
    if (self.messageMode == KDChatMessageModeNotrace) {
        MessageParamDataModel *modal = [MessageParamDataModel new];
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:safeString(sendRecord.content) forKey:@"content"];
        [dict setObject:@(sendRecord.msgType) forKey:@"msgType"];
        [dict setObject:(name.length==0?[ContactUtils uuid]:name) forKey:@"name"];
        [dict setObject:(ext.length==0?@"jpg":ext) forKey:@"ext"];
        sendRecord.msgType = MessageTypeNotrace;
        sendRecord.content = [NSString stringWithFormat:@"[%@]",ASLocalizedString(@"XTChatViewController_Notrace_Msg")];
        MessageNotraceDataModel *model = [[MessageNotraceDataModel alloc] initWithDictionary:dict];
        modal.paramObject = model;
        NSString *strParam = [NSJSONSerialization stringWithJSONObject:dict];
        modal.type = MessageTypePicture;
        modal.paramString = strParam;
        sendRecord.param = modal;
    }
    
    
    [_recordsList addObject:sendRecord];
    
    //缩略图处理
    UIImage *thumbnailImage = largeImage;
    width = 240;
    height = 240;
    if (thumbnailImage.size.width > width || thumbnailImage.size.height > height) {
        float scaleSize = width/thumbnailImage.size.width > height/thumbnailImage.size.height ? height/thumbnailImage.size.height : width/thumbnailImage.size.width;
        thumbnailImage = [self scaleImage:thumbnailImage toScale:scaleSize];
    }
    
    [[SDImageCache sharedImageCache] storeImage:thumbnailImage forKey:[[sendRecord thumbnailPictureUrl] absoluteString]];
    [[SDImageCache sharedImageCache] storeImage:largeImage forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord originalPictureUrl] imageScale:SDWebImageScalePreView]];
    
    [self sendWithRecord:sendRecord image:largeImage];
}

- (void)handleImages:(NSArray *)info
{
    for (NSDictionary *dict in info) {
        UIImage *image = [dict objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSURL *libUrl = [dict objectForKey:@"UIImagePickerControllerReferenceURL"];
        [self handleImage:image savedPhotosAlbum:NO withLibUrl:libUrl.absoluteString];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

#pragma mark - UITextView Delegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    textView.inputView = nil;
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.messageMode == KDChatMessageModeNotrace) {
        NSString *text = textView.text;
        // 拼音输入时，拼音字母处于选中状态，此时不判断是否超长
        UITextRange *selectedRange = [textView markedTextRange];
        if (!selectedRange || !selectedRange.start) {
            if (text.length > [[KDChatNotraceManager sharedInstance] maxWordsLength]) {
                textView.text = [text substringToIndex:[[KDChatNotraceManager sharedInstance] maxWordsLength]];
            }
        }
    }
    
    
    //    BOSDEBUG(@"%@", self.contentView.text);
    [self changeTextViewFrame:textView];
    //    [self changeSendButtonState];
}

-(void)gotoChooseContentPerson
{
    KDChooseContentCollectionViewController *ccvc = [[KDChooseContentCollectionViewController alloc] initWithNibName:nil bundle:nil];
    selectPersonsView.frame = CGRectMake(0.0f, CGRectGetHeight(self.navigationController.view.frame) - 44.0f, CGRectGetWidth(self.navigationController.view.frame), 44.0f);
    selectPersonsView.delegate = self;
    selectPersonsView.hidden = NO;
    ccvc.selectedPersonsView = selectPersonsView;
    ccvc.selectedPersonsView.delegate = self;
    NSMutableArray *mArrayParticipant = [NSMutableArray array];
    [self.group.participant enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
         if (person && [person accountAvailable])
         {
             // 20150318去除已注销人员
             [mArrayParticipant addObject:person];
         }
     }];
    ccvc.type = KDChooseContentAtSomeOne;
    ccvc.collectionDatas = mArrayParticipant;
    self.mentionTotal = [mArrayParticipant count];
    ccvc.navigationItem.title = self.group.groupName;
    [self.navigationController.view addSubview:selectPersonsView];
    [self.navigationController pushViewController:ccvc animated:YES];
}

- (void)shortVideo
{
    WechatShortVideoController *wechatShortVideoController = [[WechatShortVideoController alloc] init];
    wechatShortVideoController.delegate = self;
    [self presentViewController:wechatShortVideoController animated:YES completion:^{}];
}

#pragma mark - WechatShortVideoDelegate
- (void)finishWechatShortVideoCapture:(NSURL *)filePath {
    #pragma mark - WechatShortVideoDelegat {
        NSLog(@"filePath is %@", filePath);
}


//位置按钮按下
-(void)adressBtnClick
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        NSString *msg = [NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_17"),KD_APPNAME];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"XTChatViewController_Tip_18")message:msg delegate:self cancelButtonTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Sure")otherButtonTitles:nil];
        
        [alert show];
    }else {
        
        KDSendViewController *send= [[KDSendViewController alloc] init];
        send.delegate = self;
        send.title = ASLocalizedString(@"XTChatViewController_Tip_4");
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:send];
        [self presentViewController:nav animated:YES completion:nil];
        
    }
    
    
}


#pragma mark -
#pragma mark kdsendViewController delegate methods
- (void)sendLocation:(KDLocationData *)locationData {
    self.currentLocationData = locationData;
    NSData *data = UIImageJPEGRepresentation(self.currentLocationData.selfIMG,0.5);
    UIImage *image1 = [UIImage imageWithData:data];
    float width = 640.0;
    float height = 1096.0;
    if (image1.size.width > width || image1.size.height > height) {
        float scaleSize = width/image1.size.width > height/image1.size.height ? height/image1.size.height : width/image1.size.width;
        image1 = [self scaleImage:image1 toScale:scaleSize];
    }
    NSData *data1 = UIImageJPEGRepresentation(image1,0.5);
    
    image1 = [UIImage imageWithData:data1];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",self.currentLocationData.coordinate.longitude],@"longitude",[NSString stringWithFormat:@"%f",self.currentLocationData.coordinate.latitude],@"latitude",self.currentLocationData.address,@"addressName", nil];

    MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithDictionary:dic type:MessageTypeLocation];
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:_group.groupId];
    [sendRecord setMsgType:MessageTypeLocation];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    //    [sendRecord setContent:content];
    //    [sendRecord setMsgLen:content.length];
    [sendRecord setParam:param];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
    [_recordsList addObject:sendRecord];
    
    [[SDImageCache sharedImageCache] storeImage:self.currentLocationData.selfIMG forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord originalPictureUrl] imageScale:SDWebImageScaleNone]];
    
    
    
    
    
    [self sendWithRecord:sendRecord image:image1];
}

#pragma mark -
#pragma mark WechatShortVideoDelegate methods

-(void)sendShortVideo:(UIImage *)image urlArray:(NSArray *)url time:(NSString *)time andSize:(NSString *)size
{
  //
    _shortVideoUrl = [NSMutableArray arrayWithArray:url];
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:_group.groupId];
    [sendRecord setMsgType:MessageTypeShortVideo];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setNickname:ASLocalizedString(@"XTChatViewController_Tip_9")];
    [sendRecord setMsgLen:(int)self.contentView.text.length];
    [sendRecord setContent:ASLocalizedString(@"Short_video")];
    
//    CGFloat date = [NSDate timeIntervalSinceReferenceDate];

    NSString *name  = [NSString stringWithFormat:@"VID_TEMP%@_%ld.mp4",[NSDate dz_pureTodayDateString],(long)[NSDate timeIntervalSinceReferenceDate]];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"mp4",@"ext",time,@"videoTimeLength",size,@"size",name,@"name",[_shortVideoUrl lastObject],@"videoUrl", nil];
    MessageParamDataModel *shortVideoModel = [[MessageParamDataModel alloc]initWithDictionary:dic type:MessageTypeShortVideo];
    
    [sendRecord setParam:shortVideoModel];

    UIImage *image1 = [UIImage imageWithContentsOfFile:[_shortVideoUrl firstObject]];
    
    if (image1) {
        [[SDImageCache sharedImageCache] storeImage:image1 forKey:sendRecord.msgId ];
//        [[NSFileManager defaultManager]removeItemAtPath:[_shortVideoUrl firstObject] error:nil];
    }
    
    
    
    [_recordsList addObject:sendRecord];
    [self reloadData];
    [self scrollToBottomAnimated:NO];
    
    if ([self.shortVideoIDs count] > 0) {
        [self.shortVideoIDs removeAllObjects];
    }
    
    //上传图片，视频
    __weak XTChatViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self uploadVideo:[_shortVideoUrl objectAtIndex:0]
               completion:^(BOOL success){
                   if (success) {
                       
                   }else
                   {
                       [weakSelf uploadVideo:[weakSelf.shortVideoUrl objectAtIndex:0]
                              completion:^(BOOL success) {
                                  if (success) {
                                      if ([weakSelf.shortVideoIDs count] == 2) {
                                          //更新ID
                                          NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[weakSelf.shortVideoIDs lastObject],@"fileId",[weakSelf.shortVideoIDs firstObject],@"videoThumbnail",@"mp4",@"ext",time,@"videoTimeLength",size,@"size",name,@"name",((MessageTypeShortVideoDataModel *)(shortVideoModel.paramObject)).videoUrl,@"videoUrl",nil];
                                          MessageParamDataModel *shortVideoModel = [[MessageParamDataModel alloc]initWithDictionary:dic type:MessageTypeShortVideo];
                                          [sendRecord setParam:shortVideoModel];
                                          [weakSelf sendWithRecord:sendRecord image:nil];
                                      }
                                      
                                  }
                              }];
                   }
               }];
    });
}
- (void)uploadVideo:(NSString *)url
         completion:(void(^)(BOOL success))completionBlock
{
    KDQuery *query = [KDQuery query];
    [query setParameter:@"pic" filePath:url];
    __weak XTChatViewController *weakSelf = self;
    KDServiceActionDidCompleteBlock networkCompletionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse] ){
            if (results) {
                [weakSelf.shortVideoIDs addObject:results];
                [weakSelf.shortVideoUrl removeObjectAtIndex:0];
                if ([_shortVideoUrl count] > 0) {
                    completionBlock (NO);
                }else
                {
                     completionBlock (YES);
                }
                }//发送消息
                else
                {
                    completionBlock (NO);
                }
                
            }else
            {
                
            }
    };
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/upload/:uploadVideo" query:query
                                 configBlock:nil completionBlock:networkCompletionBlock];
}

// MARK: 提及
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    return [self sendMessageWithTextView:textView replacementText:text];

}

- (BOOL)sendMessageWithTextView:(UITextView *)textView
                replacementText:(NSString *)text
{
    if([text isEqualToString:@"@"] || [text isEqualToString:@"@"])
    {
        /**
       *  MARK: 提及， 进入选人
       */
        // 在中文输入法输入“随便一段话@”， 会激活@两次， 所以要防止push两次的情况
        
        
        // 为方便用户打email, 以数字,字母,下划线开头紧接着打@不会出现选人界面
        NSString *strSecondLast;
        if (_currentString.length >= 2)
        {
            strSecondLast = [NSString stringWithFormat:@"%c",[_currentString characterAtIndex:_currentString.length - 2]];
        }
        NSString *strTest = strSecondLast;
        NSRegularExpression *regex =  [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9_-]" options:0 error:nil];
        BOOL bEmailFomat = NO;
        if (regex && strTest)
        {
            NSArray *matches=[regex matchesInString:strTest options:0 range:NSMakeRange(0, strTest.length)];
            bEmailFomat = !([matches count]==0);
        }
        
        if (!bEmailFomat && [text isEqualToString:@"@"] && (self.group.groupType == GroupTypeMany) && !_pushingToChooseVC) {
            _pushingToChooseVC = YES;
            // 进入 @某人 选择界面
            [self gotoChooseContentPerson];
        }

        return YES;
    }
    else if (![text isEqualToString:@"\n"])
        return YES;
    
    // 为notifyTo(Array)：[“用户id1 “,” 用户id2 “, …]提供数据
    NSString *totalText = self.contentView.text;
    
    //检测ALL字段
    BOOL bContainAtAll = NO;
    if (!isAboveiOS8) {
        if([[totalText uppercaseString] rangeOfString:@"@ALL"].length > 0)
            bContainAtAll = YES;
    }else
    {
        if([[totalText uppercaseString] containsString:@"@ALL"])
            bContainAtAll = YES;
    }
    
    NSMutableArray *mArrayParam = [NSMutableArray new];
    /*
     @all的检测标准：
     1 如果用户把组里的人分别的@一遍
     2 包含了@all字段
     
     为了和安卓一致，只保留情况2
     */
    //    BOOL bAtAll = mSetSelectedPersons.count == self.group.participantIds.count || bContainAtAll;
    BOOL bAtAll = bContainAtAll;
    // 3.0 分支，若正则筛选出的人刚好和组内的人一致，则为 @ALL 的情景
    if (bAtAll)
    {
        //        [KDEventAnalysis event:event_session_at_all];
    }
    else
    {
        // 3.1 分支，@某些人，生成param array
        for (PersonSimpleDataModel *person in self.group.participant)
        {
            NSRange range1 = [totalText rangeOfString:[NSString stringWithFormat:@"@%@%@",person.personName,@" "]];
            NSRange range2 = [totalText rangeOfString:[NSString stringWithFormat:@"@%@%@",person.personName,@"@"]];
            NSRange range3 = [totalText rangeOfString:[NSString stringWithFormat:@"@%@",person.personName]];
            if(range1.length > 0|| range2.length > 0 || (range3.length>0 && range3.location+range3.length == totalText.length))
                [mArrayParam addObject:person.personId];
        }
    }
    
    // MARK: 点击键盘发送按钮
    _lastString = text;
    //_currentString = [textView.text stringByAppendingString:_lastString];
    if ([_lastString isEqualToString:@"\n"])
    {
        NSString *text = self.contentView.text;
        if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
        {
            return NO;
        }
        
        // 输入过长分段逻辑，暂时去掉，别删
//        int count = ceil(text.length / 500.0);
//        for (int i = 0; i < count; i++)
        {
//            int location = i * 500;
//            int lenght = 500;
//            if (i == count - 1)
//            {
//                lenght = (int) text.length - i * 500;
//            }
            
            //第三方输入回车问题 add by lee/170824
            if ([text containsString:@"\r"]) {
                text =  [text stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
            }
            
            NSString *content = text;//[text substringWithRange:NSMakeRange(location, lenght)];
            RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
            [sendRecord setGroupId:_group.groupId];
            [sendRecord setMsgType:MessageTypeText];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
            [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
            [sendRecord setStatus:MessageStatusRead];
            [sendRecord setContent:content];
            [sendRecord setMsgRequestState:MessageRequestStateRequesting];
            [sendRecord setMsgId:[ContactUtils uuid]];
            [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
            [sendRecord setMsgLen:(int) content.length];
            
            MessageParamDataModel *modal = [MessageParamDataModel new];
            NSMutableDictionary *dict = [NSMutableDictionary new];
            
            PersonSimpleDataModel *person = [self personWithGroup:self.group record:self.replyRecord];
            NSString *strName = [self personNameWithGroup:self.group record:self.replyRecord];
            
            // MARK: 消息回复
            if (self.messageMode == KDChatMessageModeReply) {
                MessageShareTextOrImageDataModel *paramObject = [[MessageShareTextOrImageDataModel alloc] init];
                
                //[KDEventAnalysis event:event_session_reply_message_send];
                
                if (self.replyRecord.msgId.length > 0) {
                    [dict setObject:self.replyRecord.msgId forKey:@"replyMsgId"];
                    paramObject.replyMsgId = self.replyRecord.msgId;
                }
                
                if (strName.length > 0) {
                    [dict setObject:strName forKey:@"replyPersonName"];
                    paramObject.replyPersonName = strName;
                }
                
                
                if (self.replyRecord.content.length > 0) {
                    [dict setObject:self.replyRecord.content forKey:@"replySummary"];
                    paramObject.replySummary = self.replyRecord.content;
                }

                modal.paramObject = paramObject;
                
                //指定回复时，单人会话不产生@效果
                if(self.group.groupType != GroupTypeDouble)
                    [mArrayParam addObject:person.personId];
                
                sendRecord.content = content;
            }

            //无痕模式以及单人会话不产生@效果
            if(self.messageMode == KDChatMessageModeNotrace || self.group.groupType == GroupTypeDouble)
            {
                bAtAll = NO;
                [mArrayParam removeAllObjects];
            }
            
            if (bAtAll)
            {
                // @all
                [dict addEntriesFromDictionary:@{@"notifyType" : @"1", @"notifyTo" : mArrayParam, @"notifyToAll" : @(YES)}];
            }
            else if (mArrayParam.count != 0)
            {
                // @some
                [dict addEntriesFromDictionary:@{@"notifyType" : @"1", @"notifyTo" : mArrayParam}];
            }
            else
            {
                // 普通消息
            }
            
            if (self.bImportantMessageMode)
            {
                [dict setObject:@(YES) forKey:@"important"];
                sendRecord.bImportant = YES;
                //                [KDEventAnalysis event:event_session_important_message_send];
            }
            else
            {
                sendRecord.bImportant = NO;
            }
            
            if (self.messageMode == KDChatMessageModeNotrace) {
                [dict setObject:safeString(sendRecord.content) forKey:@"content"];
                [dict setObject:@(sendRecord.msgType) forKey:@"msgType"];
                sendRecord.content = [NSString stringWithFormat:@"[%@]",ASLocalizedString(@"XTChatViewController_Notrace_Msg")];;
                sendRecord.msgType = MessageTypeNotrace;
                MessageNotraceDataModel *model = [[MessageNotraceDataModel alloc] initWithDictionary:dict];
                modal.paramObject = model;
            }

            
            
            NSString *strParam = [dict JSONFragment];
            
            //MessageParamDataModel *modal = [MessageParamDataModel new];
            modal.type = MessageTypePicture;
            modal.paramString = strParam;
            sendRecord.param = modal;
            [_recordsList addObject:sendRecord];
            [self sendWithRecord:sendRecord];
            //[self closeImportantMode];
        }
        
        textView.text = nil;
        //解决超过2行不会恢复原高度;
        CGSize contentSize = textView.contentSize;
        contentSize.height = 30;
        textView.contentSize = contentSize;
        [self changeTextViewFrame:textView];
        [self removeDraft];
        [self.content setString:@""];
        
        if (self.messageMode != KDChatMessageModeNotrace) {
            [self changeMessageModeTo:KDChatMessageModeNone];
        }
        return NO;
    }
    return YES;
    
}

- (void)changeTextViewFrame:(UITextView *)textView
{
    float boundsSizeHeight = textView.bounds.size.height;
    
    float contentSizeHeight = textView.contentSize.height;
    
    //    if(isAboveiOS7) {
    contentSizeHeight = [textView sizeThatFits:CGSizeMake(textView.bounds.size.width, MAXFLOAT)].height;
    //    }
    
    
    if (contentSizeHeight > boundsSizeHeight)
    {
        if (boundsSizeHeight == TextView_Max_Height) {
            return;
        }
        contentSizeHeight = MIN(TextView_Max_Height,contentSizeHeight);
    }
    else
    {
        if (boundsSizeHeight == TextView_Min_Height) {
            return;
        }
        contentSizeHeight = MAX(TextView_Min_Height, contentSizeHeight);
    }
    
    float height = contentSizeHeight - boundsSizeHeight;
    
    CGRect bubbleTableFrame = self.bubbleTable.frame;
    bubbleTableFrame.size.height -= height;
    self.bubbleTableStartHeight -= height;
    self.bubbleTable.frame = bubbleTableFrame;
    
    //change toolbar frame
    CGRect toolBarFrame = self.toolbarImageView.frame;
    toolBarFrame.size.height += height;
    toolBarFrame.origin.y -= height;
    self.toolbarImageViewStartY -= height;
    self.toolbarImageView.frame = toolBarFrame;
    
    //change textview frame
    CGRect textViewFrame = textView.frame;
    textViewFrame.size.height = contentSizeHeight;
    textView.frame = textViewFrame;
    
    [self scrollRow:[self.bubbleArray count]-1 animated:NO];
    
    [textView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - BubbleImageViewDelegate

- (void)bubbleDidDeleteMsg:(BubbleImageView *)bubbleImageView cell:(BubbleTableViewCell *)cell
{
    if (cell != nil) {
        NSIndexPath *index = [self.bubbleTable indexPathForCell:cell];
        if (!index)
        {
            return;
        }
        
        self.selectMenuCellIndexPath = index;
        self.multiseSelctMode = 0;
        self.multiselecting = YES;
    }
}

-(void)deleteMsg:(BubbleDataInternal *)data
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:[self.bubbleArray indexOfObject:data] inSection:0];
    BubbleImageView *bubbleImageView = ((BubbleTableViewCell *)[self tableView:self.bubbleTable cellForRowAtIndexPath:index]).bubbleImage;
    if (index.row >= 0 && index.row < [self.bubbleArray count]) {
        [self.bubbleArray removeObjectAtIndex:index.row];
        [self.recordsList removeObjectAtIndex:index.row];
        [self.bubbleTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:bubbleImageView.record.msgDirection == MessageDirectionLeft ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight];
        
        if (self.group.groupType == GroupTypeTodo) {
            [self reloadData];
        }
        
        //清除本地
        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordWithMsgId:bubbleImageView.record.msgId];
        
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (weakSelf.pubAccount.publicId.length > 0)
            {
                [[XTDeleteService shareService] deleteMessageWithPublicId:weakSelf.pubAccount.publicId groupId:weakSelf.group.groupId msgId:bubbleImageView.record.msgId];
            }
            else
            {
                [[XTDeleteService shareService] deleteMessageWithGroupId:weakSelf.group.groupId msgId:bubbleImageView.record.msgId];
            }
            
        });
    }
}

-(void)deleteMsgArray:(NSArray *)dataArray
{
    __weak __typeof(self) weakSelf = self;
    NSMutableArray *indexArray = [[NSMutableArray alloc] initWithCapacity:dataArray.count];
    NSMutableString *msgIdsStr = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i<dataArray.count; i++)
    {
        BubbleDataInternal *dataInternal = dataArray[i];
        NSIndexPath *index = [NSIndexPath indexPathForRow:[self.bubbleArray indexOfObject:dataInternal] inSection:0];
        if (index.row >= 0 && index.row < [self.bubbleArray count])
        {
            [indexArray addObject:index];
            if(dataInternal.record.msgId.length > 0)
            {
                [msgIdsStr appendString:dataInternal.record.msgId];
                if(i!=dataArray.count-1)
                    [msgIdsStr appendString:@","];
            }
        }
    }
    
    if(indexArray.count == 0 || msgIdsStr.length == 0)
        return;
    
    
    //从内存清除
    [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BubbleDataInternal *dataInternal = obj;
        [weakSelf.bubbleArray removeObject:dataInternal];
        [weakSelf.recordsList removeObject:dataInternal.record];
    }];
    
    //列表移除
    [self.bubbleTable deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationLeft];
    
    //刷新列表
    if (self.group.groupType == GroupTypeTodo)
        [self reloadData];
    
    //清除本地
    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordWithMsgId:msgIdsStr];
    
    //服务器删除消息
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (weakSelf.pubAccount.publicId.length > 0)
        {
            [[XTDeleteService shareService] deleteMessageWithPublicId:weakSelf.pubAccount.publicId groupId:weakSelf.group.groupId msgId:msgIdsStr];
        }
        else
        {
            [[XTDeleteService shareService] deleteMessageWithGroupId:weakSelf.group.groupId msgId:msgIdsStr];
        }
    });
    
}

- (void)cancelMsg:(BubbleImageView *)bubbleImageView cell:(BubbleTableViewCell *)cell{
    _cancelMsgId = nil;
    _cancelMsgId = bubbleImageView.record.msgId;
    _cancelMsgCell = nil;
    _cancelMsgCell = cell;
    ContactClient *cancelClient = [[ContactClient alloc] initWithTarget:self action:@selector(cancelDidReceived:result:)];
    cancelClient.clientKey = bubbleImageView.record.msgId;
    [_serviceClients setObject:cancelClient forKey:cancelClient.clientKey];
    [cancelClient cancelMessageWithGroupId:self.group.groupId  msgId: bubbleImageView.record.msgId];
    
}
- (void)cancelDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (!client.hasError || result.success) {
        [self deleteCancelCell];
    }
    else
    {
        if(result.error)
            [MBProgressHUD showMessag:result.error toView:self.view];
    }
}
- (void)deleteCancelCell{
    if ([[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordWithMsgId:_cancelMsgId]) {
        if (_cancelMsgCell != nil) {
            NSIndexPath *index = [self.bubbleTable indexPathForCell:_cancelMsgCell];
            if (!index)
            {
                return;
            }
            if (index.row >= 0 && index.row < [self.bubbleArray count]) {
                if(index.row < self.recordsList.count)
                    [self.recordsList removeObjectAtIndex:index.row];
                if(index.row < self.bubbleArray.count)
                    [self.bubbleArray removeObjectAtIndex:index.row];
                [self.bubbleTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationRight];
                
                self.group.updateTime = ((RecordDataModel *)[self successRecordsList].lastObject).msgId;
                if (self.chatMode == ChatPrivateMode) {
                    [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithUpdateTime:self.group.updateTime withGroupId:self.group.groupId];
                }else{
                    [[XTDataBaseDao sharedDatabaseDaoInstance] updatePublicGroupListWithUpdateTime:self.group.updateTime withGroupId:self.group.groupId withPublicId:self.pubAccount.publicId];
                }

                if (self.group.groupType == GroupTypeTodo) {
                    [self reloadData];
                    
                }
            }
        }
        
        
    }
    
}


#pragma mark - ProgressHud

- (MBProgressHUD *)progressHud
{
    if (_progressHud == nil) {
        UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
        _progressHud = [[MBProgressHUD alloc] initWithView:window];
        _progressHud.delegate = self;
        [window addSubview:_progressHud];
    }
    return _progressHud;
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [_progressHud removeFromSuperview];
    _progressHud = nil;
}

#pragma mark - File Action Notification

- (void)fileDidFinishedCollect:(NSNotification *)notify
{
    NSString *result = (NSString *)notify.object;
    
    if ([result isEqualToString:Result_Success]) {
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CHAT_FILE_STOW_GUIDE"]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"CHAT_FILE_STOW_GUIDE"];
            
            [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTChatViewController_Tip_20")message:ASLocalizedString(@"XTChatViewController_Tip_21")delegate:nil cancelButtonTitle:ASLocalizedString(@"XTChatViewController_Tip_22")otherButtonTitles:nil, nil] show];

            return;
        }
    }
    
    self.progressHud.labelText = [result isEqualToString:Result_Success] ? ASLocalizedString(@"XTChatViewController_Tip_20"): ASLocalizedString(@"XTChatViewController_Tip_24");
    self.progressHud.mode = MBProgressHUDModeCustomView;
    if ([result isEqualToString:Result_Success]) {
        self.progressHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]];
    }
    self.progressHud.margin = 30;
    self.progressHud.dimBackground = NO;
    [self.progressHud show:YES];
    [self.progressHud hide:YES afterDelay:1.0];
}



-(void)serveraction:(UIButton*)btn
{
    
    [self cancelAllToolbarMenuSelection];
    
    int a=(int)btn.tag;
    if (a < 200 && a >=100) {
        XTMenuEachModel*each=[self.menufirst objectAtIndex:a-100];
        if ([each.type isEqualToString:@"app"]) {
            [self openapp:each.ios withurl:each.url];
        }else if ([each.type isEqualToString:@"click"]) {
            [self menuclick:each.key withname:each.name];
        }else if ([each.type isEqualToString:@"view"]) {
            [self openweb:each.url menuId:each.ID appId:each.appId];
        }
        
    }else if (a < 300 && a >= 200)
    {
        XTMenuEachModel*each=[self.menusecond objectAtIndex:a-200];
        if ([each.type isEqualToString:@"app"]) {
            [self openapp:each.ios withurl:each.url];
        }else if ([each.type isEqualToString:@"click"]) {
            [self menuclick:each.key withname:each.name];
        }else if ([each.type isEqualToString:@"view"]) {
            [self openweb:each.url menuId:each.ID appId:each.appId];
        }
        
    }else if(a < 400 && a >= 300)
    {
        XTMenuEachModel*each=[self.menuthird objectAtIndex:a-300];
        if ([each.type isEqualToString:@"app"]) {
            [self openapp:each.ios withurl:each.url];
        }else if ([each.type isEqualToString:@"click"]) {
            [self menuclick:each.key withname:each.name];
        }else if ([each.type isEqualToString:@"view"]) {
            [self openweb:each.url menuId:each.ID appId:each.appId];
        }
    }
}


- (void)displaySecondaryMenuAnimated:(BOOL)animated {
    NSTimeInterval interval = animated?0.2f: 0.0f;
    
    [UIView animateWithDuration:interval animations:^{
        for (UIButton *theBtn in self.toolbarBtnsArray) {
            switch (theBtn.tag) {
                case 1000:
                {
                    
                }
                    break;
                case 1001:
                {
                    
                }break;
                case 1002:{
                    
                }
                default:
                    break;
            }
        }
        
        
    }];
    
    
    
}

//
- (void)cancelAllToolbarMenuSelection {
    for (UIButton *btn in self.toolbarBtnsArray) {
        if (btn.tag != 1000) {
            btn.selected = NO;
        }
    }
}
- (void)handleEventModel:(MessageTypeNewsEventsModel *)event{
    
    if ([event.event length] >0) {
        [self eventclick:event.event withname:event.title];
    }
    else if([event.url length] >0){
        [self openweb:event.url menuId:event.title appId:event.appid];
    }
    
}
-(void)eventclick:(NSString*)key withname:(NSString*)name
{
    NSString *paramString = [NSString stringWithFormat:@"{\"eventKey\":\"click\",\"eventData\":\"%@\"}",key];
    if (_issending) {
        
    }else
    {
        NSString *toUserId = @"";
        if (self.group.groupId.length == 0) {
            PersonSimpleDataModel *person = [self.group.participant firstObject];
            toUserId = person.personId;
        }
        [self.sendMessageClient toSendMsgWithGroupID:self.group.groupId toUserID:toUserId msgType:MessageTypeEvent content:name msgLent:(int)name.length param:paramString clientMsgId:[ContactUtils uuid]];
        _issending=YES;
        [UIView animateWithDuration:0.7
                         animations:^{
                             noticeview.alpha=0.8;
                             noticeview.frame=CGRectMake(100, ScreenFullHeight-160+Adjust_Offset_Xcode5, 120, 40);
                         }];
    }
}

-(void)menu:(UIButton*)btn
{
    __weak __typeof(self) weakSelf = self;
    for (UIButton *theBtn in self.toolbarBtnsArray) {
        if (theBtn == btn) {
            theBtn.selected = !theBtn.selected;
        }else {
            theBtn.selected = NO;
        }
    }
    
    if (btn.tag == 1000) {
        CGRect toolBarViewFrame = self.toolbarImageView.frame;
        
        if (_menukeyboard) {
            _menukeyboard = NO;
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.toolbarImageView.alpha=1.0;
                weakSelf.toolbarMenuview.alpha=0.0;
                weakSelf.toolbarImageView.frame =CGRectMake(0.0, weakSelf.toolbarImageViewStartY, ScreenFullWidth, toolBarViewFrame.size.height);
                weakSelf.toolbarMenuview.frame =CGRectMake(0.0, weakSelf.toolbarImageViewStartY+200, ScreenFullWidth, 49);
            }];
        }
        else {
            _menukeyboard=YES;
            [UIView animateWithDuration:0.2 animations:^{
                [weakSelf hideInputBoard];
                [weakSelf.contentView resignFirstResponder];
                weakSelf.toolbarImageView.alpha=0.0;
                weakSelf.toolbarMenuview.alpha=1.0;
                weakSelf.toolbarImageView.frame =CGRectMake(0.0, weakSelf.toolbarImageViewStartY+200, ScreenFullWidth, toolBarViewFrame.size.height);
                weakSelf.toolbarMenuview.frame =CGRectMake(0.0, weakSelf.toolbarImageViewStartY, ScreenFullWidth, 49);
            }];
        }
        
    }
    else if (btn.tag == 1001) {
        XTmenuModel*record=[self.menuarray objectAtIndex:btn.tag-1001];
        if ([record.type isEqualToString:@"app"]) {
            [self openapp:record.ios withurl:record.url];
        }else if ([record.type isEqualToString:@"click"]) {
            [self menuclick:record.key withname:record.name];
            
        }else if([record.type isEqualToString:@"view"])
        {
            [self openweb:record.url menuId:record.ID appId:record.appId];
            
        }else if ([record.type isEqualToString:@"menu"])
        {
            
        }
        
    }
    else if (btn.tag == 1002) {
        XTmenuModel*record=[self.menuarray objectAtIndex:btn.tag-1001];
        if ([record.type isEqualToString:@"app"]) {
            [self openapp:record.ios withurl:record.url];
        }else if ([record.type isEqualToString:@"click"]) {
            [self menuclick:record.key withname:record.name];
            
        }
        else if([record.type isEqualToString:@"view"]) {
            
            
            [self openweb:record.url menuId:record.ID appId:record.appId];
            
        }
        else if ([record.type isEqualToString:@"menu"]) {
            //            [UIView animateWithDuration:0.2
            //                             animations:^{
            //                                 if (self.itimage.frame.origin.y == ScreenFullHeight+Adjust_Offset_Xcode5) {
            //                                     self.itimage.frame=CGRectMake(130, ScreenFullHeight-125-40*self.menusecond.count+Adjust_Offset_Xcode5, 113, 8+self.menusecond.count*40);
            //                                     self.personimage.frame=CGRectMake(40, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
            //                                     self.otherimage.frame=CGRectMake(204, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
            //                                 }else
            //                                 {
            //                                     self.itimage.frame=CGRectMake(130, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
            //                                     self.personimage.frame=CGRectMake(40, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
            //                                     self.otherimage.frame=CGRectMake(204, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
            //                                 }
            //                             }];
            
        }
        
    }else if (btn.tag == 1003) {
        XTmenuModel*record=[self.menuarray objectAtIndex:btn.tag-1001];
        if ([record.type isEqualToString:@"app"]) {
            [self openapp:record.ios withurl:record.url];
        }else if ([record.type isEqualToString:@"click"]) {
            [self menuclick:record.key withname:record.name];
        }else if([record.type isEqualToString:@"view"])
        {
            [self openweb:record.url menuId:record.ID appId:record.appId];
        }else if ([record.type isEqualToString:@"menu"])
        {
            //            [UIView animateWithDuration:0.2
            //                             animations:^{
            //                                 if (self.otherimage.frame.origin.y == ScreenFullHeight+Adjust_Offset_Xcode5) {
            //                                     self.otherimage.frame=CGRectMake(204, ScreenFullHeight-125-40*self.menuthird.count+Adjust_Offset_Xcode5, 113, 8+self.menuthird.count*40);
            //                                     self.itimage.frame=CGRectMake(130, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
            //                                     self.personimage.frame=CGRectMake(40, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
            //                                 }else
            //                                 {
            //                                     self.otherimage.frame=CGRectMake(204, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
            //                                     self.itimage.frame=CGRectMake(130, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
            //                                     self.personimage.frame=CGRectMake(40, ScreenFullHeight+Adjust_Offset_Xcode5, 113, 100);
            //                                 }
            //
            //                             }];
        }
        
    }
}

- (void)openweb:(NSString *)url menuId:(NSString *)menuId appId:(NSString *)appId
{
    if (url.length == 0 && appId.length == 0) {
        return;
    }
    
    KDWebViewController *web = nil;
    if (appId.length > 0) {
        web = [[KDWebViewController alloc] initWithUrlString:url appId:appId];
    }
    else {
        if (self.ispublic && [self.group.participant count] == 1) {
            PersonSimpleDataModel *person = [self.group.participant firstObject];
            web = [[KDWebViewController alloc] initWithUrlString:url pubAccId:person.personId menuId:menuId];
        }else{
            web = [[KDWebViewController alloc] initWithUrlString:url];
        }
    }
    if (web) {
        web.title = self.group.groupName;
        web.hidesBottomBarWhenPushed = YES;
        
        __weak __typeof(web) weak_webvc = web;
        __weak __typeof(self) weak_controller = self;
        web.getLightAppBlock = ^() {
            if(weak_webvc && !weak_webvc.bPushed){
                [weak_controller.navigationController pushViewController:weak_webvc animated:YES];
            }
        };
    }
}

-(void)openapp:(NSString*)schemes withurl:(NSString*)url
{
    KDSchemeHostType t;
    NSDictionary *dic = [schemes schemeInfoWithType:&t shouldDecoded:NO];
    
    if(t == KDSchemeHostType_Topic) {
        NSString *topicName = [dic stringForKey:@"name"];
        if(topicName.length > 0) {
            KDTopic *topic = [[KDTopic alloc] init];
            topic.name = topicName;
            
            TrendStatusViewController *ts = [[TrendStatusViewController alloc] initWithTopic:topic];
            [self.navigationController pushViewController:ts animated:YES];
        }
    }
    else if(t == KDSchemeHostType_Local)
    {
        NSString *localMethod = [dic stringForKey:@"func"];
        if ([localMethod isEqualToString:@"camera"]) {
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        else if ([localMethod isEqualToString:@"gallery"])
        {
            KDImagePickerController *picker = [[KDImagePickerController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
            picker.allowsMultipleSelection = YES;
            picker.maximumNumberOfSelection = 9;
            picker.minimumNumberOfSelection = 1;
            picker.limitsMaximumNumberOfSelection = YES;
            picker.limitsMinimumNumberOfSelection = YES;
            picker.delegate = self;
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
    else if (t == KDSchemeHostType_Todolist) {
        NSString *type = [dic stringForKey:@"type"];
        
        if ([type isEqualToString:@"undo"]) {
            KDTodoListViewController *ctr = [[KDTodoListViewController alloc] initWithTodoType:kTodoTypeUndo];
            [self.navigationController pushViewController:ctr animated:YES];
        }
        else if ([type isEqualToString:@"done"]) {
            KDTodoListViewController *ctr = [[KDTodoListViewController alloc] initWithTodoType:kTodoTypeDone];
            [self.navigationController pushViewController:ctr animated:YES];
        }
        else if ([type isEqualToString:@"ignore"]) {
            KDTodoListViewController *ctr = [[KDTodoListViewController alloc] initWithTodoType:kTodoTypeIgnore];
            [self.navigationController pushViewController:ctr animated:YES];
        }
    }
    else if (t == KDSchemeHostType_Todonew) {
        KDCreateTaskViewController *ctr = [[KDCreateTaskViewController alloc] init];
        ctr.title =ASLocalizedString(@"XTChatViewController_Tip_25");
        [self.navigationController pushViewController:ctr animated:YES];
    }
    else {
        
        UIApplication *app = [UIApplication sharedApplication];
        
        NSURL *nsurl = [NSURL URLWithString:schemes];
        if ([app canOpenURL:nsurl]) {
            [[UIApplication sharedApplication]openURL:nsurl];
        }
        else {
            KDWebViewController *web = [[KDWebViewController alloc] initWithUrlString:url];
            web.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:web animated:YES];
        }
    }
}
//发送间隔
-(void)sending
{
    _issending=NO;
    [UIView animateWithDuration:0.7
                     animations:^{
                         noticeview.alpha=0;
                         noticeview.frame=CGRectMake(100, ScreenFullHeight, 120, 40);
                     }];
}

-(void)menuclick:(NSString*)key withname:(NSString*)name
{
    
    NSDateFormatter *fdf = [[NSDateFormatter alloc] init];
    [fdf setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *now = [fdf stringFromDate:[NSDate date]];
    NSString *paramString = [NSString stringWithFormat:@"{\"eventKey\":\"menu\",\"eventData\":{\"menuItem\":\"%@\",\"clientTime\":\"%@\"}}",key,now];
    if (_issending) {
        
    }else
    {
        NSString *toUserId = @"";
        if (self.group.groupId.length == 0) {
            PersonSimpleDataModel *person = [self.group.participant firstObject];
            toUserId = person.personId;
        }
        [self.sendMessageClient toSendMsgWithGroupID:self.group.groupId toUserID:toUserId msgType:MessageTypeEvent content:name msgLent:(int)name.length param:paramString clientMsgId:[ContactUtils uuid]];
        _issending=YES;
        [UIView animateWithDuration:0.7
                         animations:^{
                             noticeview.alpha=0.8;
                             noticeview.frame=CGRectMake(100, ScreenFullHeight-160+Adjust_Offset_Xcode5, 120, 40);
                         }];
    }
}

#pragma mark - XTChooseContentViewControllerDelegate

- (void)popViewController
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}


#pragma mark - UIGestureRecognizerDelegate Methods
- (void)contentViewTapped:(UIGestureRecognizer *)gesutre {
    [self emojiBtnClick:nil];
}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    CGPoint p = [touch locationInView:self.view];
//
//    CGRect recordBtnFrameInSelfView = [self.view convertRect:self.recordButton.frame fromView:self.toolbarImageView];
//    
//    if(CGRectContainsPoint(recordBtnFrameInSelfView, p)) {
//        [gestureRecognizer removeTarget:self.navigationController action:@selector(panned:)];
//        [gestureRecognizer addTarget:self action:@selector(panGestureRecognizer:)];
//    }
//
//    return YES;
//
//}


- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan {
    CGPoint location = [pan locationInView:self.view];
    
    CGRect recordButtonFrame = [self.view convertRect:self.recordButton.frame fromView:self.toolbarImageView];
    
    BOOL isInRecordButtonFrame = CGRectContainsPoint(recordButtonFrame, location);
    
    
    if(pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateFailed) {
        [_panrecognizer addTarget:self.navigationController action:@selector(panned:)];
        if (isInRecordButtonFrame) {
            [self recordTouchUpInside:self.recordButton];
        }else {
            [self recordTouchUpOutside:self.recordButton];
        }
        
    }else if(pan.state == UIGestureRecognizerStateChanged) {
        [self.recordButton setHighlighted:isInRecordButtonFrame];
        if (isInRecordButtonFrame) {
            [self recordTouchDragEnger:nil];
        }else {
            [self showDelSendView];
        }
    }else if(pan.state == UIGestureRecognizerStateBegan) {
        if (!isInRecordButtonFrame) {
            [self showDelSendView];
        }
    }
}

#pragma mark - XTPersonHeaderViewLongPressDelegate
// MARK: 取消长按头像@功能
- (void)personHeaderLongPressed:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person
{
    // TODO: 如果不是多人组则return
    if (!(self.group.groupType == GroupTypeMany)) {
        return;
    }
    
    
    if (person.personName.length == 0) {
        return;
    }
    
    if (self.changeButton.tag == ChangeBtnTagText) {
        [self changeBtnClick:self.changeButton];
    }
    
    if (![self.contentView isFirstResponder]) {
        [self.contentView becomeFirstResponder];
    }
    
    NSString *text = @"";
    if (self.contentView.text.length > 0) {
        text = self.contentView.text;
    }
    text = [text stringByAppendingString:[NSString stringWithFormat:@"@%@ ",person.personName]];
    
    self.contentView.text = text;
}

#pragma mark - 判断人员数量
-(NSString *)getMutiChatGroupTitle
{
//    NSInteger count = [self getMutiChatGroupParticipantCount];
    NSString *title = [NSString stringWithFormat:ASLocalizedString(@"XTChatDetailViewController_Person"),self.group.groupName,self.group.userCount];
    return title;
}

- (NSInteger)getMutiChatGroupParticipantCount {
    NSInteger peronsCount = [self.group.participantIds count];
    NSInteger count = 1;
    for(int i = 0;i < peronsCount; i++){
        NSString *personId = [self.group.participantIds objectAtIndex:i];
        if (peronsCount == 1) {
            if ([personId isEqualToString:[BOSConfig sharedConfig].user.userId]) {
                count = 1;
                break;
            }else{
                count = peronsCount + 1;
            }
        }else{
            if ([personId isEqualToString:[BOSConfig sharedConfig].user.userId]) {
                count = peronsCount;
                break;
            }else{
                count = peronsCount + 1;
            }
        }
    }
    return count;
}


#pragma mark - 草稿

- (void)fetchDraft
{
    if(self.contentView.text.length > 0)
        return;
    
    NSString *strDraft = [[XTDataBaseDao sharedDatabaseDaoInstance] queryDraftWithGroupId:self.group.groupId];
    if (strDraft.length > 0) {
        // 赋值给输入框
        self.contentView.text = strDraft;
        // 激活键盘
        [self.contentView becomeFirstResponder];
        [self changeTextViewFrame:self.contentView];
    }
}

- (void)removeDraft
{
    [[XTDataBaseDao sharedDatabaseDaoInstance] removeDraftWithGroupId:self.group.groupId];
}

- (void)updateDraft:(NSString *)strDraft
{
    if(![self.group slienceOpened])
        [[XTDataBaseDao sharedDatabaseDaoInstance] updateDraft:strDraft withGroupId:self.group.groupId];
}


#pragma mark - Property Setup

- (NSMutableString *)content
{
    if (!_content) {
        _content = [NSMutableString new];
    }
    return _content;
}

- (NSMutableArray *)toolbarBtnsArray
{
    if (!_toolbarBtnsArray) {
        _toolbarBtnsArray = [[NSMutableArray alloc] init];
    }
    return _toolbarBtnsArray;
    
}


- (void)showSecondaryMenu:(UIView *)view  from:(UIView *)theView animated:(BOOL)animated {
    if (view && theView) {
        if (!view.hidden) {
            return;
        }
        view.hidden = NO;
        NSTimeInterval timeInterval = animated?0.0f:0.3f;
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:timeInterval
                         animations:^{
                             CGRect frame = view.frame;
                             CGRect theViewFrame = [theView convertRect:theView.bounds toView:weakSelf.view];
                             frame.origin.y = CGRectGetMinY(theViewFrame) - CGRectGetHeight(frame)-8;
                             CGFloat x = CGRectGetMinX(theViewFrame)+(CGRectGetWidth(theViewFrame)-CGRectGetWidth(frame))*0.5f;
                             
                             frame.origin.x = x;
                             
                             //若超过了边界
                             CGFloat offset =  CGRectGetWidth(weakSelf.view.bounds) -CGRectGetMaxX(frame);
                             if (offset <0.0f) {
                                 x+=(offset - 3);
                                 frame.origin.x = x;
                             }
                             
                             view.frame = frame;
                             
                         }completion:^(BOOL fnished) {
                             
                             
                             
                         }];
        
    }
}

- (void)hideSecondaryMenu:(UIView *)view from:(UIView *)theView animated:(BOOL)animated {
    if (view && theView) {
        if (view.hidden) {
            return;
        }
        
        NSTimeInterval timeInterval = animated?0.0f:0.2f;
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:timeInterval
                         animations:^{
                             CGRect theViewFrame = [theView convertRect:theView.bounds toView:weakSelf.view];
                             CGRect frame = view.frame;
                             frame.origin.y = CGRectGetMaxY(theViewFrame);
                             view.frame = frame;
                             
                         } completion:^(BOOL finished) {
                             view.hidden = YES;
                             
                         }];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:UIButton.class]) {  //底部menu button
        UIButton *btn = object;
        switch (btn.tag) {
            case 1000: //最左的键盘button
            {
                
            }
                break;
            case 1001: //第一个menu
            {
                if (btn.selected) {
                    [self showSecondaryMenu:self.personimage  from:btn animated:YES];
                }else {
                    [self hideSecondaryMenu:self.personimage from:btn animated:YES];
                }
            }
                break;
            case 1002: //第二个
            {
                DLog(@"click no 2");
                if (btn.selected) {
                    DLog(@"selected  ");
                    [self showSecondaryMenu:self.itimage  from:btn animated:YES];
                }else {
                    DLog(@"NO SELETED  ");
                    [self hideSecondaryMenu:self.itimage from:btn animated:YES];
                }
                
            }
                break;
            case 1003:// 第三个
            {
                if (btn.selected) {
                    [self showSecondaryMenu:self.otherimage from:btn animated:YES];
                }else {
                    [self hideSecondaryMenu:self.otherimage from:btn animated:YES];
                }
            }
                
                break;
            default:
                break;
        }
        
        
    }
    else if ([object isKindOfClass:[GroupDataModel class]]){
        
        if ([keyPath isEqualToString:@"groupName"]) {
            if ([self.group isNewGroup]) {
                self.bubbleTable.tableHeaderView = nil;
                self.group.isNewGroup = NO;
            }
        }
    }
    else {
        if ([keyPath isEqualToString:@"frame"]) { //contentView
            _touchView.frame = self.contentView.frame;
            
        }
    }
    
}


/**
 *  MARK: 提及
 */
- (void)setEmojiBoardShow:(BOOL)emojiBoardShow {
    _emojiBoardShow = emojiBoardShow;
    _touchView.hidden = !_emojiBoardShow;
}

#pragma mark - @联系人选择页面 delegate

- (void)selectPersonViewDidConfirm:(NSMutableArray *)persons
{
    NSString *strDraft = [[XTDataBaseDao sharedDatabaseDaoInstance] queryDraftWithGroupId:self.group.groupId];
    
    if (strDraft.length > 0)
    {
        NSString *lastIndexString = [strDraft substringFromIndex:(strDraft.length - 1)];
        
        if ([lastIndexString isEqualToString:@"@"])
        {
            strDraft = [strDraft substringToIndex:(strDraft.length - 1)];
        }
        [self.content setString:strDraft];
    }
    
    if ([persons count] == self.mentionTotal)
    {
        // 全选
        //        [self.content appendFormat:];
        NSString *strAt =[self.contentView.text substringWithRange:NSMakeRange(self.contentView.selectedRange.location-1, 1)];
        
        if ([strAt isEqualToString:@"@"])
        {
            [self.contentView insertText:@"ALL "];
        }
        else
        {
            [self.contentView insertText:@"@ALL "];
        }
        
        [self.content setString:self.contentView.text];
    }
    else
    {
        for (PersonDataModel *person in persons)
        {
            NSString *strAt =[self.contentView.text substringWithRange:NSMakeRange(self.contentView.selectedRange.location-1, 1)];
            
            if ([strAt isEqualToString:@"@"])
            {
                [self.contentView insertText:[NSString stringWithFormat:@"%@ ", person.personName]];
                
            }
            else
            {
                [self.contentView insertText:[NSString stringWithFormat:@"@%@ ", person.personName]];
                
            }
            
            
            //            [self.content appendFormat:@"@%@ ", person.personName];
        }
        [self.content setString:self.contentView.text];
        
    }
    [self updateDraft:self.content];
    [self.contentView becomeFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (XTChatBannerView *)bannerView
{
    if (!_bannerView)
    {
        _bannerView = [[XTChatBannerView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, 35)];
        _bannerView.delegate = self;
        _bannerView.hidden = YES;
    }
    return _bannerView;
}
- (void)showAtBannerView
{
    if (!self.multipartyCallBannerView.hidden)
    {
        SetY(self.bannerView.frame, MaxY(self.multipartyCallBannerView.frame));
    }
    self.bannerView.hidden = NO;
}

- (void)hideAtBannerView
{
    self.bannerView.hidden = YES;
}


- (void)goUpdateBannerView
{
    //    if (self.bFirstEnter)
    //    {
    [self updateBannerView];
    [[XTDataBaseDao sharedDatabaseDaoInstance] updateNotifyToEmptyWithGroupId:self.group.groupId];
    //        self.bFirstEnter = NO;
    //    }
}

- (void)updateBannerView
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.mArrayNotifyRecords setArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryNotifyRecordsWithGroupId:weakSelf.group.groupId]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.mArrayNotifyRecords.count > 0) {
                /**
                 *  以下代码为了保证[这个@信息是否已经(将)显示到屏幕上], 如果不会, 才会加入到屏幕上方灰条上.
                 */
                BubbleDataInternal *bdi;
                RecordDataModel *m = weakSelf.mArrayNotifyRecords[0];
                for (BubbleDataInternal *bd in weakSelf.bubbleArray) {
                    if ([bd.record.msgId isEqualToString:m.msgId]) {
                        bdi = bd;
                    }
                }
                int index = (int) [weakSelf.bubbleArray indexOfObject:bdi];
                BOOL bVisible = NO;
                for (NSIndexPath *ip in [weakSelf.bubbleTable indexPathsForVisibleRows]) {
                    if (index - 1 == ip.row) {
                        bVisible = YES;
                    }
                }
                if (!bVisible) {
                    [weakSelf showAtBannerView];
                    [weakSelf.bannerView setText:[NSString stringWithFormat:@"%@%@", m.strNotifyDesc, m.content]];
                }
            } else {
                [weakSelf hideAtBannerView];
            }
        });
    });
    
    //    [self.mArrayNotifyRecords setArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryNotifyRecordsWithGroupId:self.group.groupId]];
    //    NSLog(@"~~~~~!%@",self.mArrayNotifyRecords);
    //
    //    if (self.mArrayNotifyRecords.count > 0)
    //    {
    //
    //        /**
    //         *  以下代码为了保证[这个@信息是否已经(将)显示到屏幕上], 如果不会, 才会加入到屏幕上方灰条上.
    //         */
    //
    //        BubbleDataInternal *bdi;
    //        RecordDataModel *m = self.mArrayNotifyRecords[0];
    //        for (BubbleDataInternal *bd in self.bubbleArray)
    //        {
    //            if ([bd.record.msgId isEqualToString:m.msgId])
    //            {
    //                bdi = bd;
    //            }
    //        }
    //        int index = [self.bubbleArray indexOfObject:bdi];
    //        BOOL bVisible = NO;
    //        for (NSIndexPath *ip in [self.bubbleTable indexPathsForVisibleRows])
    //        {
    //            NSLog(@"%d",ip.row);
    //
    //            if (index - 1 == ip.row) {
    //                bVisible = YES;
    //            }
    //        }
    //
    //        if (!bVisible)
    //        {
    ////            self.bannerView.hidden = NO;
    ////            [self.bannerView setText:[NSString stringWithFormat:@"%@%@",m.strNotifyDesc,m.content]];
    //            [self showAtBannerView];
    //            [self.bannerView setText:[NSString stringWithFormat:@"%@%@", m.strNotifyDesc, m.content]];
    //        }
    //
    //    }
    //    else
    //    {
    ////        self.bannerView.hidden = YES;
    //        [self hideAtBannerView];
    //    }
    //
    
}

- (void)autoLoading
{
    if (!self.hasLastPage) {
        return;
    }
    self.isLoading = YES;
    
    __weak XTChatViewController *selfInBlock = self;
    
    selfInBlock.limitSatrt += RECORDS_PAGE;
    
    
    [selfInBlock getRecordsFromDataBaseOnePage:^(int count) {
        if (count > 0) {
            
            [selfInBlock updateData];
            
            
            BubbleDataInternal *bdi;
            
            RecordDataModel *m = selfInBlock.mArrayNotifyRecords[0];
            for (BubbleDataInternal *bd in selfInBlock.bubbleArray)
            {
                if ([bd.record.msgId isEqualToString:m.msgId])
                {
                    bdi = bd;
                }
            }
            
            if (bdi) {
                int index = (int)[selfInBlock.bubbleArray indexOfObject:bdi];

                selfInBlock.lastContentSizeHeight = selfInBlock.bubbleTable.contentSize.height;
                [selfInBlock reloadData];
                [selfInBlock.bubbleTable setContentOffset:CGPointMake(0.0, selfInBlock.bubbleTable.contentSize.height - selfInBlock.lastContentSizeHeight) animated:NO];
                [selfInBlock.bubbleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
            }
            else
            {
                [selfInBlock autoLoading];
            }
        }
        if (!selfInBlock.hasLastPage && ![_group isNewGroup]) {
            selfInBlock.bubbleTable.tableHeaderView = nil;
        }
        selfInBlock.isLoading = NO;
        
        
        
    }];
    
}


#pragma mark banner view delegate
- (void)chatBannerViewButtonDeletePressed
{
    if (self.mArrayNotifyRecords.count > 0)
    {
        [self.bubbleTable setContentOffset:self.bubbleTable.contentOffset animated:NO];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak __typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                       {
                           RecordDataModel *m = weakSelf.mArrayNotifyRecords[0];
                           [[XTDataBaseDao sharedDatabaseDaoInstance] updateNotifyRecordStatusWithMsgId:m.msgId groupId:m.groupId];
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              [weakSelf updateData];
                                              [weakSelf.bubbleTable reloadData];
                                              [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                                              [weakSelf updateBannerView];
                                              
                                          });
                       });
    }
    
    
    [self hideAtBannerView];
}

- (void)chatBannerViewButtonConfirmPressed
{
    if (self.mArrayNotifyRecords.count > 0)
    {
        RecordDataModel *m = self.mArrayNotifyRecords[0];
        [self scrollToMsgId:m.msgId completion:nil];
    }
}


- (void)dealloc
{
    _group.isNewGroup = NO;
    _noticeController.dataSource = nil;
    
    @try
    {
        for (UIButton *button in self.toolbarBtnsArray)
        {
            if(button.tag == 1000)
            {
                [button removeObserver:self forKeyPath:@"selected"];
            }
        }
        
        for (int i=0; i<self.menuarray.count; i++) {
            id obj = [self.toolbarMenuview viewWithTag:1001+i ];
            if (obj) {
                [obj removeObserver:self forKeyPath:@"selected"];
            }
        }
        
        [self.contentView removeObserver:self forKeyPath:@"frame"];
        
        [_group removeObserver:self forKeyPath:@"groupName"];
        [self.personimage removeObserver:self forKeyPath:@"frame"];
        
        
        
        
    }
    @catch (NSException * __unused exception)
    {
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"chatSearchFileClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"multiVoice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gotoNewMultiVoiceView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"msgReadUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageUnreadCount" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reLoadApplist" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDHasExitGroupNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AgoraCallViewAnswer" object:nil];
}
#pragma mark -
#pragma mark NJKScrollFullScreenDelegate
- (void)dismissSearchBar{
    [self scrollFullScreen:nil scrollViewDidScrollUp:0.f];
}
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    _isAnimation = NO;
    
    if ([animationID isEqualToString:@"display"]) {
        [self performSelector:@selector(dismissSearchBar) withObject:nil afterDelay:3.0];
    }
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //    NSLog(@"%f",scrollView.contentOffset.y);
//    if (scrollView.contentOffset.y < 1.f) {
        [self performSelector:@selector(dismissSearchBar) withObject:nil afterDelay:0.5];
//    }
}
- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollUp:(CGFloat)deltaY
{
    if (CGRectGetMinY(_topView.frame) >= 0.f && !_isAnimation && _searchViewController.mode == SearchModeUnActive) {
        _isAnimation = YES;
        
        [UIView beginAnimations:@"dismiss" context:NULL];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        
        _topView.frame = CGRectMake(0, -CGRectGetHeight(_topView.frame), CGRectGetWidth(_topView.frame), CGRectGetHeight(_topView.frame));
        //        _bubbleTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        [UIView commitAnimations];
        
    }
}

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollDown:(CGFloat)deltaY
{
    if(self.multiselecting)
        return;
    
    if (CGRectGetMinY(_topView.frame) < 0.f && !_isAnimation && _searchViewController.mode == SearchModeUnActive) {
        _isAnimation = YES;
        
        [UIView beginAnimations:@"display" context:NULL];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
//        _topView.frame = CGRectMake(0, 64, CGRectGetWidth(_topView.frame), CGRectGetHeight(_topView.frame));
        //        _bubbleTable.contentInset = UIEdgeInsetsMake(CGRectGetHeight(_topView.frame), 0, 0, 0);
        [UIView commitAnimations];
        
    }
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp:(NJKScrollFullScreen *)proxy
{
    NSLog(@"drag up");
    
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown:(NJKScrollFullScreen *)proxy
{
    NSLog(@"drag down");
}
#pragma mark - XTChatSearchViewControllerDelegate methods
- (BOOL)isTopViewAnimation{
    return _isAnimation;
}
- (void)chatSearchViewWillPresent{
    
    if (self.contentView.isFirstResponder) {
        [self.contentView resignFirstResponder];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)chatSearchViewWillDismiss{
    if (self.bSearchingMode)
    {
//        if([self.navigationController.viewControllers lastObject] == self)
//            [self.navigationController popViewControllerAnimated:YES];
//        return;
        
        [_topView removeFromSuperview];
        _topView.frame = CGRectZero;
        _topView = nil;
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (UIView *)chatSearchViewPresentInMainView{
    return _mainView;
}
- (void)chatMessageDeleted:(NSString *)messageId group:(NSString *)groupId{
    
    if ([groupId isEqualToString:_group.groupId]) {
        for (int i = 0; i< [_bubbleArray count]; i++) {
            
            BubbleDataInternal *model = [_bubbleArray objectAtIndex:i];
            if ([model.record.msgId isEqualToString:messageId]) {
                
                [_bubbleArray removeObjectAtIndex:i];
                [_bubbleTable reloadData];
                
                break;
            }
        }
    }
    
}

#pragma mark -
#pragma mark KDCommunityShareViewDelegate

-(void)shareViewDidSelectButtonAtIndex:(KDCommunityShareButtonIndex)buttonindex{
    _shouldChangeTextField = YES;
}

#pragma mark -
#pragma mark Guide View Method
-(BOOL)shouldShowGuideView{
    BOOL result = NO;
    if (self.ispublic) {
        result = ![[NSUserDefaults  standardUserDefaults]boolForKey:@"PublicFirstChar"];
        if ([self.group.participant count]>0) {
            if ([self.group allowInnerShare]) {
                result = NO;
            }
        }
    }
    else{
        result = ![[NSUserDefaults  standardUserDefaults]boolForKey:@"TaskForFirstChar"];
    }
    
    return result;
}
-(void)showGuideView{
    if (self.ispublic) {
        //        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"PublicFirstChar"];
        //        [[[KDWeiboAppDelegate getAppDelegate] window] addSubview:[self getPublicGuideView]];
    }
    else{
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"TaskForFirstChar"];
        [[[KDWeiboAppDelegate getAppDelegate] window] addSubview:[self getPrivateGuideView]];
        
    }
}

-(UIView * )getPublicGuideView{
    UIView * publicGuideView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    publicGuideView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7f);
    
    
    UIImageView * messageImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tips_img_public"]];
    [messageImage setFrame:CGRectMake(0, 100, messageImage.bounds.size.width, messageImage.bounds.size.height)];
    [publicGuideView addSubview:messageImage];
    
    UIButton * guideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [guideButton setImage:[UIImage imageNamed:@"tips_btn_ok"] forState:UIControlStateNormal];
    [guideButton setImage:[UIImage imageNamed:@"tips_btn_ok_press"] forState:UIControlStateHighlighted];
    [guideButton addTarget:self action:@selector(guideViewButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [guideButton sizeToFit];
    [guideButton setCenter:CGPointMake(self.view.bounds.size.width / 2,
                                       CGRectGetMaxY(messageImage.frame) + 30 + guideButton.bounds.size.height /2)];
    [publicGuideView addSubview:guideButton];
    
    
    // 处理3.5寸屏
    if (!isAboveiPhone5) {
        AddY(messageImage.frame, -60);
        AddY(guideButton.frame, -60);
    }
    
    return publicGuideView;
}

-(UIView * )getPrivateGuideView{
    
    UIView * privateGuideView = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        [[UIScreen mainScreen] bounds].size.width,
                                                                        [[UIScreen mainScreen] bounds].size.height)];
    privateGuideView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7f);
    UIImageView * messageImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"task_tips_image"]];
    [messageImage setFrame:CGRectMake(0, 100, messageImage.bounds.size.width, messageImage.bounds.size.height)];
    [privateGuideView addSubview:messageImage];
    
    UIButton * guideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [guideButton setImage:[UIImage imageNamed:@"tips_btn_ok"] forState:UIControlStateNormal];
    [guideButton setImage:[UIImage imageNamed:@"tips_btn_ok_press"] forState:UIControlStateHighlighted];
    [guideButton addTarget:self action:@selector(guideViewButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [guideButton sizeToFit];
    [guideButton setCenter:CGPointMake(self.view.bounds.size.width / 2,
                                       CGRectGetMaxY(messageImage.frame) + 70 + guideButton.bounds.size.height /2)];
    [privateGuideView addSubview:guideButton];
    
    return privateGuideView;
}

-(void)guideViewButtonTap:(UIButton * )sender{
    UIView * superView = [sender superview];
    [superView removeFromSuperview];
}

#pragma mark - emoji

- (void)sendEmojiFileWithExpressionCode:(NSString *)expressionCode expresstionType:(KDExpresstionType)type
{
    NSString *content = [NSString stringWithFormat:@"[%@]",expressionCode];
    
    //*******************************************************************************
    /**
     *  构造param对象
     */
    MessageParamDataModel *param = [[MessageParamDataModel alloc] init];
    
    param.type = MessageTypeFile;
    
    MessageFileDataModel *paramObject = [[MessageFileDataModel alloc]init];
    paramObject.file_id = [KDExpressionManager fileIdOfExpressionCode:expressionCode expresstionType:type];
    paramObject.name = [KDExpressionManager fileNameOfExpressionCode:expressionCode expresstionType:type];
    NSDate *date = [[NSDate alloc]init];
    paramObject.uploadDate = [NSString stringWithFormat:@"%.f",[date timeIntervalSince1970]];
    
    UIImage *theImage = [UIImage imageNamed:paramObject.name];
    float length = [UIImagePNGRepresentation(theImage) length];
    paramObject.size = [NSString stringWithFormat:@"%.2f",length];
    paramObject.ext = @"png";
    paramObject.emojiType = @"original";
    
    param.paramObject = paramObject;
    
    NSMutableDictionary *theDict = [[NSMutableDictionary alloc]init];
    [theDict setObject:paramObject.name forKey:@"name"];
    [theDict setObject:paramObject.ext forKey:@"ext"];
    [theDict setObject:paramObject.uploadDate forKey:@"uploadDate"];
    [theDict setObject:paramObject.size forKey:@"size"];
    [theDict setObject:paramObject.file_id forKey:@"file_id"];
    [theDict setObject:paramObject.emojiType forKey:@"emojiType"];
    
    param.paramString = [theDict JSONFragment];
    
    //*******************************************************************************
    
    
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:_group.groupId];
    [sendRecord setMsgType:MessageTypeFile];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setContent:content];
    [sendRecord setMsgLen:(int)content.length];
    [sendRecord setParam:param];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
    sendRecord.strEmojiType = @"original";
    [_recordsList addObject:sendRecord];
    
    [self sendWithRecord:sendRecord];
}

- (NSMutableArray *)photos {
    if (!_photos) {
        _photos = [NSMutableArray new];
    }
    return _photos;
}

- (NSMutableArray *)thumbs {
    if (!_thumbs) {
        _thumbs = [NSMutableArray new];
    }
    return _thumbs;
}

// 点击快捷发送图片
- (void)buttonPreviewPressed {
    if (self.mwbrowser) {
        self.mwbrowser = nil;
    }
    // Browser
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    
    startOnGrid = NO;
    displayNavArrows = NO;
    displaySelectionButtons = YES;
    displayActionButton = NO;
    enableGrid = NO;
    
    // Create browser
    self.mwbrowser.displayActionButton = displayActionButton;
    self.mwbrowser.displayNavArrows = displayNavArrows;
    self.mwbrowser.displaySelectionButtons = displaySelectionButtons;
    self.mwbrowser.alwaysShowControls = displaySelectionButtons;
    self.mwbrowser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    self.browser.wantsFullScreenLayout = YES;
#endif
    self.mwbrowser.enableGrid = enableGrid;
    self.mwbrowser.startOnGrid = startOnGrid;
    self.mwbrowser.enableSwipeToDismiss = YES;
    self.mwbrowser.bOriginal = self.bSendOriginal;
    [self.mwbrowser setCurrentPhotoIndex:0];
    self.mwbrowser.selections = @[@YES].mutableCopy;
    self.mwbrowser.bSinlgePhotoMode = YES;
    
    [self.navigationController pushViewController:self.mwbrowser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long) index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return self.mwbrowser.selections[index];
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)photoBrowserDidPressSendButton:(MWPhotoBrowser *)photoBrowser {
    if(self.photos.count < 1)
        return;
    self.isSendingImage = YES;
    MWPhoto *photo = self.photos[0];
    [self handleImage:[photo underlyingImage] savedPhotosAlbum:NO withLibUrl:photo.photoURL.absoluteString];
    [photoBrowser.navigationController popViewControllerAnimated:YES];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didChangeOriginalStates:(BOOL)bOrigial {
    self.bSendOriginal = bOrigial;
}

- (MWPhotoBrowser *)mwbrowser {
    if (!_mwbrowser) {
        _mwbrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    }
    return _mwbrowser;
}

-(void)setMultiselecting:(BOOL)multiselecting
{
    _multiselecting = multiselecting;
     __weak __typeof(self) weakSelf = self;
    if(self.multiselecting)
    {
        //多选模式
        [self.bubbleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BubbleDataInternal *dataInternal = obj;
            if(idx == weakSelf.selectMenuCellIndexPath.row)
                dataInternal.checkMode = 1;
            else
                dataInternal.checkMode = 0;
            
            dataInternal.muliteSelectMode = weakSelf.multiseSelctMode;
        }];
        
        //初始化菜单
        if(self.multiselectActionView == nil)
        {
            self.multiselectActionView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(self.view.frame)-CHART_VIEW_TOOL_BAR_HEIGHT, ScreenFullWidth, CHART_VIEW_TOOL_BAR_HEIGHT*2)];
            //self.multiselectActionView.image = [XTImageUtil chatToolBarBackgroundImage];
            self.multiselectActionView.backgroundColor = [UIColor kdBackgroundColor2];
            self.multiselectActionView.userInteractionEnabled = YES;
            [self.mainView addSubview: self.multiselectActionView];
            [self.mainView bringSubviewToFront:self.multiselectActionView];
            
            //确认按钮
            self.multiselectActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.multiselectActionBtn.frame = CGRectMake(0, 0, self.multiselectActionView.frame.size.width,CHART_VIEW_TOOL_BAR_HEIGHT);
            //self.multiselectActionBtn.center = CGPointMake(self.multiselectActionView.frame.size.width/2, self.multiselectActionView.frame.size.height/2);
            self.multiselectActionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [self.multiselectActionBtn setTitle:ASLocalizedString(@"XTChatViewController_Tip_26")forState:UIControlStateNormal];
            [self.multiselectActionBtn setTitleColor:FC1 forState:UIControlStateNormal];
            [self.multiselectActionBtn addTarget:self action:@selector(multiselectConfirm:) forControlEvents:UIControlEventTouchUpInside];
            [self.multiselectActionView addSubview:self.multiselectActionBtn];
            
            //分割线
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CHART_VIEW_TOOL_BAR_HEIGHT, self.multiselectActionView.frame.size.width, 1)];
            lineView.backgroundColor = [UIColor kdBackgroundColor1];
            [self.multiselectActionView addSubview:lineView];
            
            
            //合并转发按钮
            self.combinForwardActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.combinForwardActionBtn.frame = CGRectMake(0, CHART_VIEW_TOOL_BAR_HEIGHT, self.multiselectActionView.frame.size.width,CHART_VIEW_TOOL_BAR_HEIGHT);
            //self.combinForwardActionBtn.center = CGPointMake(self.multiselectActionView.frame.size.width/2, self.multiselectActionView.frame.size.height/2);
            self.combinForwardActionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [self.combinForwardActionBtn setTitle:ASLocalizedString(@"XTChatViewController_Tip_mulForward")forState:UIControlStateNormal];
            [self.combinForwardActionBtn setTitleColor:FC1 forState:UIControlStateNormal];
            [self.combinForwardActionBtn addTarget:self action:@selector(multiselectConfirm:) forControlEvents:UIControlEventTouchUpInside];
            [self.multiselectActionView addSubview:self.combinForwardActionBtn];

            
            self.cancelMultiselectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.cancelMultiselectBtn.frame = CGRectMake(0, 0, 40,self.multiselectActionView.frame.size.height);
            [self.cancelMultiselectBtn setTitle:ASLocalizedString(@"Global_Cancel")forState:UIControlStateNormal];
            [self.cancelMultiselectBtn sizeToFit];
            [self.cancelMultiselectBtn setTitleColor:FC5 forState:UIControlStateNormal];
            [self.cancelMultiselectBtn addTarget:self action:@selector(cancelMultiselect:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        //取消多选按钮
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelMultiselectBtn];
        self.navigationItem.leftBarButtonItems = [NSArray
                                                  arrayWithObjects:leftBarButtonItem, nil];
        
        
        NSMutableArray *array = [self getMultiselectArray];
        if(self.multiseSelctMode == 0)
            [self.multiselectActionBtn setTitle:[NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_27"),(unsigned long)array.count] forState:UIControlStateNormal];
        else
            [self.multiselectActionBtn setTitle:ASLocalizedString(@"XTChatViewController_Tip_28") forState:UIControlStateNormal];
        
        //多选模式下不允许操作,隐藏菜单
        self.multiselectActionView.hidden = NO;
        //        self.multiVoiceWindow.hidden = YES;
        self.navigationItem.rightBarButtonItem =nil;
        [self hideInputBoard];
        _topView.frame = CGRectMake(0, -CGRectGetHeight(_topView.frame), CGRectGetWidth(_topView.frame), CGRectGetHeight(_topView.frame));
        
        NSArray *cellArray = [self.bubbleTable visibleCells];
        [cellArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BubbleTableViewCell *cell = obj;
            [cell showCellMultiSelectAnimate];
        }];
        //[self.bubbleTable reloadData];
    }
    else
    {
        //非多选模式
        [self.bubbleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BubbleDataInternal *dataInternal = obj;
            dataInternal.checkMode = -1;
            dataInternal.muliteSelectMode = -1;
        }];
        
        //恢复返回按钮
        [self setupLeftNavigationItem];
        
        //非多选模式下恢复操作，显示菜单
        self.multiselectActionView.hidden = YES;
        [self multiVoiceDidReceived:nil];
        [self setupRightNavigationItem];
        
        NSArray *cellArray = [self.bubbleTable visibleCells];
        [cellArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BubbleTableViewCell *cell = obj;
            [cell hideCellMultiSelectAnimate];
        }];
        
        
        //每次关闭都恢复初始化位置
        CGRect multiselectActionViewFrame = self.multiselectActionView.frame;
        multiselectActionViewFrame.origin.y = CGRectGetHeight(self.view.frame) - self.multiselectActionView.frame.size.height/2;
        self.multiselectActionView.frame = multiselectActionViewFrame;
        
        CGRect bubbleFrame = self.bubbleTable.frame;
        bubbleFrame.size.height = CGRectGetMinY(multiselectActionViewFrame);
        self.bubbleTable.frame = bubbleFrame;
        
        
        //[self.bubbleTable reloadData];
    }
}

-(void)cancelMultiselect:(UIButton *)btn
{
    self.multiselecting = NO;
}

-(void)multiselectConfirm:(UIButton *)btn
{
    __weak XTChatViewController *selfInBlock = self;
    if(self.multiseSelctMode == 0)
    {
        //删除
        self.multiselectArray = [self getMultiselectArray];
        //        [self.multiselectArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //            [selfInBlock deleteMsg:obj];
        //        }];
        if(self.multiselectArray.count == 0)
            return;
        [self deleteMsgArray:self.multiselectArray];
        self.multiselectArray = nil;
        self.multiselecting = NO;
    }
    else if(self.multiseSelctMode == 1)
        [self startMultiForward:btn];
}



//获得多选数组
-(NSMutableArray *)getMultiselectArray
{
    NSMutableArray  *tempArray = [[NSMutableArray alloc] init];
    [self.bubbleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BubbleDataInternal *data = obj;
        if(data.checkMode == 1)
            [tempArray addObject:obj];
    }];
    return tempArray;
}



- (void)bubbleDidCheckInMultiSelect:(BubbleImageView *)bubbleImageView cell:(BubbleTableViewCell *)cell isCheck:(BOOL)isCheck
{
    NSMutableArray *array = [self getMultiselectArray];
    if(self.multiseSelctMode == 0)
    {
        [self.multiselectActionBtn setTitle:[NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_27"),(unsigned long)array.count] forState:UIControlStateNormal];
    }
    else if(self.multiseSelctMode == 1)
    {
        //图片未下载
        if(cell.dataInternal.record.msgType == MessageTypePicture)
        {
            NSURL * thumbnailUrl = [cell.dataInternal.record thumbnailPictureUrl];
            NSURL * originalUrl = [cell.dataInternal.record canTransmitUrl];
            BOOL isThumbnailExists = [[SDWebImageManager sharedManager] diskImageExistsForURL:thumbnailUrl];
            BOOL isOriginalExists = (originalUrl!=nil);
            if(!isThumbnailExists && !isOriginalExists && ((MessageShareTextOrImageDataModel *)cell.dataInternal.record.param.paramObject).fileId.length==0)
            { 
                //还原选中状态
                cell.dataInternal.checkMode = 0;
                NSIndexPath *index = [self.bubbleTable indexPathForCell:cell];
                if(index)
                    [self.bubbleTable reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
                array = [self getMultiselectArray];
                [self.multiselectActionBtn setTitle:ASLocalizedString(@"XTChatViewController_Tip_28") forState:UIControlStateNormal];
        
                //提示不能选择
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"XTChatViewController_Tip_30")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                [alertView show];
                
                return;
            }
        }
        
        
        
        if(isCheck && array.count > 9)
        {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"XTChatViewController_Tip_31")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
            [alertView show];
            
            cell.dataInternal.checkMode = 0;
            NSIndexPath *index = [self.bubbleTable indexPathForCell:cell];
            if(index)
                [self.bubbleTable reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            
            array = [self getMultiselectArray];
        }
        
        
        
        
        
        __weak XTChatViewController *weakSelf = self;
        //调整布局
        CGRect multiselectViewFrame = self.multiselectActionView.frame;
        if(array.count > 1)//暂时屏蔽合并转发
        {
            multiselectViewFrame.origin.y = CGRectGetHeight(self.view.frame) - multiselectViewFrame.size.height;
            [self.multiselectActionBtn setTitle:[NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_oneByOneFoward"),(unsigned long)array.count] forState:UIControlStateNormal];
        }
        else
        {
            multiselectViewFrame.origin.y = CGRectGetHeight(self.view.frame) - multiselectViewFrame.size.height/2;
            [self.multiselectActionBtn setTitle:[NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_28"),(unsigned long)array.count] forState:UIControlStateNormal];
        }
        
        [self.combinForwardActionBtn setTitle:[NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_mulForward"),(unsigned long)array.count] forState:UIControlStateNormal];
        
        CGRect bubbleFrame = self.bubbleTable.frame;
        bubbleFrame.size.height = CGRectGetMinY(multiselectViewFrame);
        
        
        if(bubbleFrame.size.height != weakSelf.bubbleTable.frame.size.height)
        {
            [UIView animateWithDuration:0.5
                                  delay:0
                 usingSpringWithDamping:500.0f
                  initialSpringVelocity:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^(){
                                 {
                                     weakSelf.multiselectActionView.frame = multiselectViewFrame;
                                     weakSelf.bubbleTable.frame = bubbleFrame;
                                 }
                             }
                             completion:nil];
        }
    }
}
- (void)queryGroupInfoClientDidReceive3:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success && result.data)
    {
        GroupDataModel *groupDataModel = [[GroupDataModel alloc] initWithDictionary:result.data];
        self.group = groupDataModel;
        if(groupDataModel)
        {
            GroupListDataModel *groupListDataModel = [[GroupListDataModel alloc] init];
            groupListDataModel.list = [[NSMutableArray alloc] initWithObjects:groupDataModel, nil];
            if (groupDataModel.dissolveDate.length == 0) {
                [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDataModel];
            }
            
            if(groupDataModel && groupDataModel.mCallStatus == 1)
            {
                KDMultiVoiceViewController *multiVoceController = [[KDMultiVoiceViewController alloc] init];
                multiVoceController.groupDataModel = groupDataModel;
                
                multiVoceController.desController = self;
                
                multiVoceController.isJoinToChannel = YES;
                UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:multiVoceController];
                [self presentViewController:navi animated:YES completion:nil];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"XTChatViewController_Tip_32")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                [alert show];
            }
        }
    }
    
}

#pragma mark - 【装饰物】语音会议横幅 -

//电话会议提示
- (KDMultipartyCallBannerView *)multipartyCallBannerView
{
    if (!_multipartyCallBannerView)
    {
        _multipartyCallBannerView = [[KDMultipartyCallBannerView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, 35)];
        _multipartyCallBannerView.labelTitle.text = ASLocalizedString(@"XTChatViewController_Tip_33");
        __weak __typeof(self) weakSelf = self;
        _multipartyCallBannerView.blockButtonConfirmPressed = ^()
        {
            [KDEventAnalysis event:event_Voicon_join];
            [weakSelf goToMultiVoiceFromBannerView];
        };
        _multipartyCallBannerView.hidden = YES;
    }
    [self setMultiPartyCallBannerViewTitle];
    return _multipartyCallBannerView;
}


- (void)setMultiPartyCallBannerViewTitle
{
    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    PersonSimpleDataModel *person;
    NSString *bosPersonId = [BOSConfig sharedConfig].user.userId;
    if(agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel&& agoraSDKManager.currentGroupDataModel.groupId && [agoraSDKManager.currentGroupDataModel.groupId isEqualToString:self.group.groupId])
    {
        if(agoraSDKManager.currentGroupDataModel.mCallCreator && agoraSDKManager.currentGroupDataModel.mCallCreator)
        {
            if(!(bosPersonId && [bosPersonId isEqualToString:agoraSDKManager.currentGroupDataModel.mCallCreator]))
            {
                person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:agoraSDKManager.currentGroupDataModel.mCallCreator];
            }
        }
    }else{
        //        if(self.group.mCallStatus == 1)
        //        {
        if(self.group.mCallCreator)
        {
            if(!(bosPersonId && [bosPersonId isEqualToString:self.group.mCallCreator]))
            {
                person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:self.group.mCallCreator];
            }
            //            }
        }
    }
    if(person)
    {
        _multipartyCallBannerView.labelTitle.text =[NSString stringWithFormat:ASLocalizedString(@"%@发起的语音会议正在进行中"),person.personName];
    }else{
        _multipartyCallBannerView.labelTitle.text =[NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_33")];
    }
    
    if(!agoraSDKManager.isUserLogin || !agoraSDKManager.currentGroupDataModel)
    {
        if(person)
        {
            _multipartyCallBannerView.labelTitle.text =[NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_35"),person.personName];
        }else{
            _multipartyCallBannerView.labelTitle.text =[NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_36")];
        }
    }
}


- (void)showMultiBannerView
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (weakSelf.bSearchingMode)
        {
            return;
        }
        
        if([weakSelf.group chatAvailable])
        {
            if(weakSelf.multipartyCallBannerView.hidden == YES)
            {
                weakSelf.multipartyCallBannerView.hidden = NO;
            }
            [weakSelf setMultiPartyCallBannerViewTitle];
            //            KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
            //            if(agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel && [agoraSDKManager.currentGroupDataModel.groupId isEqualToString:self.group.groupId])
            //            {
            //                _multipartyCallBannerView.labelTitle.text = ASLocalizedString(@"语音会议正在进行中...");
            //            } else {
            //                _multipartyCallBannerView.labelTitle.text = ASLocalizedString(@"你有一个会议待加入");
            //            }
        }else{
            weakSelf.multipartyCallBannerView.hidden = YES;
        }
        
        if (!weakSelf.bannerView.hidden && !weakSelf.multipartyCallBannerView.hidden)
        {
            SetY(weakSelf.bannerView.frame, MaxY(weakSelf.multipartyCallBannerView.frame));
        }
    });
}

- (void)hideMultiBannerView
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(weakSelf.multipartyCallBannerView.hidden == NO)
        {
            weakSelf.multipartyCallBannerView.hidden = YES;
            if (!weakSelf.bannerView.hidden)
            {
                SetY(weakSelf.bannerView.frame, kd_StatusBarAndNaviHeight);
            }
        }
    });
}
- (void)goToMultiVoiceFromBannerView
{
    if(!([[KDApplicationQueryAppsHelper shareHelper]getGroupTalkStatus]  && [self.group chatAvailable]))
    {
        return;
    }
    
    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    BOOL hasCallIng = agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel;
    BOOL isSameGroup = NO;
    if(hasCallIng && [self.group.groupId isEqualToString:agoraSDKManager.currentGroupDataModel.groupId])
    {
        isSameGroup = YES;
    }
    
    if(hasCallIng && !isSameGroup)
    {//不同的已存在的会议
        [[KDAgoraSDKManager sharedAgoraSDKManager] showAlreadyHaveMultiVoiceAlertWithGroup:self.group controller:self];
    }else if(hasCallIng && isSameGroup)
    {//同一会议
        KDMultiVoiceViewController *multiVoceController = [[KDMultiVoiceViewController alloc] init];
        multiVoceController.groupDataModel = self.group;
        multiVoceController.desController = self;
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:multiVoceController];
        [self presentViewController:navi animated:YES completion:nil];
    }else{
        //        KDMultiVoiceViewController *multiVoceController = [[KDMultiVoiceViewController alloc] init];
        //        multiVoceController.groupDataModel = self.group;
        //        multiVoceController.desController = self;
        //        //判断当前组是否已开始多人会话
        //        if(self.group.mCallStatus == 1)
        //        {
        //已开通会议  则直接加入会议 二次校验
        if(!self.queryGroupInfoClient)
        {
            self.queryGroupInfoClient = [[ContactClient alloc] initWithTarget:self action:@selector(queryGroupInfoClientDidReceive3:result:)];
        }
        [self.queryGroupInfoClient queryGroupInfoWithGroupId:self.group.groupId];
        return;
        
        
        //        }else{
        //            //开启一个会议
        //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"发起人已关闭语音会议")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        //            [alert show];
        //            [self hideMultiBannerView];
        //            return;
        //        }
        //        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:multiVoceController];
        //        [self presentViewController:navi animated:YES completion:nil];
    }
    
}
- (void)cancelHud
{
    if (self.recordingHud)
    {
        [self.recordingHud removeFromSuperview];
        self.recordingHud = nil;
    }
}

- (void)agoraStopMyCallNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if(userInfo)
    {
        NSString *groupId = [userInfo objectForKey:@"groupId"];
        
        if ([[KDApplicationQueryAppsHelper shareHelper]getGroupTalkStatus])
        {
            if ([self.group chatAvailable])
            {
                KDAgoraSDKManager *agoraManager = [KDAgoraSDKManager sharedAgoraSDKManager];
                if(groupId && [groupId isEqualToString:self.group.groupId])
                {
                    self.group.mCallStatus = 0;
                    //                        if(!(agoraManager.isUserLogin && agoraManager.currentGroupDataModel))
                    //                        {
                    [self hideMultiBannerView];
                    //                        }else{
                    //                            [self showMultiBannerView];
                    //                        }
                }else if(!groupId)
                {
                    id status = [userInfo objectForKey:@"status"];
                    if(status && [status integerValue] == 1)
                    {
                        self.group.mCallStatus = status;
                        [self showMultiBannerView];
                    }
                }
                else if(self.group.mCallStatus || !(agoraManager.isUserLogin && agoraManager.currentGroupDataModel))
                {
                    [self hideMultiBannerView];
                }else{
                    //                        [self showMultiBannerView];
                }
            }
        }
    }
}

- (void)groupListChangedFunction
{
    if([[KDApplicationQueryAppsHelper shareHelper]getGroupTalkStatus])
    {
        //当有会话时
        KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
        if(agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel && [agoraSDKManager.currentGroupDataModel.groupId isEqualToString:self.group.groupId])
        {
            if([self.group chatAvailable])
            {
                if(self.group.mCallStatus == 0)
                {
                    //会议已关闭
                    if(agoraSDKManager.agoraPersonsChangeBlock)
                    {
                         agoraSDKManager.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_needExitChannel,nil,nil,nil);
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"KDAgoraSDKManager_Tip_5")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                    [alert show];
                    [agoraSDKManager leaveChannelSimple];
                    agoraSDKManager.isUserLogin = NO;
                    [self hideMultiBannerView];
                    
                }else
                {
                    [self showMultiBannerView];
                }
            }else{
                [self hideMultiBannerView];
                KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
                
                if(agoraSDKManager.agoraPersonsChangeBlock)
                {
                     agoraSDKManager.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_needExitChannel,nil,nil,nil);
                }
                [agoraSDKManager leaveChannel];
                [agoraSDKManager agoraLogout];
            }
        }else if([self.group chatAvailable] && self.group.mCallStatus == 1)
        {
            [self showMultiBannerView];
        }else{
            [self hideMultiBannerView];
        }
    }
}


-(void)msgReadUpdate:(NSNotification *)sender
{
    [self reloadTable:(int)self.bubbleArray.count];
}

- (void)messageUnreadCount:(NSNotification *)sender
{
    NSDictionary *dic = sender.userInfo;
    NSNumber *unreadCount = dic[@"unreadUserCount"];
    
    if ([unreadCount integerValue] == 0)
    {
        //闪一下的动画
        [self reloadTable:(int)self.bubbleArray.count];
        
        self.progressHud.labelText = ASLocalizedString(@"XTChatViewController_Tip_38");
        self.progressHud.mode = MBProgressHUDModeText;
        self.progressHud.margin = 10;
        [self.progressHud show:YES];
        [self.progressHud hide:YES afterDelay:1];
        
        return;
    }
    
    if ([unreadCount integerValue] == -1)
    {
        //直接去掉数据库中得内容
        NSString *msgId = dic[@"msgId"];
        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteMsgUnreadStateWithMsgId:msgId];
        [self reloadTable:(int)self.bubbleArray.count];
        return;
    }
    
    if ([unreadCount integerValue] > 0)
    {
        //弹出控制界面
        NSString *msgId  = dic[@"msgId"];
        NSString *groupId = dic[@"groupId"];
        NSArray *readArray = dic[@"readUsers"];
        NSArray *unreadArray = dic[@"unreadUsers"];
        XTChatUnreadCollectionView *con = [[XTChatUnreadCollectionView alloc]init];
        [con setGroupId:groupId];
        [con setMsgId:msgId];
        con.group = self.group;
        [con setReadArray:readArray UnreadArray:unreadArray];
        [self.navigationController pushViewController:con animated:YES];
        return;
    }
}



#pragma mark - 【装饰物】未读消息提醒 -

- (void)showUnreadMessageButton
{
    if (self.iUnreadMessageCount >= 10) {
        self.buttonUnreadMessage.hidden = NO;
        NSString *str = nil;
        if (self.iUnreadMessageCount > 99) {
            str  = ASLocalizedString(@"XTChatViewController_Tip_39");
        } else {
            str = [NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_40"), self.iUnreadMessageCount];
        }
        UILabel *label = (UILabel *)[self.buttonUnreadMessage viewWithTag:999];
        label.text = str;
        SetWidth(label.frame, [label.text sizeWithFont:label.font].width);
        SetWidth(self.buttonUnreadMessage.frame, [str sizeWithFont:label.font].width+12+9+8+12);
        SetX(self.buttonUnreadMessage.frame, ScreenFullWidth-Width(self.buttonUnreadMessage.frame));
    }
}

- (void)hideUnreadMessageButton
{
    self.buttonUnreadMessage.hidden = YES;
    self.iUnreadMessageCount = 0;
}

- (UIButton *)buttonUnreadMessage
{
    if (!_buttonUnreadMessage)
    {
        _buttonUnreadMessage = [UIButton new];
        _buttonUnreadMessage.backgroundColor = [UIColor clearColor];
        //        [_buttonUnreadMessage.titleLabel setFont:FS6];
        //        [_buttonUnreadMessage setTitleColor:FC5 forState:UIControlStateNormal];
        [_buttonUnreadMessage addTarget:self action:@selector(buttonNewMessagePressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonUnreadMessage setBackgroundImage:[[UIImage imageNamed:@"message_bg_display"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)] forState:UIControlStateNormal];
        [_buttonUnreadMessage setBackgroundImage:[[UIImage imageNamed:@"message_bg_display_press"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)] forState:UIControlStateHighlighted];


        //        [_buttonUnreadMessage setImage:[UIImage imageNamed:@"message_tip_newmsg"] forState:UIControlStateNormal];

        _buttonUnreadMessage.hidden = YES;
        //        [_buttonUnreadMessage setTitle: forState:UIControlStateNormal];
        _buttonUnreadMessage.frame = CGRectMake(ScreenFullWidth - 102, 150, 102, 35);

        //        _buttonUnreadMessage.imageView.contentMode = UIViewContentModeScaleAspectFit;
        //        [_buttonUnreadMessage setImageEdgeInsets:UIEdgeInsetsMake(7, -6, 7, 0)];
        _buttonUnreadMessage.alpha = .95;

        //        [_buttonUnreadMessage setContentEdgeInsets:UIEdgeInsetsMake(0, 17, 0, 0)];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, (35-9)/2.0, 9, 9)];
        imageView.image = [UIImage imageNamed:@"message_tip_newmsg"];
        imageView.userInteractionEnabled = NO;
        [_buttonUnreadMessage addSubview:imageView];

        UILabel *labelTitle = [UILabel new];
        labelTitle.frame = CGRectMake(MaxX(imageView.frame)+8, 0, Width(_buttonUnreadMessage.frame)-12-Width(imageView.frame)-8-12, 35);
        labelTitle.tag = 999;
        labelTitle.font = FS6;
        labelTitle.textColor = FC5;
        labelTitle.textAlignment = NSTextAlignmentLeft;
        [_buttonUnreadMessage addSubview:labelTitle];
    }
    return _buttonUnreadMessage;
}
//
- (void)buttonNewMessagePressed:(UIButton *)button
{
    if (self.strFirstUnreadMessageMsgId.length > 0)
    {
        __weak __typeof(self) weakSelf = self;

//        [self kd_showLoading];
//        [self scrollToMsgId:self.strFirstUnreadMessageMsgId ScrollType:BubbleTableScrollNewMessagePressed];
//
        if (!self.bLoadingLock) {
            [self kd_showLoading];
            self.bLoadingLock = YES;
            [self scrollToMsgId:self.strFirstUnreadMessageMsgId completion:^{
                [weakSelf kd_hideLoading];
                weakSelf.bLoadingLock = NO;
            }];
        }

    }
    [self hideUnreadMessageButton];
}
//
//
//显示[消息收取中]
- (void)showNoticeView
{
    _issending = YES;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.7
                     animations: ^{
                         noticeview.alpha = 0.8;
                         noticeview.frame = CGRectMake((ScreenFullWidth-100)/2.0, ScreenFullHeight - 160 + Adjust_Offset_Xcode5, 120, 40);
                     }
                     completion:^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                             [weakSelf hideNoticeView];
                         });
                     }];
}

//隐藏[消息收取中]
- (void)hideNoticeView
{
    _issending = NO;
    
    if (noticeview.alpha == 0) {
        return;
    }
    [UIView animateWithDuration:0.7
                     animations:^
     {
         noticeview.alpha = 0;
         noticeview.frame = CGRectMake((ScreenFullWidth - 100)/2, ScreenFullHeight, 120, 40);
     }];
}


#pragma mark - 网络连接断开
- (KDNetworkDisconnectView *)networkDisconnectView{
    if (!_networkDisconnectView) {
        _networkDisconnectView = [[KDNetworkDisconnectView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 35)];
        _networkDisconnectView.hidden = YES;
    }
    return _networkDisconnectView;
}

- (void)showNetworkDisconnetView{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.bSearchingMode)return;
        if([weakSelf.group chatAvailable]){
            if(weakSelf.networkDisconnectView.hidden == YES){
                weakSelf.networkDisconnectView.hidden = NO;
            }
        }else{
            weakSelf.networkDisconnectView.hidden = YES;
        }
        if (!weakSelf.bannerView.hidden && !weakSelf.networkDisconnectView.hidden){
            SetY(weakSelf.bannerView.frame, MaxY(weakSelf.networkDisconnectView.frame));
        }
    });
}

- (void)hideNetworkDisconnetView{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf.networkDisconnectView.hidden == NO){
            weakSelf.networkDisconnectView.hidden = YES;
            if (!weakSelf.bannerView.hidden){
                SetY(weakSelf.bannerView.frame, kd_StatusBarAndNaviHeight);
            }
        }
    });
}

- (void)setNetworkConnectStatus:(NSNotification *)info{
    if ([info.userInfo[KDReachabilityStatusKey] intValue] > 0) {
        [self hideNetworkDisconnetView];
    }else{
        [self showNetworkDisconnetView];
    }
}
- (void)resetScrollPositionWithBlock:(void(^)())block{
    self.lastContentSizeHeight = self.bubbleTable.contentSize.height;
    if (block) {
        block();
    }
    double height = self.bubbleTable.contentSize.height - self.lastContentSizeHeight;
    if(height < kd_StatusBarAndNaviHeight) {
        height = -kd_StatusBarAndNaviHeight;
    }
    [self.bubbleTable setContentOffset:CGPointMake(0.0,height) animated:NO];
}
// 下拉 消息菊花
- (void)stopLoading{
    [self.lastPageIndicatorView stopAnimating];
}

// 上拉 消息菊花
- (void)startLoadingNextPage{
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        weakSelf.bubbleTable.tableFooterView = weakSelf.pullUpLabel;
        [weakSelf.nextPageIndicatorView startAnimating];
    });
}

- (void)stopLoadingNextPage{
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        weakSelf.bubbleTable.tableFooterView = nil;
        [weakSelf.nextPageIndicatorView stopAnimating];
    });
}

- (NSString *)userId{
    NSString *personId = nil;
    if ([self.group.participant count] > 0)
    {
        PersonSimpleDataModel *person = [self.group.participant firstObject];
        personId = person.personId;
    }
    return personId;
}

- (BOOL)isInMemoryMsgId:(NSString *)msgId{
    if (msgId.length == 0) {
        return NO;
    }
    
    for (RecordDataModel *model in self.recordsList) {
        if ([msgId isEqualToString:model.msgId]) {
            return YES;
        }
    }
    
    return NO;
}


- (NSMutableArray *)successRecordsList{
    NSMutableArray *mArray = [NSMutableArray new];
    for (RecordDataModel *model in self.recordsList) {
        if (model.msgRequestState == MessageRequestStateSuccess) {
            [mArray addObject:model];
        }
    }
    if (mArray.count > 0) {
        [mArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sendTime" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"msgId" ascending:NO]]];
    }
    return mArray;
}

- (NSString *)oldestMsgId{
    RecordDataModel *model = [self successRecordsList].firstObject;
    return model.msgId;
}

- (NSString *)oldestMsgSendTime{
    RecordDataModel *model = [self successRecordsList].firstObject;
    return model.sendTime;
}

- (NSString *)latestMsgSendTime
{
    NSMutableArray *recordList = [self successRecordsList];
    NSString *latestMsgId = [self latestMsgId];
    if(latestMsgId.length == 0)
        return @"";
    
    for(NSInteger i = recordList.count - 1;i>=0;i--)
    {
        RecordDataModel *model = recordList[i];
        if([model.msgId isEqualToString:latestMsgId])
        {
            return model.sendTime;
        }
    }
    return @"";
}

- (NSString *)latestMsgId{
    //数据库旧的字段，拿来存latestMsgId
    //预防存有旧数据upateTime,时间长度小于20
    if(self.group.updateTime.length<20)
        return @"";
    
    return self.group.updateTime;
}

- (void)reloadCurrentData
{
    NSString *msgId = ((RecordDataModel *)[self.recordsList firstObject]).msgId;
    if (msgId.length == 0) {
        return;
    }
    NSInteger count = [self.recordsList count];
    
    [self.recordsList removeAllObjects];
    
    CGPoint contentOffset = self.bubbleTable.contentOffset;
    
    __weak __typeof(self) weakSelf = self;
    [self getOnePageFromDBWithMsgId:msgId
                 recordCountPerPage:(int)count
                          direction:MessagePagingDirectionCurrent
                         completion:^(NSArray *records) {
                             [weakSelf reloadData];
                             if (weakSelf.bubbleTable.contentOffset.y > weakSelf.bubbleTable.contentSize.height - weakSelf.bubbleTable.bounds.size.height - 300) {
                                 [weakSelf scrollToBottomAnimated:NO];
                             } else {
                                 [weakSelf.bubbleTable setContentOffset:contentOffset animated:NO];
                             }
                         }];
}
- (void)scrollToBottomAnimated:(BOOL)bAnimated
{
//    [self.bubbleTable scrollRectToVisible:CGRectMake(0, self.bubbleTable.contentSize.height - self.bubbleTable.bounds.size.height, self.bubbleTable.bounds.size.width, self.bubbleTable.bounds.size.height) animated:bAnimated];
    
//    [self.bubbleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.bubbleArray.count -1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:bAnimated];
    
    if (kd_safeArray(self.bubbleArray).count > 0) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:[self.bubbleArray count] - 1 inSection:0];
        [self.bubbleTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:bAnimated];
    } else {
        [self.bubbleTable scrollRectToVisible:CGRectMake(0, self.bubbleTable.contentSize.height - self.bubbleTable.bounds.size.height, self.bubbleTable.bounds.size.width, self.bubbleTable.bounds.size.height) animated:bAnimated];
    }
}
// 是否是公共号发言人
- (BOOL)isPublicGroupSpeaker{
    PersonSimpleDataModel *person = [self.group.participant firstObject];
    if ([person isPublicAccount]) {
        KDPublicAccountDataModel *pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:person.personId];
        if (pubacc.manager )
        {
                return YES;
        }
        else
        {
            return NO;
        }
    }
     return NO;
}

#pragma mark 消息拉取接口
- (ContactClient *)msgListClient
{
    if (!_msgListClient) {
        _msgListClient = [[ContactClient alloc]initWithTarget:self action:@selector(msgListClientDidReceived:result:)];
    }
    return _msgListClient;
}

- (void)getMsgListClientWithGroupId:(NSString *)groupId
                             userId:(NSString *)userId
                              msgId:(NSString *)msgId
                               type:(NSString *)type
                              count:(NSString *)count
                         completion:(void (^)(BOOL succ, NSDictionary *dictData))completion
{
    self.blockMsgListClient = completion;
    
    if (self.chatMode == ChatPublicMode) {
        [self.msgListClient getPublicSpeakerMsgListWithGroupId:groupId
                                                        userId:userId
                                                         msgId:msgId
                                                          type:type
                                                         count:count
                                                      publicId:self.chatMode == ChatPrivateMode ? nil : self.pubAccount.publicId];
    } else {
        [self.msgListClient getMsgListWithGroupId:groupId
                                           userId:userId
                                            msgId:msgId
                                             type:type
                                            count:count];
    }
}


- (void)msgListClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (!result.success && result.errorCode == 1007) {
        [[KDNotificationChannelCenter defaultCenter] logout:result.error data:result.data];
        return;
    }
    if (!client.hasError && [result isKindOfClass:[BOSResultDataModel class]] && result.success && result.data) {
        if (self.blockMsgListClient) {
            self.blockMsgListClient(YES, result.data);
        }
    } else {
        if (self.blockMsgListClient) {
            self.blockMsgListClient(NO, nil);
        }
    }
}

// 显示前内存做一次排序
- (void)sortRecordsList
{
    [self.recordsList sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sendTime" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"msgId" ascending:NO]]];
}
- (NSMutableArray *)mArrayRecordsFromMsgList
{
    if (!_mArrayRecordsFromMsgList) {
        _mArrayRecordsFromMsgList = [NSMutableArray new];
    }
    return _mArrayRecordsFromMsgList;
}
- (NSMutableArray *)mArrayRecordsFromMsgListRaw
{
    if (!_mArrayRecordsFromMsgListRaw) {
        _mArrayRecordsFromMsgListRaw = [NSMutableArray new];
    }
    return _mArrayRecordsFromMsgListRaw;
}
#pragma mark 数据库分页拉取

// 分页加载
- (void)getOnePageFromDBWithMsgId:(NSString *)msgId
               recordCountPerPage:(int)recordCountPerPage
                        direction:(MessagePagingDirection)direction
                       completion:(void(^)(NSArray *records))completionBlock
{
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSArray *records = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecordWithGroupId:weakSelf.group.groupId
                                                                                    toUserId:[weakSelf userId]
                                                                                    publicId:weakSelf.chatMode == ChatPrivateMode ? nil : weakSelf.pubAccount.publicId
                                                                                       count:recordCountPerPage
                                                                                       msgId:msgId
                                                                                   direction:direction];
        dispatch_async(dispatch_get_main_queue(), ^ {
            for (int i = 0; i < [records count]; i++) {
                if (![weakSelf.recordsList containsObject:records[i]]) {
                    [weakSelf.recordsList insertObject:[records objectAtIndex:i] atIndex:0];
                } else {
                    NSInteger index = [weakSelf.recordsList indexOfObject:records[i]];
                    [weakSelf.recordsList replaceObjectAtIndex:index withObject:records[i]];
                }
            }
            // 内存排序, 因为现在可能是双向的拉取
            [weakSelf sortRecordsList];
            completionBlock(records);
        });
    });
}
#pragma mark -
#pragma mark 网络拉取核心方法[1]: 逐页拉取 (通用)

/**
 *  拉取核心方法[1]: 逐页拉取 (通用)
 *  1. MessagePagingDirectionOld 从本地最旧一条消息从服务器往更旧的方向取一页消息
 *  2. MessagePagingDirectionNew 从本地最新一条消息从服务器往更新的方向取一页消息, 如果msgId为空, 则取最新的一页.
 *
 *  @param direction      方向
 *  @param recursiveBlock 内部递归使用, 在setupRecursiveBlocks后, 添加blockRecursiveGetMoreMessagesNew或blockRecursiveGetMoreMessagesOld
 *  @param completion     最终完成回调
 */
- (void)fetchMessageOnePageWithDirection:(MessagePagingDirection)direction
                      recordCountPerPage:(int)recordCountPerPage
                          recursiveBlock:(void (^)(BOOL succ, BOOL more, void (^completion)()))recursiveBlock
                              completion:(void (^)())completion{
    
    __weak __typeof(self) weakSelf = self;
    NSString *strMsgId = nil;
    NSString *strType = nil;
    switch (direction) {
        case MessagePagingDirectionOld: {
            strMsgId = self.oldestMsgId;
            strType = @"old";
        }
            break;
        case MessagePagingDirectionNew: {
            strMsgId = self.latestMsgId;
            strType = @"new";
        }
            break;
        default:
            break;
    }
    // 偶发的防御已读未读msgid为nil产生全量刷新，但产生首次进入发信息被return掉的问题
    //    if (strMsgId.length == 0 && !self.bFirstFetch) {
    //        [weakSelf stopLoadingNextPage];
    //        return;
    //    }
    [weakSelf getMsgListClientWithGroupId:weakSelf.group.groupId
                                   userId:[weakSelf userId]
                                    msgId:strMsgId
                                     type:strType
                                    count:[NSString stringWithFormat:@"%d",recordCountPerPage]
                               completion:^(BOOL succ, NSDictionary *dictData) {
                                   [weakSelf stopLoadingNextPage];
                                   [weakSelf stopLoading];
                                   if (succ) {
                                       RecordListDataModel *records = [[RecordListDataModel alloc] initWithDictionary:dictData];
                                       if (records.list.count == 0) {
                                           if (records.groupId) {
                                               weakSelf.group.groupId = records.groupId;
                                           }
                                           if (recursiveBlock) {
                                               recursiveBlock(NO, NO, completion);
                                           }
                                           
                                           //假如没消息，就刷进去最后一条消息，预防该msgId无效
                                           weakSelf.group.updateTime = ((RecordDataModel *)[weakSelf successRecordsList].lastObject).msgId;
                                           if (weakSelf.chatMode == ChatPrivateMode) {
                                               [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithUpdateTime:weakSelf.group.updateTime withGroupId:weakSelf.group.groupId];
                                           }else{
                                               [[XTDataBaseDao sharedDatabaseDaoInstance] updatePublicGroupListWithUpdateTime:weakSelf.group.updateTime withGroupId:weakSelf.group.groupId withPublicId:weakSelf.pubAccount.publicId];
                                           }

                                           
                                       } else {
                                           [weakSelf hideNoticeView];
                                           if (records.groupId) {
                                               weakSelf.group.groupId = records.groupId;
                                           }
                                           
                                           //更新最新消息的msgId，使用旧字段updateTime
                                           {
                                               weakSelf.group.updateTime = ((RecordDataModel *)records.list.lastObject).msgId;
                                               if (weakSelf.chatMode == ChatPrivateMode) {
                                                   [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithUpdateTime:weakSelf.group.updateTime withGroupId:weakSelf.group.groupId];
                                               }else{
                                                   [[XTDataBaseDao sharedDatabaseDaoInstance] updatePublicGroupListWithUpdateTime:weakSelf.group.updateTime withGroupId:weakSelf.group.groupId withPublicId:weakSelf.pubAccount.publicId];
                                               }
                                           }
                                           
//                                           [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithUpdateTime:weakSelf.group.updateTime withGroupId:weakSelf.group.groupId];
                                           
                                           [weakSelf.mArrayRecordsFromMsgListRaw addObjectsFromArray:records.list];
                                           
                                           //删除撤回消息
                                           NSMutableArray *cancelList = [NSMutableArray array];
                                           [records.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                               RecordDataModel *record = (RecordDataModel *)obj;
                                               if(record.msgType == MessageTypeCancel)
                                                   [cancelList addObject:record.sourceMsgId];
                                           }];
                                           
                                           
                                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                               
                                               //删除撤回消息
                                               [cancelList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                   [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordWithMsgId:obj];
                                                   
                                                   //删除内存中的数据
                                                   RecordDataModel *cancelRecord = [[RecordDataModel alloc] init];
                                                   cancelRecord.msgId = obj;
                                                   [weakSelf.recordsList removeObject:cancelRecord];
                                               }];
                                               
                                               //清除本地缓存数据
                                               [records.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                   KDToDoMessageDataModel *record = (KDToDoMessageDataModel *)obj;
                                                   if(record.clientMsgId.length == 0)
                                                       return;
                                                   
                                                   
                                                   int row = (int)[weakSelf rowOfTableView:record.clientMsgId];
                                                   if (row >= 0 && row < weakSelf.bubbleArray.count)
                                                   {
                                                       //删除数据库中的数据
                                                       [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordWithMsgId:record.clientMsgId];
                                                       
                                                       //删除内存中的数据
                                                       RecordDataModel *cancelRecord = [[RecordDataModel alloc] init];
                                                       cancelRecord.msgId = record.clientMsgId;
                                                       [weakSelf.recordsList removeObject:cancelRecord];
                                                   }
                                               }];
                                               
                                               [[XTDataBaseDao sharedDatabaseDaoInstance] insertRecords:records.list
                                                                                               publicId:weakSelf.chatMode == ChatPrivateMode ? nil : weakSelf.pubAccount.publicId];
                                               //                                               [weakSelf.recordsList setArray:[[KDChatWithdrawManager sharedInstance] withdrawMsgIdsWithRecords:records.list inMemoryRecords:weakSelf.recordsList]];
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [weakSelf getOnePageFromDBWithMsgId:strMsgId
                                                                    recordCountPerPage:recordCountPerPage
                                                                             direction:direction
                                                                            completion:^(NSArray *records) {
                                                                                if (records.count > 0) {
                                                                                    [weakSelf.mArrayRecordsFromMsgList addObjectsFromArray:records];
                                                                                    
                                                                                    if (recursiveBlock){
                                                                                        recursiveBlock(YES, [dictData boolForKey:@"more"], completion);
                                                                                    }
                                                                                    
                                                                                } else {
                                                                                    if (recursiveBlock) {
                                                                                        recursiveBlock(NO, NO, completion);
                                                                                    }
                                                                                }
                                                                            }];
                                               });
                                           });
                                       }
                                   } else {
                                       if (recursiveBlock) {
                                           recursiveBlock(NO, NO, completion);
                                       }
                                   }
                               }];
}

#pragma mark 网络拉取核心方法[2]: 逐页拉取 (new方向) 直到more为false
- (void)fetchNewMessagesPageByPageWithRecordCountPerPage:(int)recordCountPerPage completion:(void (^)())completion{
    self.lastMsgSendTime = self.latestMsgSendTime;
    __weak __typeof(self) weakSelf = self;
    
    if (!self.blockRecursiveGetMoreMessagesNew) {
        self.blockRecursiveGetMoreMessagesNew = ^(BOOL succ, BOOL more, void (^completion)()) {
            // 递归防御
            if (succ && more){// && [[weakSelf.latestMsgSendTime dz_dateValue] dz_laterThan:[weakSelf.lastMsgSendTime dz_dateValue]]) {
                [weakSelf fetchMessageOnePageWithDirection:MessagePagingDirectionNew
                                        recordCountPerPage:recordCountPerPage
                                            recursiveBlock:weakSelf.blockRecursiveGetMoreMessagesNew
                                                completion:completion];
            } else {
                if (completion) {
                    completion();
                }
            }
        };
    }
    
    
    //    [UIView animateWithDuration:0
    //                     animations:^ {
    //                     } completion:^(BOOL finished) {
    // 兼容第一次拉取
    [weakSelf fetchMessageOnePageWithDirection:MessagePagingDirectionNew
                            recordCountPerPage:recordCountPerPage
                                recursiveBlock:weakSelf.blockRecursiveGetMoreMessagesNew
                                    completion:completion];
    //                     }];
}


#pragma mark 网络拉取核心方法[3]: 逐页拉取 (old方向) 直到找到传入的msgId
- (void)fetchOldMessagePageByPageToMsgId:(NSString *)toMsgId
                              completion:(void (^)())completion{
    self.lastMsgSendTime = self.oldestMsgSendTime;
    //    [self startLoadingNextPage];
    self.fetchOldToMsgId = toMsgId;
    __weak __typeof(self) weakSelf = self;
    
    if (!self.blockRecursiveGetMoreMessagesOld) {
        self.blockRecursiveGetMoreMessagesOld = ^(BOOL succ, BOOL more, void (^completion)()) {
            if ([weakSelf isInMemoryMsgId:weakSelf.fetchOldToMsgId]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf reloadData];
                    [weakSelf scrollToMsgId:weakSelf.fetchOldToMsgId completion:^ {
                        if (completion) {
                            completion();
                        }
                    }];
                });
            } else {
                // 递归防御
                if (succ && more && [[weakSelf.oldestMsgSendTime dz_dateValue] dz_earlierThan:[weakSelf.lastMsgSendTime dz_dateValue]]) {
                    [weakSelf fetchMessageOnePageWithDirection:MessagePagingDirectionOld
                                            recordCountPerPage:TEMP_NUMBER_OF_RECORDS_PER_PAGE
                                                recursiveBlock:weakSelf.blockRecursiveGetMoreMessagesOld
                                                    completion:completion];
                } else {
                    [weakSelf reloadData];
                    if (completion) {
                        completion();
                    }
                }
            }
        };
        
    }
    
    [UIView animateWithDuration:0 animations:^ {
        [weakSelf.lastPageIndicatorView startAnimating];
    } completion:^(BOOL finished) {
        [weakSelf fetchMessageOnePageWithDirection:MessagePagingDirectionOld
                                recordCountPerPage:TEMP_NUMBER_OF_RECORDS_PER_PAGE
                                    recursiveBlock:weakSelf.blockRecursiveGetMoreMessagesOld
                                        completion:completion];
    }];
    
}

#pragma mark -
#pragma mark 事件[1] 首次进入聊天页面
- (void)loadOnePageAtViewDidLoad{
    if (self.strScrollToMsgId) {
        [self kd_showLoading];
    }
    
    //拉取新消息块 首先拉取组迭代更新的人员信息，然后再走之前拉取消息的接口，这里
    __weak __typeof(self) weakSelf = self;
    void (^blockFetchNewMessagesPageByPage)(int recordCountPerPage) = ^(int recordCountPerPage){
        __block BOOL bBrandnewGroup = weakSelf.recordsList.count == 0;
        [weakSelf startLoadingNextPage];
       
        //拉数据前根据updateScore去拉人
        weakSelf.localUpdateScore = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupLocalUpdateScoreWithGroupId:weakSelf.group.groupId];
        NSInteger  updateScore = weakSelf.group.updateScore;
        //迭代获取相关人员信息块
        weakSelf.blockRecursiveGetGroupUser = ^(BOOL succ, SimplePersonListDataModel *personListData, void (^completion)()) {
            // 递归防御
            if (succ){
                if (personListData.hasMore) {
                    [weakSelf fetchGroupUsersByPageWithGroupId:weakSelf.group.groupId
                                                         Score:[NSString stringWithFormat:@"%ld",weakSelf.localUpdateScore]
                                                recursiveBlock:weakSelf.blockRecursiveGetGroupUser
                                                    completion:completion];
                    return ;
                }else
                {
//                   // 更新updateScore
//                    [[XTDataBaseDao sharedDatabaseDaoInstance] updateGroupLocalUpdateScoreWithGroupId:weakSelf.group.groupId updateScore:[NSString stringWithFormat:@"%ld",personListData.lastUpdateScore]];
//                    weakSelf.group.participantIds = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupParticipateWithGroupId:weakSelf.group.groupId];
//                    //填满self.group.participant 免得挖坑
//                    weakSelf.group.participant = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupParticipatePersonsWithIds:weakSelf.group.participantIds];
////                    [XTDataBaseDao sharedDatabaseDaoInstance]insertUpdatePrivateGroupList:
//                    //更新title
//                    [weakSelf setupChatTitle];
                }
            }
            //原来拉取msglist逻辑 不依赖于拉取相关人员的接口是否成功，但是如果成功且hasmore为1 则拉取完再拉消息
            [weakSelf fetchNewMessagesPageByPageWithRecordCountPerPage:recordCountPerPage
                                                            completion:^{
                                                                weakSelf.bFirstFetch = NO;
                                                                
                                                                [weakSelf reloadData];
                                                                [weakSelf scrollToBottomAnimated:NO];
                                                                
                                                                if (weakSelf.strScrollToMsgId) {
                                                                    [weakSelf scrollToMsgId:weakSelf.strScrollToMsgId
                                                                                 completion:^{
                                                                                     [weakSelf kd_hideLoading];
                                                                                     weakSelf.bLoadingLock = NO;
                                                                                     if (!weakSelf.jumpSuccess) {
                                                                                         [weakSelf scrollToBottomAnimated:YES];
                                                                                     }
                                                                                     
                                                                                 }];
                                                                } else {
                                                                    if (!bBrandnewGroup) { // 首次进入不显示未读 by姚琪 20151117
                                                                        if (weakSelf.iUnreadMessageCount >= 10 && weakSelf.recordsList.count >= weakSelf.iUnreadMessageCount) {
                                                                            RecordDataModel *model = [[RecordDataModel alloc] init];
                                                                            if (weakSelf.iUnreadMessageCount > 99) {
                                                                                model = weakSelf.recordsList[weakSelf.recordsList.count - 99];
                                                                            } else {
                                                                                model = weakSelf.recordsList[weakSelf.recordsList.count - weakSelf.iUnreadMessageCount];
                                                                            }
                                                                            weakSelf.strFirstUnreadMessageMsgId = model.msgId;
                                                                            [weakSelf showUnreadMessageButton];
                                                                        }
                                                                    }
                                                                    [weakSelf goUpdateBannerView];
                                                                    weakSelf.bLoadingLock = NO;
                                                                }
                                                            }];
        };

        //如果小说明有人员更新 先去拉人员数据 然后再走之前拉消息逻辑
        if (self.localUpdateScore < updateScore) {
            [weakSelf fetchGroupUsersByPageWithGroupId:weakSelf.group.groupId
                                                 Score:[NSString stringWithFormat:@"%ld",self.localUpdateScore]
                                        recursiveBlock:weakSelf.blockRecursiveGetGroupUser
                                             completion:nil];
        }else
        {
            //原来拉取msglist逻辑
            [weakSelf fetchNewMessagesPageByPageWithRecordCountPerPage:recordCountPerPage
                                                            completion:^{
                                                                weakSelf.bFirstFetch = NO;
                                                                
                                                                [weakSelf reloadData];
                                                                [weakSelf scrollToBottomAnimated:NO];
                                                                
                                                                if (weakSelf.strScrollToMsgId) {
                                                                    [weakSelf scrollToMsgId:weakSelf.strScrollToMsgId
                                                                                 completion:^{
                                                                                     [weakSelf kd_hideLoading];
                                                                                     weakSelf.bLoadingLock = NO;
                                                                                     if (!weakSelf.jumpSuccess) {
                                                                                         [weakSelf scrollToBottomAnimated:YES];
                                                                                     }
                                                                                     
                                                                                 }];
                                                                } else {
                                                                    if (!bBrandnewGroup) { // 首次进入不显示未读 by姚琪 20151117
                                                                        if (weakSelf.iUnreadMessageCount >= 10 && weakSelf.recordsList.count >= weakSelf.iUnreadMessageCount) {
                                                                            RecordDataModel *model = [[RecordDataModel alloc] init];
                                                                            if (weakSelf.iUnreadMessageCount > 99) {
                                                                                model = weakSelf.recordsList[weakSelf.recordsList.count - 99];
                                                                            } else {
                                                                                model = weakSelf.recordsList[weakSelf.recordsList.count - weakSelf.iUnreadMessageCount];
                                                                            }
                                                                            weakSelf.strFirstUnreadMessageMsgId = model.msgId;
                                                                            [weakSelf showUnreadMessageButton];
                                                                        }
                                                                    }
                                                                    [weakSelf goUpdateBannerView];
                                                                    weakSelf.bLoadingLock = NO;
                                                                }
                                                            }];

        }

    };
    
    
    
    self.bLoadingLock = YES;
    
    // 表示外部调用过取db数据
    if (self.recordsList.count > 0) {
//        [self reloadData];
//        [self scrollToBottomAnimated:NO];
        blockFetchNewMessagesPageByPage(TEMP_NUMBER_OF_RECORDS_PER_PAGE);
    } else {
        //先取本地数据
        [self getOnePageFromDBWithMsgId:@""
                     recordCountPerPage:NUMBER_OF_RECORDS_PER_PAGE
                              direction:MessagePagingDirectionNew
                             completion:^(NSArray *records) {
                                 if (records.count > 0) {
                                     [weakSelf reloadData];
                                     [weakSelf scrollToBottomAnimated:NO];
                                     blockFetchNewMessagesPageByPage(TEMP_NUMBER_OF_RECORDS_PER_PAGE);
                                    } else {
                                        // 首次拉取 msgId为空, 方向为new
                                        blockFetchNewMessagesPageByPage(NUMBER_OF_RECORDS_PER_PAGE);
                                    }
                                 }];

         }
}

//拉去组人员信息块
- (void)fetchGroupUsersByPageWithGroupId:(NSString *)groupId
                                   Score:(NSString *)personScore
                          recursiveBlock:(void (^)(BOOL succ, SimplePersonListDataModel *personListData, void (^completion)()))recursiveBlock
                              completion:(void (^)())completion{
    
     __weak __typeof(self) weakSelf = self;
    [self.userHelper  getGroupUsersWithGroupId:groupId
                                         Score:personScore
                                    completion:^(BOOL success, BOOL more, NSDictionary *personsDic, NSString *error) {
                                     if (success) {
                                         SimplePersonListDataModel *personList = [[SimplePersonListDataModel alloc]initWithDictionary:personsDic];
                                         if ([personList.list count ] > 0) {
                                             //太慢了 得优化
                                             NSMutableArray *personIdArray = [NSMutableArray array];
                                             [personList.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                 PersonSimpleDataModel *person = (PersonSimpleDataModel *) obj;
                                                 //插入人员表 可能有个坑，新增人员不会出现在最近联系人里面
                                                 [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:person];
                                                 
                                                 //生成人员id列表
                                                 [personIdArray addObject:person.personId];
                                             }];
                                             
                                             
                                             //把删除人员移除组参与人
                                             [[XTDataBaseDao sharedDatabaseDaoInstance] deleteParticpantWithPersonIdArray:personIdArray groupId:groupId];
                                             //把新增人员添加到参与id表里面
                                             [[XTDataBaseDao sharedDatabaseDaoInstance] addParticpantWithPersonIdArray:personIdArray groupId:groupId];
                                             
                                        }
                                         
                                         if ([personList.delList count] > 0) {
                                             //把删除人员移除组参与人
                                             [[XTDataBaseDao sharedDatabaseDaoInstance] deleteParticpantWithPersonIdArray:personList.delList groupId:groupId];
                                         }
                                        
                                         // 更新updateScore
                                         [[XTDataBaseDao sharedDatabaseDaoInstance] updateGroupLocalUpdateScoreWithGroupId:weakSelf.group.groupId updateScore:[NSString stringWithFormat:@"%ld",personList.lastUpdateScore]];
                                         weakSelf.group.participantIds = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupParticipateWithGroupId:weakSelf.group.groupId];
                                         //bug 12500，更新group的人员id列表
                                         [[XTDataBaseDao sharedDatabaseDaoInstance] updateGroupParticipantWithGroupId:weakSelf.group.groupId participantIdArray:weakSelf.group.participantIds];
                                         //填满self.group.participant 免得挖坑
                                         weakSelf.group.participant = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupParticipatePersonsWithIds:weakSelf.group.participantIds];
                                         //更新title
                                         [weakSelf setupChatTitle];
                                         
                                         if (recursiveBlock){
                                             //拉数据前根据updateScore去拉人
                                             weakSelf.localUpdateScore = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupLocalUpdateScoreWithGroupId:weakSelf.group.groupId];
                                             recursiveBlock(YES, personList, completion);
                                         }
                                         
                                     }else
                                     {
                                         if (recursiveBlock) {
                                             recursiveBlock(NO,nil,completion);
                                         }
                                     }
                                 }];
}

#pragma mark 事件[2] 下拉 旧消息
- (void)startLoading
{
    if (!self.bLoadingLock && !self.bNoMoreOldPagings) {
        __weak __typeof(self) weakSelf = self;
        weakSelf.bLoadingLock = YES;
        [UIView animateWithDuration:0 animations:^ {
            [weakSelf.lastPageIndicatorView startAnimating];
        } completion:^(BOOL finished) {
            [weakSelf getOnePageFromDBWithMsgId:weakSelf.oldestMsgId
                             recordCountPerPage:NUMBER_OF_RECORDS_PER_PAGE
                                      direction:MessagePagingDirectionOld
                                     completion:^(NSArray *records) {
                                         if (records.count == 0) {
                                             [weakSelf fetchMessageOnePageWithDirection:MessagePagingDirectionOld
                                                                     recordCountPerPage:NUMBER_OF_RECORDS_PER_PAGE
                                                                         recursiveBlock:^(BOOL succ, BOOL more, void (^completion)()) {
                                                                             if (succ) {
                                                                                 [weakSelf resetScrollPositionWithBlock:^{
                                                                                     [weakSelf reloadData];
                                                                                 }];
                                                                             }
                                                                             weakSelf.bLoadingLock = NO;
                                                                             weakSelf.bNoMoreOldPagings = !more;
                                                                         } completion:nil];
                                         } else {
                                             [weakSelf resetScrollPositionWithBlock:^{
                                                 [weakSelf reloadData];
                                                 [weakSelf stopLoading];
                                                 weakSelf.bLoadingLock = NO;
                                             }];
                                         }
                                     }];
        }];
    }
}

#pragma mark 事件[3] 轮询、长连接，获取网络数据
- (void)fetchDataFromNet:(NSString *)msgId {
    //如果已经是最新的消息，则不需要更新(仅仅的状态或者未读数的变更)
    if (msgId && [msgId isEqualToString:[self latestMsgId]]) {
        return;
    }
    //拉数据前根据updateScore去拉人
    self.localUpdateScore = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupLocalUpdateScoreWithGroupId:self.group.groupId];
    NSInteger  updateScore = self.group.updateScore;
    //迭代获取相关人员信息块
    __weak __typeof(self) weakSelf = self;
    weakSelf.blockRecursiveGetGroupUser = ^(BOOL succ, SimplePersonListDataModel *personListData, void (^completion)()) {
        // 递归防御
        if (succ){
            if (personListData.hasMore) {
                [weakSelf fetchGroupUsersByPageWithGroupId:weakSelf.group.groupId
                                                     Score:[NSString stringWithFormat:@"%ld",weakSelf.localUpdateScore]
                                            recursiveBlock:weakSelf.blockRecursiveGetGroupUser
                                                completion:completion];
                return ;
            }else
            {
//                // 更新updateScore
//                [[XTDataBaseDao sharedDatabaseDaoInstance] updateGroupLocalUpdateScoreWithGroupId:weakSelf.group.groupId updateScore:[NSString stringWithFormat:@"%ld",personListData.lastUpdateScore]];
//                weakSelf.group.participantIds = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupParticipateWithGroupId:weakSelf.group.groupId];
//                //填满self.group.participant 免得挖坑
//                weakSelf.group.participant = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupParticipatePersonsWithIds:weakSelf.group.participantIds];
//                //更新title
//                [weakSelf setupChatTitle];
            }
            [weakSelf fetchNewMessages];
        }
        
    };
    
    //如果小说明有人员更新 先去拉人员数据 然后再走之前拉消息逻辑
    if (self.localUpdateScore < updateScore) {
        [self fetchGroupUsersByPageWithGroupId:weakSelf.group.groupId
                                         Score:[NSString stringWithFormat:@"%ld",self.localUpdateScore]
                                recursiveBlock:self.blockRecursiveGetGroupUser
                                    completion:nil];
    }else
    {
        [self fetchNewMessages];
    }

    
    
}

// 单纯的new方向更新数据到最新
- (void)fetchNewMessages {
    if (!self.bLoadingLock) {
        self.bLoadingLock = YES;
        __weak __typeof(self) weakSelf = self;
        
        [self fetchNewMessagesPageByPageWithRecordCountPerPage:TEMP_NUMBER_OF_RECORDS_PER_PAGE
                                                    completion:^{
//                                                        [weakSelf afterMsgList: weakSelf.mArrayRecordsFromMsgList rawRecords: weakSelf.mArrayRecordsFromMsgListRaw];
                                                        [weakSelf reloadData];
                                                        [weakSelf.mArrayRecordsFromMsgList removeAllObjects];
                                                        [weakSelf.mArrayRecordsFromMsgListRaw removeAllObjects];
                                                        [weakSelf scrollToBottom];
                                                        weakSelf.bLoadingLock = NO;
                                                    }];
    }
}
#pragma mark 事件[4] 跳转
- (void)scrollToMsgId:(NSString *)msgId completion:(void(^)())completion{
    __weak __typeof(self) weakSelf = self;
    // 从内存里找, 找到跳
    void (^jumpInMemory)(void(^)(BOOL)) = ^(void(^blockFindIt)(BOOL findit)) {
        // 内存中有就跳
        weakSelf.todoBdi = nil;
        [weakSelf.bubbleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BubbleDataInternal *bd = (BubbleDataInternal *)obj;
            if ([bd.record.msgId isEqualToString:msgId]) {
               weakSelf.todoBdi = bd;
                *stop = YES;
            }

        }];
        
        if (weakSelf.todoBdi ) {
                NSInteger index = [weakSelf.bubbleArray indexOfObject:weakSelf.todoBdi];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [weakSelf.bubbleTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                    BubbleTableViewCell *cell = [weakSelf.bubbleTable cellForRowAtIndexPath:indexPath];
                    [cell.bubbleImage.layer addAnimation:[weakSelf opacityAnimation:0.4] forKey:nil];
                });
                weakSelf.jumpSuccess = YES;
                weakSelf.strScrollToMsgId = nil;
                if (blockFindIt) {
                    blockFindIt(YES);
                }
            } else {
                if (blockFindIt) {
                    blockFindIt(NO);
                }
            }
    };
    
    // 从数据库找, 找到跳
    void (^jumpInDatabase)(void(^)(BOOL)) = ^(void(^blockFindIt)(BOOL findit)) {
        [weakSelf.bubbleTable setContentOffset:weakSelf.bubbleTable.contentOffset animated:NO];
        NSString *personId = nil;
        if ([weakSelf.group.participantIds count] > 0) {
            personId = [weakSelf.group.participantIds firstObject];
        }
        __block NSMutableArray *mArray = [NSMutableArray new];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [mArray setArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryRecordsWithGroupId:weakSelf.group.groupId toUserId:personId publicId:nil fromMsgId:msgId]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (mArray.count > 0) {
                    [weakSelf.recordsList removeAllObjects];
                    // TODO: 超多消息时卡在这里
                    for (int i = 0; i < [mArray count]; i++) {
                        [weakSelf.recordsList insertObject:[mArray objectAtIndex:i] atIndex:0];
                    }
                    weakSelf.jumpSuccess = YES;
                    [weakSelf reloadData];
                    if (weakSelf.bubbleArray.count > 0) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        [weakSelf.bubbleTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                            
                            
                            BubbleTableViewCell *cell = [weakSelf.bubbleTable cellForRowAtIndexPath:indexPath];
                            [cell.bubbleImage.layer addAnimation:[weakSelf opacityAnimation:0.4] forKey:nil];
                            
                        });
                        
                    }
                    blockFindIt(YES);
                } else {
                    blockFindIt(NO);
                    
                }
            });
        });
    };
    
    jumpInMemory(^(BOOL findit) {
        if (!findit) {
            // (3) 数据库寻找msgId并跳转
            jumpInDatabase(^(BOOL findit) {
                if (!findit) {
                    // (4) 从服务器寻找msgId并跳转
                    [weakSelf fetchOldMessagePageByPageToMsgId:msgId
                                                    completion:^ {
                                                        // (5) 找到执行内存跳转
                                                        jumpInMemory(^(BOOL findit) {
                                                            if (completion) {
                                                                completion();
                                                            }
                                                        });
                                                    }];
                } else {
                    if (completion) {
                        completion();
                    }
                }
            });
        } else {
            if (completion) {
                completion();
            }
        }
    });
}
- (void)scrollToBottom {
//    if (self.bubbleTable.contentOffset.y > self.bubbleTable.contentSize.height - self.bubbleTable.bounds.size.height - 300) {
//        [self scrollToBottomAnimated:NO];
//    }
    
    NSArray *paths = [self.bubbleTable indexPathsForVisibleRows];
    NSIndexPath *previousLastIndexPath = [NSIndexPath indexPathForRow:self.bubbleArray.count - 2 inSection:0];
    BOOL shouldScroll = NO;
    for (NSIndexPath *indexPath in paths) {
        if (indexPath.row == previousLastIndexPath.row && indexPath.section == previousLastIndexPath.section) {
            shouldScroll = YES;
            break;
        }
    }
    if (shouldScroll) {
        [self scrollToBottomAnimated:NO];
    }
}

//外部联系人群组 标题   等待添加图标
- (void)setupTitleView
{
    CGFloat maxWidth = ScreenFullWidth - 80*2;  //200.0f;
    
    UIView *extenalGroupTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 44)];
    extenalGroupTitleView.backgroundColor = [UIColor clearColor];
    extenalGroupTitleView.autoresizingMask = self.navigationItem.titleView.autoresizingMask;
    self.navigationItem.titleView = extenalGroupTitleView;
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectZero;
    [extenalGroupTitleView addSubview:view];
    
    UIImageView *extenalGroupTitleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_tip_shang_small"]];//图片需要需改
    extenalGroupTitleImageView.frame = CGRectMake(0, (44 - 16)/2 , 16, 16);
    [view addSubview:extenalGroupTitleImageView];
    
    UILabel *extenalGroupTitleLabel = [[UILabel alloc] init];
    extenalGroupTitleLabel.textColor = FC1;
    extenalGroupTitleLabel.font = FS1;
    extenalGroupTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    extenalGroupTitleLabel.text = self.title;
    
    CGSize size = CGSizeMake(maxWidth - [NSNumber kdDistance2] - CGRectGetWidth(extenalGroupTitleImageView.frame), 44);
    //    CGSize labelsize = [extenalGroupTitleLabel.text sizeWithFont:FS1 constrainedToSize:size lineBreakMode:NSLineBreakByTruncatingMiddle];
    CGSize labelsize = [extenalGroupTitleLabel.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:FS1} context:nil].size;
    extenalGroupTitleLabel.frame = CGRectMake(CGRectGetMaxX(extenalGroupTitleImageView.frame) + [NSNumber kdDistance2], 0, labelsize.width , 44);
    
    [view addSubview:extenalGroupTitleLabel];
    
    view.frame = CGRectMake(0, 0, CGRectGetMaxX(extenalGroupTitleLabel.frame), 44);
    view.center = extenalGroupTitleView.center;
}


#pragma mark - 消息回复

- (UIButton *)buttonGrayFilter{
    if (!_buttonGrayFilter) {
        _buttonGrayFilter = [UIButton new];
        _buttonGrayFilter.backgroundColor = [UIColor blackColor];
        _buttonGrayFilter.alpha = 0.3;
        _buttonGrayFilter.frame = self.view.bounds;
        _buttonGrayFilter.hidden = YES;
        [_buttonGrayFilter addTarget:self action:@selector(buttonGrayFilterPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonGrayFilter;
}

- (void)buttonGrayFilterPressed {
    [self changeMessageModeTo:KDChatMessageModeNone];
    [self hideInputBoard];
    [self.view endEditing:YES];
}

// 进入回复模式
- (void)showGrayFilter {
    self.buttonGrayFilter.hidden = NO;
    if (self.changeButton.tag == ChangeBtnTagText) {
        [self changeBtnClick:self.changeButton];
    }
    if (!self.contentView.isFirstResponder) {
        [self.contentView becomeFirstResponder];
    }
    if (self.contentView.text.length > 0) {
        self.contentView.text = nil;
    }
}

// 退出回复模式
- (void)closeReplyMode {
    if (![self.contentView.placeholder isEqualToString: ASLocalizedString(@"XTChatViewController_Placeholder_Important")] && ![self.contentView.placeholder isEqualToString: ASLocalizedString(@"XTChatViewController_Placeholder_Notrace")]) {
        self.contentView.placeholder = @"";
    }
    self.buttonGrayFilter.hidden = YES;
    self.replyRecord = nil;
}

#pragma mark - 特殊消息模式转换 -

- (void)changeMessageModeTo:(KDChatMessageMode)mode {
    self.messageMode = mode;
    switch (mode) {
        case KDChatMessageModeNone: {
            [self closeReplyMode];
            //[self closeImportantMode];
            [self closeNotraceMode];
        }
            break;
        case KDChatMessageModeNotrace: {
            //add
            [KDEventAnalysis event: event_dialog_plus_traceless_message];
            [KDEventAnalysis eventCountly: event_dialog_plus_traceless_message];
            [self openNotraceMode];
            [self closeReplyMode];
            //[self closeImportantMode];
        }
            break;
        case KDChatMessageModeImportant: {
            //[self openImportantMode];
            [self closeReplyMode];
            [self closeNotraceMode];
        }
            break;
        case KDChatMessageModeReply: {
            [self showGrayFilter];
            [self closeNotraceMode];
            //[self closeImportantMode];
        }
            break;
        default:
            break;
    }
}

- (void)closeNotraceMode {
    if ([self.contentView.placeholder isEqualToString: ASLocalizedString(@"XTChatViewController_Placeholder_Notrace")]) {
        self.contentView.placeholder = @"";
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;//BOSCOLORWITHRGBA(kTextViewBoarderColorNormal, 1.0).CGColor;
    }
    
    [self.boardView removeFromSuperview];
    self.boardView = nil;
    [self.inputBoardBGView addSubview:self.boardView];
    [self enableChangeButton];
}

- (void)openNotraceMode {
    self.contentView.text = @""; // 因为有字数限制，不清空则需截取
    // 截取代码如下 (预留)
    //    if (self.contentView.text.length > [[KDChatNotraceManager sharedInstance] maxWordsLength]) {
    //        self.contentView.text = [self.contentView.text substringToIndex:[[KDChatNotraceManager sharedInstance] maxWordsLength]];
    //    }
    self.contentView.layer.borderColor = BOSCOLORWITHRGBA(kTextViewBoarderColorNotrac, 1.0).CGColor;
    self.contentView.placeholder = ASLocalizedString(@"XTChatViewController_Placeholder_Notrace");
    [self.boardView removeFromSuperview];
    self.boardView = nil;
    [self.inputBoardBGView addSubview:self.boardView];
    [self disableChangeButton];
}

// ui要求自定义alpha
- (void)enableChangeButton {
    self.changeButton.userInteractionEnabled = YES;
    self.changeButton.alpha = 1;
}

- (void)disableChangeButton {
    self.changeButton.userInteractionEnabled = NO;
    self.changeButton.alpha = 0.3;
}


- (NSString * _Nullable)personNameWithGroup:(GroupDataModel * _Nullable)group record:(RecordDataModel * _Nullable)record
{
    if(!group || !record)
        return @"";
    
    __block PersonSimpleDataModel *person = nil;
    [group.participant enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PersonSimpleDataModel *participant = obj;
        if([participant.personId isEqualToString:record.fromUserId])
        {
            person = participant;
            *stop = YES;
        }
    }];
    
    if(!person)
    {
        PersonSimpleDataModel *currentUser =[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:[BOSConfig sharedConfig].user.userId];
        if([currentUser.personId isEqualToString:record.fromUserId])
            person = currentUser;
    }
    
    if(person)
        return person.personName;
    
    return @"";
}

- (PersonSimpleDataModel * _Nullable)personWithGroup:(GroupDataModel * _Nullable)group record:(RecordDataModel * _Nullable)record
{
    __block PersonSimpleDataModel *person = nil;
    if(!group || !record)
        return person;
    
    [group.participant enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PersonSimpleDataModel *participant = obj;
        if([participant.personId isEqualToString:record.fromUserId])
        {
            person = participant;
            *stop = YES;
        }
    }];
    
    if(!person)
    {
        PersonSimpleDataModel *currentUser =[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:[BOSConfig sharedConfig].user.userId];
        if([currentUser.personId isEqualToString:record.fromUserId])
            person = currentUser;
    }
    
    return person;
}

#pragma mark scrollReply
- (void)scrollReplyWithMsg:(NSString *)messageID replyFlag:(BOOL)flag{
//    self.replyBdi = nil;
//    for (BubbleDataInternal *bd in self.bubbleArray) {
//        if ([bd.record.msgId isEqualToString:messageID]) {
//            self.replyBdi = bd;
//            break;
//        }
//    }
//    if (!self.replyBdi) {
//        [self reloadData];
//    }
//    [self scrollToMsgId:messageID ScrollType:BubbleTableScrollReply];
    
    [self scrollToMsgId:messageID completion:nil];
}

-(CABasicAnimation *)opacityAnimation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.3f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = 5;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeRemoved;
    animation.delegate = self;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];///没有的话是均匀的动画。
    return animation;
}


- (void) playVideo:(NSString *)file
{

    KDVideoPlayerManager *player = [KDVideoPlayerManager sharedInstance];
    player.contentURL = [NSURL fileURLWithPath:file];
    player.delegate = self;
    player.shortVideoType = YES;
    _videoDuration = [KDVideoPlayerManager secondsOfVideoOfPath:file];
    _videoDuration = _videoDuration == 0 ? _videoDuration = 1 : _videoDuration;

    UIView *playBgView =[[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    playBgView.tag = 100001;
    playBgView.backgroundColor = [UIColor blackColor];
    playBgView.userInteractionEnabled = YES;
    
    
    CGSize videoSize = [player videoNaturalSize];
    
    //适配安卓的长宽
    if(videoSize.height<videoSize.width)
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    
    CGFloat radio = videoSize.height/videoSize.width;
    CGFloat maxWidth = ScreenFullWidth;
    CGFloat maxHeight = ScreenFullWidth*4/3;
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"])
    {
        maxHeight = ScreenFullHeight*0.7;
        maxWidth = maxHeight*3/4;
    }
    
    CGFloat playViewWidth = maxWidth;
    CGFloat playViewHeight = maxHeight;
    if(maxWidth*radio>maxHeight)
    {
        playViewHeight = maxHeight;
        playViewWidth = playViewHeight/radio;
    }
    else
    {
        playViewWidth = maxWidth;
        playViewHeight = playViewWidth*radio;
    }
    
    UIView *playView = [[UIView alloc]initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, playViewWidth, playViewHeight)];
    playView.center = CGPointMake(CGRectGetWidth(playBgView.frame)/2, playView.center.y);
    playView.backgroundColor = [UIColor clearColor];
    playView.tag = 10002;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeVideoView:)];
    singleTap.numberOfTapsRequired = 1;
    [playView addGestureRecognizer:singleTap];
    
    [playBgView addSubview:playView];
    
    
    
    self.playTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenFullWidth/2 - 20, kd_StatusBarAndNaviHeight+maxHeight+10 , 40, 40)];
    [self.playTimeLabel setTextColor:[UIColor whiteColor]];
    [self.playTimeLabel setFont:[UIFont systemFontOfSize:16.f]];
    [playBgView addSubview:self.playTimeLabel];
    
    
    KDWeiboAppDelegate *delegate = (KDWeiboAppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:playBgView];
    
    [player startPlayInView:playView];

}
#pragma mark
#pragma mark KDVideoPlayerManager delegate

#pragma mark playController delegate
- (void)videoPlayFinished:(KDVideoPlayerManager *)player
{
    
}

- (void)currentTimeOfVideo:(CGFloat)seconds
{
    [self updatePlayTimeLabel:seconds];
}

- (void)updatePlayTimeLabel:(CGFloat)time
{
    self.playTimeLabel.text = [NSString stringWithFormat:@"0:%02lu", _videoDuration - (int)time];
}


- (void)closeVideoView:(UIGestureRecognizer *)gesture
{
    KDVideoPlayerManager *player = [KDVideoPlayerManager sharedInstance];
    [player stopPlay];
    KDWeiboAppDelegate *delegate = (KDWeiboAppDelegate*)[UIApplication sharedApplication].delegate;
    [[delegate.window viewWithTag:100001] removeFromSuperview];
}

//请求失败
-(void)KDCloudAPI:(XTCloudClient *)api didFailedDownloadWithError:(NSError *)error
{
    [self downloadFileFailWithError:error];
}

- (void)downloadFileFailWithError:(NSError *)error {
    if (error.code == ASIFileManagementError) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTFileDetailViewController_DownLoad_Fail")message:ASLocalizedString(@"XTFileDetailViewController_Empty_File")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
    }
    else if(error.code == ASIConnectionFailureErrorType){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTFileDetailViewController_DownLoad_Fail")message:ASLocalizedString(@"XTFileDetailViewController_Error_Retry")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTFileDetailViewController_DownLoad_Fail")message:ASLocalizedString(@"XTFileDetailViewController_Retry")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
    }
}

//markBanner
- (KDMarkBottomBanner *)markBanner
{
    if (!_markBanner) {
        _markBanner = [[KDMarkBottomBanner alloc] initWithFrame:CGRectZero];
        _markBanner.delegate = self;
    }
    return _markBanner;
}

- (void)hideMarkBanner {
    __weak __typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.markBanner.frame = CGRectMake(0, -104, weakSelf.mainView.frame.size.width, 44);
    }];
}

- (void)showMarkBanner {
    __weak __typeof(self) weakSelf = self;
    
    [self.markBanner.superview bringSubviewToFront:self.markBanner];
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.markBanner.frame = CGRectMake(0, kd_StatusBarAndNaviHeight, weakSelf.mainView.frame.size.width, 44);
    }];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMarkBanner) object:nil];
    [self performSelector:@selector(hideMarkBanner) withObject:nil afterDelay:4];
}

- (void) markBannerPressed {
    //    KDMarkModel [onSetEvent(chatVC, model:markModel)
    // [KDMarkModel onSetEvent:self model:self.currentDoubleTappedMarkModel];
//    [KDEventAnalysis event:mark_chat_banner_entry];
    KDMarkListVC *vc = [KDMarkListVC new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


-(RecordDataModel *)findMsgId:(NSString *)msgId inRecords:(NSMutableArray *)records
{
    if(msgId.length == 0 || records.count == 0)
        return nil;
    
    for (RecordDataModel *record in records)
    {
        if ([record.msgId isEqualToString:msgId])
        {
            return record;
        }
    }
    return nil;
}


- (void)reloadChatGroupApplist:(NSNotification *)noti {
    NSString *chatGroupAppids = [[BOSSetting sharedSetting].params objectForKey:@"chatGroupAPP"];
    if (![chatGroupAppids isKindOfClass:[NSNull class]] && chatGroupAppids.length > 0){
        [self.chatAppClientCloud getDefineLightAppsWithMid:[BOSConfig sharedConfig].user.eid appids:chatGroupAppids openToken:[BOSConfig sharedConfig].user.token urlParam:nil];
    }
}

- (MCloudClient *)chatAppClientCloud
{
    if (!_chatAppClientCloud) {
        _chatAppClientCloud = [[MCloudClient alloc] initWithTarget:self action:@selector(getLightAppParamDidReceived:result:)];
    }
    return _chatAppClientCloud;
}

- (void)getLightAppParamDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (result.success && result.data && [result.data isKindOfClass:[NSArray class]]){
        NSArray *data = (NSArray *)result.data;
        [BOSSetting sharedSetting].chatGroupAPPArr = data;
    }
    else {
        [BOSSetting sharedSetting].chatGroupAPPArr = nil;
    }
    
    [[BOSSetting sharedSetting] saveSetting];
    
    [self.boardView removeFromSuperview];
    self.boardView = nil;
    [self.inputBoardBGView addSubview:self.boardView];
}

/**
 *  已经退出群组
 */
- (void)receivedExitGroupNotification:(NSNotification *)notification {
    
    __block BOOL isCurrentGroupId = NO;
    __weak __typeof(self) weakSelf = self;
    NSArray *groupExitList = notification.object;
    [groupExitList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id groupId = [obj objectForKey:@"groupId"];
        if ([weakSelf.group.groupId isEqualToString:groupId]) {
            isCurrentGroupId = YES;
            *stop = YES;
        }
    }];
    
    if (isCurrentGroupId) {
        if (self.noticeController.isPopupShowing) {
            [self.noticeController hidePopup];
        }
        self.isDissolveGroup = YES;
        [self resetTableFrameAndHideInputBoard];
//        [KDPopup showHUDToast:ASLocalizedString(@"XTChatViewController_group_dissolved") inView:self.view];
    }
}

- (void)resetTableFrameAndHideInputBoard {
    CGRect rect = self.bubbleTable.frame;
    self.toolbarImageView.hidden = YES;
    if ([self.contentView isFirstResponder]) {
        [self.contentView resignFirstResponder];
    }
    self.bubbleTableStartHeight = Height(self.mainView.frame);
    rect.size.height = self.bubbleTableStartHeight;
    self.bubbleTable.frame = rect;
    [self hideInputBoard];
}

#pragma mark - silenced
- (void)updateSilencedStatus {
    if (![self.group isManager] && [self.group slienceOpened]) {
        self.contentView.text = ASLocalizedString(@"全员禁言中");
        [self hideInputBoard];
        self.toolbarMenuview.hidden = YES;
        self.toolbarImageView.userInteractionEnabled = NO;
        self.toolbarImageView.alpha = 0.5;
        self.contentView.font = FS3;
        self.contentView.textColor = FC2;
        self.contentView.textAlignment = NSTextAlignmentCenter;
        self.contentView.userInteractionEnabled = NO;
    } else {
        if ([self.contentView.text isEqualToString:ASLocalizedString(@"全员禁言中")]) {
            self.contentView.text = @"";
        }
        self.toolbarMenuview.hidden = NO;
        self.toolbarImageView.userInteractionEnabled = YES;
        self.toolbarImageView.alpha = 1;
        self.contentView.font = FS4;
        self.contentView.textColor = FC1;
        self.contentView.textAlignment = NSTextAlignmentLeft;
        self.contentView.userInteractionEnabled = YES;
        self.contentView.textContainerInset = UIEdgeInsetsMake(self.contentView.textContainerInset.top, 8, self.contentView.textContainerInset.bottom, 8);
        
        // 取出草稿
        if(!_pushingToChooseVC)
            [self fetchDraft];
    }
}

- (void)hasMsgDelDidReceive:(NSNotification *)sender {
    // 更新该组的消息bubblearray
    NSMutableArray *list = sender.object;
    if ([list count] > 0) {
        NSMutableArray *containRecord = [NSMutableArray array];
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DeleteMsgDateModel *msgData = obj;
            NSString *msgId = msgData.msgId;
            [self.recordsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                RecordDataModel *record = obj;
                if ([record.msgId isEqualToString:msgId]) {
                    [containRecord addObject:record];
                }
            }];
            
        }];
        if (self.recordsList.count > 0) {
            [self.recordsList removeObjectsInArray:containRecord];
        }
    }
    [self updateData];
}

- (void)goToImageEditorWithImage:(UIImage *)image {
    if (!image) {
        return;
    }
    
    KDImageEditorViewController *editor = [[KDImageEditorViewController alloc] initWithImage:image delegate:self];
    [self presentViewController:editor animated:YES completion:nil];
}

#pragma mark- KKImageEditorDelegate

- (void)imageDidFinishEdittingWithImage:(UIImage *)image {
    if (!image) {
        return;
    }
    [self handleImage:image savedPhotosAlbum:NO withLibUrl:nil];
}

#pragma mark - KDCameraViewControllerDelegate
- (void)cameraViewController:(id)camera WithImage:(UIImage *)image {
    [self handleImage:image savedPhotosAlbum:NO withLibUrl:nil];
}
- (KDUserHelper *)userHelper
{
    if (_userHelper == nil) {
        _userHelper = [[KDUserHelper alloc]init];
    }
    return _userHelper;
}

@end
