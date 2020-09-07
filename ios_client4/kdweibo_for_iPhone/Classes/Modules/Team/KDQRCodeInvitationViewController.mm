//
//  KDQRCodeInvitationViewController.m
//  kdweibo
//
//  Created by Tan Yingqi on 14-7-8.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDQRCodeInvitationViewController.h"
#import "QREncoder.h"
#import "KDCommunityManager.h"
#import "BOSConfig.h"
#import "UIImage+Extension.h"
#import "MBProgressHUD+Add.h"

#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentMessageObject.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "KDSheet.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "KDPermissionErrorViewController.h"

#define KD_RE_INVITATION_QE_IMAGE_WIDTH   150.0f
#define KDWEIBO_QQ_APP_KEY @"1101093724"


@interface KDQRCodeInvitationViewController ()<UIAlertViewDelegate,UIActionSheetDelegate, KDSheetDelegate>

@property(nonatomic,strong)UILabel *companyNameLabel;
@property(nonatomic,strong)UILabel *qrcodeTypeLabel;
@property(nonatomic,copy)NSString *invitationURL;
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)NSString *appId;
@property(nonatomic,strong)NSString *ticket;
@property(nonatomic,strong)UIView * backgroundView;
@property(nonatomic,strong)NSString * userName;
@property(nonatomic,strong)UIImage * qrcodeImage;
@property(nonatomic,strong)TencentOAuth * tencentOAuth;
@property (nonatomic, strong) UIButton *buttonShare;
@property (nonatomic, strong) UIButton *buttonCopy;
@property (nonatomic, strong) KDSheet *sheet;


@end
static NSString * const buttonImageNames[] = {@"invite_img_phone",@"invite_img_wechat",@"invite_img_qq",@"invite_img_sina"};
static NSString * const buttonTitles[] = {ASLocalizedString(@"保存到手机"),ASLocalizedString(@"分享到微信"),ASLocalizedString(@"分享到QQ"),ASLocalizedString(@"分享到微博")};

//static NSString * const shareTextString =[NSString stringWithFormat:ASLocalizedString(@"我在%@创建了“%@”的工作圈，很多同事都在这了，扫一扫下面的二维码就能加入了!"),KD_APPNAME];



@implementation KDQRCodeInvitationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.appId = @"102";
        self.canShare = NO;
        self.title = ASLocalizedString(@"面对面邀请");
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoteDidSucc:) name:KD_NOTE_SHARE_DID_SUCC object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KD_NOTE_SHARE_DID_SUCC object:nil];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor3];
    
    
    //    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [rightButton setFrame:CGRectMake(0.0, 0.0, 50, 50)];
    //    [rightButton setBackgroundImage:[UIImage imageNamed:@"head_btn_share"] forState:UIControlStateNormal];
    //    [rightButton setBackgroundImage:[UIImage imageNamed:@"head_btn_share_press"] forState:UIControlStateHighlighted];
    //    [rightButton addTarget:self action:@selector(showShareActionSheet) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    //    self.navigationItem.rightBarButtonItem = rightItem;
    
    //获取信息
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    CompanyDataModel *currentUser = communityManager.currentCompany;
    UserDataModel * userDataModel = currentUser.user;
    _userName = userDataModel.name;
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    // scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds) + 20);
    scrollView.backgroundColor = [UIColor clearColor];
    
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(7.5, 12, CGRectGetWidth(self.view.bounds) - 15, 250)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [scrollView  addSubview:backgroundView];
    self.backgroundView = backgroundView;
    
    //企业头像
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 54, 54)];
    iconView.image = [UIImage imageNamed:@"icon"];
    iconView.clipsToBounds = YES;
    iconView.layer.cornerRadius = 4;
    [backgroundView addSubview:iconView];
    
    //邀请人信息
    UILabel * userLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame) +3, 17, CGRectGetWidth(backgroundView.bounds)- 29 -(CGRectGetMaxX(iconView.frame) +33), 16)];
    userLabel.textColor = UIColorFromRGB(0x808080);
    userLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    userLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    userLabel.textAlignment = NSTextAlignmentCenter;
    userLabel.text = [NSString stringWithFormat:ASLocalizedString(@"%@邀请你"),_userName];
    [backgroundView addSubview:userLabel];
    
    //提示信息
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame) +3, CGRectGetMaxY(userLabel.frame)+8, CGRectGetWidth(backgroundView.bounds)- 29 -(CGRectGetMaxX(iconView.frame) +33), 16)];
    label1.textColor = UIColorFromRGB(0x808080);
    label1.font = [UIFont systemFontOfSize:14.0f];
    label1.backgroundColor = [UIColor clearColor];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = ASLocalizedString(@"扫描二维码加入工作圈");
    
    [backgroundView addSubview:label1];
    
    //企业名称
    self.companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(label1.frame) +20.0f, CGRectGetWidth(backgroundView.bounds), 16)];
    _companyNameLabel.textColor = [UIColor blackColor];
    _companyNameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _companyNameLabel.textAlignment = NSTextAlignmentCenter;
    _companyNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _companyNameLabel.backgroundColor = [UIColor clearColor];
    self.companyNameLabel.text = currentUser.name;
    [backgroundView addSubview:_companyNameLabel];
    
    //二维码图片
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(backgroundView.bounds) - KD_RE_INVITATION_QE_IMAGE_WIDTH)/2.0, CGRectGetMaxY(_companyNameLabel.frame) + 9.0f, KD_RE_INVITATION_QE_IMAGE_WIDTH, KD_RE_INVITATION_QE_IMAGE_WIDTH)];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    _imageView.backgroundColor = [UIColor lightGrayColor];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    [backgroundView  addSubview:_imageView];
    
    
    self.qrcodeTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imageView.frame)+10.0f,  CGRectGetWidth(backgroundView.bounds), 18)];
    self.qrcodeTypeLabel.center = CGPointMake(backgroundView.center.x, self.qrcodeTypeLabel.center.y);
    _qrcodeTypeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [backgroundView addSubview:_qrcodeTypeLabel];
    _qrcodeTypeLabel.textColor = UIColorFromRGB(0x808080);
    _qrcodeTypeLabel.text = ASLocalizedString(@"需要管理员审核");
    _qrcodeTypeLabel.font = [UIFont systemFontOfSize:14.0f];
    _qrcodeTypeLabel.textAlignment = NSTextAlignmentCenter;
    
    
    CGRect rect = backgroundView.frame;
    rect.size.height = CGRectGetMaxY(_qrcodeTypeLabel.frame) + 17.0f;
    backgroundView.frame = rect;
    
    
    [scrollView addSubview:self.buttonCopy];
    [scrollView addSubview:self.buttonShare];
    
    [self getURL];
    
}


- (void)getURL {
    [self showHud:YES];
    __weak typeof(self) welf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        [self hideHud:YES];
        if([response isValidResponse]) {
            if(results) {
                NSString * url = results[@"url"];
                NSString * timeline = results[@"timeline"];
                if (timeline && [timeline length] > 0 && self.type != KDVerificationTypeShould) {
                    
                    // 2014-09-22 16:30:22 -> 2014-09-22 16:30
                    // string->date
                    NSString *dateString = timeline;
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *dateFromString = [[NSDate alloc] init];
                    dateFromString = [dateFormatter dateFromString:dateString];
                    // date->string
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                    NSString *stringDate = [dateFormatter stringFromDate:dateFromString];
                    
                    welf.qrcodeTypeLabel.text = [NSString stringWithFormat:ASLocalizedString(@"有效时间至：%@ "),stringDate];
                }
                if (url && [url length] > 0) {
                    welf.invitationURL = url;
                    [welf getQRcodeImage];
                    welf.canShare = YES;
                }
                
                [KDEventAnalysis event:event_invite_send attributes:@{ label_invite_send_inviteType : label_invite_send_inviteType_facetoface }];
            }
        }else {
            
        }
        if (!welf.canShare) {
            [welf getUrlFailed];
        }
    };
    [self getInvitationURLWithCompleteBlock:completionBlock source:@"4"];
}

- (void)getQRcodeImage {
    DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:self.invitationURL];
    //then render the matrix
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:KD_RE_INVITATION_QE_IMAGE_WIDTH];
    self.imageView.image = qrcodeImage;
    self.imageView.backgroundColor = [UIColor clearColor];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma ShareButton Method
-(void)saveImageToPhone{
    if ([self canVisitAlbum]) {
        UIImageWriteToSavedPhotosAlbum([self shareQrCodeImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }
    else{
        [self showNoPermissionView];
    }
}

// 保存相册的指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    
    if(error != NULL){
        [MBProgressHUD showError:ASLocalizedString(@"KDVideoPickerViewController_save_fail")toView:nil];
        
    }else{
        
        [MBProgressHUD showSuccess:ASLocalizedString(@"SavePhoto_Success") toView:nil];
        
    }
}


-(UIImage *)shareQrCodeImage{
    if (_qrcodeImage) {
        return _qrcodeImage;
    }
    UIGraphicsBeginImageContext(_backgroundView.bounds.size);
    [_backgroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    _qrcodeImage = img;
    return _qrcodeImage;
}

-(BOOL)canVisitAlbum{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied)
    {
        return NO;
    }
    return YES;
}

- (void)showNoPermissionView
{
    KDPermissionErrorViewController * viewController = [[KDPermissionErrorViewController alloc]init];
    UINavigationController * navigation = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self presentViewController:navigation animated:YES completion:nil];
    
}
/*
 -(void)showShareActionSheet{
 UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"分享二维码")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"保存到手机"),ASLocalizedString(@"分享到微信"),ASLocalizedString(@"分享到QQ"),ASLocalizedString(@"分享到新浪微博"), nil];
 [actionSheet showInView:self.view];
 }
 
 #pragma mark -
 #pragma mark UIAlertView Delegate
 - (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
 NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
 if (title) {
 if ([title isEqualToString:ASLocalizedString(@"保存到手机")]) {
 [self saveImageToPhone];
 }
 else if ([title isEqualToString:ASLocalizedString(@"分享到微信")]) {
 [self shareToWechat];
 }
 else if ([title isEqualToString:ASLocalizedString(@"分享到QQ")]) {
 [self shareToQQ];
 }
 else if ([title isEqualToString:ASLocalizedString(@"分享到新浪微博")]) {
 [self shareToSinaWeibo];
 
 }
 }
 }
 
 */
- (KDSheet *)sheet
{
    if (!_sheet)
    {
        _sheet = [[KDSheet alloc]initImageWithShareWay:KDSheetShareWayWechat | KDSheetShareWayQQ | KDSheetShareWayWeibo
                                             imageData:UIImageJPEGRepresentation([self shareQrCodeImage], 1) viewController:self];
        
        _sheet.delegate = self;
    }
    return _sheet;
}

- (void)onNoteDidSucc:(NSNotification *)note
{
    int shareWay = [note.userInfo[KD_NOTE_USERINFO_KEY_SHAREWAY] intValue];
    
    NSString *strResult;
    
    if (shareWay & KDSheetShareWayQQ) {
        strResult = label_invite_link_share_inviteType_qq;
    }
    else if (shareWay == KDSheetShareWayWeibo) {
        strResult = label_invite_link_share_inviteType_weibo;
    }
    else if (shareWay == KDSheetShareWaySMS) {
        strResult = label_invite_link_share_inviteType_sms;
    }
    else {
        strResult = label_invite_link_share_inviteType_weixin;
    }
    
    [KDEventAnalysis event:event_invite_facebyface_share attributes:@{label_invite_facebyface_share_inviteType : strResult}];
}

- (void)buttonPressedWithShareWay:(KDSheetShareWay)shareWay
{
    //这里不作记录了，成功后再记录 -> onNoteDidSucc
}

- (UIButton *)buttonShare
{
    if (!_buttonShare)
    {
        _buttonShare = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDVoteViewController_Share")];
        
        
        _buttonShare.titleLabel.font = FS2;
        [_buttonShare addTarget:self action:@selector(buttonSharePressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_buttonShare];
        
        [_buttonShare makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.view.left).with.offset(12);
             make.right.equalTo(self.view.right).with.offset(-12);
             make.top.equalTo(self.qrcodeTypeLabel.bottom).with.offset(20);
             make.height.mas_equalTo(44);
             make.centerX.equalTo(self.view.centerX);
         }];
        
        [_buttonShare setCircle];
//        _buttonShare = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_buttonShare addTarget:self action:@selector(buttonSharePressed) forControlEvents:UIControlEventTouchUpInside];
//        [_buttonShare setTitle:ASLocalizedString(@"分享")forState:UIControlStateNormal];
//        _buttonShare.layer.cornerRadius = 5;
//        _buttonShare.titleLabel.font = [UIFont systemFontOfSize:16];
//        _buttonShare.backgroundColor = UIColorFromRGB(0x20c000);
//        CGRect rect = self.backgroundView.frame;
//        _buttonShare.frame = CGRectMake(15,CGRectGetHeight(rect)+22,CGRectGetWidth(self.view.frame) - 20,42);
    }
    return _buttonShare;
}

- (UIButton *)buttonCopy
{
    if (!_buttonCopy)
    {
        _buttonCopy = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonCopy addTarget:self action:@selector(buttonCopyPressed) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCopy setTitle:ASLocalizedString(@"保存到本地")forState:UIControlStateNormal];
        [_buttonCopy setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _buttonCopy.layer.cornerRadius = 5;
        _buttonCopy.titleLabel.font = [UIFont systemFontOfSize:16];
        _buttonCopy.backgroundColor = [UIColor whiteColor];
        CGRect rect = self.backgroundView.frame;
        
        _buttonCopy.frame = CGRectMake(15,CGRectGetHeight(rect)+22+42+10,CGRectGetWidth(self.view.frame) - 20,42);
    }
    return _buttonCopy;
}


- (void)buttonCopyPressed
{
    [self saveImageToPhone];
}

- (void)buttonSharePressed
{
    [self.sheet share];
}

/*
 
 -(void)shareToQQ{
 [[KDSocialsShareManager shareSocialsShareManager]shareToQQImage:[self shareQrCodeImage] title:ASLocalizedString(@"二维码邀请")description:ASLocalizedString(@"二维码邀请")previewImage:[self shareQrCodeImage] delegate:self];
 }
 
 -(void)shareToSinaWeibo{
 [[KDSocialsShareManager shareSocialsShareManager] shareToSinaWeiboText:[NSString stringWithFormat:shareTextString,self.companyNameLabel.text]
 image:[self shareQrCodeImage]];
 }
 
 -(void)shareToWechat{
 [[KDSocialsShareManager shareSocialsShareManager]shareToWeChatImage:[self shareQrCodeImage] thumbImage:[self shareQrCodeImage]];
 }
 
 
 -(void)handleQQresponseCode:(NSNumber *)codeNumber{
 //取消所有发送结果的提示----我大奇哥的要求
 //     NSString * message = nil;
 //    switch (code)
 //    {
 //        case EQQAPISENDSUCESS:{
 //            message = ASLocalizedString(@"分享成功！");
 //            break;
 //        }
 //        case EQQAPIQQNOTINSTALLED:{
 //            message = ASLocalizedString(@"分享失败，你目前还没有安装手机QQ！");
 //            break;
 //        }
 //        case EQQAPIAPPNOTREGISTED:
 //        case EQQAPIMESSAGECONTENTINVALID:
 //        case EQQAPIMESSAGECONTENTNULL:
 //        case EQQAPIMESSAGETYPEINVALID:
 //        case EQQAPIQQNOTSUPPORTAPI:
 //        case EQQAPISENDFAILD:
 //        {
 //            message = ASLocalizedString(@"分享失败！");
 //            break;
 //        }
 //        default:
 //        {
 //            message = ASLocalizedString(@"分享失败！");
 //            break;
 //        }
 //    }
 //    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"温馨提示")message:message  delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
 //    [alertView show];
 
 }
 
 */
@end
