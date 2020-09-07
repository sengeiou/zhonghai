//
//  XTFilePreviewViewController.m
//  XT
//
//  Created by kingdee eas on 13-11-7.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTFileDetailViewController.h"
#import "XTFilePreviewViewController.h"
#import "XTChooseContentViewController.h"
#import "XTFileUtils.h"
#import "UIImage+XT.h"
#import "UIButton+XT.h"
#import "XTForwardDataModel.h"
#import "KDCommunityShareView.h"
#import "XTWbClient.h"
#import "MBProgressHUD.h"
#import "KDWpsTool.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "KDWebViewController.h"
#import "XTPersonsCollectionView.h"
#import "XTPersonalFilesController.h"
#import "XTFileInGroupReadAndUnReadUsersController.h"
#import "XTPersonDetailViewController.h"
//#import "AppDelegate.h"
#import "KDWPSFileShareManager.h"
#import "KDMultiVoiceViewController.h"
#import "KDAppOpen.h"
#import "KDForwardChooseViewController.h"

#define kSchemeOfWPS @"cloudhub"

@interface XTFileDetailViewController ()<KDCloudAPIDelegate,XTChooseContentViewControllerDelegate,XTPersonHeaderViewDelegate,MJPhotoBrowserDelegate
#if !(TARGET_IPHONE_SIMULATOR)
, KWOfficeApiDelegate
#endif
>
{
    NSString *_ownerId;
    NSInteger _readCount;
    NSInteger _uploadCount;
    NSArray *_users;
    PersonSimpleDataModel *_ownerPersonDataModel;
}

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) XTWbClient    *wbClient;

@property (nonatomic, strong) UIImageView *guideLayer;

@property (nonatomic, strong) XTWbClient *fileWbClient;
@property (nonatomic, strong) XTWbClient *findDetailInfoClient;

@property (nonatomic, strong) XTWbClient *openOnlineClient;

@property (nonatomic, strong) UILabel *ownerInfoLabel;
@property (nonatomic, strong) XTPersonsCollectionView *personsCollectionView;
@property (nonatomic, strong) XTPersonHeaderImageView *readUserImageView;
@property (nonatomic, strong) UILabel *readUserContributionLabel;
@property (nonatomic, strong) UILabel *readCountLabel;

@property (nonatomic, assign) BOOL isWPSOpen;

@property (nonatomic, assign) BOOL isNeedRefresh;

@end

@implementation XTFileDetailViewController

- (UIImageView *)guideLayer{
    if (_guideLayer) {
        return _guideLayer;
    }
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    imgView.image = isAboveiPhone5?[UIImage imageNamed:@"file_img_detail_tips1136"]:[UIImage imageNamed:@"file_img_detail_tips960"];
    imgView.userInteractionEnabled = YES;
    //    if(!isAboveiPhone5 && !isAboveiOS7)
    if(!isAboveiPhone5)
    {
        AddY(imgView.frame, -12);
        AddHeight(imgView.frame, 12);
    }
    
    
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    
    CGRect rect = CGRectMake((CGRectGetWidth([[UIScreen mainScreen] bounds]) - 184)*0.5, 235 - 44, 184, 44);
    if (isAboveiPhone5) {
        rect.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - 130.f;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(removeGuideLayer) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:ASLocalizedString(@"KDApplicationViewController_tips_i_know")forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 5.0f;
    button.layer.masksToBounds = YES;
    button.backgroundColor = FC5;
    button.frame = rect;
    [imgView addSubview:button];
    
    _guideLayer = imgView;
    
    return _guideLayer;
}
- (void)removeGuideLayer{
    
    [self.guideLayer removeFromSuperview];
}
- (id)initWithFile:(FileModel *)file
{
    if (self = [super init]) {
        _file = file;
        _client = [[XTCloudClient alloc] init];
        _client.delegate = self;
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setNavigationStyle:KDNavigationStyleYellow];
    
    //屏蔽蒙层
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FILE_DETAIL_SEND_GUIDE"]) {
//        [self.view.window addSubview:self.guideLayer];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FILE_DETAIL_SEND_GUIDE"];
//    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.needDownLoadWhenViewWillAppear == XTFileDetailButtonType_makeDownloadAction || (!self.file.isFinished && self.needDownLoadWhenViewWillAppear == XTFileDetailButtonType_open))
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:self.file.path])
        {
            if (!self.isDownloading)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if(!self.fileWbClient)
                    {
                        self.fileWbClient = [[XTWbClient alloc] initWithTarget:self action:NULL];
                    }
                    [self.fileWbClient markDocMessageWithFileId:self.file.fileId userId:nil messageId:self.messageId networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId threadId:self.threadId];
                });
                self.isDownloading = YES;
                self.downloadBtn.hidden = YES;
                self.progressView.hidden = NO;
                _percentLabel.hidden = NO;
                if(self.isFromSharePlayWPS)
                {
                    self.cancelDownloadBtn.hidden = NO;
                }
                [_client downLoadFileByFile:_file];
//                [KDEventAnalysis event:event_filedetail_download];
            }
        }
    }
}

//- (void)loadView{
//    [super loadView];
//    CGRect bounds = [[UIScreen mainScreen] bounds];
//    bounds.size.height -= StatusBarHeight + NavigationBarHeight;
//    UIView *view = [[UIView alloc] initWithFrame:bounds];
//    self.view = view;
//}
-(void)setupRightBarButtonItem{
    //如果是共享wps 和 来自js且share非yes，则不现实
    if (self.isFromSharePlayWPS ||  ![self allowShare] || self.isReadOnly){
        return;
    }
//    if(!self.isFromSharePlayWPS && !self.isFromJSBridge)
//    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 60, 20);
        [button.titleLabel setFont:FS3];
        button.titleLabel.textAlignment = NSTextAlignmentRight;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:ASLocalizedString(@"XTFileDetailViewController_Share") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItems = @[item];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.isFromJSBridge)
    {
        [self setNavigationStyle:KDNavigationStyleNormal];
    }
    
    self.title = ASLocalizedString(@"XTFileDetailViewController_Detail");
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    
    //商务伙伴权限问题
    if ([BOSConfig sharedConfig].user.partnerType != 1) {
        [self setupRightBarButtonItem];
    }
    
    //解决高度上升
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)
//        self.edgesForExtendedLayout=UIRectEdgeNone;
    
    
    
    CGFloat sY = 50 + 12;
    if (isAboveiPhone5) {
        sY += 32.f;
    }
    
    
    UIImage *image = [UIImage imageNamed:[XTFileUtils fileTypeWithExt:_file.ext needBig:YES]];
    _thumbnailPic = [[UIImageView alloc] initWithImage:image];
    _thumbnailPic.backgroundColor = [UIColor clearColor];
    if (_file.ext && _file.ext.length>0 && [XTFileUtils isPhotoExt:_file.ext]) {
        NSString *url = [NSString stringWithFormat:@"%@%@%@%@", [[KDWeiboServicesContext defaultContext] serverBaseURL], @"/microblog/filesvr/", _file.fileId, @"?thumbnail"];
        [_thumbnailPic setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:_file.ext]]];
    }else{
        _thumbnailPic.image = [UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:_file.ext]];
    }
    
    _thumbnailPic.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - 70.f)*0.5f, sY, 70.0, 70.0);
    [self.view addSubview:_thumbnailPic];
    
    _fileName = [[UILabel alloc] init];
    _fileName.text = _file.name;
    _fileName.textAlignment = NSTextAlignmentCenter;
    _fileName.textColor = FC1;
    _fileName.font = FS4;
    _fileName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _fileName.backgroundColor = [UIColor clearColor];
    _fileName.numberOfLines = 3;
    _fileName.frame = CGRectMake([NSNumber kdDistance1], CGRectGetMaxY(_thumbnailPic.frame) + 15.f, CGRectGetWidth(self.view.frame) -[NSNumber kdDistance1]*2, 90);
    _fileName.preferredMaxLayoutWidth = CGRectGetWidth(_fileName.frame);
    [_fileName sizeToFit];
    _fileName.frame = CGRectMake([NSNumber kdDistance1], CGRectGetMaxY(_thumbnailPic.frame) + 15.f, CGRectGetWidth(self.view.frame) -[NSNumber kdDistance1]*2, CGRectGetHeight(_fileName.frame));
    [self.view addSubview:_fileName];
    
    CGRect frame = _fileName.frame;
    CGFloat fileSizeY = frame.origin.y + frame.size.height + 9.0;
    _fileSize = [[UILabel alloc] initWithFrame:CGRectMake(130.0, fileSizeY, CGRectGetWidth(self.view.frame) - 2 * 130.f, 20.0)];
    _fileSize.text = [XTFileUtils fileSize:_file.size];
    _fileSize.textAlignment = NSTextAlignmentCenter;
    _fileSize.textColor = FC2;
    _fileSize.font = FS7;
    _fileSize.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_fileSize];
    
    //js桥传进来的文件大小是0时，不显示文件大小
    if(_file.size == 0)
        _fileSize.hidden = YES;
    //A.wang 样式修改+30
     CGFloat progressY = fileSizeY + _fileSize.frame.size.height + (CGRectGetHeight(self.view.frame)<= 568 ? 0 : 49.0)+30;
    
    self.progressView =  [[KDProgressView alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], progressY, CGRectGetWidth(self.view.frame) - 2 * [NSNumber kdDistance1], 5.f)];
    self.progressView.progressTintColor = FC5;
    self.progressView.trackTintColor = FC2;
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = 3;
    [self.view addSubview:_progressView];
    _client.progressDelegate = self;
    
    CGFloat left = self.isFromSharePlayWPS ? 25: [NSNumber kdDistance1];
    CGFloat width = self.isFromSharePlayWPS? (CGRectGetWidth(self.view.frame) - 50-26) : CGRectGetWidth(self.view.frame) - 2 * [NSNumber kdDistance1];
    [_progressView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(left);
        make.top.equalTo(self.fileSize.bottom).offset((CGRectGetHeight(self.view.frame)== 480 ? 0 : 49.0+30));
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(5);
    }];

    if(self.isFromSharePlayWPS)
    {
        self.cancelDownloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelDownloadBtn setImage:[UIImage imageNamed:@"app_badge_tip_delete"] forState:UIControlStateNormal];
        [self.cancelDownloadBtn addTarget:self action:@selector(whenCancelDownloadBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelDownloadBtn.hidden = YES;
        [self.view addSubview:self.cancelDownloadBtn];
        [self.cancelDownloadBtn makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.progressView.right).offset(6);
            make.top.equalTo(self.progressView.top).offset(-7.5);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        }];
    }

    
    self.percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(34.f, CGRectGetMaxY(_progressView.frame)+10.f, CGRectGetWidth(self.view.frame) -2*34.f, 20)];
    [self.view addSubview:_percentLabel];
    _percentLabel.textAlignment = NSTextAlignmentCenter;
    _percentLabel.textColor = FC2;
    [_percentLabel setFont:FS7];
    [_percentLabel setBackgroundColor:[UIColor clearColor]];
    
    
    CGFloat downloadY = CGRectGetMinY(_progressView.frame);
    
    _downloadBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"XTFileDetailViewController_DownLoad")];
    [_downloadBtn setBackgroundImage:[UIImage imageWithColor:[UIColor kdNavYellowColor]] forState:UIControlStateNormal];
    [_downloadBtn setBackgroundImage:[UIImage imageWithColor:[UIColor kdNavYellowColor]] forState:UIControlStateHighlighted];
    [_downloadBtn addTarget:self action:@selector(downloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _downloadBtn.frame = CGRectMake(34.f, downloadY, CGRectGetWidth(self.view.bounds) - 2*34.f, 41.0f);
    [_downloadBtn setCircle];
    [self.view addSubview:_downloadBtn];
    
    _openBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"XTFileDetailViewController_Open_File")];
    [_openBtn setBackgroundImage:[UIImage imageWithColor:[UIColor kdNavYellowColor]] forState:UIControlStateNormal];
    [_openBtn setBackgroundImage:[UIImage imageWithColor:[UIColor kdNavYellowColor]] forState:UIControlStateHighlighted];
    _openBtn.frame = _downloadBtn.frame;
    [_openBtn setCircle];
    [_openBtn addTarget:self action:@selector(openBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_openBtn];
    
//    if (![XTFileUtils canOpenFile:self.file.ext]) {
//        [_openBtn setTitle:ASLocalizedString(@"XTFileDetailViewController_DownLoaded")forState:UIControlStateNormal];
//        _openBtn.userInteractionEnabled = NO;
//    }
    
    // 避免第三方应用无法用isFinished属性判断文件是否下载
    if (!self.file.isFinished && !self.isReadOnly) {
        _openBtn.hidden = YES;
    } else {
        _downloadBtn.hidden = YES;
    }
    _progressView.hidden = YES;
    
    progressY = CGRectGetMaxY(_downloadBtn.frame) +8.f;
    
    
            _viewOnlineLable = [[UILabel alloc] initWithFrame:CGRectMake(10.0, CGRectGetMinY(_downloadBtn.frame)-30, 300.0, 25.0)];
            _viewOnlineLable.center = CGPointMake(ScreenFullWidth/2, _viewOnlineLable.center.y);
            //_viewOnlineLable.textColor = BOSCOLORWITHRGBA(0x888888, 1.0);
            _viewOnlineLable.textAlignment = NSTextAlignmentCenter;
            _viewOnlineLable.font = [UIFont systemFontOfSize:14.f];
            _viewOnlineLable.backgroundColor = [UIColor clearColor];
           if([[BOSSetting sharedSetting] openOnlineExt:self.file.ext]){
           
               NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:@"文件可以在线预览" ];
               [attribtStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(4,4)];
               //加下划线
               [attribtStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(4, 4)];
            //赋值
            _viewOnlineLable.attributedText = attribtStr;
            UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelClick:)];
            
            [_viewOnlineLable addGestureRecognizer:gestureRecognizer];
            _viewOnlineLable.userInteractionEnabled = YES;
           }else{
               _viewOnlineLable.text = @"该文件暂不支持在线预览，请下载后查看";
               _viewOnlineLable.userInteractionEnabled = NO;
               
           }
               
            [self.view addSubview:_viewOnlineLable];

     //progressY += 30.0 ;
    
    if (![[BOSSetting sharedSetting] allowFileDownload:self.file.ext] && ![[BOSSetting sharedSetting] attachViewUrlWithId:self.file.fileId])
    {
        if (self.file.isFinished) {
            [_openBtn setTitle:ASLocalizedString(@"XTFileDetailViewController_DownLoaded")forState:UIControlStateNormal];
            _openBtn.userInteractionEnabled = NO;
        }
        
        _unSupportTip = [[UILabel alloc] initWithFrame:CGRectMake(10.0, progressY, 300.0, 25.0)];
        _unSupportTip.center = CGPointMake(ScreenFullWidth/2, _unSupportTip.center.y);
        _unSupportTip.textColor = BOSCOLORWITHRGBA(0x888888, 1.0);
        _unSupportTip.textAlignment = NSTextAlignmentCenter;
        _unSupportTip.text = ASLocalizedString(@"XTFileDetailViewController_NoSupport");
        _unSupportTip.font = [UIFont systemFontOfSize:14.f];
        _unSupportTip.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_unSupportTip];
        
        progressY += 25.0 + 15.f;
    }
    else
        progressY +=  15.f;
    
    UIButton *zfBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [zfBtn setImage:[UIImage imageNamed:@"file_img_zf"] forState:UIControlStateNormal];
    [zfBtn setFrame:CGRectMake(77.f, progressY, 24.f+40.f, 24.f)];
    [zfBtn setTitle:ASLocalizedString(@"KDStatusDetailViewController_Forward")forState:UIControlStateNormal];
    [zfBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -36)];
    [zfBtn setTitleColor:MESSAGE_DATE_COLOR forState:UIControlStateNormal];
    zfBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    zfBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [zfBtn addTarget:self action:@selector(sendToChat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zfBtn];
    
    UIButton *scBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scBtn setImage:[UIImage imageNamed:@"file_img_sc"] forState:UIControlStateNormal];
    [scBtn setFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-77.f-34.f - 20.f, progressY, 24.f+40.f, 24.f)];
    [scBtn setTitle:ASLocalizedString(@"KDABActionTabBar_tips_1")forState:UIControlStateNormal];
    [scBtn setTitleEdgeInsets:UIEdgeInsetsMake(2, 10, 0, -36)];
    [scBtn setTitleColor:MESSAGE_DATE_COLOR forState:UIControlStateNormal];
    scBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [scBtn addTarget:self action:@selector(stowFile) forControlEvents:UIControlEventTouchUpInside];
    scBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    scBtn.tag = 10001;
    [self.view addSubview:scBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) -235)*0.5f,progressY+(CGRectGetHeight(self.view.frame)<= 568 ? 20 : 90), 235, 50.0)];
    label.textColor = BOSCOLORWITHRGBA(0x888888, 1.0);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14.f];
    label.text = @"";//[NSString stringWithFormat:ASLocalizedString(@"XTFileDetailViewController_Check_OnComputer"),KD_APPNAME];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    //    if (isAboveiOS6) {
    //        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:label.attributedText];
    //        [attributedString addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(23, 131, 253) range:NSMakeRange(3, 11)];
    //        [label setAttributedText:attributedString];
    //    }
    [self.view addSubview:label];

        
    
   if(![[BOSSetting sharedSetting] allowFileDownload:_file.ext] )//||![[BOSSetting sharedSetting] openOnlineExt:_file.ext]
    {
        _openBtn.enabled = NO;
        _downloadBtn.enabled = NO;
        _unSupportTip.hidden = NO;
        
        _downloadBtn.backgroundColor = RGBCOLOR(200, 200, 200);
        _openBtn.backgroundColor = RGBCOLOR(200, 200, 200);
    }
    else
        _unSupportTip.hidden = YES;
    
    
    //配置了在线查看url最为优先
    if([[BOSSetting sharedSetting] attachViewUrlWithId:_file.fileId])
    {
        _openBtn.hidden = NO;
        _openBtn.enabled = YES;
        _openBtn.backgroundColor = FC5;
        _downloadBtn.hidden = YES;
    }
    
    
    if (self.isFromJSBridge == YES) {
        [self JSBridgeGoBack];
    }
    else
    {
        UIButton *button = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")];
        [button addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
    
    //获取文件收藏状态
    [self getFileStowState];
    
    if(self.fileDetailFunctionType == XTFileDetailFunctionType_count)
    {
        self.isNeedRefresh = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(!self.fileWbClient)
                self.fileWbClient = [[XTWbClient alloc] initWithTarget:self action:NULL];

            [self.fileWbClient markDocMessageWithFileId:self.file.fileId userId:[BOSConfig sharedConfig].user.wbUserId messageId:self.messageId networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId threadId:self.threadId];
        });
        [self addTopOwnerInfoView];
        [self addCollectionViewHeaderView];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText =ASLocalizedString(@"XTFileDetailViewController_CheckInfo");
        
        [self.findDetailInfoClient findDetailInfoWithFileId:self.file.fileId networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId threadId:self.threadId messageId:self.messageId pageIndex:1 pageSize:20 desc:YES dedicatorId:self.dedicatorId];
    }

    if (self.needDownLoadWhenViewWillAppear == XTFileDetailButtonType_makeDownloadAction
        || (!self.file.isFinished && self.needDownLoadWhenViewWillAppear == XTFileDetailButtonType_open))
    {
        [self downloadBtnClick:_downloadBtn];
    }
    else if(self.needDownLoadWhenViewWillAppear == XTFileDetailButtonType_open)
    {
        [self openBtnClick:_openBtn];
    }
    //同步控制 周展源要求
    if(![self allowShare])
    {
        zfBtn.hidden = YES;
//        scBtn.hidden = YES;
        label.hidden = YES;
    }
    
//    王小眉跟杨岚的神之逻辑，收藏按钮只有公共号图文消息附件点开受控
//    1.受消息转发参数控制的会话消息，包括文件和图片，
//    长按都显示收藏按钮，点击查看详情都有收藏按钮，即会话中的收藏按钮不受控
//    2.受公共号转发参数控制的公共号会话消息，包括发言人发送的消息和公共号群发消息，
//    除了公共号消息附件，其他地方的收藏都不受控，
//    公共号消息附件受公共号转发权限控制，可以转发的时候显示收藏，不可转发的时候不显示收藏按钮
    KDPublicAccountDataModel *pubacc = nil;
    if (self.isFromJSBridge && _file.appId.length > 0) {
        pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:_file.appId];
    }
    
    if(self.isFromJSBridge && pubacc != nil && ![pubacc allowInnerShare])
        scBtn.hidden = YES;
        

    
    
    //云盘只读 单独设置
    if (self.isFromJSBridge && self.isReadOnly) {
        zfBtn.hidden = YES;
        scBtn.hidden = YES;
        label.hidden = YES;
    }
}

-(BOOL)allowShare
{
    //公共号消息网页调用js桥
    KDPublicAccountDataModel *pubacc = nil;
    if (self.isFromJSBridge && _file.appId.length > 0) {
        pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:_file.appId];
    }
    
    if(pubacc)
        return [pubacc allowInnerShare];
    
    //公共号消息列表点击进来
    if(self.pubAccId)
    {
        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicGroupWithPublicPersonId:self.pubAccId];
        if(group.groupType >= GroupTypePublic && group.groupType <= GroupTypeTodo)
            return [group allowInnerShare];
    }
    
    return (!self.isFromJSBridge) && [[BOSSetting sharedSetting] allowMsgInnerMobileShare];
}

- (void)findDetailInfo:(XTWbClient *)client result:(BOSResultDataModel *)result
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (client.hasError) {
        [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTFileDetailViewController_CheckInfo_Fail")message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"XTFileDetailViewController_OK")otherButtonTitles:nil, nil] show];
        
        return;
    }
    if (!result.success) {
        [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTFileDetailViewController_CheckInfo_Fail")message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"XTFileDetailViewController_OK")otherButtonTitles:nil, nil] show];
        
    }
    else {
        NSDictionary *resultData = result.data;
        if(resultData)
        {
            NSDictionary *ownerDic = resultData[@"owner"];
            if(ownerDic && [ownerDic isKindOfClass:[NSDictionary class]])
            {
                PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
                person.wbUserId = [ownerDic objectForKey:@"userId"];
                person.personId = [ownerDic objectForKey:@"personId"];
                person.personName = [ownerDic objectForKey:@"name"];
                person.photoUrl = [ownerDic objectForKey:@"photoUrl"];
                BOOL isOpen = [[ownerDic objectForKey:@"hasOpened"] boolValue];
                if(isOpen)
                    person.status = 3;
                else
                    person.status = 7;
                _ownerId = person.wbUserId;
                _ownerPersonDataModel = self.dedicator;
                if (!_ownerPersonDataModel) {
                    _ownerPersonDataModel = person;
                }
            }
            else
            {
                _ownerId = @"";
                _ownerPersonDataModel = nil;
                
            }
            
            
            NSArray *users = resultData[@"users"];
            
            id readCountD = resultData[@"readCount"];
            if(readCountD && ![readCountD isKindOfClass:[NSNull class]])
            {
                _readCount = [readCountD integerValue];
            }else
            {
                _readCount = 0;
            }
            id uploadCountD = resultData[@"uploadCount"];
            if(uploadCountD && ![uploadCountD isKindOfClass:[NSNull class]])
            {
                _uploadCount = [uploadCountD integerValue];
            }else
            {
                _uploadCount = 0;
            }
            self.readUserContributionLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTFileDetailViewController_File_Num"),(long)_uploadCount];
            
//            switch (self.fileDetailSourceType)
//            {
//                case XTFileDetailSourceTypeSearch://这里有问题 暂时不做区分
//                    _ownerPersonDataModel = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonDetailWithWebPersonId:self.dedicatorId];
//                    break;
//                    
//                default:
//                    _ownerPersonDataModel = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonDetailWithWebPersonId:self.dedicatorId];
//                    break;
//            }
            
            
//            if([_ownerId isEqualToString:self.dedicatorId])
//            {
//                self.ownerInfoLabel.text = _ownerPersonDataModel ? _ownerPersonDataModel.personName : @"";
//            }
//            else
//            {
//                self.ownerInfoLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTFileDetailViewController_Forward"),_ownerPersonDataModel ? _ownerPersonDataModel.personName : @""];
//            }
            
            self.ownerInfoLabel.text = _ownerPersonDataModel ? _ownerPersonDataModel.personName : @"";
            self.readUserImageView.hidden = NO;
            self.readUserImageView.person = _ownerPersonDataModel;
            
            if(users && users.count>0)
            {
                NSMutableArray *userSimpleArray = [NSMutableArray array];
                [users enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *stop) {
                    PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
                    person.wbUserId = [obj objectForKey:@"userId"];
                    person.personId = [obj objectForKey:@"personId"];
                    person.personName = [obj objectForKey:@"name"];
                    person.photoUrl = [obj objectForKey:@"photoUrl"];
                    BOOL isOpen = [[obj objectForKey:@"hasOpened"] boolValue];
                    if(isOpen)
                        person.status = 3;
                    else
                        person.status = 7;
                    [userSimpleArray addObject:person];
                }];
                
                _users = userSimpleArray;//[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithWbPersonIds:userIds];
                if(_users && _users.count>0)
                {
                    [self addPersonsCollectionView];
                }
            }
        }
    }
}


- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    if (self.isDownloading) {
        self.isDownloading = NO;
        self.downloadBtn.hidden = NO;
        self.progressView.hidden = YES;
        if(self.isFromSharePlayWPS)
        {
            self.cancelDownloadBtn.hidden = YES;
        }
        self.progressView.progress = 0.0;
        [_downloadBtn setTitle:ASLocalizedString(@"XTFileDetailViewController_DownLoad")forState:UIControlStateNormal];
        [_client stopRequest];
    }
    
}

- (void)JSBridgeGoBack {
    UIView *leftBarItemView = nil;
    
    UIButton *button = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [button addTarget:self action:@selector(myGoBack) forControlEvents:UIControlEventTouchUpInside];
    
    
    leftBarItemView = button;
    
    
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarItemView];
    
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
}

- (void)myGoBack {
    [self setNavigationStyle:KDNavigationStyleNormal];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goBack:(id)sender {
    [self setNavigationStyle:KDNavigationStyleNormal];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)stowFileDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{
    
    if (client.hasError) {
        [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTChatViewController_Tip_24")message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"XTFileDetailViewController_OK")otherButtonTitles:nil, nil] show];
        [_hud hide:YES];
        return;
    }
    if (!result.success) {
        [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTChatViewController_Tip_24")message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"XTFileDetailViewController_OK")otherButtonTitles:nil, nil] show];
        [_hud hide:YES];
    }
    else{
        
        _file.type = @"STOW";
        UIButton *scBtn = (UIButton *)[self.view viewWithTag:10001];
        [scBtn setImage:[UIImage imageNamed:@"file_img_qxsc"] forState:UIControlStateNormal];
        [scBtn setTitle:ASLocalizedString(@"XTFileDetailViewController_Collect_Cancel")forState:UIControlStateNormal];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FILE_DETAIL_STOW_GUIDE"]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"FILE_DETAIL_STOW_GUIDE"];
            [_hud hide:YES];
            
            [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTChatViewController_Tip_20")message:ASLocalizedString(@"XTChatViewController_Tip_21")delegate:nil cancelButtonTitle:ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_32")otherButtonTitles:nil, nil] show];
        }
        else{
            [_hud setLabelText:ASLocalizedString(@"XTChatViewController_Tip_23")];
            [_hud hide:YES afterDelay:2.0];
        }
    }
    
}

- (void)cancelStowFileDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{
    
    if (client.hasError) {
        [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTFileDetailViewController_Collect_Cancel_Fail")message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"XTFileDetailViewController_OK")otherButtonTitles:nil, nil] show];
        [_hud hide:YES];
        return;
    }
    if (!result.success) {
        [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTFileDetailViewController_Collect_Cancel_Fail")message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"XTFileDetailViewController_OK")otherButtonTitles:nil, nil] show];
        [_hud hide:YES];
    }
    else
    {
        _file.type = @"";
        UIButton *scBtn = (UIButton *)[self.view viewWithTag:10001];
        [scBtn setImage:[UIImage imageNamed:@"file_img_sc"] forState:UIControlStateNormal];
        [scBtn setTitle:ASLocalizedString(@"KDABActionTabBar_tips_1")forState:UIControlStateNormal];
        [_hud setLabelText:ASLocalizedString(@"XTFileDetailViewController_Collect_Cancel_Scuess")];
        [_hud hide:YES afterDelay:2.0];
    }
    
}

//A.wang 在线预览
- (void)receivePreviewFile:(XTWbClient *)client result:(BOSResultDataModel *)result{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (client.hasError) {
        return;
    }
    if (!result.success) {
    }
    else{
         NSString *attactUrl = [result.dictJSON objectForKey:@"pdfUrl"] ;
        self.webController= [[KDWebViewController alloc] initWithUrlString:attactUrl];
        self.webController.title = _file.name;
        self.webController.hidesBottomBarWhenPushed = YES;
        self.webController.isRigthBtnHide = YES;
        [self.navigationController pushViewController:self.webController animated:YES];
        return;
        
    }
    
}

- (void)receiveFileState:(XTWbClient *)client result:(BOSResultDataModel *)result{
    
    if (client.hasError) {
        return;
    }
    if (!result.success) {
    }
    else{
        BOOL isStow = [[result.data objectForKey:@"isStow"] boolValue];
        if(isStow)
        {
            _file.type = @"STOW";
            UIButton *scBtn = (UIButton *)[self.view viewWithTag:10001];
            [scBtn setImage:[UIImage imageNamed:@"file_img_qxsc"] forState:UIControlStateNormal];
            [scBtn setTitle:ASLocalizedString(@"XTFileDetailViewController_Collect_Cancel")forState:UIControlStateNormal];
            
        }
        else
        {
            _file.type = @"";
            UIButton *scBtn = (UIButton *)[self.view viewWithTag:10001];
            [scBtn setImage:[UIImage imageNamed:@"file_img_sc"] forState:UIControlStateNormal];
            [scBtn setTitle:ASLocalizedString(@"KDABActionTabBar_tips_1")forState:UIControlStateNormal];
        }
        
    }
    
}

#pragma mark - Button Action
- (void)sendToChat{
    
    [KDEventAnalysis event:event_filedetail_trans];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[_file.name,[NSString stringWithFormat:@"%d",ForwardMessageFile],[_file messageFileFromFileModel]] forKeys:@[@"message",@"forwardType",@"messageFileDM"]];
    XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:dict];
//    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentForward];
//    contentViewController.delegate = self;
//    contentViewController.forwardData = forwardDM;
//    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
//    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
    
    KDForwardChooseViewController *contentViewController = [[KDForwardChooseViewController alloc] initWithCreateExtenalGroup:YES];
    contentViewController.isFromConversation = YES;
    contentViewController.hidesBottomBarWhenPushed = YES;
    contentViewController.isFromFileDetailViewController = NO;   //触发转发文件埋点
    //contentViewController.fileDetailDictionary = notify.userInfo;
    contentViewController.isMulti = YES;
    contentViewController.forwardData = @[forwardDM];
    contentViewController.delegate = self;
    contentViewController.type = XTChooseContentForward;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
}
- (void)stowFile{
    
    [KDEventAnalysis event:event_filedetail_favorite];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    hud.mode = MBProgressHUDModeText;
    [hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    hud.removeFromSuperViewOnHide = YES;
    [self.view.window addSubview:hud];
    [hud show:YES];
    
    self.hud = hud;
    
    if([_file.type isEqualToString:@"STOW"])
    {
        self.wbClient = [[XTWbClient alloc] initWithTarget:self action:@selector(cancelStowFileDidReceived:result:)];
        [_wbClient cancelStowFile:_file.fileId];
    }
    else
    {
        self.wbClient = [[XTWbClient alloc] initWithTarget:self action:@selector(stowFileDidReceived:result:)];
        [_wbClient stowFile:_file.fileId networkId:[BOSConfig sharedConfig].user.eid];
    }
}

-(void)getFileStowState
{
    self.wbClient = [[XTWbClient alloc] initWithTarget:self action:@selector(receiveFileState:result:)];
    [_wbClient getFileIsStow:_file.fileId];
}

- (void)setProgress:(float)progress{
    
    [_progressView setProgress:progress];
    
    _percentLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTFileDetailViewController_DownLoad_Persent"), progress * 100];
}

- (void)labelClick:(id)sender{
    self.openOnlineClient = [[XTWbClient alloc] initWithTarget:self action:@selector(receivePreviewFile:result:)];
    [_openOnlineClient previewFile:_file.fileId userId:[BOSConfig sharedConfig].user.userId];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText =ASLocalizedString(@"KDChooseOrganizationViewController_Waiting");

}

- (void)downloadBtnClick:(id)sender
{
    if (!self.isDownloading) {
        
        self.isDownloading = YES;
        self.downloadBtn.hidden =YES;
        self.progressView.hidden = NO;
        if(self.isFromSharePlayWPS)
        {
            self.cancelDownloadBtn.hidden = NO;
        }
        if(_file.fileId.length == 0){
            // 若三方轻应用的文件没有fileId，临时生成一个，用于拼接存储下载文件的地址
            _file.fileId = [[NSString stringWithFormat:@"%@_%@",_file.fileDownloadUrl,_file.name] MD5DigestKey];
            [_client downLoadFileByFileUrl:_file];
        }else{
            [_client downLoadFileByFile:_file];
        }
    }
}

- (void)openBtnClick:(id)sender
{
    self.isWPSOpen = NO;
    //假如提供了在线查看的url
    NSString *attactUrl = [[BOSSetting sharedSetting] attachViewUrlWithId:_file.fileId];
    if(attactUrl)
    {
        self.webController= [[KDWebViewController alloc] initWithUrlString:attactUrl];
        self.webController.title = _file.name;
        self.webController.hidesBottomBarWhenPushed = YES;
        self.webController.isRigthBtnHide = YES;
        [self.navigationController pushViewController:self.webController animated:YES];
        return;
    }
    
    //调用wps打开office文档,前提是后台有设置wps参数
    if(([XTFileUtils isDocExt:_file.ext] || [XTFileUtils isTxtExt:_file.ext])&&[[BOSSetting sharedSetting] isWPSControlOpen])
    {
        self.wpsTool = [[KDWpsTool alloc] init];
        self.wpsTool.fileName = _file.name;
        self.wpsTool.filePath = _file.path;
        if(![self.wpsTool openWPSWithFile:_file.path])
        {
            //假如打开失败，刷新下状态
            if (!self.file.isFinished)
            {
                _openBtn.hidden = YES;
                _downloadBtn.hidden = NO;
            }
            else
            {
                _openBtn.hidden = NO;
                _downloadBtn.hidden = YES;
            }
        }
        return;
    }
    
    
    if([XTFileUtils isPhotoExt:_file.ext])
    {
        MJPhoto *mjPhoto = [[MJPhoto alloc] init];
        mjPhoto.url = [NSURL fileURLWithPath:_file.path];
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.delegate = self;
        browser.photos = @[mjPhoto];
        [browser show];
    }
    else
    {
        //为了云盘 下载然后打开
        if (!self.file.isFinished && self.isReadOnly) {
            self.openBtn.hidden = YES;
            [self downloadBtnClick:nil];
            return;
        }
        XTFilePreviewViewController *previewVC = [[XTFilePreviewViewController alloc] initWithFilePath:_file.path andFileExt:_file.ext];
        previewVC.file = _file;
        previewVC.hidesBottomBarWhenPushed = YES;
        previewVC.title = _file.name;
        previewVC.isFromJSBridge = self.isFromJSBridge;
        previewVC.isReadOnly = self.isReadOnly;
        [self.navigationController pushViewController:previewVC animated:YES];
    }
}

//识别二维码
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser scanWithresult:(NSString *)result
{
    __weak __typeof(self) weakSelf = self;
    [[KDQRAnalyse sharedManager] execute:result callbackBlock:^(QRLoginCode qrCode, NSString *qrResult) {
        
        [photoBrowser hide];
        [[KDQRAnalyse sharedManager] gotoResultVCInTargetVC:weakSelf withQRResult:qrResult andQRCode:qrCode];
        
    }];
}


- (void)shareBtnClick:(id)sender
{
    [KDEventAnalysis event:event_filedetail_share];
    
//    KDCommunityShareView *shareView = [[KDCommunityShareView alloc] initWithFrame:self.view.bounds type:KDCommunityShareTypeFile isForIPhone5:isAboveiPhone5];
//    MessageFileDataModel *file = [self.file messageFileFromFileModel];
//    shareView.fileDataModel = file;
//    [self.view addSubview:shareView];
//    [shareView becomeFirstResponderShareView];
    
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    pvc.isSelectRange = YES;
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
    
    draft.content = ASLocalizedString(@"KDCommunityShareView_ShareFile");
    MessageFileDataModel *fileDataModel = [self.file messageFileFromFileModel];
    
    NSString * baseURL = [NSString stringWithFormat:@"%@/%@", [KDWeiboServicesContext defaultContext].serverSNSBaseURL, [KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId];
    KDStatus *status = [draft sendingStatus:nil videoPath:nil];
    KDAttachment * attachment = [[KDAttachment alloc]init];
    attachment.fileId = fileDataModel.file_id;
    attachment.filename = fileDataModel.name;
    attachment.fileSize = [fileDataModel.size integerValue];
    attachment.url = [NSString stringWithFormat:@"%@/filesvr/%@",baseURL,fileDataModel.file_id];
    attachment.objectId = status.statusId;
    attachment.attachmentType = KDAttachmentTypeStatus;
    attachment.contentType = fileDataModel.ext;
    
    pvc.attachment = attachment;
    pvc.fileDataModel = fileDataModel;
    
    pvc.draft = draft;
    [KDWeiboAppDelegate setExtendedLayout:pvc];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showPostViewController:pvc];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}


#pragma mark - XTChooseContentViewControllerDelegate

- (void)popViewController
{
    // 从应用-我的文件进入
    [self setNavigationStyle:KDNavigationStyleNormal];
    if (self.bShouldNotPopToRootVC)
    {
        // currently, do nothing
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 0 ;
        
    }
    else // 从聊天页面进入
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileForwardFinish:)]) {
        [self.delegate fileForwardFinish:self];
    }
}

#pragma mark - KDCloudAPIDelegate
//下载文件完成
-(void)KDCloudAPI:(XTCloudClient *)api didFinishedDownloadWithDownloadPath:(NSString *)downloadPath
{
    self.isDownloading = NO;
    self.file.path = downloadPath;
    
    _progressView.hidden = YES;
    _downloadBtn.hidden = YES;
    _openBtn.hidden = NO;
    
//    if (![XTFileUtils canOpenFile:self.file.ext]) {
//        [_openBtn setTitle:ASLocalizedString(@"XTFileDetailViewController_DownLoaded")forState:UIControlStateNormal];
//        _openBtn.userInteractionEnabled = NO;
//    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(controller:downloadFinishedWithModel:)]) {
        [self.delegate controller:self downloadFinishedWithModel:self.file];
    }
    
    //非图片文件进行加密
    if(![XTFileUtils isPhotoExt:self.file.ext])
    {
        [[KDWpsTool shareInstance] encryptFile:downloadPath complectionBlock:^(BOOL success, NSData *data, NSString *fileCachePath) {
            //office文档分享
            if(self.isFromSharePlayWPS)
                [self sharePlayWPS];
        }];
    }
    else
    {
        if(self.isFromSharePlayWPS)
        {
            self.cancelDownloadBtn.hidden = YES;
            [self sharePlayWPS];
        }
    }
    
    if (!self.isFromSharePlayWPS && self.needDownLoadWhenViewWillAppear == XTFileDetailButtonType_makeDownloadAction)
    {
        self.needDownLoadWhenViewWillAppear = XTFileDetailButtonType_open;
        if (self.delegate && [self.delegate respondsToSelector:@selector(controller:downloadFinishedWithModel:)]) {
            [self.delegate controller:self downloadFinishedWithModel:self.file];
        }
        return;
    }
    else if(self.needDownLoadWhenViewWillAppear == XTFileDetailButtonType_open)
    {
        [self openBtnClick:nil];
    }
}


-(void)sharePlayWPS
{
    //下载完成 开始分享
    NSString *fileName = self.file.name;
    if (!fileName || [fileName isEqualToString:@""]) {
        fileName = [NSString stringWithFormat:@"/%@.%@", self.file.fileId,self.file.ext];
    }
    NSString *path = [[ContactUtils fileFilePathWithFileId:self.file.fileId] stringByAppendingFormat:@".%@", self.file.ext];
    ;
    
    [[KDWPSFileShareManager sharedInstance] startSharePlay:[NSData dataWithContentsOfFile:path] withFileName:self.file.name];
    NSArray *viewsControllers = self.rt_navigationController.viewControllers;
    for (RTContainerController *viewController in viewsControllers) {
        if([viewController.contentViewController isMemberOfClass:[KDMultiVoiceViewController class]])
        {
            [self.navigationController popToViewController:viewController.contentViewController animated:NO];
            return;
        }
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}

//请求失败
-(void)KDCloudAPI:(XTCloudClient *)api didFailedDownloadWithError:(NSError *)error
{
    self.isDownloading = NO;
    [self setProgress:0.0f];
    _progressView.hidden = YES;
    _downloadBtn.hidden = NO;
    _openBtn.hidden = YES;
     self.isWPSOpen = NO;
    
    if(self.isFromSharePlayWPS)
    {
        self.cancelDownloadBtn.hidden = YES;
    }
    [_downloadBtn setTitle:ASLocalizedString(@"XTFileDetailViewController_DownLoad")forState:UIControlStateNormal];
    
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

//请求完成
-(void)KDCloudAPI:(XTCloudClient *)api didFinishedRequestWithResponeString:(NSString *)responeString
{
    
}
//请求失败
-(void)KDCloudAPI:(XTCloudClient *)api didFailedRequestWithError:(NSError *)error
{
    
}

- (void)addTopOwnerInfoView
{
    UIView *topOwerInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50)];
    topOwerInfoView.backgroundColor = [UIColor colorWithRGB:0xf3f5f9];
    [self.view addSubview:topOwerInfoView];
    topOwerInfoView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goingToPersonalFilesController)];
    [topOwerInfoView addGestureRecognizer:tapGesture];
    
    self.readUserImageView = [[XTPersonHeaderImageView alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], 8, 34, 34) checkStatus:NO];
    self.readUserImageView.image = [UIImage imageNamed:@"user_default_portrait"];
    self.readUserImageView.userInteractionEnabled = YES;
    self.readUserImageView.layer.masksToBounds = YES;
    self.readUserImageView.layer.cornerRadius = 6;
    UITapGestureRecognizer *readUserImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goingToPersonDetailViewController)];
    self.readUserImageView.userInteractionEnabled = YES;
    [self.readUserImageView addGestureRecognizer:readUserImageViewTap];
    self.readUserImageView.hidden = YES;
    [topOwerInfoView addSubview:self.readUserImageView];
    
    
    self.ownerInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.readUserImageView.frame) + [NSNumber kdDistance1] , 10, CGRectGetWidth(self.view.frame) - 100, 15)];
    self.ownerInfoLabel.backgroundColor = [UIColor clearColor];
    self.ownerInfoLabel.textColor =FC1;
    self.ownerInfoLabel.font = FS5;
    [topOwerInfoView addSubview:self.ownerInfoLabel];
    self.ownerInfoLabel.text = ASLocalizedString(@"XTFileDetailViewController_Name");
    
    self.readUserContributionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.readUserImageView.frame) + [NSNumber kdDistance1] , CGRectGetMaxY(self.readUserImageView.frame) - 15, CGRectGetWidth(self.ownerInfoLabel.frame), 15)];
    self.readUserContributionLabel.backgroundColor = [UIColor clearColor];
    self.readUserContributionLabel.textColor= FC2;
    self.readUserContributionLabel.font = FS8;
    self.readUserContributionLabel.text = ASLocalizedString(@"XTFileDetailViewController_ZeroFile");
    [topOwerInfoView addSubview:self.readUserContributionLabel];
    
    UIImageView *rightArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 7-[NSNumber kdDistance1],18.5, 7, 13)];
    rightArrowImageView.image = [UIImage imageNamed:@"cell_arrow"];
    [topOwerInfoView addSubview:rightArrowImageView];
    
}

- (void)addPersonsCollectionView
{
    if(_users && _users.count>0)
    {
        if(!self.personsCollectionView)
        {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.minimumInteritemSpacing = 0;
            layout.minimumLineSpacing = 20;
            layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
            
            self.personsCollectionView = [[XTPersonsCollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 84 - kd_StatusBarAndNaviHeight-15, CGRectGetWidth(self.view.frame), 84) collectionViewLayout:layout];
            self.personsCollectionView.deleteDelegate = self;
            [self.view addSubview:self.personsCollectionView];
        }
        
        [self.personsCollectionView setPersonsArray:_users];
        self.readCountLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTFileDetailViewController_Read_Total"),_readCount];
    }
}

- (void)addCollectionViewHeaderView
{
    //A.wang +30
    UIView *collectionViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 106 - kd_StatusBarAndNaviHeight-15, CGRectGetWidth(self.view.frame), 22)];
    collectionViewHeaderView.backgroundColor = [UIColor colorWithRGB:0xf3f5f9];
    [self.view addSubview:collectionViewHeaderView];
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], 0, 60, 22)];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.text = ASLocalizedString(@"XTFileDetailViewController_Read_Current");
    leftLabel.font = FS7;
    leftLabel.textColor = FC1;
    [collectionViewHeaderView addSubview:leftLabel];
    
    self.readCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, CGRectGetWidth(self.view.frame) - 130, 22)];
    self.readCountLabel.backgroundColor = [UIColor clearColor];
    self.readCountLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTFileDetailViewController_Read_Total"),_readCount];
    self.readCountLabel.textColor =FC5;
    self.readCountLabel.font = FS7;
    self.readCountLabel.textAlignment = NSTextAlignmentRight;
    [collectionViewHeaderView addSubview:self.readCountLabel];
    
    UIImageView *rightArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 7 - [NSNumber kdDistance1],3.5, 7, 13)];
    rightArrowImageView.image = [UIImage imageNamed:@"cell_arrow"];
    [collectionViewHeaderView addSubview:rightArrowImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenReadUserTapClicked:)];
    [collectionViewHeaderView addGestureRecognizer:tap];
}

- (XTWbClient *)findDetailInfoClient
{
    if(!_findDetailInfoClient)
    {
        _findDetailInfoClient = [[XTWbClient alloc] initWithTarget:self action:@selector(findDetailInfo:result:)];
    }
    return  _findDetailInfoClient;
}

- (void)goingToPersonalFilesController
{
    XTPersonalFilesController *personalFilesController = [[XTPersonalFilesController alloc] init];
    personalFilesController.personModel = _ownerPersonDataModel;
    personalFilesController.threadId = self.threadId;
    personalFilesController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personalFilesController animated:YES];
}

-(void)goingToPersonDetailViewController
{
    XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:_ownerPersonDataModel with:NO];
    personDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personDetail animated:YES];
}

- (void)whenReadUserTapClicked:(id)sender
{
    XTFileInGroupReadAndUnReadUsersController *controller = [[XTFileInGroupReadAndUnReadUsersController alloc] init];
    controller.threadId = self.threadId;
    controller.fileId = self.file.fileId;
    controller.messageId = self.messageId;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)whenCancelDownloadBtnClicked:(id)sender
{
    self.isDownloading = NO;
    self.downloadBtn.hidden = NO;
    self.progressView.hidden = YES;
    _percentLabel.hidden = YES;
    if(self.isFromSharePlayWPS)
    {
        self.cancelDownloadBtn.hidden = YES;
    }
    self.progressView.progress = 0.0;
    [_client stopRequest];
//    [KDEventAnalysis event:event_fileshare_cance];
    NSArray *viewsControllers = self.rt_navigationController.viewControllers;
    for (RTContainerController *viewController in viewsControllers) {
        if([viewController.contentViewController isMemberOfClass:[KDMultiVoiceViewController class]])
        {
            [self.navigationController popToViewController:viewController.contentViewController animated:NO];
            return;
        }
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - XTPersonHeaderCanDeleteViewDelegate
- (void)personHeaderClicked:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person
{
    XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:NO];
    personDetail.isFromWeibo = YES;
    personDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personDetail animated:YES];
}


-(XTFileDetailButtonType)needDownLoadWhenViewWillAppear {
    if (!_needDownLoadWhenViewWillAppear) {
        _needDownLoadWhenViewWillAppear = XTFileDetailButtonType_default;
    }
    return _needDownLoadWhenViewWillAppear;
}

#if !(TARGET_IPHONE_SIMULATOR)
//2014.12.30 WPS代理方法wanyalin
#pragma mark - KWOfficeApi delegate
//wps回传文件数据
- (void)KWOfficeApiDidReceiveData:(NSDictionary *)dict {}

//wps编辑完成返回 结束与WPS链接
- (void)KWOfficeApiDidFinished {}

//wps退出后台
- (void)KWOfficeApiDidAbort {}

//断开链接
- (void)KWOfficeApiDidCloseWithError:(NSError *)error {}

#endif

- (void)wpsBtnClicked:(id)sender {
//    [KDEventAnalysis event:event_filedetail_open attributes:@{label_filedetail_open_type : label_filedetail_open_type_wps}];
    if (![KDAppOpen isWPSInstalled]) {
        [KDAppOpen openWPSIntro:self];
        return;
    }
    
    if (!self.file.isFinished) {
        [self downloadBtnClick:nil];
        self.isWPSOpen = YES;
        return;
    }
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    NSData *data = [NSData dataWithContentsOfFile:_file.path];
    if (data == nil)
        return;
    NSError *error = nil;
    BOOL isOk = NO;
    
    if ([XTFileUtils isUseWPSOpenExt:_file.ext] || [XTFileUtils isZipExt:_file.ext]) {
        NSDictionary *policyOfUseWPS = nil;
        isOk = [[KWOfficeApi sharedInstance] sendFileData:data
                                             withFileName:_file.name
                                                 callback:kSchemeOfWPS
                                                 delegate:self
                                                   policy:policyOfUseWPS
                                                    error:&error];
    }
    else if (([_file.ext isEqualToString:@"doc"] || [_file.ext isEqualToString:@"docx"]) && ![_file.path hasSuffix:@".txt"]) {
        NSDictionary *policyOfDoc = @{@"wps.document.openInEditMode" : @"1",                      //文档是否以编辑模式打开
                                      @"wps.shell.editmode.toolbar.mark" : @"1",
                                      @"wps.shell.editmode.toolbar.revisionEnable" : @"1",
                                      @"wps.document.saveAs" : @"1",
                                      @"wps.document.localization" : @"1"};
        isOk = [[KWOfficeApi sharedInstance] sendFileData:data
                                             withFileName:_file.name
                                                 callback:kSchemeOfWPS
                                                 delegate:self
                                                   policy:policyOfDoc
                                                    error:&error];
    }
    else if (([_file.ext isEqualToString:@"xls"] || [_file.ext isEqualToString:@"xlsx"] || [_file.ext isEqualToString:@"csv"]) && ![_file.path hasSuffix:@".txt"]) {
        NSDictionary *policyOfXls = @{@"et.document.editMode" : @"1", @"et.document.saveAs" : @"1", @"et.document.localization" : @"1"};
        isOk = [[KWOfficeApi sharedInstance] sendFileData:data
                                             withFileName:_file.name
                                                 callback:kSchemeOfWPS
                                                 delegate:self
                                                   policy:policyOfXls
                                                    error:&error];
    }
    else if (([_file.ext isEqualToString:@"ppt"] || [_file.ext isEqualToString:@"pptx"]) && ![_file.path hasSuffix:@".txt"]) {
        NSDictionary *policyOfPpt = @{@"ppt.document.editMode" : @"1", @"ppt.document.saveAs" : @"1", @"ppt.document.localization" : @"1"};
        isOk = [[KWOfficeApi sharedInstance] sendFileData:data
                                             withFileName:_file.name
                                                 callback:kSchemeOfWPS
                                                 delegate:self
                                                   policy:policyOfPpt
                                                    error:&error];
    }
    else if ([_file.ext isEqualToString:@"pdf"] && ![_file.path hasSuffix:@".txt"]) {
        NSDictionary *policyOfPdf = nil;
        isOk = [[KWOfficeApi sharedInstance] sendFileData:data
                                             withFileName:_file.name
                                                 callback:kSchemeOfWPS
                                                 delegate:self
                                                   policy:policyOfPdf
                                                    error:&error];
    }
    else if ([_file.ext isEqualToString:@"txt"]|| [_file.path hasSuffix:@".txt"]) {
        NSDictionary *policyOfPdf = nil;
        isOk = [[KWOfficeApi sharedInstance] sendFileData:data
                                             withFileName:_file.name
                                                 callback:kSchemeOfWPS
                                                 delegate:self
                                                   policy:policyOfPdf
                                                    error:&error];
    }
    
#endif
}


@end
