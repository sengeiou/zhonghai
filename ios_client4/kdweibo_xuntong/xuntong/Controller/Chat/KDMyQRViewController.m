//
//  KDMyQRViewController.m
//  kdweibo
//
//  Created by KongBo on 15/10/21.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDMyQRViewController.h"
#import "KDQRUtility.h"
#import "BOSConfig.h"
//#import "KDURLPathManager.h"
#import "ContactClient.h"
#import "UIImage+Extension.h"
#import "XTShareManager.h"
#import "SDImageCache.h"
#import "XTCloudClient.h"
#import "MBProgressHUD+Add.h"
#import "KDSheet.h"
//#import "KDAddColleaguesManager.h"
//#import "KDMsgassistClient.h"
#import "UIActionSheet+Blocks.h"
#import "UIAlertView+Blocks.h"
#import "KDForwardChooseViewController.h"
#import "ContactUtils.h"
#import "KDTodoClient.h"
//#import "KDGroupChangeManager.h"
//#import "KDFindNetWorkInfoRequest.h"

@interface KDMyQRViewController () <XTChooseContentViewControllerDelegate,XTQRScanViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *myQRImg;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *genderImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;

@property (strong, nonatomic) KDTodoClient *groupQRClient;
//@property (strong, nonatomic) KDMsgassistClient *innerGroupClient;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) KDSheet *sheet;
@property (strong, nonatomic) NSDictionary *requestData;

@property (strong, nonatomic) UITextField *externalField;
@property (strong, nonatomic) UIButton *inviteButton;

@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *shareQRButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation KDMyQRViewController

- (void)viewDidLoad {
	[super viewDidLoad];

    _requestData = [NSDictionary dictionary];
    [self.forwardButton setTitleColor:FC5 forState:UIControlStateNormal];
    [self.shareQRButton setTitleColor:FC5 forState:UIControlStateNormal];
    self.forwardButton.titleLabel.font = FS4;
    self.shareQRButton.titleLabel.font = FS4;
    self.forwardButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.shareQRButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
	self.contentView.layer.cornerRadius = 6;
	self.contentView.layer.masksToBounds = YES;
	self.headerImg.layer.cornerRadius = 22;
	self.headerImg.layer.masksToBounds = YES;
    if (![self.group isExternalGroup] && self.group.groupId) {
        UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [scanButton setFrame:CGRectMake(0, 0, 44, 44)];
        [scanButton setImage:[UIImage imageNamed:@"nav_btn_sweep_normal"] forState:UIControlStateNormal];
        [scanButton setImage:[UIImage imageNamed:@"nav_btn_sweep_press"] forState:UIControlStateHighlighted];
        [scanButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [scanButton setImageEdgeInsets:UIEdgeInsetsMake(0, 14.5, 0, -14.5)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:scanButton];
        [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
        [self.shareQRButton setTitle:@"保存图片" forState:UIControlStateNormal];
        [self addDetailView];
    }
//    else {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(moreSelect)];
//    }
    
//    if (self.isNetworkQR) {
//        // 工作圈二维码
//        self.genderImgView.hidden = YES;
//        self.tipsLabel.hidden = YES;
//        __weak __typeof (self)weakSelf = self;
//        
//        [[KDAddColleaguesManager sharedAddColleaguesManager] getShortLinkWithHub:YES hubHideDelay:NO phone:nil name:nil method:KDAddColleaguesByQR completeBlock:^(BOOL success, NSDictionary *result) {
//            __strong __typeof(weakSelf) strongSelf = weakSelf;
//            if (success) {
//                NSString *urlPath = [result objectForKey:@"url"];
//                NSString *timeline = [result objectForKey:@"timeline"];
//                if (urlPath == nil || [urlPath isEqualToString:@""] || [urlPath isKindOfClass:[NSNull class]]) {
//                    return;
//                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [strongSelf createGroupQRWithUrl:urlPath];
//                    [strongSelf updateTimeline:timeline];
//                });
//            }
//            
//        }];
//        [self queryCompanyInfo];
//        return;
//    }
    
	if (self.group.groupId) {
		[self.headerImg setImageWithURL:[NSURL URLWithString:self.group.headerUrl] placeholderImage:[UIImage imageNamed:@"group_default_portrait"]];
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
		self.nameLabel.text = [NSString stringWithFormat:@"%@(%d)", self.group.groupName, (int)self.group.participant.count+1];
		
        self.tipsLabel.numberOfLines = 2;
		self.tipsLabel.text = @"该二维码七天内有效\n重新进入请更新";
        self.genderImgView.hidden = YES;
        
        if (!_groupQRClient) {
            _groupQRClient = [[KDTodoClient alloc]initWithTarget:self action:@selector(groupQRClientDidReceive:result:)];
        }
        [_groupQRClient getInnerQRUrlWithGroupId:self.group.groupId];
	}
//    else {
//		NSString *strPhotoUrl = [BOSConfig sharedConfig].user.photoUrl;
//		if ([strPhotoUrl rangeOfString:@"?"].location != NSNotFound) {
//			strPhotoUrl = [strPhotoUrl stringByAppendingString:@"&spec=180"];
//		}
//		[self.headerImg setImageWithURL:[NSURL URLWithString:strPhotoUrl] placeholderImage:[UIImage imageNamed:@"user_default_portrait"]];
//
//		self.nameLabel.text = [BOSConfig sharedConfig].user.name ?[BOSConfig sharedConfig].user.name : @"";
//		[self updateGenderImg];
//		self.tipsLabel.text = @"使用云之家扫一扫，加为好友";
//        [self createMyQR];
//	}
    
}

- (void)addDetailView {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 3)];
    pointView.backgroundColor = FC2;
    pointView.layer.cornerRadius = 1.5;
    pointView.layer.masksToBounds = YES;
    UIView *pointView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 3)];
    pointView1.backgroundColor = FC2;
    pointView1.layer.cornerRadius = 1.5;
    pointView1.layer.masksToBounds = YES;
    [leftView addSubview:pointView];
    [rightView addSubview:pointView1];
    pointView.center = leftView.center;
    pointView1.center = rightView.center;
    
//    _externalField = [[UITextField alloc] initWithFrame:CGRectZero];
//    _externalField.text = @"外部好友无法通过此二维码加入本群";
//    _externalField.textColor = FC2;
//    _externalField.font = FS4;
//    _externalField.textAlignment = NSTextAlignmentCenter;
//    _externalField.leftViewMode = UITextFieldViewModeAlways;
//    _externalField.rightViewMode = UITextFieldViewModeAlways;
//    _externalField.leftView = leftView;
//    _externalField.rightView = rightView;
//    _externalField.userInteractionEnabled = NO;
//    [_externalField sizeToFit];
//    [self.view addSubview:_externalField];
//    [_externalField makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view.centerX);
//        make.top.mas_equalTo(_contentView.bottom).offset(12);
//        make.width.mas_equalTo(_externalField.frame.size.width);
//        make.height.mas_equalTo(_externalField.frame.size.height);
//    }];
//    
//    UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    inviteLabel.textColor = FC5;
//    inviteLabel.font = FS4;
//    inviteLabel.text = @"如何邀请外部好友进群";
//    inviteLabel.textAlignment = NSTextAlignmentCenter;
//    inviteLabel.userInteractionEnabled = YES;
//    [inviteLabel sizeToFit];
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMessage)];
//    [inviteLabel addGestureRecognizer:tapGesture];
//    [self.view addSubview:inviteLabel];
//    [inviteLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view.centerX);
//        make.top.mas_equalTo(_externalField.bottom).offset(10);
//        make.width.mas_equalTo(inviteLabel.frame.size.width);
//        make.height.mas_equalTo(inviteLabel.frame.size.height);
//    }];
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
//    lineView.backgroundColor = FC5;
//    [self.view addSubview:lineView];
//    [lineView makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view.centerX);
//        make.top.mas_equalTo(inviteLabel.bottom);
//        make.width.mas_equalTo(inviteLabel.frame.size.width);
//        make.height.mas_equalTo(1);
//    }];
}

- (void)showMessage {
    NSString *title = @"邀请外部好友进群的方式：";
    NSString *message = @"1、在群组设置中直接添加外部好友\n2、重新发起一个含外部好友的群组并分享二维码";
    [UIAlertView showWithTitle:title message:message cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
}

- (void)groupQRClientDidReceive:(BOSConnect *)client result:(BOSResultDataModel *)result {
    if (result == nil || ![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success && [result.data isKindOfClass:[NSDictionary class]]) {
        _requestData = result.data;
        NSString *groupUrl = result.data[@"url"];
        [self createGroupQRWithUrl:groupUrl];
        
        if (result.data[@"desc"]) {
            self.tipsLabel.text = result.data[@"desc"];
        }
    }
}

//- (void)queryCompanyInfo {
//    KDFindNetWorkInfoRequest *request = [[KDFindNetWorkInfoRequest alloc] init];
//    [request startCompletionBlockWithSuccess:^(__kindof KDRequest * _Nonnull request) {
//        NSDictionary *data = (NSDictionary *)request.response.responseObject;
//        if ([data isKindOfClass:[NSDictionary class]]) {
//            KDNetworkInfoModal *infoMd = [[KDNetworkInfoModal alloc] initWithDict:data];
//            infoMd.networkPhotoUrl = [data objectForKey:@"networkPhotoUrl"];
//            infoMd.name = [data objectForKey:@"networkName"];
//            
//            if (infoMd.name.length > 0) {
//                _nameLabel.text = infoMd.name;
//            }
//            if (infoMd.networkPhotoUrl.length > 0) {
//                [_headerImg kd_setImageWithURL:[NSURL URLWithString:infoMd.networkPhotoUrl] placeholderImage:[UIImage imageNamed:@"company_default"]];
//            }
//        }
//    } failure:^(__kindof KDRequest * _Nonnull request) {
//        [KDPopup showHUDToast:@"获取失败"];
//    }];
//}

- (void)updateTimeline:(NSString *)timeline {
    if (timeline.length > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *validityDate = [formatter dateFromString:timeline];
        NSTimeInterval time = [validityDate timeIntervalSinceNow];
        int days = ceil(time/(24*3600));
        NSString *dayStr = [NSString stringWithFormat:@"%d天", days];
        
        self.tipsLabel.hidden = NO;
        NSString *text = [NSString stringWithFormat:@"扫码进团队\n该二维码%@内(%@前)有效", dayStr,[ContactUtils xtDateFormatterAtTimelineExYear:timeline]];
        //不需要增加颜色
        //NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:text];
//        NSRange range1 = [text rangeOfString:dayStr];
//        NSRange range2 = [text rangeOfString:[ContactUtils xtDateFormatterAtTimeline:timeline]];
//        [attributeStr addAttribute:NSForegroundColorAttributeName value:FC5 range:range1];
//        [attributeStr addAttribute:NSForegroundColorAttributeName value:FC5 range:range2];
        self.tipsLabel.text = text;
    }
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
	self.contentHeight.constant = ScreenFullWidth - 150 + 100 + 64;
}

//- (void)updateGenderImg {
//	self.genderImgView.hidden = YES;
//
//	if (self.person.gender) {
//		switch (self.person.gender.integerValue) {
//			case 0:
//			{}
//			 break;
//
//			case 1:
//			{
//				self.genderImgView.image = [UIImage imageNamed:@"card_tip_male"];
//				self.genderImgView.hidden = NO;
//			}
//			break;
//
//			case 2:
//			{
//				self.genderImgView.image = [UIImage imageNamed:@"card_tip_female"];
//				self.genderImgView.hidden = NO;
//			}
//			break;
//
//			default:
//				break;
//		}
//	}
//}

- (void)rightButtonClick:(UIButton *)bt {
    
    //add
    [KDEventAnalysis event: event_dialog_dialog_group_scan_qrcode];
    [KDEventAnalysis eventCountly: event_dialog_dialog_group_scan_qrcode];
	XTQRScanViewController *qrScanController = [[XTQRScanViewController alloc] init];

	qrScanController.controller = self;
    qrScanController.delegate = self;
	UINavigationController *qrScanNavController = [[UINavigationController alloc] initWithRootViewController:qrScanController];

	[self presentViewController:qrScanNavController animated:YES completion:nil];
}

- (void)qrScanViewController:(XTQRScanViewController *)controller loginCode:(int)qrLoginCode result:(NSString *)result
{
    __weak __typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        [[KDQRAnalyse sharedManager] execute:result callbackBlock:^(QRLoginCode qrCode, NSString *qrResult) {
            [[KDQRAnalyse sharedManager] gotoResultVCInTargetVC:weakSelf withQRResult:qrResult andQRCode:qrCode];
        }];
    }];
}

- (void)qrScanViewControllerDidCancel:(XTQRScanViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadWebViewControllerWithUrl:(NSString *)url
{
    if (url.length == 0) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        [[KDQRAnalyse sharedManager] execute:url callbackBlock:^(QRLoginCode qrCode, NSString *qrResult) {
            [[KDQRAnalyse sharedManager] gotoResultVCInTargetVC:weakSelf withQRResult:qrResult andQRCode:qrCode];
        }];
    }];
}

//- (void)moreSelect {
//    //[KDEventAnalysis event:businesschat_code_more];
//    [UIActionSheet showInView:self.view withTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"保存图片", @"扫一扫"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
//        UIImage *qrImage = [self viewSnapshot:self.contentView withInSize:CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height - 46)];
//        if (buttonIndex == 0) {
//            [KDEventAnalysis event:businesschat_more_select attributes:@{label_businesschat_more_select : label_businesschat_more_select_save}];
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                UIImageWriteToSavedPhotosAlbum(qrImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//            });
//        } else if (buttonIndex == 1) {
//            XTQRScanViewController *qrScanController = [[XTQRScanViewController alloc] init];
//            
//            qrScanController.controller = self;
//            RTRootNavigationController *qrScanNavController = [[RTRootNavigationController alloc] initWithRootViewController:qrScanController];
//
//            [self presentViewController:qrScanNavController animated:YES completion:nil];
//        }
//    }];
//}

//请求商务会话组二维码
- (void)createGroupQRWithUrl:(NSString *)groupUrl {
	if (groupUrl) {
		CIImage *qrCIImage = [KDQRUtility createQRForString:groupUrl];
		UIImage *qrUIImage = [KDQRUtility createNonInterpolatedUIImageFormCIImage:qrCIImage withSize:300];
		self.myQRImg.image = [KDQRUtility imageBlackToTransparent:qrUIImage withRed:0 andGreen:0 andBlue:0];
	}
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if (error) {
		[MBProgressHUD showError:@"保存失败" toView:self.view];
	}
	else {
		[MBProgressHUD showSuccess:@"已保存到系统相册" toView:self.view];
	}
}

- (UIImage *)viewSnapshot:(UIView *)view withInSize:(CGSize)rectSize {
	UIGraphicsBeginImageContextWithOptions(rectSize, NO, 0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

#pragma mark - ChooseVCDelegate
- (void)popViewController {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Botton Btn event

- (IBAction)shareToWechat:(id)sender {
    UIImage *qrImage = [self viewSnapshot:self.contentView withInSize:CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height - 46)];
    //NSData *imageData = UIImagePNGRepresentation(qrImage);
    if (![self.group isExternalGroup] && self.group.groupId) {
        //      //add
        [KDEventAnalysis event: event_dialog_group_qrcode_save];
        [KDEventAnalysis eventCountly: event_dialog_group_qrcode_save];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImageWriteToSavedPhotosAlbum(qrImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        });
        
        return;
    }
//
//    if ([self.group isExternalGroup]) {
//        NSString *title = self.requestData[@"weixinTitle"];
//        NSString *description = self.requestData[@"weixinDesc"];
//        NSString *webpageUrl = self.requestData[@"url"];
//        UIImage *iamge = [UIImage imageNamed:@"search_tip_logo"];
//        
//        if ((title.length + description.length) == 0) {
//            return;
//        }
//        [[KDGroupChangeManager shareGroupChangeManager] doShareExtQRUrlWithUrl:webpageUrl complete:^(BOOL success, NSString *error) {
//            self.sheet = [[KDSheet alloc] initMediaWithShareWay:KDSheetShareWayWechat title:title description:description thumbData:UIImageJPEGRepresentation(iamge, 1) webpageUrl:webpageUrl viewController:self];
//            
//            [self.sheet share];
//        }];
//        return;
//    }
//    
//    self.sheet = [[KDSheet alloc] initImageWithShareWay:KDSheetShareWayWechat imageData:imageData viewController:self];
//    [self.sheet share];
}

- (IBAction)forwardQR:(id)sender {
    
    //add
    [KDEventAnalysis event: event_dialog_group_qrcode_forward];
    [KDEventAnalysis eventCountly: event_dialog_group_qrcode_forward];
    UIImage *qrImage = [self viewSnapshot:self.contentView withInSize:CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height - 46)];
    
    NSString *key = [NSString stringWithFormat:@"http://QRImage_%@",[ContactUtils uuid]];
    [[SDImageCache sharedImageCache] storeImage:qrImage forKey:key];
    
    XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
    forwardDM.forwardType = ForwardMessagePicture;
    forwardDM.originalUrl = [NSURL URLWithString:key];
//    forwardDM.localImage = qrImage;
//    [KDEventAnalysis event:businesschat_more_select attributes:@{label_businesschat_more_select : label_businesschat_more_select_forword}];
    
    KDForwardChooseViewController *contentViewController = [[KDForwardChooseViewController alloc] initWithCreateExtenalGroup:[self.group isExternalGroup]];
    contentViewController.isMulti = YES;
    contentViewController.hidesBottomBarWhenPushed = YES;
    contentViewController.isFromFileDetailViewController = YES;   //触发转发文件埋点
    contentViewController.forwardData = @[forwardDM];
    contentViewController.delegate = self;
    contentViewController.type = XTChooseContentForward;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [self presentViewController:contentNav animated:YES completion:nil];
}

@end
