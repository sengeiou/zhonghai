//
//  KDSignInNotSettingViewController.m
//  kdweibo
//
//  Created by weihao_xu on 14-5-20.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDSignInNotSettingViewController.h"
#import "KDExpressionLabel.h"

#import <OHAttributedLabel/OHAttributedLabel.h>
@interface KDSignInNotSettingViewController ()

@end

@implementation KDSignInNotSettingViewController
@synthesize didTryUseBlock;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
     
 - (void)setUpView{
     self.title = ASLocalizedString(@"KDSignInNotSettingViewController_navigationItem_title");
     [self.view setBackgroundColor:RGBCOLOR(237, 237, 237)];
     
     UIScrollView *bgView = [[UIScrollView alloc]initWithFrame:self.view.bounds];// autorelease];
         bgView.scrollEnabled = YES;
     bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
     bgView.contentOffset = CGPointMake(0, 0);
     
     UIImageView *alertImageView = [[UIImageView alloc]init];//autorelease];
     [alertImageView setFrame:CGRectMake(0, 0, 60, 60)];
     [alertImageView setImage:[UIImage imageNamed:@"app_img_sign_wqy"]];
     [alertImageView setBackgroundColor:[UIColor clearColor]];
     [alertImageView setCenter:CGPointMake(160, 58)];
     [bgView addSubview:alertImageView];
     
     UILabel *alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(alertImageView.frame) + 15.f , CGRectGetWidth(self.view.frame) - 15 *2 , 16.f)];// autorelease];
     alertLabel.text = ASLocalizedString(@"KDSignInNotSettingViewController_alertLabel_text");
     alertLabel.textAlignment = NSTextAlignmentCenter;
     alertLabel.textColor = UIColorFromRGB(0xff6600);
     alertLabel.font = [UIFont systemFontOfSize:16.f];
     [bgView addSubview:alertLabel];
     
     
     UIButton *tryUseButton = [[UIButton alloc]initWithFrame:CGRectMake(15.f, CGRectGetMaxY(alertLabel.frame) + 15.f, CGRectGetWidth(self.view.frame) - 15*2, 35)] ;//autorelease];
     tryUseButton.backgroundColor = RGBACOLOR(32, 192, 0, 1);
     [tryUseButton setTitle:ASLocalizedString(@"KDSignInNotSettingViewController_tryUseButton_title")forState:UIControlStateNormal];
     [tryUseButton.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
     [tryUseButton addTarget:self action:@selector(tryButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
     [bgView addSubview:tryUseButton];
     
     OHAttributedLabel *remindLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(tryUseButton.frame) + 22.f, CGRectGetWidth(self.view.frame) - 15 *2, 83.f)];// autorelease];
     remindLabel.numberOfLines = 0;
     remindLabel.lineBreakMode = NSLineBreakByWordWrapping;
     remindLabel.font = [UIFont systemFontOfSize:15.f];
     remindLabel.textColor = RGBACOLOR(164, 164, 164,1);
     
     
     remindLabel.automaticallyAddLinksForType = 0;
     NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: ASLocalizedString(@"KDSignInNotSettingViewController_remindLabel_attributedText")];// autorelease];
     
     //全文颜色 and 字体
     [attributedString addAttributes:@{NSForegroundColorAttributeName:RGBACOLOR(147, 147, 147,1),NSFontAttributeName :[UIFont systemFontOfSize:14.f]} range:NSMakeRange(0, attributedString.length)];
     

     //如何启用？
     [attributedString addAttributes:@{NSForegroundColorAttributeName:RGBACOLOR(149, 149, 149,1),NSFontAttributeName :[UIFont boldSystemFontOfSize:17.f]} range:NSMakeRange(0, 5)];
     
     //应用>签到>签到设置
    [attributedString addAttribute:NSForegroundColorAttributeName value:BOSCOLORWITHRGBA(0xff6600, 1.0) range:NSMakeRange(38,10)];
     
     
    [remindLabel setAttributedText:attributedString];
     [bgView addSubview:remindLabel];

     UIImageView *mapRemindView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"app_img_sign_pic"]];// autorelease];
     [mapRemindView setFrame:CGRectMake(15 , CGRectGetMaxY(remindLabel.frame) + 15.f, CGRectGetWidth(self.view.frame) - 15 *2, 200)];
     [bgView addSubview:mapRemindView];
     
     bgView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(mapRemindView.frame) + 70);

     [self.view addSubview:bgView];
 }

- (IBAction)tryButtonDidClicked:(id)sender{
    didTryUseBlock();
    [self.navigationController popViewControllerAnimated:YES];
}

@end
