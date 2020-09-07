//
//  KDAutoWifiSignInIntroduceController.m
//  kdweibo
//
//  Created by lichao_liu on 1/5/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDAutoWifiSignInIntroduceController.h"
#import "KDSheet.h"
#import "KDAutoWifiSignInSettingController.h"

@interface KDAutoWifiSignInIntroduceController ()
@property(nonatomic,retain)UIScrollView *scrollView;
@property(nonatomic,retain)KDSheet * sheet;
@end

@implementation KDAutoWifiSignInIntroduceController
@synthesize scrollView = scrollView_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = ASLocalizedString(@"WIFI自动签到");
    self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(backAction:)];
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
    CGRect frame = self.view.bounds;
    frame.origin.y = 5;
    frame.size.height = CGRectGetHeight(frame)-5;
    scrollView_ = [[UIScrollView alloc] initWithFrame:frame];
    [self.view addSubview:scrollView_];
    scrollView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addImageViewToScrllView:scrollView_ imageNameFormat:@"autoSignIn_intro" imageCount:2];
}

-(void)addImageViewToScrllView:(UIScrollView *)scrollView imageNameFormat:(NSString * )imageNameFormat imageCount:(NSUInteger)imageCount{
    if (scrollView == nil || imageNameFormat == nil || imageCount == 0) {
        return;
    }
    float heignt = 5;
    for (NSInteger i = 1 ; i <= imageCount; i++) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.text = i == 1 ? ASLocalizedString(@"什么是WIFI签到?"):ASLocalizedString(@"有什么好处?");
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectMake(10, heignt , CGRectGetWidth(titleLabel.frame), CGRectGetHeight(titleLabel.frame));
        heignt +=CGRectGetHeight(titleLabel.frame);
        [scrollView addSubview:titleLabel];
        
        UILabel *detailLabel = [[UILabel alloc] init];
        detailLabel.backgroundColor = [UIColor clearColor];
         detailLabel.textColor = [UIColor lightGrayColor];
        detailLabel.textAlignment = NSTextAlignmentLeft;
        detailLabel.numberOfLines = 0;
        detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        detailLabel.font = [UIFont systemFontOfSize:14.f];
        detailLabel.text = i == 1 ? ASLocalizedString(@"当你在上下班时间进入／离开工作地点时，系统会自动匹配你连接的WIFI和签到点备案的WIFI，如果吻合则自动为你签到，并发送签到成功提示。"):ASLocalizedString(@"WIFI签到作为一种全新的模式，它解决室内定位失败,定位偏移的问题，另外解决忘记打卡的问题。同时它有自身的弱势，那就是必须有WIFI。");
   
        CGSize labelSize = [detailLabel.text sizeWithFont:[UIFont systemFontOfSize:14]
                         constrainedToSize:CGSizeMake(scrollView.frame.size.width, 400)
                                            lineBreakMode:NSLineBreakByCharWrapping];
        detailLabel.frame = CGRectMake(10, heignt+ 15, self.view.bounds.size.width - 20, labelSize.height+20);
        
        heignt += labelSize.height + 15 + 20;
        
        [scrollView addSubview:detailLabel];
        
        NSString * imageName = [NSString stringWithFormat:@"%@%ld",imageNameFormat,(long)i];
        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        CGRect frame = imageView.bounds;
        frame.origin.y = heignt + 15;
        imageView.frame = frame;
        imageView.center = CGPointMake(scrollView.center.x, imageView.center.y);
        [scrollView addSubview:imageView];
        heignt += CGRectGetHeight(imageView.frame)+ 15;
    }
    
    UIButton *autoSignInSetBtn = [[UIButton alloc] init];
    [autoSignInSetBtn setTitle:ASLocalizedString(@"自动签到设置")forState:UIControlStateNormal];
    [autoSignInSetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [autoSignInSetBtn setBackgroundColor:BOSCOLORWITHRGBA(0x1A85FF,1.0)];
    autoSignInSetBtn.frame = CGRectMake((CGRectGetWidth(self.view.frame)- 250)/2.0, heignt + 25, 250, 40);
    autoSignInSetBtn.layer.cornerRadius = 10;
    autoSignInSetBtn.layer.masksToBounds = YES;
    [autoSignInSetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [autoSignInSetBtn addTarget:self action:@selector(whenAutoSignInSetBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:autoSignInSetBtn];
    
    heignt += 65;
    
    [scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, heignt)];
}

- (void)whenAutoSignInSetBtnClicked:(UIButton *)sender
{
    KDAutoWifiSignInSettingController *settingController = [[KDAutoWifiSignInSettingController alloc] init];
    [self.navigationController pushViewController:settingController animated:YES];
}

- (void)backAction:(id)sender {
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
