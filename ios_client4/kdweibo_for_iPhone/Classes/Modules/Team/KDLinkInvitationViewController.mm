//
//  KDLinkInvitationViewController.m
//  kdweibo
//
//  Created by AlanWong on 14-7-14.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDLinkInvitationViewController.h"
#import "KDCommunityManager.h"
#import "UserDataModel.h"
#import "BOSConfig.h"
#import <MessageUI/MessageUI.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentMessageObject.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "KDSheet.h"
#import "MBProgressHUD+Add.h"
#import "KDSocialsShareManager.h"


@interface KDLinkInvitationViewController () <KDSheetDelegate>
@property(nonatomic,strong)NSArray * buttonTitleArray ;
@property(nonatomic,strong)NSArray * buttonImageNameArray ;
@property(nonatomic,strong)NSString *appId;
@property(nonatomic,strong)XTOpenSystemClient *openClient;
@property(nonatomic,strong)NSString *ticket;
@property(nonatomic,copy)NSString *invitationURL;
@property (nonatomic, strong) MBProgressHUD *hud;
@property(nonatomic,strong)NSString * companyName;
@property(nonatomic,strong)NSString * userName;
@property(nonatomic,strong)NSString * timeString;
@property(nonatomic,strong)TencentOAuth * tencentOAuth;
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic,assign)BOOL canShare;

// 9.18号改造内容
@property (nonatomic, strong) UIView *viewBackgroud;
@property (nonatomic, strong) UIButton *buttonShare;
@property (nonatomic, strong) UIButton *buttonCopy;
@property (nonatomic, strong) UILabel *labelLink;
@property (nonatomic, strong) UILabel *labelCompany;
@property (nonatomic, strong) UILabel *labelDate;

@property (nonatomic, strong) KDSheet *sheet;
@property (nonatomic,strong) NSString *strCopyPasteText;

@end

//static NSString * const shareTextString =[NSString stringWithFormat:ASLocalizedString(@"我在创建了“%@”的工作圈，很多同事都在这了，点击链接就能加入了！链接地址：%@ "),KD_APPNAME];
static NSString * const shareTextStringShould =ASLocalizedString(@"%@邀请你加入【%@】工作圈。%@（需要管理员审核）。");
static NSString * const shareTextStringNone =ASLocalizedString(@"%@邀请你加入【%@】工作圈。%@（有效时间至：%@）。");
#define KDWEIBO_QQ_APP_KEY @"1101093724"

@implementation KDLinkInvitationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.appId = @"102";
        self.canShare = NO;
        self.title = ASLocalizedString(@"生成邀请地址");
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    [self.view addSubview:self.viewBackgroud];
    [self.view addSubview:self.buttonShare];
    [self.view addSubview:self.buttonCopy];
    [self.view addSubview:self.labelCompany];
    [self.view addSubview:self.labelDate];
    [self.view addSubview:self.labelLink];
    
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    CompanyDataModel *currentUser = communityManager.currentCompany;
    _companyName = currentUser.name;
    UserDataModel * userDataModel = currentUser.user;
    _userName = userDataModel.name;
    _labelCompany.text = [NSString stringWithFormat:ASLocalizedString(@"工作圈: %@"),_companyName];
    [self getURL];
    
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

- (void)buttonSharePressed
{
    
    [self.sheet share];
}

- (void)buttonCopyPressed
{
    [[UIPasteboard generalPasteboard] setString:self.strCopyPasteText];
    
    
    [MBProgressHUD showSuccess:ASLocalizedString(@"地址已复制")toView:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)getURL
{
    [self showHud:YES];
    __weak typeof(self) welf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        [self hideHud:YES];
        if([response isValidResponse]) {
            if(results) {
                NSString *url = results[@"url"];
                NSString * timeline = results[@"timeline"];
                if (timeline && [timeline length] > 0 && self.type != KDVerificationTypeShould ) {
                    
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
                    welf.labelDate.text = [NSString stringWithFormat:ASLocalizedString(@"有效时间至：%@ "),stringDate];
                    
                    welf.timeString = timeline;
                }
                if (url && [url length] > 0) {
                    welf.invitationURL = url;
                    self.labelLink.text = url;
                    NSString * message = nil;
                    if (welf.type == KDVerificationTypeNone) {
                        message =[NSString stringWithFormat:shareTextStringNone,welf.userName,welf.companyName,welf.invitationURL,welf.timeString];
                    }
                    else{
                        message = [NSString stringWithFormat:shareTextStringShould,welf.userName,welf.companyName,welf.invitationURL];
                    }
                    self.strCopyPasteText = message;
                    welf.canShare = YES;
                    [welf setButtonEnable:welf.canShare buttonCount:4];
                }
                
                [KDEventAnalysis event:event_invite_send attributes:@{ label_invite_send_inviteType : label_invite_send_inviteType_Link }];
            }
        }else {
            
        }
        if (!welf.canShare) {
            [welf getUrlFailed];
            
        }
        
    };
    [self getInvitationURLWithCompleteBlock:completionBlock source:@"3"];
}

/*
 #pragma mark - ShareButton Method -
 
 -(void)shareButtonTap:(id)sender
 {
 
 UIButton * button = (UIButton *)sender;
 switch (button.tag) {
 case 1000: //分享到短信
 [self shareToMessage];
 break;
 case 1001: //分享到微信
 [self shareToWechat];
 break;
 case 1002: //分享到QQ
 [self shareToQQ];
 break;
 case 1003: //分享到微博
 [self shareToSinaWeibo];
 break;
 default:
 break;
 }
 }
 
 -(void)shareToMessage
 {
 NSString * message = nil;
 if (self.type == KDVerificationTypeNone) {
 message =[NSString stringWithFormat:shareTextStringNone,_userName,_companyName,_invitationURL,_timeString];
 }
 else{
 message = [NSString stringWithFormat:shareTextStringShould,_userName,_companyName,_invitationURL];
 }
 [[KDSocialsShareManager shareSocialsShareManager]shareToMessageText:message delegate:self];
 }
 
 -(void)shareToQQ
 {
 NSString * message;
 if (self.type == KDVerificationTypeNone) {
 message = [NSString stringWithFormat:shareTextStringNone,_userName,_companyName,_invitationURL,_timeString];
 }
 else{
 message = [NSString stringWithFormat:shareTextStringShould,_userName,_companyName,_invitationURL];
 }
 
 [[KDSocialsShareManager shareSocialsShareManager] shareToQQText:message delegate:self];
 }
 
 -(void)shareToSinaWeibo
 {
 NSString * message = nil;
 if (self.type == KDVerificationTypeNone) {
 message = [NSString stringWithFormat:shareTextStringNone,_userName,_companyName,_invitationURL,_timeString];
 }
 else{
 message = [NSString stringWithFormat:shareTextStringShould,_userName,_companyName,_invitationURL];
 }
 [[KDSocialsShareManager shareSocialsShareManager]shareToSinaWeiboText:message image:nil];
 }
 
 -(void)shareToWechat
 {
 NSString * title =  [NSString stringWithFormat:ASLocalizedString(@"我在创建了“%@”的工作圈，现在邀请你加入！"),_companyName];
 NSString * description = [NSString stringWithFormat:shareTextString,_companyName,_invitationURL];
 UIImage * thumbImage = [UIImage imageNamed:@"icon120.png"];
 [[KDSocialsShareManager shareSocialsShareManager]shareToWeChatLinkUrl:_invitationURL title:title description:description thumbImage:thumbImage];
 }
 
 -(void)handleQQresponseCode:(NSNumber *)codeNumber
 {
 
 //    NSInteger code = [codeNumber integerValue];
 //    NSString * message = ASLocalizedString(@"分享失败！");
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
 //            break;
 //        }
 //    }
 //    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"温馨提示")message:message  delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
 //    [alertView show];
 
 }
 
 #pragma mark -  MFMessageComposeViewController Delegate -
 
 -(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
 {
 //取消所有发送结果的提示----我大奇哥的要求
 //    NSString * message = nil;
 //    switch (result)
 //    {
 //        case MessageComposeResultCancelled:
 //            message = ASLocalizedString(@"您已经取消短信分享！");
 //            break;
 //        case MessageComposeResultSent:
 //            message = ASLocalizedString(@"短信分享成功！");
 //            break;
 //        case MessageComposeResultFailed:
 //            message = ASLocalizedString(@"短信分享失败！");
 //            break;
 //        default:
 //            message = ASLocalizedString(@"短信分享失败！");
 //            break;
 //    }
 //
 [self dismissViewControllerAnimated:YES completion:NULL];
 //    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"温馨提示")//                                                        message:message
 //                                                       delegate:nil
 //                                              cancelButtonTitle:ASLocalizedString(@"Global_Sure")//                                              otherButtonTitles: nil];
 //    [alertView show];
 }
 */

- (KDSheet *)sheet
{
    if (!_sheet)
    {
        NSString * message = nil;
        if (self.type == KDVerificationTypeNone)
        {
            message =[NSString stringWithFormat:shareTextStringNone,_userName,_companyName,_invitationURL,_timeString];
        }
        else
        {
            message = [NSString stringWithFormat:shareTextStringShould,_userName,_companyName,_invitationURL];
        }
        NSString *title =  [NSString stringWithFormat:ASLocalizedString(@"我在%@创建了“%@”的工作圈，现在邀请你加入！"),KD_APPNAME,_companyName];
        NSString *description = [NSString stringWithFormat:ASLocalizedString(@"我在%@创建了“%@”的工作圈，很多同事都在这了，点击链接就能加入了！链接地址：%@ "),KD_APPNAME,_companyName,_invitationURL];
        UIImage *thumbImage = [UIImage imageNamed:@"icon120.png"];
        
        _sheet = [[KDSheet alloc]initMediaWithShareWay:KDSheetShareWaySMS | KDSheetShareWayWechat | KDSheetShareWayQQ | KDSheetShareWayWeibo
                                                 title:title
                                           description:description
                                             thumbData:UIImageJPEGRepresentation(thumbImage, 1)
                                            webpageUrl:_invitationURL
                                        viewController:self];
        
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
    
    [KDEventAnalysis event:event_invite_link_share attributes:@{label_invite_link_share_inviteType : strResult}];
}

- (void)buttonPressedWithShareWay:(KDSheetShareWay)shareWay
{
    //这里不作记录了，成功后再记录 -> onNoteDidSucc
}

- (UIView *)viewBackgroud
{
    if (!_viewBackgroud)
    {
        _viewBackgroud = [[UIView alloc]initWithFrame:CGRectMake(6, 7, 308, 117)];
        _viewBackgroud.backgroundColor = [UIColor whiteColor];
        _viewBackgroud.layer.borderColor = UIColorFromRGB(0xcbcbcb).CGColor;
        _viewBackgroud.layer.borderWidth = .5;
    }
    return _viewBackgroud;
}

- (UIButton *)buttonShare
{
    if (!_buttonShare)
    {
        _buttonShare = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonShare addTarget:self action:@selector(buttonSharePressed) forControlEvents:UIControlEventTouchUpInside];
        [_buttonShare setTitle:ASLocalizedString(@"分享")forState:UIControlStateNormal];
        _buttonShare.layer.cornerRadius = 5;
        _buttonShare.titleLabel.font = [UIFont systemFontOfSize:16];
        _buttonShare.backgroundColor = UIColorFromRGB(0x20c000);
        _buttonShare.frame = CGRectMake(15,134,290,42);
    }
    return _buttonShare;
}

- (UIButton *)buttonCopy
{
    if (!_buttonCopy)
    {
        _buttonCopy = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonCopy addTarget:self action:@selector(buttonCopyPressed) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCopy setTitle:ASLocalizedString(@"复制邀请地址")forState:UIControlStateNormal];
        [_buttonCopy setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _buttonCopy.layer.cornerRadius = 5;
        _buttonCopy.titleLabel.font = [UIFont systemFontOfSize:16];
        _buttonCopy.backgroundColor = [UIColor whiteColor];
        _buttonCopy.frame = CGRectMake(15,186,290,42);
    }
    return _buttonCopy;
}

- (UILabel *)labelLink
{
    if (!_labelLink)
    {
        _labelLink = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 268, 40)];
        _labelLink.backgroundColor = [UIColor clearColor];
        _labelLink.font = [UIFont systemFontOfSize:16];
        _labelLink.textColor = [UIColor blackColor];
        _labelLink.textAlignment = NSTextAlignmentCenter;
    }
    return _labelLink;
}

- (UILabel *)labelCompany
{
    if (!_labelCompany)
    {
        _labelCompany = [[UILabel alloc]initWithFrame:CGRectMake(20, 65, 268, 17)];
        _labelCompany.backgroundColor = [UIColor clearColor];
        _labelCompany.font = [UIFont systemFontOfSize:14];
        _labelCompany.textColor = UIColorFromRGB(0x808080);
        _labelCompany.textAlignment = NSTextAlignmentCenter;
    }
    return _labelCompany;
}

- (UILabel *)labelDate
{
    if (!_labelDate)
    {
        _labelDate = [[UILabel alloc]initWithFrame:CGRectMake(20, 86, 268, 17)];
        _labelDate.backgroundColor = [UIColor clearColor];
        _labelDate.font = [UIFont systemFontOfSize:14];
        _labelDate.textColor = UIColorFromRGB(0x808080);
        _labelDate.textAlignment = NSTextAlignmentCenter;
        _labelDate.text = ASLocalizedString(@"需要管理员审核");
    }
    return _labelDate;
}

@end
