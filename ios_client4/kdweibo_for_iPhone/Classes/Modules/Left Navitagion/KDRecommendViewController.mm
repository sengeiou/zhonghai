//
//  KDRecommendViewController.m
//  kdweibo
//
//  Created by Tan Yingqi on 14-5-8.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDRecommendViewController.h"
#import "UIImage+Extension.h"
#import "XTSMSHandle.h"
#import "BOSSetting.h"
//#import "QREncoder.h"
#import "QREncoder.h"
#import "DataMatrix.h"

#define   KD_RE_COMMEND_QE_IMAGE_WIDTH    132.0f
#define   APP_INSTALL_URL   @"http://wbtest.msbu.kingdee.com/public/download"
@interface KDRecommendViewController ()
@property(nonatomic,retain)UIImageView *imageView;
@end

@implementation KDRecommendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
         self.title = ASLocalizedString(@"KDLeftMenuBottomView_recommand");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [KDEventAnalysis event:event_recommend_open];
    [KDEventAnalysis eventCountly:event_recommend_count];
    
    self.view.backgroundColor =[UIColor kdBackgroundColor1];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 25 + kd_StatusBarAndNaviHeight, CGRectGetWidth(self.view.bounds) - 30, 15)];
    label1.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    label1.text = ASLocalizedString(@"Recommend_scan");
    label1.font = [UIFont systemFontOfSize:14.0f];
    label1.textColor = UIColorFromRGB(0x808080);
    label1.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:label1];
//    [label1 release];
    
    
    UILabel *attentionLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, CGRectGetMaxY(label1.frame)+10.0f, CGRectGetWidth(self.view.bounds) - 50.0f, 62.0f)];
    attentionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    attentionLabel.numberOfLines = 0;
    attentionLabel.text = ASLocalizedString(@"Recommend_QR");
    attentionLabel.font = [UIFont systemFontOfSize:14.0f];
    attentionLabel.textColor = UIColorFromRGB(0xff6600);
    attentionLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:attentionLabel];
//    [attentionLabel release];

    
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"SERVER_BASE_URL_WITH_HTTP"];
    NSString *url = [NSString stringWithFormat:@"%@/public/qrcode?height=160&width=160&path=/public/download",baseUrl];
    //UIImage *image = [QREncoder encode:url];
    
    //    DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:url];
    //    //then render the matrix
    //    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:KD_RE_COMMEND_QE_IMAGE_WIDTH];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *qrcodeImage = [UIImage imageWithData:data];
    _imageView = [[UIImageView  alloc] initWithImage:qrcodeImage];
    _imageView.frame = CGRectMake(0, CGRectGetMaxY(attentionLabel.frame)+25.0f, KD_RE_COMMEND_QE_IMAGE_WIDTH, KD_RE_COMMEND_QE_IMAGE_WIDTH);
    _imageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), _imageView.center.y);
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
  
    [self.view addSubview:_imageView];
    
    // Do any additional setup after loading the view.
    /*UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_imageView.frame) +30, CGRectGetWidth(self.view.bounds) - 30, 15)];
    label2.text = ASLocalizedString(@"2.通过发送短信的方式推荐好友使用;");
    label2.font = [UIFont systemFontOfSize:14.0f];
    label2.textColor = UIColorFromRGB(0x808080);
    label2.backgroundColor = [UIColor clearColor];
     label2.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:label2];
    [label2 release];
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake(0, CGRectGetMidY(label2.frame) + 30, 214,40);
    button.center = CGPointMake(CGRectGetMidX(self.view.bounds), button.center.y);
    label2.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:ASLocalizedString(@"短信推荐")forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_sms_recommend"] forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    button.layer.cornerRadius = 5.0f;
    button.layer.masksToBounds = YES;
    [button setBackgroundColor:UIColorFromRGB(0x20c000)];
    [button addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:button];*/

}


- (void)btnTapped:(id)sender {
	[KDEventAnalysis event:event_recommend_sendmessage];

	NSString *content = [NSString stringWithFormat:ASLocalizedString(@"%@是一款移动工作平台，挺简单的，推荐你用一下 。点击 %@ 下载手机客户端。"),KD_APPNAME, APP_INSTALL_URL];
	[XTSMSHandle sharedSMSHandle].controller = [KDWeiboAppDelegate getAppDelegate].sideMenuViewController;
	[[XTSMSHandle sharedSMSHandle] smsWithContent:content];
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(_imageView);
    //[super dealloc];
}
@end
