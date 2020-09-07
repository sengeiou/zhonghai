//
//  KDSheet.m
//  kdweibo
//
//  Created by DarrenZheng on 14-9-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDSheet.h"
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
#import "KDSocialsShareManager.h"

@interface KDSheet ()
<MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) UIButton *buttonGrayFilter;
@property (nonatomic, strong) UIView *viewSheet;
@property (nonatomic, strong) UIView *viewLine;
@property (nonatomic, strong) UIButton *buttonCancel;
@property (nonatomic, strong) UILabel *labelSheetTitle;

@property (nonatomic, strong) UIViewController *vcParent;
@property (nonatomic, assign) KDSheetShareWay shareWay;

@property (nonatomic, copy) NSString *strTitle;
@property (nonatomic, copy) NSString *strDesc;
@property (nonatomic, copy) NSString *strWebPageUrl;
@property (nonatomic, copy) NSString *strText;
@property (nonatomic, strong) NSData *dataImage;
@property (nonatomic, strong) NSData *dataThumb;

@property (nonatomic, assign) double dSheetHeight;

@end

@implementation KDSheet

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.buttonGrayFilter removeFromSuperview];
    [self.viewSheet removeFromSuperview];
    self.buttonGrayFilter = nil;
    self.viewSheet = nil;
    _buttonGrayFilter.userInteractionEnabled = NO;
}

- (KDSheet *)initTextWithShareWay:(KDSheetShareWay)shareWay
                             text:(NSString *)strText
                   viewController:(UIViewController *)vcParent
{
    if (self = [super init])
    {
        self.shareType = KDSheetShareTypeText;
        self.shareWay = shareWay;
        self.strText = strText;
        self.vcParent = vcParent;
        if ([KDSocialShareModal isSingleSelection:shareWay])
            return self;
        [self setupWithShareWay:shareWay
                 viewController:vcParent];
    }
    
    return self;
}

- (KDSheet *)initImageWithShareWay:(KDSheetShareWay)shareWay
                         imageData:(NSData *)dataImage
                    viewController:(UIViewController *)vcParent
{
    if (self = [super init])
    {
        self.shareType = KDSheetShareTypeImage;
        self.shareWay = shareWay;
        self.dataImage = dataImage;
        self.vcParent = vcParent;
        if ([KDSocialShareModal isSingleSelection:shareWay])
            return self;
        [self setupWithShareWay:shareWay
                 viewController:vcParent];
    }
    return self;
}

- (KDSheet *)initMediaWithShareWay:(KDSheetShareWay)shareWay
                             title:(NSString *)strTitle
                       description:(NSString *)strDesc
                         thumbData:(NSData *)dataThumb
                        webpageUrl:(NSString *)strWebPageUrl
                    viewController:(UIViewController *)vcParent
{
    if (self = [super init])
    {
        self.shareType = KDSheetShareTypeMedia;
        self.shareWay = shareWay;
        self.vcParent = vcParent;
        self.strTitle = strTitle;
        self.strDesc = strDesc;
        self.dataThumb = dataThumb;
        self.strWebPageUrl = strWebPageUrl;
        if ([KDSocialShareModal isSingleSelection:shareWay])
            return self;
        [self setupWithShareWay:shareWay
                 viewController:vcParent];
    }
    return self;
}

- (void)share
{
    if ([KDSocialShareModal isSingleSelection:self.shareWay])
    {
        [self shareWithShareType:self.shareType
                        shareWay:self.shareWay];
    }
    else
    {
        [self showSheet];
    }
}

- (void)shareWithShareType:(KDSheetShareType)shareType
                  shareWay:(KDSheetShareWay)shareWay
{
    switch (shareWay)
    {
        case KDSheetShareWaySMS:
        {
            switch (shareType)
            {
                case KDSheetShareTypeText:
                    [SHARE_MANAGER shareToMessageText:self.strText
                                             delegate:self
                                       viewController:(UIViewController *) self.vcParent];
                    break;
                //#为标志符,为提示图片无法发送短信
                case KDSheetShareTypeImage:
                    [SHARE_MANAGER shareToMessageText:@"#"
                                             delegate:self
                                       viewController:(UIViewController *) self.vcParent];
                    break;
                case KDSheetShareTypeMedia:
                {
                    NSString *text = [NSString stringWithFormat:@"【%@】\n%@ \n%@", self.strTitle, self.strDesc, self.strWebPageUrl];
                    [SHARE_MANAGER shareToMessageText:text
                                             delegate:self
                                       viewController:(UIViewController *) self.vcParent];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case KDSheetShareWayWechat:
        {
            switch (shareType)
            {
                case KDSheetShareTypeText:
                    [SHARE_MANAGER shareToWechatWithText:self.strText
                                              isTimeline:NO];
                    break;
                    
                case KDSheetShareTypeImage:
                    [SHARE_MANAGER shareToWechatWithImageData:self.dataImage
                                                   isTimeline:NO];
                    break;
                    
                case KDSheetShareTypeMedia:
                    [SHARE_MANAGER shareToWechatWithTitle:self.strTitle
                                              description:self.strDesc
                                                thumbData:self.dataThumb
                                               webpageUrl:self.strWebPageUrl
                                               isTimeline:NO];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case KDSheetShareWayMoment:
        {
            switch (shareType)
            {
                case KDSheetShareTypeText:
                    [SHARE_MANAGER shareToWechatWithText:self.strText
                                              isTimeline:YES];
                    break;
                    
                case KDSheetShareTypeImage:
                    [SHARE_MANAGER shareToWechatWithImageData:self.dataImage
                                                   isTimeline:YES];
                    break;
                    
                case KDSheetShareTypeMedia:
                    [SHARE_MANAGER shareToWechatWithTitle:self.strTitle
                                              description:self.strDesc
                                                thumbData:self.dataThumb
                                               webpageUrl:self.strWebPageUrl
                                               isTimeline:YES];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case KDSheetShareWayQQ:
        {
            switch (shareType)
            {
                case KDSheetShareTypeText:
                    [SHARE_MANAGER shareToQQWithText:self.strText
                                             isQzone:NO];
                    break;
                    
                case KDSheetShareTypeImage:
                    [SHARE_MANAGER shareToQQWithImageData:self.dataImage
                                                  isQzone:NO];
                    break;
                    
                case KDSheetShareTypeMedia:
                    [SHARE_MANAGER shareToQQWithTitle:self.strTitle
                                          description:self.strDesc
                                            thumbData:self.dataThumb
                                           webpageUrl:self.strWebPageUrl
                                              isQzone:NO];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case KDSheetShareWayQzone:
        {
            switch (shareType)
            {
                case KDSheetShareTypeText:
                    [SHARE_MANAGER shareToQQWithText:self.strText
                                             isQzone:YES];
                    break;
                    
                case KDSheetShareTypeImage:
                    [SHARE_MANAGER shareToQQWithImageData:self.dataImage
                                                  isQzone:YES];
                    break;
                    
                case KDSheetShareTypeMedia:
                    [SHARE_MANAGER shareToQQWithTitle:self.strTitle
                                          description:self.strDesc
                                            thumbData:self.dataThumb
                                           webpageUrl:self.strWebPageUrl
                                              isQzone:YES];
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
            
        case KDSheetShareWayWeibo:
        {
            switch (shareType)
            {
                case KDSheetShareTypeText:
                    [SHARE_MANAGER shareToWeiboWithText:self.strText];
                    break;
                    
                case KDSheetShareTypeImage:
                    [SHARE_MANAGER shareToWeiboWithImageData:self.dataImage];
                    break;
                    
                case KDSheetShareTypeMedia:
                    [SHARE_MANAGER shareToWeiboWithTitle:self.strTitle
                                          description:self.strDesc
                                            thumbData:self.dataThumb
                                           webpageUrl:self.strWebPageUrl];
                    
                default:
                    break;
            }
            
        }
            break;
        case KDSheetShareWayBuluo:
        {
            if ([BOSConfig sharedConfig].user.partnerType == 1) {
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
                hud.labelText = ASLocalizedString(@"KDSignInViewController_Share_Moment_Fail");
                [hud hide:YES afterDelay:2.0];
                return;
            }
            KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
            PostViewController *pvc = [factory getPostViewController];
            pvc.isSelectRange = YES;
            KDDraft *draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
            
            switch (shareType) {
                case KDSheetShareTypeText:{
                    draft.content = self.strText;
                }
                    break;
                case KDSheetShareTypeImage:
                    break;
                case KDSheetShareTypeMedia:{
                    draft.content = [NSString stringWithFormat:@"【%@】%@ \n%@",self.strTitle,self.strDesc,self.strWebPageUrl];
                }
                    break;
                    
                default:
                    return ;
                    break;
            }
            
            pvc.draft = draft;
            [KDWeiboAppDelegate setExtendedLayout:pvc];
            [[KDDefaultViewControllerContext defaultViewControllerContext] showPostViewController:pvc];
        }
            break;
            
        default:
            break;
    }
}

- (void)setupWithShareWay:(KDSheetShareWay)shareWay
           viewController:(UIViewController *)vcParent
{
    
    [vcParent.navigationController.view addSubview:self.buttonGrayFilter];
    [vcParent.navigationController.view addSubview:self.viewSheet];
    
    NSMutableArray *mArrayImageNames = [NSMutableArray new];
    NSMutableArray *mArrayLabelTexts = [NSMutableArray new];
    NSMutableArray *mArrayShareTypeNumbers = [NSMutableArray new];
    
    void(^blockSetupArrays)(KDSheetShareWay, NSString *, NSString *) = ^(KDSheetShareWay shareWayParam, NSString *strImageName, NSString *strLabelText)
    {
        if((shareWay & shareWayParam) == shareWayParam)
        {
            [mArrayImageNames addObject:strImageName];
            [mArrayLabelTexts addObject:strLabelText];
            [mArrayShareTypeNumbers addObject:[NSNumber numberWithInt:shareWayParam]];
        }
    };
    blockSetupArrays(KDSheetShareWayBuluo, @"me_icon_newsfeed", ASLocalizedString(@"KDDefaultViewControllerContext_trends")); // 动态
    blockSetupArrays(KDSheetShareWaySMS,    @"me_icon_message",    ASLocalizedString(@"KDSheet_SheetShareWaySMS"));
    blockSetupArrays(KDSheetShareWayWechat, @"me_icon_wechat",   ASLocalizedString(@"KDSheet_SheetShareWayWechat"));
    blockSetupArrays(KDSheetShareWayMoment, @"me_icon_friend",   ASLocalizedString(@"KDSheet_SheetShareWayMoment"));
    blockSetupArrays(KDSheetShareWayQQ,     @"me_icon_qq",       @"QQ");
    blockSetupArrays(KDSheetShareWayQzone,  @"me_icon_qzone",   ASLocalizedString(@"KDSheet_SheetShareWayQzone"));
    blockSetupArrays(KDSheetShareWayWeibo,  @"me_icon_weibo",     ASLocalizedString(@"XTPersonDetailViewController_WB"));
    
    for (int i = 0; i < mArrayImageNames.count; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *strImageName = mArrayImageNames[i];
        button.tag = [mArrayShareTypeNumbers[i] intValue];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(17+(i%4)*79,50+(i/4)*80,50,50);
        [button setBackgroundImage:[UIImage imageNamed:strImageName] forState:UIControlStateNormal];
        [self.viewSheet addSubview:button];
        
        NSString *strTitle = mArrayLabelTexts[i];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(17+(i%4)*79, 105+(i/4)*80, 50, 16)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = strTitle;
        [self.viewSheet addSubview:label];
        
        self.dSheetHeight = 181+(i/4)*80;
    }
    
    [self.viewSheet addSubview:self.buttonCancel];
    [self.viewSheet addSubview:self.viewLine];
    
}

- (void)buttonPressed:(UIButton *)button
{
//    [self.delegate buttonPressedWithShareWay:button.tag];
//    [self shareWithShareType:self.shareType
//                    shareWay:button.tag];
    [self shareWithShareType:self.shareType
                    shareWay:button.tag];
    [self hideSheet];
}

- (void)buttonGrayFilterPressed
{
    [self buttonCancelPressed];
}

- (void)buttonCancelPressed
{
    [self hideSheet];
}

- (void)showSheet
{
    [UIView animateWithDuration:.25
                     animations:^
     {
         self.buttonGrayFilter.alpha = .7;
         self.viewSheet.frame = CGRectMake(0,CGRectGetHeight(self.vcParent.navigationController.view.frame)-self.dSheetHeight, ScreenFullWidth, self.dSheetHeight);
         
         self.buttonCancel.frame = CGRectMake(0,self.dSheetHeight-46,ScreenFullWidth,46);
         self.viewLine.frame = CGRectMake(0, self.dSheetHeight-47, ScreenFullWidth, 1);
         
     }
                     completion:^(BOOL finished)
     {
         if (finished)
         {
             _buttonGrayFilter.userInteractionEnabled = YES;
         }
     }];
}

- (void)hideSheet
{
    [UIView animateWithDuration:.25
                     animations:^
     {
         self.buttonGrayFilter.alpha = 0;
         self.viewSheet.frame = CGRectMake(0, CGRectGetHeight(self.vcParent.navigationController.view.frame), ScreenFullWidth, 181);
     }];
}

#pragma mark - ui setup -

- (UIButton *)buttonCancel
{
    if (!_buttonCancel)
    {
        _buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonCancel addTarget:self action:@selector(buttonCancelPressed) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel setTitle:ASLocalizedString(@"Global_Cancel")forState:UIControlStateNormal];
        _buttonCancel.layer.cornerRadius = 5;
        _buttonCancel.titleLabel.font = [UIFont systemFontOfSize:16];
        [_buttonCancel setTitleColor:UIColorFromRGB(0x1a85ff) forState:UIControlStateNormal];
        _buttonCancel.backgroundColor = [UIColor clearColor];
        _buttonCancel.frame = CGRectMake(0,CGRectGetHeight(self.vcParent.navigationController.view.frame)-46,ScreenFullWidth,46);
    }
    
    return _buttonCancel;
}

- (UIButton *)buttonGrayFilter
{
    if (!_buttonGrayFilter)
    {
        _buttonGrayFilter = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonGrayFilter.frame = [[UIScreen mainScreen] bounds];
        [_buttonGrayFilter addTarget:self action:@selector(buttonGrayFilterPressed) forControlEvents:UIControlEventTouchUpInside];
        _buttonGrayFilter.backgroundColor = [UIColor blackColor];
        _buttonGrayFilter.alpha = 0;
        _buttonGrayFilter.userInteractionEnabled = NO;
    }
    return _buttonGrayFilter;
}

- (UIView *)viewSheet
{
    if (!_viewSheet)
    {
        _viewSheet = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.vcParent.navigationController.view.frame), ScreenFullWidth, 181)];
        _viewSheet.backgroundColor = UIColorFromRGB(0xfafafa);
        
        [_viewSheet addSubview:self.viewLine];
        [_viewSheet addSubview:self.buttonCancel];
        [_viewSheet addSubview:self.labelSheetTitle];
    }
    return _viewSheet;
}

- (UIView *)viewLine
{
    if (!_viewLine)
    {
        _viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.vcParent.navigationController.view.frame)-47, ScreenFullWidth, 1)];
        _viewLine.backgroundColor = UIColorFromRGB(0xdddddd);
    }
    return _viewLine;
}

- (UILabel *)labelSheetTitle
{
    if (!_labelSheetTitle)
    {
        _labelSheetTitle = [[UILabel alloc]initWithFrame:CGRectMake(17, 16, 58, 20)];
        _labelSheetTitle.backgroundColor = [UIColor clearColor];
        _labelSheetTitle.text = ASLocalizedString(@"KDSheet_labelSheetTitle_text");
        _labelSheetTitle.font = [UIFont systemFontOfSize:16];
    }
    return _labelSheetTitle;
}

#pragma mark -  MFMessageComposeViewController Delegate -

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self.vcParent dismissViewControllerAnimated:YES completion:NULL];
    
    NSString * message = nil;
    switch (result)
    {
        case MessageComposeResultCancelled:
            message = ASLocalizedString(@"KDSheet_MessageComposeResultCancelled");
            break;
        case MessageComposeResultSent:
            message = ASLocalizedString(@"KDSheet_MessageComposeResultSent");
            break;
        case MessageComposeResultFailed:
            message = ASLocalizedString(@"KDSheet_MessageComposeResultFailed");
            break;
        default:
            message = ASLocalizedString(@"KDSheet_MessageComposeResultFailed");
            break;
    }
    
    if (result == MessageComposeResultSent)
    {
        [KDSocialShareModal postNoteSuccWithShareWay:KDSheetShareWaySMS];
        
    }
    else
    {
        [KDSocialShareModal postNoteFailWithShareWay:KDSheetShareWaySMS
                                               error:message];
    }
}

@end
