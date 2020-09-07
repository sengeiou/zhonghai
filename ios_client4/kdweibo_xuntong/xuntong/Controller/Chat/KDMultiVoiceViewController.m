//
//  KDMultiVoiceViewController.m
//  kdweibo
//
//  Created by 陈彦安 on 15/4/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDMultiVoiceViewController.h"
#import "KDVoiceButtonForMultiVoice.h"
#import "KDVoiceMeetingBottomButton.h"
#import "KDApplicationQueryAppsHelper.h"
#import "KDMultiVoiceViewCell.h"
#import "BOSConfig.h"
#import "KDAgoraSDKManager.h"
#import "XTDataBaseDao.h"
#import "ContactClient.h"
#import "XTMyFilesViewController.h"
#import "KDWPSFileShareManager.h"
#import "KDAppOpen.h"
#import "KDFileShareBanner.h"
#import "KDAgoraVoiceBanner.h"
#import "KDPlusMenuView.h"
#import "XTFilePreviewViewController.h"
#import "KDVoiceMeetingMeImageView.h"
//#import "KDSignInUtil.h"
#import "KDVoiceHostModeGuideView.h"
#import "KDVoiceHostModeTipsView.h"
#import "KDPersonFetch.h"
#import "KDVoicePopView.h"
#import "XTChooseContentViewController.h"


@interface KDMultiVoiceViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate,KDVoicePopViewDelegate,XTChooseContentViewControllerDelegate>
{
    BOOL _showTopViewFlag;
    BOOL _showRedViewFlag;
    BOOL _showFileShareBannerFlag;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) KDVoiceButtonForMultiVoice *voiceButton;
@property (nonatomic, strong) KDVoiceButtonForMultiVoice *micButton;
@property (nonatomic, strong) KDVoiceMeetingBottomButton *startSharePlayBtn;
@property (nonatomic, strong) KDVoiceMeetingBottomButton *moreBtn;
@property (nonatomic, strong) KDVoiceMeetingBottomButton *muteAllBtn;
@property (nonatomic, strong) UIView *hostModeView;
@property (nonatomic, strong) KDVoiceHostModeTipsView *tipsView;
@property (nonatomic, strong) KDVoiceHostModeGuideView *guideView;

@property (nonatomic, strong) NSMutableArray *personArray;
@property (nonatomic, strong) UILabel *topTipLabel;
@property (nonatomic, strong) NSString *topTipStr;
@property (nonatomic, strong) UIImageView *shareArrow;
@property (nonatomic, strong) UIView *bottomBgView;
@property (nonatomic, strong) KDAgoraSDKManager *agoraSDKManager;
@property (nonatomic, assign) BOOL needJoinChannel;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) KDVoiceMeetingMeImageView *meImageView;
@property (nonatomic, strong) CALayer *grayLayer;
@property (nonatomic, strong) CALayer *blueLayer;
@property (nonatomic, strong) UIButton *quitChatButton;
@property (nonatomic, strong) NSDictionary *createTalkParamDict;
@property (nonatomic, strong) ContactClient *stopSpeakerClient;

@property (nonatomic, strong) KDFileShareBanner *fileShareBanner;
@property (nonatomic, strong) KDAgoraVoiceBanner *agoraVoiceBanner;
@property (nonatomic, strong) KDPlusMenuView *plusMenuView;
@property (nonatomic, assign) BOOL bShowingPlusMenu;
@property (nonatomic, strong) ContactClient *mCallStartRecordClient;
@property (nonatomic, strong) ContactClient *mCallFinishClient;
@property (nonatomic, assign) BOOL fileShareEnable;
@property (nonatomic, assign) BOOL isCallCreator;
@property (nonatomic) dispatch_queue_t dispatchQueue;

@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) KDVoicePopView *voicePopView;//更多弹出的View
@property (nonatomic, strong) ContactClient *addPersonClient;


@end

@implementation KDMultiVoiceViewController

- (ContactClient *)mCallStartRecordClient
{
    if(!_mCallStartRecordClient)
    {
        _mCallStartRecordClient = [[ContactClient alloc] initWithTarget:self action:@selector(mCallStartRecord:result:)];
    }
    return  _mCallStartRecordClient;
}

- (ContactClient *)mCallFinishClient
{
    if(!_mCallFinishClient)
    {
        _mCallFinishClient = [[ContactClient alloc] initWithTarget:self action:@selector(mCallFinishRecord:result:)];
    }
    return _mCallFinishClient;
}

- (NSMutableArray *)personArray {
    if (!_personArray) {
        _personArray = [NSMutableArray array];
    }
    return _personArray;
}

- (dispatch_queue_t)dispatchQueue{
    if(!_dispatchQueue){
        _dispatchQueue = dispatch_queue_create("com.agoraModel.com", NULL);
    }
    return _dispatchQueue;
}

- (KDVoiceHostModeGuideView *)guideView {
    if (!_guideView) {
        _guideView = [[KDVoiceHostModeGuideView alloc] initWithFrame:CGRectZero];
    }
    return _guideView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 10001)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        //参与人退出会议
        if(buttonIndex == 1)
        {
//            [KDEventAnalysis event:event_second_voice_end];
            [self reloadTitle];
            self.agoraSDKManager.agoraPersonsChangeBlock = nil;
            [self.agoraSDKManager leaveChannel];
            [self.agoraSDKManager agoraLogout];
            [self multiVoiceBack:nil];
        }
    }else if(alertView.tag == 10002)
    {
        if (buttonIndex == 0)
        {
            [self multiVoiceBack:nil];
        }
    }else if(alertView.tag == 10003)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if(buttonIndex == 1)
        {
            //结束会议
//            [KDEventAnalysis event:event_first_voice_end];
            self.agoraSDKManager.agoraPersonsChangeBlock = nil;
            [self.agoraSDKManager sendQuitChannelMessageWithChannelId:self.agoraSDKManager.currentGroupDataModel ?[self.agoraSDKManager.currentGroupDataModel getChannelId]:nil];
            //            [self.agoraSDKManager agoraLogout];
            [self removeTipsView:NO];
            [self multiVoiceBack:nil];
        }
    }else if(alertView.tag == 10004)
    {
        self.agoraSDKManager.isHostMode = NO;
        [self multiVoiceBack:nil];
    }else if(alertView.tag == 10005)
    {
        self.agoraSDKManager.isHostMode = NO;
        [self multiVoiceBack:nil];
    }else if(alertView.tag == 10006)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if(buttonIndex == 1)
        {
            //结束会议
            [self reloadTitle];
            self.agoraSDKManager.agoraPersonsChangeBlock = nil;
            [self.agoraSDKManager leaveChannelAndCloseChannel];
            [self.agoraSDKManager agoraLogout];
            [self removeTipsView:NO];
            [self multiVoiceBack:nil];
        }else if(buttonIndex == 2)
        {
            //退出会议
            [self reloadTitle];
            self.agoraSDKManager.agoraPersonsChangeBlock = nil;
            [self.agoraSDKManager leaveChannel];
            [self.agoraSDKManager agoraLogout];
            [self removeTipsView:NO];
            [self multiVoiceBack:nil];
        }
    }else if(alertView.tag == 10007)
    {
        if(buttonIndex == 0)
        {
            [self.agoraSDKManager setModeEnable:NO];
            [self.micButton setModeTureFlag:NO];
        }
    }else if(alertView.tag == 11111)
    {
        
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAgoraCreateMyCallNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(self.stopSpeakerClient)
    {
        [self.stopSpeakerClient cancelRequest];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(_plusMenuView)
    {
        [_plusMenuView removeFromSuperview];
        _plusMenuView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.needJoinChannel = YES;
    
    if([self.agoraSDKManager isAgoraTalkIng])
    {
        KDWPSFileShareManager *shareManger = [KDWPSFileShareManager sharedInstance];
        if(!shareManger.accessCode)
        {
            if(_showFileShareBannerFlag)
            {
                [self hiddenFileShareBanner];
            }
        }else{
            if(!_showFileShareBannerFlag)
            {
                [self showFileShareBanner];
            }
        }
    }
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:FC10,NSForegroundColorAttributeName,FS3,NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:FC10,NSForegroundColorAttributeName,FS3,NSFontAttributeName, nil] forState:UIControlStateHighlighted];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:FC10,NSForegroundColorAttributeName,FS3,NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:FC10,NSForegroundColorAttributeName,FS3,NSFontAttributeName, nil] forState:UIControlStateHighlighted];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)setUpRightBarItemWithTitle:(NSString *)title
{
    [self.navigationItem.rightBarButtonItem setTitle:title];
}

- (instancetype)init{
    if(self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(createAgoraCallNotification:)
                                                     name:KDAgoraCreateMyCallNotification
                                                   object:nil];
    }
    return self;
}
- (KDAgoraSDKManager *)agoraSDKManager{
    if(!_agoraSDKManager){
        _agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
        self.agoraSDKManager.agoraPersonsChangeBlock = [self getAgoraPersonChangeBlock];
        self.agoraSDKManager.agoraTalkHeartBeatBlock = [self getAgoraTalkHeartBeatBlock];
#if !(TARGET_IPHONE_SIMULATOR)
        self.agoraSDKManager.agoraNetworkQualityBlock = [self getAgoraNetworkQualityBlock];
#endif
    }
    return _agoraSDKManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"隐藏"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(leftBarButtonItemDidClick)];
    [self.navigationItem.leftBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdLeftItemDistance], 0)
                                                        forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(quitChatButtonClicked:)];
    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenWindowEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.fileShareEnable = [BOSSetting sharedSetting].fileShareEnable;
    
    _showTopViewFlag = NO;
    _showRedViewFlag = NO;
    
    if(self.groupDataModel.lastMCallStartTimeInterval == 0)
    {
        NSDate *date  = [NSDate date];
        self.groupDataModel.lastMCallStartTimeInterval = [date timeIntervalSince1970] * 1000;
    }
    [self reloadTitle];
    
    [self setUpView];
    
    if(!self.isCreatMyCall && !self.isJoinToChannel)
    {
        //已加入会议直接显示
        self.topTipStr = @"会议正在进行中";
        self.topTipLabel.text = [NSString stringWithFormat:@"%@  %@", [self heartTimeStrWithTimeout:self.agoraSDKManager.heartbeatTimeout], self.topTipStr];
        [self reloadCollectionView];
        
    }else if(self.isJoinToChannel)
    {
        //已存在会议，加入会议
        self.topTipStr = @"正在加入会议中";
        self.topTipLabel.text = [NSString stringWithFormat:@"%@  %@", [self heartTimeStrWithTimeout:self.agoraSDKManager.heartbeatTimeout], self.topTipStr];
        if(self.agoraSDKManager.isUserLogin)
        {
            NSLog(@"\n----------正在加入会议中 isUserLogin----------");
            [self.agoraSDKManager joinChannelWithGroupDataModel:self.groupDataModel isSelfStartCall:NO];
            [self reloadCollectionView];
        }else{
            [self.agoraSDKManager agoraLoginWithGroupType:self.groupDataModel.isExternalGroup];
            self.needJoinChannel = YES;
        }
    }else if(self.isCreatMyCall)
    {
        self.groupDataModel.mCallCreator = [self commonPersonId];
    }
    [self showTopViewWithTitle:self.topTipStr];
    
    if(self.groupDataModel && self.groupDataModel.recordStatus == 1)
    {
        [self.agoraVoiceBanner whenStartRecordBtnClicked:nil];
    }

    UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTitleViewTapped:)];
    [self.navigationController.navigationBar addGestureRecognizer:titleTap];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    titleTap.numberOfTapsRequired = 5;

    
}


-(BOOL)isCallCreator
{
    return [[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator];
}

- (void)whenTitleViewTapped:(id)sender
{
    NSString *str = [NSString stringWithFormat:@"channelId: %@  account:%@",(self.agoraSDKManager.currentGroupDataModel && [self.agoraSDKManager.currentGroupDataModel getChannelId])?[self.agoraSDKManager.currentGroupDataModel getChannelId]:@"还未获取",self.groupDataModel.mCallCreator?self.groupDataModel.mCallCreator:@"未知"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:str];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"channelid 和发起人account 已复制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

- (void)checkPersonMessageIsComplete {
    NSMutableArray *inCompletePerson = [NSMutableArray array];
    
    for (KDAgoraModel *personModel in self.agoraSDKManager.agoraModelArray) {
        if (personModel) {
            PersonSimpleDataModel *person = personModel.person;
            if(!person || !person.personName || [person.personName isKindOfClass:[NSNull class]] || person.photoUrl == nil)
            {
                [inCompletePerson addObject:personModel.account];
            }
        }
    }
    
    if (inCompletePerson.count > 0) {
        __weak KDMultiVoiceViewController *weakSelf = self;
        
        [KDPersonFetch fetchWithPersonIds:inCompletePerson
                          completionBlock:^(BOOL success, NSArray *persons, BOOL isAdminRight) {
                              if (success && [persons count] > 0) {
                                  for (PersonDataModel *personDataModel in persons) {
                                      NSString *personId = personDataModel.personId;
                                      KDAgoraModel *personModel = [weakSelf.agoraSDKManager findAgoraModelByAccount:personId];
                                      PersonSimpleDataModel *newPerson = [KDCacheHelper personForKey:personId];
                                      NSUInteger *modelIndex = [weakSelf.agoraSDKManager.agoraModelArray indexOfObject:personModel];
                                      personModel.person = newPerson;
                                      [weakSelf.agoraSDKManager.agoraModelArray replaceObjectAtIndex:modelIndex withObject:personModel];
                                  }
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [weakSelf reloadCollectionView];
                                  });
                              }
                          }];
    }
}

- (void)reloadCollectionView
{
    __weak KDMultiVoiceViewController *weakSelf = self;
    //    dispatch_async(self.dispatchQueue, ^{
    if(self.personArray.count>0)
    {
        [self.personArray removeAllObjects];
    }
    
    if(self.agoraSDKManager.agoraModelArray.count>0){
        //排序 发言->举手->静音
        [self.agoraSDKManager.agoraModelArray sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSInteger diff = ((KDAgoraModel *)obj1).mute - ((KDAgoraModel *)obj2).mute;
            if (diff == 0) {
                return NSOrderedSame;
            }
            else {
                return (diff < 0) ? NSOrderedAscending : NSOrderedDescending;
            }
        }];
        
        [self moveCreaterToTheFirst];
        
        [self.personArray addObjectsFromArray:self.agoraSDKManager.agoraModelArray];
        
        __block NSMutableArray *array = self.personArray;
        //设置人员数组,过滤掉当前用户的信息（不显示在collectionView中）
        NSString *commonPersonId = [self commonPersonId];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[KDAgoraModel class]]) {
                KDAgoraModel *personModel = (KDAgoraModel *)obj;
                if (personModel.person) {
                    if ([personModel.person.personId isEqualToString:commonPersonId]) {
                        [array removeObject:obj];
                        *stop = YES;
                    }
                }
            }
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.collectionView reloadData];
        [weakSelf reloadTitle];
    });
    //    });
}

- (void)moveCreaterToTheFirst{
    for (NSInteger index = 0; index < self.agoraSDKManager.agoraModelArray.count; index++) {
        KDAgoraModel *model = [self.agoraSDKManager.agoraModelArray safeObjectAtIndex:index];
        if(model && self.agoraSDKManager.currentGroupDataModel && self.agoraSDKManager.currentGroupDataModel.mCallCreator && model.account && [model.account isEqualToString:self.agoraSDKManager.currentGroupDataModel.mCallCreator]){
            [self.agoraSDKManager.agoraModelArray removeObject:model];
            [self.agoraSDKManager.agoraModelArray insertObject:model atIndex:0];
            break;
        }
    }
}

- (void)reloadTitle{
    if(self.groupDataModel && self.groupDataModel.groupName)
    {
        self.title = [NSString stringWithFormat:@"%@%@",self.groupDataModel.groupName,self.agoraSDKManager.agoraModelArray&&self.agoraSDKManager.agoraModelArray.count>0?[NSString stringWithFormat:@"(%lu人)",(unsigned long)self.agoraSDKManager.agoraModelArray.count]:@""];
    }else{
        self.title = @"语音会议";
    }
}

- (void)setUpView
{
    self.agoraVoiceBanner = [[KDAgoraVoiceBanner alloc] initWithFrame:CGRectZero];
    self.agoraVoiceBanner.titleLabel.text = [self heartTimeStrWithTimeout:self.agoraSDKManager.heartbeatTimeout];
    [self.view addSubview:self.agoraVoiceBanner];
    
    [self.agoraVoiceBanner makeConstraints:^(MASConstraintMaker *make) {
        //banner与navigationBar距离为11,左右间距为40
        make.top.equalTo(self.view.top).offset(80);
        make.left.equalTo(self.view.left).offset(40);
        make.right.equalTo(self.view.right).offset(-40);
        make.height.mas_equalTo(36);
    }];
    [self.agoraVoiceBanner makeMasory];
    [self.agoraVoiceBanner layoutIfNeeded];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenJoinSharePlayBtnClicked:)];
    [self.agoraVoiceBanner addGestureRecognizer:tapGestureRecognizer];
    self.agoraVoiceBanner.userInteractionEnabled = NO;
    
    self.hostModeView = [[UIView alloc] initWithFrame:CGRectZero];
    self.hostModeView.backgroundColor = FC10;
    //14为hostModeView的高度
    self.hostModeView.layer.cornerRadius = 14 / 2;
    self.hostModeView.layer.masksToBounds = YES;
    [self.view addSubview:self.hostModeView];
    self.hostModeView.hidden = YES;
    
    UILabel *hostModeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    hostModeLabel.textColor = FC6;
    hostModeLabel.font = FS9;
    hostModeLabel.textAlignment = NSTextAlignmentCenter;
    hostModeLabel.text = @"主持人模式";
    [self.hostModeView addSubview:hostModeLabel];
    
    [self.hostModeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.agoraVoiceBanner.mas_centerX);
        make.centerY.equalTo(self.agoraVoiceBanner.top);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(14);
    }];
    
    [hostModeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.hostModeView).with.insets(UIEdgeInsetsZero);
    }];
    
    self.topTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.topTipLabel.backgroundColor = [UIColor clearColor];
    self.topTipLabel.textColor = FC2;
    self.topTipLabel.textAlignment = NSTextAlignmentCenter;
    self.topTipLabel.font = FS6;
    
    self.topTipStr = self.agoraSDKManager.isUserLogin? @"会议正在进行中" : @"正在进入会议中";
    self.topTipLabel.text = [NSString stringWithFormat:@"%@  %@", [self heartTimeStrWithTimeout:self.agoraSDKManager.heartbeatTimeout], self.topTipStr];
    
    [self.agoraVoiceBanner addSubview:self.topTipLabel];
    [self.topTipLabel makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18);
        make.left.equalTo(self.agoraVoiceBanner.left).offset(0);
        make.right.equalTo(self.agoraVoiceBanner.right).offset(0);
        make.centerY.mas_equalTo(self.agoraVoiceBanner.mas_centerY).with.offset(-30);
    }];
    
    self.shareArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone_btn_arrow_share"]];
    [self.topTipLabel addSubview:self.shareArrow];
    self.shareArrow.hidden = YES;
    [self.shareArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topTipLabel.mas_centerY);
        make.right.mas_equalTo(self.topTipLabel).with.offset(-[NSNumber kdDistance1]);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(10);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat minSpace = (ScreenFullWidth - 300)/5.0;
    layout.sectionInset = UIEdgeInsetsMake(2, minSpace, 0, minSpace);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 5;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView setBackgroundColor:[UIColor kdBackgroundColor2]];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView registerClass:[KDAgoraPersonCell class] forCellWithReuseIdentifier:@"KDAgoraPersonCell"];
    [self.view addSubview:self.collectionView];
    
    self.bottomBgView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.bottomBgView];
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(self.collectionView);
        make.height.mas_equalTo(44);
    }];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = FC6;
    [self.view addSubview:self.bottomView];
    
    [self.bottomView makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(0);
         make.right.equalTo(self.view.right).with.offset(0);
         make.bottom.equalTo(self.view.bottom).with.offset(0);
         make.height.mas_equalTo(isAboveiPhone6 ? 122 : 114);
     }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(0);
        make.right.equalTo(self.view.right).offset(0);
        make.top.equalTo(self.agoraVoiceBanner.bottom).offset(isAboveiPhone6?28:12);
        make.bottom.equalTo(self.bottomView.top).offset(isAboveiPhone6?-60:-24);
    }];
    
    PersonSimpleDataModel *person = [KDCacheHelper personForKey:[self commonPersonId]];
    NSURL *imageURL = nil;
    if (person.hasHeaderPicture) {
        NSString *url = person.photoUrl;
        NSRange range = [url rangeOfString:@"?"];
        if (range.length != 0) {
            url = [url stringByAppendingString:@"&spec=180"];
        }
        else {
            url = [url stringByAppendingString:@"?spec=180"];
        }
        imageURL = [NSURL URLWithString:url];
    }
    self.meImageView = [[KDVoiceMeetingMeImageView alloc] init];
    self.meImageView.userInteractionEnabled = YES;
    self.meImageView.layer.cornerRadius = 45;
    self.meImageView.layer.masksToBounds = YES;
    [self.bottomView addSubview:self.meImageView];
    if (imageURL != nil) {
        [self.meImageView setImageWithURL:imageURL];
    }
    else {
        [self.meImageView setImage:[UIImage imageNamed:@"user_default_portrait"]];
    }
    
    [self.meImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(90);
    }];
    
    UITapGestureRecognizer *meImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(meImageViewDidTap:)];
    [self.meImageView addGestureRecognizer:meImageViewTap];
    
    //外放
#if !(TARGET_IPHONE_SIMULATOR)
    self.voiceButton = [KDVoiceButtonForMultiVoice buildWithFrame:CGRectZero
                                                           NorImg:@"phone_btn_hf_normal"
                                                           PreImg:@"phone_btn_hf_down"
                                                             Type:KDVoiceButtonType_Speaker
                                                           enable:self.agoraSDKManager.speakerEnable
                                                            agora:self.agoraSDKManager.engineKit];
#endif
    [self.voiceButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.voiceButton];
    
    [self.voiceButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.right).with.offset(-50 - minSpace + 33/2);
        make.top.mas_equalTo(25);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    //静音
#if !(TARGET_IPHONE_SIMULATOR)
    if (self.agoraSDKManager.isHostMode && ![[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
        self.micButton = [KDVoiceButtonForMultiVoice buildWithFrame:CGRectZero
                                                             NorImg:@"phone_btn_handsUp_off"
                                                             PreImg:@"phone_btn_handsUp_on"
                                                               Type:KDVoiceButtonType_HandsUp
                                                             enable:[self isHandsUp]
                                                              agora:self.agoraSDKManager.engineKit];
    }
    else {
        self.micButton = [KDVoiceButtonForMultiVoice buildWithFrame:CGRectZero
                                                             NorImg:@"phone_btn_mute_down"
                                                             PreImg:@"phone_btn_mute_normal"
                                                               Type:KDVoiceButtonType_Mute
                                                             enable:self.agoraSDKManager.modeEnable
                                                              agora:self.agoraSDKManager.engineKit];
    }
#endif
    [self.micButton addTarget:self action:@selector(micButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.micButton];
    
    [self.micButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(50 + minSpace - 33/2);
        make.top.mas_equalTo(25);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];

    if (self.agoraSDKManager.modeEnable) {
        if (self.agoraSDKManager.isHostMode && ![[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
            if ([self isHandsUp]) {
                [self setMeImageViewType:KDVoiceMeetingMeImageViewType_HandsUp];
            }
            else {
                [self setMeImageViewType:KDVoiceMeetingMeImageViewType_HandsDown];
            }
        }
        else {
            [self setMeImageViewType:KDVoiceMeetingMeImageViewType_Mute];
        }
    }
    else {
        [self setMeImageViewType:KDVoiceMeetingMeImageViewType_Speak];
        if (self.agoraSDKManager.isHostMode && ![[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
            [self.micButton changeType:KDVoiceButtonType_Disable NorImg:@"phone_btn_handsUp_disable" PreImg:@"phone_btn_handsUp_disable" enable:NO];
        }
    }
    
    
//    [self.moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.bottomView addSubview:self.moreBtn];
//    [self.moreBtn makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(self.bottomView.mas_centerX);
//        make.bottom.mas_equalTo(self.bottomView.bottom);
//        make.height.mas_equalTo(44);
//    }];
//    self.startSharePlayBtn.hidden = YES;

    
//    if(self.fileShareEnable)
//    {
        self.moreBtn = [KDVoiceMeetingBottomButton buttonWithFrame:CGRectZero title:@"更多" image:[UIImage imageNamed:@"voiceAdd"] imageIsSquare:YES];
        [self.moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.moreBtn];
        [self.moreBtn makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(self.bottomView.mas_centerX);
            make.bottom.mas_equalTo(self.bottomView.bottom);
            make.height.mas_equalTo(44);
        }];
        
        self.muteAllBtn = [KDVoiceMeetingBottomButton buttonWithFrame:CGRectZero title:@"主持人模式" selectedColor:FC10];
        [self.muteAllBtn addTarget:self action:@selector(whenStopModeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.muteAllBtn];
        [self.muteAllBtn makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.view.right);
            make.left.mas_equalTo(self.bottomView.mas_centerX);
            make.bottom.mas_equalTo(self.bottomView.bottom);
            make.height.mas_equalTo(44);
        }];
        self.muteAllBtn.hidden = YES;
        self.moreBtn.hidden = YES;
        if (self.agoraSDKManager.isHostMode) {
            [self.muteAllBtn changeToHostMode];
            [self changeBannerColor];
            [self showTipsView];
        }
//    }
//    else {
//        self.muteAllBtn = [KDVoiceMeetingBottomButton buttonWithFrame:CGRectZero title:@"主持人模式" selectedColor:FC10];
//        [self.muteAllBtn addTarget:self action:@selector(whenStopModeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.bottomView addSubview:self.muteAllBtn];
//        [self.muteAllBtn makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(self.view.right);
//            make.left.mas_equalTo(self.bottomView);
//            make.bottom.mas_equalTo(self.bottomView.bottom);
//            make.height.mas_equalTo(44);
//        }];
//        self.muteAllBtn.hidden = YES;
//        if (self.agoraSDKManager.isHostMode) {
//            [self.muteAllBtn changeToHostMode];
//            [self changeBannerColor];
//            [self showTipsView];
//        }
//    }

    if([[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator])
    {
        [self setUpRightBarItemWithTitle:@"结束会议"];
        if(self.isCallCreator)
        {
            
            self.voicePopView = [[KDVoicePopView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, ScreenFullHeight)];
            self.voicePopView.delegate = self;
            self.voicePopView.enableSharePPT = self.fileShareEnable;
            [AppWindow addSubview:self.voicePopView];
            self.bottomView.backgroundColor = [UIColor colorWithRGB:0xFCFDFD];
            
            
            
            [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(isAboveiPhone6 ? 154 : 146);
            }];
            [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.bottomView.top).offset(isAboveiPhone6?-44:-12);
            }];
            self.startSharePlayBtn.hidden = NO;
            self.moreBtn.hidden = NO;
            self.muteAllBtn.hidden = NO;
        }
    }
    else
    {
        [self setUpRightBarItemWithTitle:@"退出会议"];
        if(self.isCallCreator)
        {
            self.startSharePlayBtn.hidden = YES;
            self.muteAllBtn.hidden = YES;
            self.moreBtn.hidden = YES;
        }
    }
    
    if([self.agoraSDKManager isAgoraTalkIng])
    {
        KDWPSFileShareManager *shareManger = [KDWPSFileShareManager sharedInstance];
        if(shareManger.accessCode && shareManger.serverHost)
        {
            [self showFileShareBanner];
        }
    }
    
    [self.view layoutSubviews];
    //collectionView底部滑动过渡效果
//    [KDSignInUtil insertTransparentGradientWithView:self.bottomBgView];
}

- (BOOL)isHandsUp {
    KDAgoraModel *model = [self.agoraSDKManager findAgoraModelByAccount:[self commonPersonId]];
    BOOL enable = NO;
    if (model && model.mute == 1) {
        //举手状态
        enable = YES;
    }
    return enable;
}

- (NSString *)commonPersonId
{
    return (self.groupDataModel.isExternalGroup ? [BOSConfig sharedConfig].user.externalPersonId : [BOSConfig sharedConfig].user.userId);
}

- (void)meImageViewDidTap:(UITapGestureRecognizer *)gestureRecognizer {
    if ([[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
//        [KDEventAnalysis event:event_first_voice_portrait];
    }
    else {
//        [KDEventAnalysis event:event_second_voice_portrait];
    }
}

- (void)leftBarButtonItemDidClick {
    if ([[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
//        [KDEventAnalysis event:event_first_voice_hide];
    }
    else {
//        [KDEventAnalysis event:event_second_voice_hide];
    }
    [self multiVoiceBack:nil];
}

- (void)multiVoiceBack:(id)sender {
    self.agoraSDKManager.agoraPersonsChangeBlock = nil;
    self.agoraSDKManager.agoraTalkHeartBeatBlock = nil;
#if !(TARGET_IPHONE_SIMULATOR)
    self.agoraSDKManager.agoraNetworkQualityBlock = nil;
#endif
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)voiceButtonClicked:(KDVoiceButtonForMultiVoice *)sender {
    if (![KDAgoraSDKManager sharedAgoraSDKManager].speakerEnable) {
        if ([[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
//            [KDEventAnalysis event:event_first_open_voicealoud];
        }
        else {
//            [KDEventAnalysis event:event_second_open_voicealoud];
        }
        NSString *str = @"扬声器已打开";
        [self showAlertViewWithTitle:str];
    }
    else {
        if ([[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
//            [KDEventAnalysis event:event_first_close_voicealoud];
        }
        else {
//            [KDEventAnalysis event:event_second_close_voicealoud];
        }
        NSString *str = @"扬声器已关闭";
        [self showAlertViewWithTitle:str];
    }
    
    [sender changeState];
}

- (void)micButtonClicked:(KDVoiceButtonForMultiVoice *)sender {
//    if (![[KDAgoraSDKManager sharedAgoraSDKManager] checkMicrophonePermission:nil]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"获取麦克风权限失败,请到手机“设置”-“隐私”-“麦克风”打开云之家权限") message:nil delegate:nil cancelButtonTitle:ASLocalizedString() otherButtonTitles:nil];
//        
////        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"获取麦克风权限失败,请到手机“设置”-“隐私”-“麦克风”打开云之家权限", nil, [KDLocalized bundle], @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"确定", nil, [KDLocalized bundle], @"") otherButtonTitles:nil];
//        [alertView show];
//        return;
//    }
    
    if (sender.type == KDVoiceButtonType_Mute) {
        if ([KDAgoraSDKManager sharedAgoraSDKManager].modeEnable) {
            if ([[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
//                [KDEventAnalysis event:event_first_open_voicetube];
            }
            else {
//                [KDEventAnalysis event:event_second_open_voicetube];
            }
            NSString *str = @"话筒已打开";
            [self showAlertViewWithTitle:str];
        }
        else {
            if ([[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
//                [KDEventAnalysis event:event_first_close_voicetube];
            }
            else {
//                [KDEventAnalysis event:event_second_close_voicetube];
            }
            NSString *str = @"话筒已关闭";
            [self showAlertViewWithTitle:str];
        }
    }
    else if (sender.type == KDVoiceButtonType_HandsUp) {
        if ([self isHandsUp]) {
            NSString *str = @"举手已取消";
            [self showAlertViewWithTitle:str];
        }
        else {
            NSString *str = @"举手成功";
            [self showAlertViewWithTitle:str];
        }
    }
    else if (sender.type == KDVoiceButtonType_Disable) {
        NSString *str = @"话筒已打开,不可举手";
        [self showAlertViewWithTitle:str];
    }
    
    [sender changeState];
}

- (void)quitChatButtonClicked:(UIButton *)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if([[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定要结束会议?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 10003;
        [alertView show];
    }else{
        
        if(!self.agoraSDKManager.agoraModelArray || self.agoraSDKManager.agoraModelArray.count == 1)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定退出或结束当前会议?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"结束会议",@"退出会议", nil];
            alertView.tag = 10006;
            [alertView show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定要退出会议?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 10001;
            [alertView show];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.personArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KDAgoraPersonCell *cell = (KDAgoraPersonCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"KDAgoraPersonCell" forIndexPath:indexPath];
    KDAgoraModel *agoraModel = [self.personArray safeObjectAtIndex:indexPath.row];
    if(self.agoraSDKManager.isUserLogin && self.agoraSDKManager.currentGroupDataModel && [self.groupDataModel.mCallCreator isEqualToString:agoraModel.person.personId]){
        cell.isCreate = true;
    }else{
        cell.isCreate = false;
    }
    cell.agoraModel = agoraModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.agoraSDKManager.isHostMode && [self.groupDataModel.mCallCreator isEqualToString:[self commonPersonId]]) {
        KDAgoraModel *agoraModel = [self.personArray safeObjectAtIndex:indexPath.row];
        if (agoraModel.mute == 0) {
            [self.agoraSDKManager sendPersonStatusMessage:1 personId:agoraModel.account];
        }
        else if (agoraModel.mute == 1 || agoraModel.mute == 2) {
            [self.agoraSDKManager sendPersonStatusMessage:0 personId:agoraModel.account];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}

- (void)createAgoraCallNotification:(NSNotification *)notification
{
    if(!self.agoraSDKManager){
        self.agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAgoraCreateMyCallNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSDictionary *user = notification.userInfo;
    if(user)
    {
        BOOL result = [[user objectForKey:@"result"] boolValue];
        if(result)
        {
            NSDictionary *paramDict = [user objectForKey:@"param"];
            if(paramDict)
            {
                self.groupDataModel.param = paramDict;
                self.createTalkParamDict = paramDict;
                if([[self commonPersonId] isEqual:self.groupDataModel.mCallCreator])
                {
                    [self setUpRightBarItemWithTitle:@"结束会议"];
                    if(self.isCallCreator)
                    {
                        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.height.mas_equalTo(isAboveiPhone6 ? 154 : 146);
                        }];
                        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.bottom.equalTo(self.bottomView.top).offset(isAboveiPhone6?-44:-12);
                        }];
                        self.startSharePlayBtn.hidden = NO;
                        self.muteAllBtn.hidden = NO;
                        self.moreBtn.hidden = NO;
                    }
                }else
                {
                    [self setUpRightBarItemWithTitle:@"退出会议"];
                    if(self.isCallCreator)
                    {
                        self.startSharePlayBtn.hidden = YES;
                        self.muteAllBtn.hidden = YES;
                        self.moreBtn.hidden = YES;
                    }
                }
            }
            //创建会议成功
            if(self.isCreatMyCall)
            {
                [self showTopViewWithTitle:@"正在进入会议中"];
                if(self.agoraSDKManager.isUserLogin)
                {
                    [self.agoraSDKManager joinChannelWithGroupDataModel:self.groupDataModel isSelfStartCall:NO];
                    [self reloadCollectionView];
                }else{
                    self.needJoinChannel = YES;
                    [self.agoraSDKManager  agoraLoginWithGroupType:self.groupDataModel.isExternalGroup];
                }
                
            }
        }else {
            //创建会议失败
            self.agoraSDKManager.currentGroupDataModel = nil;
            self.agoraSDKManager.agoraPersonsChangeBlock = nil;
            if(self.agoraSDKManager.agoraModelArray && self.agoraSDKManager.agoraModelArray.count>0)
            {
                [self.agoraSDKManager.agoraModelArray removeAllObjects];
            }
            [self.agoraSDKManager leaveChannelSimple];
            [self reloadTitle];
            [self performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:2];
        }
    }
}


- (agoraPersonsChangeBlock)getAgoraPersonChangeBlock
{
    __weak KDMultiVoiceViewController *weakSelf = self;
    return ^(KDAgoraPersonsChangeType type,NSString *personId,NSMutableArray *personIdArray,NSArray *speakers){
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (type) {
                case KDAgoraPersonsChange_leave:
                {
                    PersonSimpleDataModel *person = [KDCacheHelper personForKey:personId];
                    if(person)
                    {
                        [self showTopViewWithTitle:[NSString stringWithFormat:@"%@ 退出会议",person.personName]];
                    }
                    
                    [weakSelf reloadCollectionView];
                }
                    break;
                case KDAgoraPersonsChangeType_channelLeave:
                {
                    PersonSimpleDataModel *person = [KDCacheHelper personForKey:personId];
                    if(person)
                    {
                        [weakSelf showTopViewWithTitle:[NSString stringWithFormat:@"%@ 退出会议", person.personName]];
                    }
                    [weakSelf reloadCollectionView];
                }
                    break;
                case KDAgoraPersonsChangeType_join:
                {
                    __block KDAgoraModel *personModel = [self.agoraSDKManager findAgoraModelByAccount:personId];
                    if (personModel) {
                        PersonSimpleDataModel *person = personModel.person;
                        if(person && person.personName && ![person.personName isKindOfClass:[NSNull class]] && person.photoUrl != nil)
                        {
                            [weakSelf showTopViewWithTitle:[NSString stringWithFormat:@"%@ 进入会议", person.personName]];
                        }
                        else {
                            [KDPersonFetch fetchWithPersonIds:@[personId]
                                              completionBlock:^(BOOL success, NSArray *persons, BOOL isAdminRight) {
                                                  if (success && [persons count] > 0) {
                                                      PersonSimpleDataModel *newPerson = [KDCacheHelper personForKey:personId];
                                                      NSUInteger *modelIndex = [weakSelf.agoraSDKManager.agoraModelArray indexOfObject:personModel];
                                                      personModel.person = newPerson;
                                                      [weakSelf.agoraSDKManager.agoraModelArray replaceObjectAtIndex:modelIndex withObject:personModel];
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [weakSelf reloadCollectionView];
                                                      });
                                                  }
                                              }];
                        }
                    }
                    
                    [weakSelf reloadCollectionView];
                }
                    break;
                case KDAgoraPersonsChangeType_personList:
                {
                    [weakSelf checkPersonMessageIsComplete];
                    [weakSelf reloadCollectionView];
                }
                    break;
                case KDAgoraPersonsChangeType_reConnected:
                {
                    //                    [weakSelf showTopViewWithTitle:@"成功连接会议"];
                    //                    [weakSelf hideRedView];
                }
                    break;
                case KDAgoraPersonsChangeType_reConnecting:
                {
                    //                    [weakSelf showTopViewWithTitle: @"正在重新连接会议"];
                    //                    [weakSelf showRedView];
                }
                    break;
                case KDAgoraPersonsChangeType_channelJoinSuccess:
                {
                    [weakSelf reloadCollectionView];
                    [weakSelf showTopViewWithTitle:@"你已成功加入会议"];
                    //                    if(weakSelf.agoraSDKManager.currentGroupDataModel && weakSelf.agoraSDKManager.currentGroupDataModel.micDisable == 1)
                    //加入会议成功后,发起人默认不静音,参与人默认都静音
                    if(weakSelf.agoraSDKManager.currentGroupDataModel && ![[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator])
                    {
                        [weakSelf.micButton setModeTureFlag:YES];
                    }else{
                        [weakSelf.micButton setModeTureFlag:NO];
                    }
                    weakSelf.agoraSDKManager.speakerEnable = NO;
                    [weakSelf.voiceButton setSpeakerTureFlag:weakSelf.agoraSDKManager.speakerEnable];
                }
                    break;
                case KDAgoraPersonsChangeType_loginSuccess:
                {
//                    if(weakSelf.needJoinChannel)
//                    {
//<<<<<<< Updated upstream
                        NSLog(@"\n----------needJoinChannel == YES----------");
//                        weakSelf.needJoinChannel = NO;
                        [weakSelf.agoraSDKManager joinChannelWithGroupDataModel:weakSelf.groupDataModel isSelfStartCall:NO];
//                    }
                    [weakSelf showTopViewWithTitle:ASLocalizedString(@"KDMultiVoiceViewController_Tip_22")];
//=======
//        
//                    [weakSelf.agoraSDKManager joinChannelWithGroupDataModel:weakSelf.groupDataModel isSelfStartCall:NO];
//                    //                    }
//                    [weakSelf showTopViewWithTitle: @"你已成功进入会议"];
//                        NSLog(@"\n----------needJoinChannel == YES----------");
////                    }
//>>>>>>> Stashed changes
                    //                    [weakSelf reloadCollectionView];
                }
                    break;
                case KDAgoraPersonsChangeType_logout:
                {
                    [weakSelf reloadCollectionView];
                    [weakSelf showTopViewWithTitle:@"你已成功退出会议"];
                    [weakSelf performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:2];
                }
                    break;
                case KDAgoraPersonsChangeType_joinFailed:
                {
                    [weakSelf reloadCollectionView];
                    [weakSelf showTopViewWithTitle:@"加入会议失败"];
                    [weakSelf performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:2];
                }break;
                case KDAgoraPersonsChangeType_channelOver:
                {
                    [weakSelf showTopViewWithTitle:@"会议结束"];
                    [weakSelf reloadTitle];
                    [weakSelf performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:2];
                }
                    break;
                case KDAgoraPersonsChangeType_receiveMessageQuitChannel:
                {
                    PersonSimpleDataModel *person = [KDCacheHelper personForKey:personId];
                    if(person && person.personName && ![person.personName isKindOfClass:[NSNull class]])
                    {
                        [weakSelf showTopViewWithTitle:[NSString stringWithFormat:@"发起人%@已经结束本次会议",person.personName]];
                    }else{
                        [weakSelf showTopViewWithTitle:[NSString stringWithFormat:@"发起人已经结束本次会议"]];
                    }
                    [weakSelf reloadTitle];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"发起人%@已经结束本次会议",person.personName] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    alertView.tag = 10004;
                    [alertView show];
                }
                    break;
                case KDAgoraPersonsChangeType_loginFailured:
                {
                    if(weakSelf.createTalkParamDict)
                    {
                        [self.agoraSDKManager closeAgoraGroupTalkWithChannelId:weakSelf.createTalkParamDict[@"channelId"] groupId:weakSelf.groupDataModel.groupId];
                    }
                    [weakSelf showTopViewWithTitle:@"进入会议失败"];
                    [weakSelf reloadTitle];
                    [weakSelf performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:2];
                }
                    break;
                case KDAgoraPersonsChangeType_timeout:
                {
                    [weakSelf showTopViewWithTitle:@"开了三小时的会，也该歇歇啦~"];
                    [weakSelf reloadTitle];
                    [weakSelf performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:2];
                }
                    break;
                case KDAgoraMultiCallGroupType_logoutOccure:
                {
                    [weakSelf showTopViewWithTitle:@"你的帐号已在另一台设备登录"];
                    [weakSelf reloadTitle];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你的帐号已在另一台设备登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] ;
                    alertView.tag = 10005;
                    [alertView show];
                }
                    break;
                case KDAgoraMultiCallGroupType_creatorClose:
                {
                    [weakSelf showTopViewWithTitle:@"发起人已经结束会议"];
                    [weakSelf reloadTitle];
                    [weakSelf.agoraSDKManager leaveChannel];
                    [weakSelf.agoraSDKManager agoraLogout];
                    [weakSelf performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:2];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发起人已经结束会议" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    
                }
                    break;
                case KDAgoraMultiCallGroupType_logout4NetFailued:
                {
                    [weakSelf showTopViewWithTitle:@"重连中…"];
                }
                    break;
                case KDAgoraMultiCallGroupType_createChannelFailued:
                {
                    NSLog(@"\n----------createChannelFailued----------");
                    [weakSelf showTopViewWithTitle:@"当前网络不可用，请检查你的网络设置"];
                    [weakSelf reloadTitle];
                    weakSelf.agoraSDKManager.currentGroupDataModel = nil;
                    if(weakSelf.agoraSDKManager.agoraModelArray.count>0)
                    {
                        [weakSelf.agoraSDKManager.agoraModelArray removeAllObjects];
                    }
                    [weakSelf.agoraSDKManager stopTimer];
                    weakSelf.agoraSDKManager.isUserLogin = NO;
                    [weakSelf performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:2];
                }
                    break;
                case KDAgoraPersonsChangeType_needExitChannel:
                {
                    if(weakSelf.personArray && weakSelf.personArray.count>0)
                    {
                        [weakSelf.personArray removeAllObjects];
                    }
                    [weakSelf.collectionView reloadData];
                    [weakSelf reloadTitle];
                    [weakSelf performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:0];
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraCreatorCloseChannel:
                {
                    [weakSelf showTopViewWithTitle:@"发起人已经结束本次会议"];
                    [weakSelf performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:0];
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraRejoinedFailed:
                {
                    [weakSelf showTopViewWithTitle:@"当前网络不可用，你已退出会议"];
                    [weakSelf reloadTitle];
                    weakSelf.agoraSDKManager.currentGroupDataModel = nil;
                    if(weakSelf.agoraSDKManager.agoraModelArray.count>0)
                    {
                        [weakSelf.agoraSDKManager.agoraModelArray removeAllObjects];
                    }
                    [weakSelf.agoraSDKManager stopTimer];
                    weakSelf.agoraSDKManager.isUserLogin = NO;
                    [weakSelf performSelector:@selector(multiVoiceBack:) withObject:nil afterDelay:2];
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraStopMute:
                {
                    PersonSimpleDataModel *person = nil;
                    if(self.agoraSDKManager.currentGroupDataModel.mCallCreator)
                    {
                        person = [KDCacheHelper personForKey:self.agoraSDKManager.currentGroupDataModel.mCallCreator];
                    }
                    NSString *showDes = [NSString stringWithFormat:@"发起人%@已关闭你的话筒",(person && person.personName) ? person.personName:@""];
                    [weakSelf showAlertViewWithTitle:showDes];
                    [weakSelf.micButton setModeTureFlag:YES];
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraHandsUpSelf:
                {
                    [weakSelf.micButton changeType:KDVoiceButtonType_HandsUp NorImg:@"phone_btn_handsUp_off" PreImg:@"phone_btn_handsUp_on" enable:YES];
                    [weakSelf setMeImageViewType:KDVoiceMeetingMeImageViewType_HandsUp];
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraHandsDownSelf:
                {
                    KDAgoraModel *personModel = [self.agoraSDKManager findAgoraModelByAccount:personId];
                    if (personModel.mute == 2) {
                        [weakSelf setMeImageViewType:KDVoiceMeetingMeImageViewType_HandsDown];
                    }
                    else {
                        [weakSelf setMeImageViewType:KDVoiceMeetingMeImageViewType_Speak];
                    }
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraHandsUpOther:
                {
                    if ([[weakSelf commonPersonId] isEqualToString:weakSelf.groupDataModel.mCallCreator]) {
                        PersonSimpleDataModel *person = [KDCacheHelper personForKey:personId];
                        if(person)
                        {
                            [weakSelf showTopViewWithTitle:[NSString stringWithFormat:@"%@举手,申请发言", person.personName]];
                        }
                    }
                    [weakSelf reloadCollectionView];
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraHandsDownOther:
                {
                    [weakSelf reloadCollectionView];
                }
                    break;
                case KDAgoraMultiCallGroupType_createrMuteMe:
                {
                    if (weakSelf.agoraSDKManager.isHostMode) {
                        [weakSelf showTopViewWithTitle:@"发起人关闭了你的话筒"];
                    }
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraMuteSelf:
                {
                    if (weakSelf.agoraSDKManager.isHostMode && ![[weakSelf commonPersonId] isEqualToString:weakSelf.groupDataModel.mCallCreator]) {
                        [weakSelf.micButton changeType:KDVoiceButtonType_HandsUp NorImg:@"phone_btn_handsUp_off" PreImg:@"phone_btn_handsUp_on" enable:NO];
                        [weakSelf setMeImageViewType:KDVoiceMeetingMeImageViewType_HandsDown];
                    }
                    else {
                        [weakSelf setMeImageViewType:KDVoiceMeetingMeImageViewType_Mute];
                    }
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraUnMuteSelf:
                {
                    [weakSelf setMeImageViewType:KDVoiceMeetingMeImageViewType_Speak];
                    if (weakSelf.agoraSDKManager.isHostMode && ![[weakSelf commonPersonId] isEqualToString:weakSelf.groupDataModel.mCallCreator]) {
                        [weakSelf.micButton changeType:KDVoiceButtonType_Disable NorImg:@"phone_btn_handsUp_disable" PreImg:@"phone_btn_handsUp_disable" enable:NO];
                        [weakSelf showTopViewWithTitle:@"发起人打开了你的话筒"];
                    }
                }
                    break;
                case KDAgoraMultiCallGroupType_reloadCollectionView:
                {
                    [weakSelf reloadCollectionView];
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraMuteOther:
                {
                    [weakSelf reloadCollectionView];
                }
                    break;
                case KDAgoraMultiCallGroupType_agoraUnMuteOther:
                {
                    [weakSelf reloadCollectionView];
                }
                    break;
                case KDAgoraMultiCallGroupType_sharePlayFile:
                {
                    if(!_showFileShareBannerFlag)
                    {
                        [weakSelf showFileShareBanner];
                    }else{
                        KDWPSFileShareManager *shareManager = [KDWPSFileShareManager sharedInstance];
                        PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:shareManager.originatorPersonId];
                        weakSelf.fileShareBanner.titleLabel.text = [NSString stringWithFormat:@"%@ 正在共享文件",person?person.personName:@""];
                    }
                }
                    break;
                case KDAgoraMultiCallGroupType_sharePlayOver:
                {
                    
                }
                    break;
                case KDAgoraMultiCallGroupType_startRecord:
                {
                    [self.agoraVoiceBanner whenStartRecordBtnClicked:nil];
                    NSMutableDictionary *paramDict = [NSMutableDictionary new];
                    if(self.groupDataModel.param)
                    {
                        [paramDict addEntriesFromDictionary:self.groupDataModel.param];
                    }
                    [paramDict setObject:@(1) forKey:@"recordStatus"];
                    self.agoraSDKManager.currentGroupDataModel.param = paramDict;
                    self.groupDataModel.param = paramDict;
                    GroupListDataModel *groupListDataModel = [[GroupListDataModel alloc] init];
                    groupListDataModel.list = [[NSMutableArray alloc] initWithObjects:self.groupDataModel, nil];
                    [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDataModel];
                }
                    break;
                case KDAgoraMultiCallGroupType_finishedRecord:
                {
                    [self.agoraVoiceBanner whenFinishRecordBtnClicked:nil];
                    NSMutableDictionary *paramDict = [NSMutableDictionary new];
                    if(self.groupDataModel.param)
                    {
                        [paramDict addEntriesFromDictionary:self.groupDataModel.param];
                    }
                    [paramDict setObject:@(0) forKey:@"recordStatus"];
                    self.agoraSDKManager.currentGroupDataModel.param = paramDict;
                    self.groupDataModel.param = paramDict;
                    GroupListDataModel *groupListDataModel = [[GroupListDataModel alloc] init];
                    groupListDataModel.list = [[NSMutableArray alloc] initWithObjects:self.groupDataModel, nil];
                    [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDataModel];
                }
                    break;
                case KDAgoraMultiCallGroupType_fileShareFinished:
                {
                    [weakSelf hiddenFileShareBanner];
                }
                    break;
                case KDAgoraMultiCallGroupType_speakerVolumeChanged:
                {
                    if (_showRedViewFlag) {
                        break;
                    }
                    
                    dispatch_async(weakSelf.dispatchQueue, ^{
                        if(!speakers || speakers.count == 0){
                            BOOL isNeedChange = false;
                            if(weakSelf.agoraSDKManager.agoraModelArray.count>0){
                                for (NSInteger index = 0; index<weakSelf.agoraSDKManager.agoraModelArray.count; index++) {
                                    KDAgoraModel *model = weakSelf.agoraSDKManager.agoraModelArray[index];
                                    if(model.volumeType>0){
                                        model.volumeType = 0;
                                        isNeedChange = true;
                                    }
                                }
                                if(isNeedChange){
                                    //                                    dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf reloadCollectionView];
                                    //                                    });
                                }
                            }
                        }else{
#if !(TARGET_IPHONE_SIMULATOR)
                            //在speakers中的用户的动画处理
                            for (AgoraRtcAudioVolumeInfo *speaker in speakers) {
                                //                                NSLog(@"volume: %lu uid:%lu",(unsigned long)speaker.volume,(unsigned long)speaker.uid);
                                NSUInteger uid = speaker.uid;
                                NSUInteger volume = speaker.volume;
                                
                                //当前用户
                                if (uid == 0) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [weakSelf startAnimation:volume];
                                    });
                                }
                                else {
                                    if(weakSelf.personArray.count>0){
                                        for (NSInteger i = 0; i<weakSelf.personArray.count; i++) {
                                            KDAgoraModel *model = weakSelf.personArray[i];
                                            if (model.uid == uid) {
                                                model.volumeType = volume;
                                                [weakSelf.personArray replaceObjectAtIndex:i withObject:model];
                                                KDAgoraPersonCell *cell = (KDAgoraPersonCell *)[weakSelf.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                                                if (cell && model.mute != 2) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [cell startAnimation:volume];
                                                    });
                                                }
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
#endif
                        }
                    });
                }
                    break;
                case KDAgoraMultiCallGroupType_HostMeetingMode:
                {
                    [weakSelf changeBannerColor];
                    [weakSelf showTopViewWithTitle:@"发起人开启主持人模式"];
                    
                    if (![[weakSelf commonPersonId] isEqualToString:weakSelf.groupDataModel.mCallCreator]) {
                        [weakSelf.micButton setModeTureFlag:YES];
                        [weakSelf.micButton changeType:KDVoiceButtonType_HandsUp NorImg:@"phone_btn_handsUp_off" PreImg:@"phone_btn_handsUp_on" enable:NO];
                    }
                    else {
                        [weakSelf.muteAllBtn changeToHostMode];
                    }
                    
                    [weakSelf showTipsView];
                }
                    break;
                case KDAgoraMultiCallGroupType_FreeMeetingMode:
                {
                    [weakSelf changeBannerColor];
                    [weakSelf showTopViewWithTitle:@"发起人关闭主持人模式"];
                    
                    if (![[weakSelf commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
                        [weakSelf.micButton changeType:KDVoiceButtonType_Mute NorImg:@"phone_btn_mute_down" PreImg:@"phone_btn_mute_normal" enable:self.agoraSDKManager.modeEnable
                         ];
                        if (weakSelf.meImageView.imageViewType == KDVoiceMeetingMeImageViewType_HandsUp) {
                            [weakSelf.micButton setModeTureFlag:NO];
                            [weakSelf setMeImageViewType:KDVoiceMeetingMeImageViewType_Speak];
                            [weakSelf.agoraSDKManager sendPersonStatusMessage:3 personId:[weakSelf commonPersonId]];
                        }
                        else if (weakSelf.meImageView.imageViewType == KDVoiceMeetingMeImageViewType_HandsDown) {
                            [weakSelf setMeImageViewType:KDVoiceMeetingMeImageViewType_Mute];
                        }
                    }
                    else {
                        [weakSelf.muteAllBtn changeToFreeMode];
                    }
                    
                    [weakSelf removeTipsView:YES];
                }
                    break;
                case KDAgoraMultiCallGroupType_newAttributeUnMute:
                {
                    [weakSelf reloadCollectionView];
                }
                    break;
                default:
                    break;
            }
        });
    };
}

- (agoraTalkHeartBeatBlock)getAgoraTalkHeartBeatBlock
{
    __weak KDMultiVoiceViewController *weakSelf = self;
    return ^(long long timeout)
    {
        if (weakSelf.personArray.count == 0 && [[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator]) {
            NSLog(@"[weakSelf heartTimeStrWithTimeout:timeout] %@",[weakSelf heartTimeStrWithTimeout:timeout]);
            weakSelf.agoraVoiceBanner.titleLabel.text = [NSString stringWithFormat:@"%@  %@", [weakSelf heartTimeStrWithTimeout:timeout], @"等待其他成员加入"];
        }
        else {
            weakSelf.agoraVoiceBanner.titleLabel.text = [weakSelf heartTimeStrWithTimeout:timeout];
        }
//        NSLog(@"1111111 %@",[weakSelf heartTimeStrWithTimeout:timeout]);
        weakSelf.topTipLabel.text = [NSString stringWithFormat:@"%@  %@", [weakSelf heartTimeStrWithTimeout:timeout], weakSelf.topTipStr];
    };
}

#if !(TARGET_IPHONE_SIMULATOR)
- (agoraNetworkQualityBlock)getAgoraNetworkQualityBlock
{
    __weak KDMultiVoiceViewController *weakSelf = self;
    return ^(AgoraRtcQuality quality)
    {
        if (quality == AgoraRtc_Quality_Excellent || quality == AgoraRtc_Quality_Good) {
            if (_showRedViewFlag) {
                [weakSelf hideRedView];
//                [KDEventAnalysis event:event_Voice_badquality];
            }
        } else if (quality == AgoraRtc_Quality_Down || quality == AgoraRtc_Quality_Poor ||
                   quality == AgoraRtc_Quality_Bad || quality == AgoraRtc_Quality_VBad) {
            if (!_showRedViewFlag) {
                [weakSelf showRedView];
            }
        }
    };
}
#endif

- (NSString *)heartTimeStrWithTimeout:(long long)timeout
{
    timeout = timeout>0?timeout:1;
    NSInteger hour = timeout/3600;
    NSInteger minute = (timeout- hour * 3600)/60;
    NSInteger ss = timeout - hour * 3600 - minute * 60;
    if(hour == 0)
    {
        return  [NSString stringWithFormat:@"%02ld:%02ld",(long)minute,(long)ss];
    }
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)minute,(long)ss];
}

//TipLabel的updateConstraints方法show、hide、reset
- (void)showLabel:(UILabel *)label {
    [label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.agoraVoiceBanner.mas_centerY);
    }];
    [label setNeedsUpdateConstraints];
    [label updateConstraintsIfNeeded];
}

- (void)hideLabel:(UILabel *)label {
    [label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.agoraVoiceBanner.mas_centerY).with.offset(30);
    }];
    [label setNeedsUpdateConstraints];
    [label updateConstraintsIfNeeded];
}

- (void)resetLabel:(UILabel *)label {
    [label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.agoraVoiceBanner.mas_centerY).with.offset(-30);
    }];
}

- (void)showTopViewWithTitle:(NSString *)title
{
    if (_showFileShareBannerFlag) {
        self.agoraVoiceBanner.userInteractionEnabled = YES;
        self.shareArrow.hidden = NO;
    }
    else {
        self.agoraVoiceBanner.userInteractionEnabled = NO;
        self.shareArrow.hidden = YES;
    }
    
    if (!(_showFileShareBannerFlag && _showTopViewFlag)) {
        self.topTipStr = title;
        self.topTipLabel.text = [NSString stringWithFormat:@"%@  %@", [self heartTimeStrWithTimeout:self.agoraSDKManager.heartbeatTimeout], self.topTipStr];
    }
    
    if(_showTopViewFlag)
    {
        return;
    }
    _showTopViewFlag = YES;
    
    [self showLabel:self.topTipLabel];
    [self hideLabel:self.agoraVoiceBanner.titleLabel];
    [UIView animateWithDuration:0.5 animations:^{
        [self.agoraVoiceBanner layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self resetLabel:self.agoraVoiceBanner.titleLabel];
    }];
    if (!_showFileShareBannerFlag) {
        [self performSelector:@selector(hideTopView) withObject:nil afterDelay:3];
    }
}

- (void)hideTopView
{
    [self hideLabel:self.topTipLabel];
    [self showLabel:self.agoraVoiceBanner.titleLabel];
    [UIView animateWithDuration:0.5 animations:^{
        [self.agoraVoiceBanner layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self resetLabel:self.topTipLabel];
        _showTopViewFlag = NO;
        
        if (self.agoraVoiceBanner.titleLabel.frame.origin.y < 0) {
            [self showLabel:self.agoraVoiceBanner.titleLabel];
        }
    }];
}

- (void)showRedView
{
    _showRedViewFlag = YES;
    self.agoraVoiceBanner.userInteractionEnabled = NO;
    
    self.meImageView.lastImageViewType = self.meImageView.imageViewType;
    self.meImageView.imageViewType = KDVoiceMeetingMeImageViewType_BadNetwork;
    
    [self stopAnimation];
}

- (void)hideRedView
{
    [self setMeImageViewType:self.meImageView.lastImageViewType];
    _showRedViewFlag = NO;
}

- (void)showTipsView
{
    if (self.tipsView && self.tipsView.superview) {
        return;
    }
    
    if ([[self commonPersonId] isEqualToString:self.groupDataModel.mCallCreator] && ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kVoiceHostModeTipsCount]).integerValue < 3 && ![[NSUserDefaults standardUserDefaults] boolForKey:kCurrentVoiceHostModeTipsHide]) {
        __weak KDMultiVoiceViewController *weakSelf = self;
        self.tipsView = [[KDVoiceHostModeTipsView alloc] initWithFrame:CGRectZero];
        self.tipsView.clickedBlock = ^(void){
            [weakSelf.guideView show];
        };
        self.tipsView.closeBlock = ^(void){
            [weakSelf removeTipsView:YES];
        };
        [self.bottomView addSubview:self.tipsView];
        [self.tipsView makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(100);
            make.width.mas_equalTo(200);
            make.right.equalTo(self.bottomView).with.offset(-12);
            make.bottom.equalTo(self.bottomView).with.offset(-30);
        }];
    }
}

- (void)removeTipsView:(BOOL)isVoiceHostModeTipsHide
{
    if (self.tipsView && self.tipsView.superview) {
        NSNumber *oldCount = [[NSUserDefaults standardUserDefaults] objectForKey:kVoiceHostModeTipsCount];
        NSNumber *newCount = nil;
        if (oldCount) {
            newCount = [NSNumber numberWithInteger:oldCount.integerValue + 1];
        }
        else {
            newCount = [NSNumber numberWithInteger:1];
        }
        [[NSUserDefaults standardUserDefaults] setObject:newCount forKey:kVoiceHostModeTipsCount];
        
        [self.tipsView removeFromSuperview];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:isVoiceHostModeTipsHide forKey:kCurrentVoiceHostModeTipsHide];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)changeBannerColor
{
    if (_showFileShareBannerFlag) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            self.agoraVoiceBanner.titleLabel.textColor = [UIColor colorWithRGB:0xf87e4e];;
            self.topTipLabel.textColor = [UIColor colorWithRGB:0xf87e4e];
            self.agoraVoiceBanner.backgroundColor = [UIColor colorWithRGB:0xf87e4e alpha:0.2];
            self.agoraVoiceBanner.layer.borderColor = [UIColor colorWithRGB:0xf87e4e alpha:0.2].CGColor;
            self.hostModeView.backgroundColor = [UIColor colorWithRGB:0xf87e4e];
        } completion:^(BOOL finished) {
            self.agoraVoiceBanner.layer.borderColor = [UIColor colorWithRGB:0xf87e4e].CGColor;
            if (self.agoraSDKManager.isHostMode) {
                self.hostModeView.hidden = NO;
            }
            else {
                self.hostModeView.hidden = YES;
            }
        }];
    }
    else if (self.agoraSDKManager.isHostMode) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            self.agoraVoiceBanner.titleLabel.textColor = FC10;
            self.topTipLabel.textColor = FC10;
            self.agoraVoiceBanner.backgroundColor = [UIColor colorWithRGB:0x31D2EA alpha:0.2];
            self.agoraVoiceBanner.layer.borderColor = [UIColor colorWithRGB:0x31D2EA alpha:0.2].CGColor;
            self.hostModeView.backgroundColor = FC10;
        } completion:^(BOOL finished) {
            self.agoraVoiceBanner.layer.borderColor = FC10.CGColor;
            self.hostModeView.hidden = NO;
        }];
    }
    else {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            self.agoraVoiceBanner.titleLabel.textColor = FC2;
            self.topTipLabel.textColor = FC2;
            self.agoraVoiceBanner.backgroundColor = [UIColor kdBackgroundColor7];
            self.agoraVoiceBanner.layer.borderColor = [UIColor colorWithRGB:0x31D2EA alpha:0.2].CGColor;
            self.hostModeView.hidden = YES;
        } completion:^(BOOL finished) {
            self.agoraVoiceBanner.layer.borderColor = [UIColor kdBackgroundColor7].CGColor;
        }];
    }
}

//点击反馈
- (void)setButtonSelected:(UIButton *)button {
    button.selected = YES;
    [self performSelector:@selector(setButtonUnSelected:) withObject:button afterDelay:0.2];
}

- (void)setButtonUnSelected:(UIButton *)button {
    button.selected = NO;
}

//主持人模式按钮
- (void)whenStopModeBtnClicked:(id)sender
{
    [self setButtonSelected:self.muteAllBtn];
//    [KDEventAnalysis event:event_first_voice_allmute];
    [KDPopup showHUD];
    NSString *channelId = self.agoraSDKManager.currentGroupDataModel ?[self.agoraSDKManager.currentGroupDataModel getChannelId]:nil;
    if(channelId)
    {
        if(!self.stopSpeakerClient)
        {
            self.stopSpeakerClient = [[ContactClient alloc] initWithTarget:self action:@selector(stopMuteMyCallDidReceived:result:)];
        }
        if (self.agoraSDKManager.isHostMode) {
            [self.stopSpeakerClient stopMuteMyCallWithGroupId:self.agoraSDKManager.currentGroupDataModel.groupId status:1 channelId:channelId micDisable:0];
        }
        else {
            [self.stopSpeakerClient stopMuteMyCallWithGroupId:self.agoraSDKManager.currentGroupDataModel.groupId status:1 channelId:channelId micDisable:2];
        }
    }
}

- (void)stopMuteMyCallDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [KDPopup hideHUD];
    if (result == nil) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if(result.success)
    {
        if (result.data) {
            NSNumber *micDisable = (NSNumber *)[result.data objectForKey:@"micDisable"];
            if ([micDisable integerValue] == 2) {
                //                NSString *str = @"已关闭所有人的话筒";
                //                [self showTopViewWithTitle:str];
                //                [self showAlertViewWithTitle:str];
                [self.agoraSDKManager sendStopMuteChannelMessageWithChannelId:self.agoraSDKManager.currentGroupDataModel ?[self.agoraSDKManager.currentGroupDataModel getChannelId]:nil];
                [self.agoraSDKManager sendMeetingTypeMessage:2];
            }
            else if ([micDisable integerValue] == 0) {
                [self.agoraSDKManager sendMeetingTypeMessage:0];
            }
        }
    }else{
        if(result.error)
        {
            [self showAlertViewWithTitle:result.error];
        }
    }
}

- (void)showAlertViewWithTitle:(NSString *)title
{
    [KDPopup showHUDToast:title];
}

- (void)moreBtnClick:(id)sender
{
    [self.voicePopView showPopView];
}

//- (void)whenSharePlayBtnClicked:(id)sender
//{
//    [self setButtonSelected:self.startSharePlayBtn];
//    if(!(self.agoraSDKManager.isUserLogin && self.agoraSDKManager.currentGroupDataModel))
//    {
//        [KDPopup showHUDToast:@"请稍后,语音会议加入中"];
//        return;
//    }
//    if (![KDAppOpen isWPSInstalled]) {
//        [KDAppOpen openWPSIntro:nil];
//        return;
//    }
//    
//    KDWPSFileShareManager *fileShareManager = [KDWPSFileShareManager sharedInstance];
//    if(fileShareManager.accessCode && fileShareManager.accessCode.length>0)
//    {
//        [fileShareManager joinWpsSharePlay];
//        return;
//    }
//    XTMyFilesViewController *ctr = [[XTMyFilesViewController alloc] init];
//    ctr.fromType = 2;
//    ctr.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:ctr animated:YES];
//}

//PPT共享的时候banner点击事件
- (void)whenJoinSharePlayBtnClicked:(id)sender
{
//    [KDEventAnalysis event:event_fileshare_permanent];
    KDWPSFileShareManager *shareManager = [KDWPSFileShareManager sharedInstance];
    [shareManager joinWpsSharePlay];
}

- (void)showFileShareBanner
{
    _showFileShareBannerFlag = YES;
    KDWPSFileShareManager *shareManager = [KDWPSFileShareManager sharedInstance];
    NSString *wpsBannerStr = @"";
    if(shareManager.originatorPersonId && [shareManager.originatorPersonId isEqualToString:[self commonPersonId]])
    {
        wpsBannerStr = @"我正在共享文件";
    }else{
        PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:shareManager.originatorPersonId];
        wpsBannerStr =  [NSString stringWithFormat:@"%@ 正在共享文件",person?person.personName:@""];
    }
    
    [self showTopViewWithTitle:wpsBannerStr];
    [self changeBannerColor];
}

- (void)hiddenFileShareBanner
{
    self.agoraVoiceBanner.userInteractionEnabled = NO;
    if (!_showFileShareBannerFlag) {
        return;
    }
    
    _showFileShareBannerFlag = NO;
    [self hideTopView];
    [self changeBannerColor];
}

- (void)setMeImageViewType:(KDVoiceMeetingMeImageViewType)type {
    if (self.meImageView.imageViewType != type) {
        self.meImageView.imageViewType = type;
        switch (type) {
            case KDVoiceMeetingMeImageViewType_Speak:
            {
                if (self.grayLayer == nil) {
                    self.grayLayer = [self setUpGrayLayerInSuperLayer:self.bottomView.layer size:CGSizeMake(95.5, 95.5) tintColor:[UIColor kdBackgroundColor7]];
                }
            }
                break;
            case KDVoiceMeetingMeImageViewType_Mute:
            {
                [self stopAnimation];
            }
                break;
            case KDVoiceMeetingMeImageViewType_HandsUp:
            {
                
            }
                break;
            case KDVoiceMeetingMeImageViewType_HandsDown:
            {
                [self stopAnimation];
            }
                break;
            default:
                break;
        }
    }
}

//当前用户的音量动画
- (CALayer *)setUpGrayLayerInSuperLayer:(CALayer *)superLayer size:(CGSize)size tintColor:(UIColor *)tintColor {
    CAShapeLayer *circle = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenFullWidth / 2, 45) radius:size.height/2 startAngle:M_PI/2 endAngle:5.0/2 * M_PI clockwise:YES];
    circle.path = path.CGPath;
    circle.fillColor = nil;
    circle.lineWidth = 2.5;
    circle.strokeColor = tintColor.CGColor;
    [superLayer addSublayer:circle];
    [superLayer insertSublayer:circle below:self.meImageView.layer];
    return circle;
}

- (CALayer *)setUpAnimationInLayer:(CALayer *)superLayer size:(CGSize)size tintColor:(UIColor *)tintColor fromValue:(float)fromValue toValue:(float)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @(fromValue);
    animation.toValue = @(toValue);
    animation.duration = 0.3;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenFullWidth / 2, 45) radius:size.height/2 startAngle:M_PI/2 endAngle:5.0/2 * M_PI clockwise:YES];
    circle.path = path.CGPath;
    circle.fillColor = nil;
    circle.lineWidth = 2.5;
    circle.strokeColor = tintColor.CGColor;
    [circle addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    [superLayer addSublayer:circle];
    [superLayer insertSublayer:circle below:self.meImageView.layer];
    return circle;
}

- (void)startAnimation:(NSInteger)volume {
    float distance = volume == 0 ? 0 : volume * 1.0 / 255;
    if (distance >= 0) {
        UIColor *color = FC10;
        if (self.blueLayer == nil) {
            self.blueLayer = [self setUpAnimationInLayer:self.bottomView.layer size:CGSizeMake(95.5, 95.5) tintColor:color fromValue:0 toValue:distance];
        }
        else {
            CABasicAnimation *animation = (CABasicAnimation *)[self.blueLayer animationForKey:NSStringFromSelector(@selector(strokeEnd))];
            if (animation) {
                float oldValue = [animation.toValue floatValue];
                if (oldValue != distance) {
                    if (self.blueLayer) {
                        [self.blueLayer removeFromSuperlayer];
                        self.blueLayer = nil;
                    }
                    self.blueLayer = [self setUpAnimationInLayer:self.bottomView.layer size:CGSizeMake(95.5, 95.5) tintColor:color fromValue:oldValue toValue:distance];
                }
            }
            
        }
    }
    else {
        if (self.blueLayer) {
            [self.blueLayer removeFromSuperlayer];
            self.blueLayer = nil;
        }
    }
}

- (void)stopAnimation {
    if (self.blueLayer) {
        [self.blueLayer removeFromSuperlayer];
        self.blueLayer = nil;
    }
    
    if (self.grayLayer) {
        [self.grayLayer removeFromSuperlayer];
        self.grayLayer = nil;
    }
}

- (KDPlusMenuView *)plusMenuView
{
    if (!_plusMenuView)
    {
        __block KDMultiVoiceViewController *weakSelf = self;
        
        _plusMenuView = [[KDPlusMenuView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, ScreenFullHeight)];
        NSMutableArray *mArray = @[].mutableCopy;
        
        
        [mArray addObject:[KDPlusMenuViewModel modelWithTitle:@"全部静音"
                                                    imageName:@"menu_tip_all_mute"
                                                    selection:^
                           {
                               [weakSelf whenStopModeBtnClicked:nil];
                               [weakSelf hidePlusMenu];
                           }]];
        
        if(self.isCallCreator)
        {
            if(self.groupDataModel.recordStatus == 0)
            {
                [mArray addObject:[KDPlusMenuViewModel modelWithTitle:@"开始录音"
                                                            imageName:@"menu_tip_record"
                                                            selection:^
                                   {
                                       [weakSelf startRecordBtnClicked:nil];
                                       [weakSelf hidePlusMenu];
                                   }]];
                
            }else{
                [mArray addObject:[KDPlusMenuViewModel modelWithTitle:@"结束录音"
                                                            imageName:@"menu_tip_record"
                                                            selection:^
                                   {
                                       [weakSelf finishRecordBtnClicked:nil];
                                       [weakSelf hidePlusMenu];
                                   }]];
            }
        }
        _plusMenuView.mArrayModels = mArray;
        
        _plusMenuView.backgroundPressed = ^
        {
            [weakSelf hidePlusMenu];
        };
        _plusMenuView.alpha = 0;
    }
    return _plusMenuView;
}


- (void)whenRightBarItemClicked:(id)sender
{
    if(self.agoraSDKManager.isUserLogin && self.agoraSDKManager.currentGroupDataModel)
    {
        if (self.bShowingPlusMenu)
        {
            [self hidePlusMenu];
        } else {
            [self showPlusMenu];
        }
    }else{
        [KDPopup showHUDToast:@"请稍后,语音会议加入中"];
    }
}

- (void)showPlusMenu
{
    if(!self.plusMenuView.superview)
    {
        if (self.bShowingPlusMenu)
        {
            self.plusMenuView.alpha = 0;
            self.bShowingPlusMenu = NO;
        }
        [AppWindow addSubview:self.plusMenuView];
    }
    [self.plusMenuView restoreTable];
    [UIView animateWithDuration:.25 animations:^
     {
         self.plusMenuView.alpha = 1;
         
     }];
    self.bShowingPlusMenu = YES;
}

- (void)hidePlusMenu
{
    [UIView animateWithDuration:.25 animations:^
     {
         self.plusMenuView.alpha = 0;
         [self.plusMenuView shrinkTable];
     } completion:^(BOOL finished) {
         [_plusMenuView removeFromSuperview];
         _plusMenuView = nil;
     }];
    self.bShowingPlusMenu = NO;
}

- (void)mCallStartRecord:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [KDPopup hideHUD];
    if (result == nil) {
        [self showAlertViewWithTitle:@"开始录音失败"];
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if(result.success)
    {
        [self.agoraSDKManager sendStartRecordMessage];
        [self.agoraVoiceBanner whenStartRecordBtnClicked:nil];
        NSMutableDictionary *paramDict = [NSMutableDictionary new];
        if(self.groupDataModel.param)
        {
            [paramDict addEntriesFromDictionary:self.groupDataModel.param];
        }
        [paramDict setObject:@(1) forKey:@"recordStatus"];
        self.agoraSDKManager.currentGroupDataModel.param = paramDict;
        self.groupDataModel.param = paramDict;
        GroupListDataModel *groupListDataModel = [[GroupListDataModel alloc] init];
        groupListDataModel.list = [[NSMutableArray alloc] initWithObjects:self.groupDataModel, nil];
        [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDataModel];
    }else{
        if(result.error)
        {
            [self showAlertViewWithTitle:result.error];
        }
    }
}

- (void)mCallFinishRecord:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [KDPopup hideHUD];
    if (result == nil) {
        [self showAlertViewWithTitle:@"结束录音失败"];
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if(result.success)
    {
        [self.agoraSDKManager sendFinishRecordMessage];
        [self.agoraVoiceBanner whenFinishRecordBtnClicked:nil];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary new];
        if(self.groupDataModel.param)
        {
            [paramDict addEntriesFromDictionary:self.groupDataModel.param];
        }
        [paramDict setObject:@(0) forKey:@"recordStatus"];
        self.agoraSDKManager.currentGroupDataModel.param = paramDict;
        self.groupDataModel.param = paramDict;
        GroupListDataModel *groupListDataModel = [[GroupListDataModel alloc] init];
        groupListDataModel.list = [[NSMutableArray alloc] initWithObjects:self.groupDataModel, nil];
        [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDataModel];
    }else{
        if(result.error)
        {
            [self showAlertViewWithTitle:result.error];
        }
    }
}

- (void)startRecordBtnClicked:(id)sender
{
    [KDPopup showHUD];
    [self.mCallStartRecordClient mCallRecordStateChangedWithGroundId:self.agoraSDKManager.currentGroupDataModel.groupId status:1 channelId:[self.agoraSDKManager.currentGroupDataModel getChannelId]];
}

- (void)finishRecordBtnClicked:(id)sender
{
    [KDPopup showHUD];
    [self.mCallFinishClient mCallRecordStateChangedWithGroundId:self.agoraSDKManager.currentGroupDataModel.groupId status:0 channelId:[self.agoraSDKManager.currentGroupDataModel getChannelId]];
}

- (void)whenWindowEnterForeground
{
    if([self.agoraSDKManager isAgoraTalkIng])
    {
        KDWPSFileShareManager *shareManger = [KDWPSFileShareManager sharedInstance];
        if(!shareManger.accessCode)
        {
            if(_showFileShareBannerFlag)
            {
                [self hiddenFileShareBanner];
            }
        }else{
            if(!_showFileShareBannerFlag)
            {
                [self showFileShareBanner];
            }
        }
    }
    
}


#pragma mark -KDVoicePopViewDelegate
- (void)invitePersonJoinMeeting {
//    [KDEventAnalysis event:event_voice_add];
//    [self.currentMeetingModel updateGroupStatus];
//    [self.agoraSDKManager.currentGroupDataModel updateGroupStatus];
//    if (self.currentMeetingModel.isAddusermark && !self.currentMeetingModel.isManger) {
//        [self addPersonsFromInnerGroup];
//    } else {
//        [self addPersonsFromOtherGroup];
//    }
    
    [self addPersonsFromInnerGroup];
    [self.voicePopView hiddenPopView];
}

- (void)sharePPTForMeeting {
//    [self setButtonSelected:self.startSharePlayBtn];
    if(!(self.agoraSDKManager.isUserLogin && self.agoraSDKManager.currentGroupDataModel))
    {
        [KDPopup showHUDToast:@"请稍后,语音会议加入中"];
        return;
    }
    if (![KDAppOpen isWPSInstalled]) {
        [KDAppOpen openWPSIntro:nil];
        return;
    }
    
    KDWPSFileShareManager *fileShareManager = [KDWPSFileShareManager sharedInstance];
    if(fileShareManager.accessCode && fileShareManager.accessCode.length>0)
    {
        [fileShareManager joinWpsSharePlay];
        return;
    }
    XTMyFilesViewController *ctr = [[XTMyFilesViewController alloc] init];
    ctr.fromType = 2;
    ctr.hidesBottomBarWhenPushed = YES;
    [self.voicePopView hiddenPopView];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)addPersonsFromInnerGroup
{
    //重新拉取，加人后人员变化了
    self.groupDataModel = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:self.groupDataModel.groupId];
    
    __block NSMutableArray *selectedPersons = [[NSMutableArray alloc]init];
    [self.groupDataModel.participant enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
        [selectedPersons addObject:person];
    }];
    
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentAdd];
    contentViewController.delegate = self;
    contentViewController.selectedAgoraPersons = selectedPersons;
    contentViewController.inviteFromAgora = YES;
    contentViewController.exitedGroup = self.groupDataModel;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [self.navigationController presentViewController:contentNav animated:YES completion:nil];
}

#pragma mark - XTChooseContentViewControllerDelegate

- (void)chooseContentView:(XTChooseContentViewController *)controller persons:(NSArray *)persons
{
    __block NSMutableArray *personIdsArr = [NSMutableArray arrayWithCapacity:(persons.count + self.groupDataModel.participantIds.count)];
    for (PersonSimpleDataModel *person in persons) {
        [personIdsArr addObject:person.personId];
    }
    if (self.addPersonClient == nil) {
        self.addPersonClient = [[ContactClient alloc] initWithTarget:self action:@selector(addPersonDidReceived:result:)];
    }
    
    [KDPopup showHUDInView:self.view];
    [self.addPersonClient addGroupUserWithGroupId:self.groupDataModel.groupId userIds:personIdsArr];
}

- (void)addPersonDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [KDPopup showHUDToast:result.error inView:self.view];
        return;
    }
    GroupDataModel *tempGroup = [[GroupDataModel alloc]initWithDictionary:result.data];
    if(tempGroup.participant != [NSNull null] && tempGroup.participant.count > 0)
        self.groupDataModel.participant = tempGroup.participant;
    
    if(tempGroup.participantIds != [NSNull null] && tempGroup.participantIds.count > 0)
        self.groupDataModel.participantIds = tempGroup.participantIds;
    
    [KDPopup showHUDToast:ASLocalizedString(@"KDMultiVoiceViewController_invite") inView:self.view];
    
//    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}


@end
