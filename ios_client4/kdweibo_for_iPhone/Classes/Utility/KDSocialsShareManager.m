//
//  KDSocialsShareManager.m
//  kdweibo
//
//  Created by AlanWong on 14-8-5.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//


#import "KDSocialsShareManager.h"
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentMessageObject.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

#define KDWEIBO_SINA_APP_KEY @"3318103260"
#define KDWEIBO_QQ_APP_KEY @"1101093724"
#define KDWEIBO_WECHAT_DESCRIPTION @"demo 2.0"

@interface KDSocialsShareManager()

@property (nonatomic,strong)TencentOAuth * tencentOAuth;
@property (nonatomic, strong) void (^blockCompletion)(BOOL success, NSString *error);
@end

@implementation KDSocialsShareManager

+(KDSocialsShareManager *)shareSocialsShareManager
{
    static KDSocialsShareManager * socialsShareManager = nil;
    @synchronized(self)
    {
        if (socialsShareManager == nil)
        {
            socialsShareManager = [[self alloc] init];
            
            [[NSNotificationCenter defaultCenter] addObserver:socialsShareManager
                                                     selector:@selector(onNotiWeiboShareSucc:)
                                                         name:ON_NOTI_WEIBO_SHARE_SUCC
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:socialsShareManager
                                                     selector:@selector(onNotiWeiboShareFail:)
                                                         name:ON_NOTI_WEIBO_SHARE_FAIL
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:socialsShareManager
                                                     selector:@selector(onNotiWechatShareSucc:)
                                                         name:ON_NOTI_WECHAT_SHARE_SUCC
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:socialsShareManager
                                                     selector:@selector(onNotiWechatShareFail:)
                                                         name:ON_NOTI_WECHAT_SHARE_FAIL
                                                       object:nil];
        }
    }
    return socialsShareManager;
}



- (void)onNotiWeiboShareSucc:(NSNotification *)note
{
    [KDSocialShareModal postNoteSuccWithShareWay:KDSheetShareWayWeibo];
}

- (void)onNotiWeiboShareFail:(NSNotification *)note
{
    [KDSocialShareModal postNoteFailWithShareWay:KDSheetShareWayWeibo
                                            error:note.userInfo[@"error"]];
}



- (void)onNotiWechatShareSucc:(NSNotification *)note
{
    [KDEventAnalysis event:event_invite_send attributes:@{ label_invite_send_inviteType : label_invite_send_inviteType_weixin }];

    [KDSocialShareModal postNoteSuccWithShareWay:KDSheetShareWayWechat | KDSheetShareWayMoment];
    
}

- (void)onNotiWechatShareFail:(NSNotification *)note
{
    [KDSocialShareModal postNoteFailWithShareWay:KDSheetShareWayWechat | KDSheetShareWayMoment
                                            error:note.userInfo[@"error"]];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Register Method

+(void)registerQQ{
    
}
+(void)registerWeChat{
    [WXApi registerApp:KD_WECHAT_APP_KEY withDescription:KDWEIBO_WECHAT_DESCRIPTION];
}
+(void)registerSinaWeibo{
    [WeiboSDK registerApp:KDWEIBO_SINA_APP_KEY];
}
#pragma mark -
#pragma mark HandleOpenURL Method

+(BOOL)qqHandleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url];
}
+(BOOL)weChatHandleOpenURL:(NSURL *) url delegate:(id<WXApiDelegate>) delegate{
    return [WXApi handleOpenURL:url delegate:delegate];
}
+(BOOL)sinaWeiboHandleOpenURL:(NSURL *)url delegate:(id<WeiboSDKDelegate>)delegate{
    return [WeiboSDK handleOpenURL:url delegate:delegate];
}

#pragma mark - 微博 -

// 文本
- (void)shareToWeiboWithText:(NSString *)text
{
    WBMessageObject *message = [WBMessageObject message];
    message.text =text;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
}

// 图片
- (void)shareToWeiboWithImageData:(NSData *)dataImage
{
    WBMessageObject *message = [WBMessageObject message];
    
    WBImageObject *imageObject = [WBImageObject object];
    imageObject.imageData = dataImage;
    message.imageObject = imageObject;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
}

// 富文本
- (void)shareToWeiboWithTitle:(NSString *)strTitle
                  description:(NSString *)strDesc
                    thumbData:(NSData *)dataThumb
                   webpageUrl:(NSString *)strWebPageUrl
{
    WBMessageObject *message = [WBMessageObject message];
    
    if (dataThumb) {
        WBImageObject *imageObject = [WBImageObject object];
        imageObject.imageData = dataThumb;
        message.imageObject = imageObject;
    }
    
    message.text = [NSString stringWithFormat:@"【%@】\n%@ \n%@", strTitle, strDesc, strWebPageUrl];
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
}

#pragma mark - QQ/Qzone -

// 文本
- (void)shareToQQWithText:(NSString *)text
                  isQzone:(BOOL)bQzone
{
    if (![TencentOAuth iphoneQQInstalled]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDSocialsShareManager_QQ_NoInstalled")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    if (!_tencentOAuth) {
        _tencentOAuth = [[TencentOAuth alloc]initWithAppId:KD_QQ_APP_KEY andDelegate:nil];
    }
    
    QQApiTextObject *txtObj = nil;
    txtObj = [QQApiTextObject objectWithText:text];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
    
    if (bQzone)
    {
        uint64_t cflag = 1;
        [txtObj setCflag:cflag];
    }
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    //分享到QZone // QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req]; [self handleSendResult:sent];
    [self handleQQresponseCode:sent];
    
}


// 图片
- (void)shareToQQWithImageData:(NSData *)dataImage
                       isQzone:(BOOL)bQzone
{
    if (![TencentOAuth iphoneQQInstalled])
    {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDSocialsShareManager_QQ_NoInstalled")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    if (!_tencentOAuth)
    {
        _tencentOAuth = [[TencentOAuth alloc]initWithAppId:KD_QQ_APP_KEY andDelegate:nil];
    }
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:dataImage
                                               previewImageData:dataImage
                                                          title:nil
                                                    description:nil];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
    if (bQzone)
    {
        uint64_t cflag = 1;
        [imgObj setCflag:cflag];
    }
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self deleteQQDataBase];
    [self handleQQresponseCode:sent];
}

// 富文本
- (void)shareToQQWithTitle:(NSString *)strTitle
               description:(NSString *)strDesc
                 thumbData:(NSData *)dataThumb
                webpageUrl:(NSString *)strWebPageUrl
                   isQzone:(BOOL)bQzone
{
    if (![TencentOAuth iphoneQQInstalled])
    {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDSocialsShareManager_QQ_NoInstalled")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    if (!_tencentOAuth)
    {
        _tencentOAuth = [[TencentOAuth alloc]initWithAppId:KD_QQ_APP_KEY andDelegate:nil];
    }
    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:strWebPageUrl]
                                                        title:strTitle
                                                  description:strDesc
                                             previewImageData:dataThumb];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    if (bQzone)
    {
        uint64_t cflag = 1;
        [newsObj setCflag:cflag];
    }
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self deleteQQDataBase];
    [self handleQQresponseCode:sent];
}

#pragma mark - 微信/朋友圈 -

// 文本
- (void)shareToWechatWithText:(NSString *)text
                   isTimeline:(BOOL)bTimeline
{
    if (![WXApi isWXAppInstalled])
    {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDSocialsShareManager_WeChat_NoInstalled")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.text = text;
    req.bText = YES;
    req.scene = bTimeline ? WXSceneTimeline : WXSceneSession;
    [WXApi sendReq:req];
}

// 图片
- (void)shareToWechatWithImageData:(NSData *)dataImage
                        isTimeline:(BOOL)bTimeline
{
    if (![WXApi isWXAppInstalled])
    {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDSocialsShareManager_WeChat_NoInstalled")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    
    WXImageObject *imageObj = [WXImageObject object];
    imageObj.imageData = dataImage;
    message.mediaObject = imageObj;
    
    message.thumbData = UIImageJPEGRepresentation([UIImage imageWithData:dataImage], 0);
    message.title = ASLocalizedString(@"KDEvent_Picture");
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = bTimeline ? WXSceneTimeline : WXSceneSession;
    [WXApi sendReq:req];
}

// 富文本
- (void)shareToWechatWithTitle:(NSString *)strTitle
                   description:(NSString *)strDesc
                     thumbData:(NSData *)dataThumb
                    webpageUrl:(NSString *)strWebPageUrl
                    isTimeline:(BOOL)bTimeline
{
    if (![WXApi isWXAppInstalled])
    {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDSocialsShareManager_WeChat_NoInstalled")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = strTitle;
    message.description = strDesc;
    message.thumbData = dataThumb;
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = strWebPageUrl;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = bTimeline ? WXSceneTimeline : WXSceneSession;
    
    [WXApi sendReq:req];
}

#pragma mark - SMS -

- (void)shareToMessageText:(NSString *)text
                  delegate:(id <MFMessageComposeViewControllerDelegate>)delegate
            viewController:(UIViewController *)viewController {
    if ([MFMessageComposeViewController canSendText]) {
        if ([text isEqualToString:@"#"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")
                                                                message:ASLocalizedString(@"KDSocialsShareManager_Msg_NoImgShareSuport")
                                                               delegate:self
                                                      cancelButtonTitle:ASLocalizedString(@"Global_Sure")
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = delegate;
            picker.body = text;
            //        UIViewController * controller = (UIViewController *)delegate;
            [viewController presentViewController:picker animated:YES completion:nil];
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")
                                                            message:ASLocalizedString(@"KDSocialsShareManager_Msg_NoSuport")
                                                           delegate:self
                                                  cancelButtonTitle:ASLocalizedString(@"Global_Sure")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark -
#pragma mark Private Method

-(void)deleteQQDataBase
{
    NSString *databasePath= [NSHomeDirectory()
                             stringByAppendingPathComponent:@"Documents/tencent_analysis_qc.db"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:databasePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:databasePath error:nil];
        
    }
}

- (void)handleQQresponseCode:(QQApiSendResultCode )code
{
    
    /**
     *  说明: QQ的cancel事件无法拿到, 所以不能排除返回分享成功其实是用户取消发送.
     */
    
    NSString * message = ASLocalizedString(@"KDSocialsShareManager_Share_Fail");
    switch (code)
    {
        case EQQAPISENDSUCESS:
            message = ASLocalizedString(@"KDSocialsShareManager_Share_Success");
            break;
        case EQQAPIQQNOTINSTALLED:
            message = ASLocalizedString(@"KDSocialsShareManager_QQ_NoInstalled");
            break;
        case EQQAPIAPPNOTREGISTED:
            message = @"EQQAPIAPPNOTREGISTED";
            break;
        case EQQAPIMESSAGECONTENTINVALID:
            message = @"EQQAPIMESSAGECONTENTINVALID";
            break;
        case EQQAPIMESSAGECONTENTNULL:
            message = @"EQQAPIMESSAGECONTENTNULL";
            break;
        case EQQAPIMESSAGETYPEINVALID:
            message = @"EQQAPIMESSAGETYPEINVALID";
            break;
        case EQQAPIQQNOTSUPPORTAPI:
            message = @"EQQAPIQQNOTSUPPORTAPI";
            break;
        case EQQAPISENDFAILD:
            message = ASLocalizedString(@"KDSocialsShareManager_Share_Fail");
            break;
        case EQQAPIQZONENOTSUPPORTTEXT:
            message = ASLocalizedString(@"KDSocialsShareManager_qzone_NoSuport_text");
            break;
        case EQQAPIQZONENOTSUPPORTIMAGE:
            message = ASLocalizedString(@"KDSocialsShareManager_qzone_NoSuport_image");
            break;
        default:
            break;
    }
    
    if (code == EQQAPISENDSUCESS)
    {
        [KDSocialShareModal postNoteSuccWithShareWay:KDSheetShareWayQQ | KDSheetShareWayQzone];
        
    }
    else
    {
        [KDSocialShareModal postNoteFailWithShareWay:KDSheetShareWayQQ | KDSheetShareWayQzone
                                                error:message];
    }
}


@end
