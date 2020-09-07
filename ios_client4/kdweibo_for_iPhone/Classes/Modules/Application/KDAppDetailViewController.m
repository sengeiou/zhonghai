//
//  KDAppDetailViewController.m
//  kdweibo
//
//  Created by AlanWong on 14-9-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDAppDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "BOSUtils.h"
#import "UIButton+XT.h"
#import "KDAppDataModel.h"

#define kImageDefaultIcon @"app_default_icon.png"
@interface KDAppDetailViewController ()
{
    UIScrollView *bgView;
    UIImageView *topBG;
    UIImageView *imageView;
    UILabel *appTitle;
    UILabel *detailTitle;
    UILabel *appVersion;
    UIButton *setupBtn;
    UIImageView *detailTagView;
    UILabel *detailDescribe;
    KDAppDataModel *appDM;
}
@end

@implementation KDAppDetailViewController

- (id)initWithAppDataModel:(KDAppDataModel * )appDataModel{
    self = [super init];
    if (self)
    {
        _sourceType = KDAppSourceTypeCentre;
        appDM = appDataModel;
        
        self.title = ASLocalizedString(@"KDAppDetailViewController_detail");
        [self.view setBackgroundColor:[UIColor kdBackgroundColor2]];
        
        //底图
        bgView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, ScreenFullHeight)];
        bgView.backgroundColor = [UIColor kdBackgroundColor2];//BOSCOLORWITHRGBA(0xEEEEEE, 1.0);
        [self.view addSubview:bgView];
        
        //上部分底
        topBG = [[UIImageView alloc] init];
        topBG.backgroundColor = [UIColor kdBackgroundColor2];//BOSCOLORWITHRGBA(0xFAFAFA, 1.0);
        topBG.userInteractionEnabled = YES;
        topBG.frame = CGRectMake(0, 0, ScreenFullWidth, 125);
        [bgView addSubview:topBG];
        
        //分割线
        UIView *splitLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topBG.frame), self.view.frame.size.width, 1)];
        splitLineView.backgroundColor = [UIColor kdBackgroundColor1];
        [bgView addSubview:splitLineView];
        
        //应用图标
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(15, 17, 64, 64);
        imageView.layer.cornerRadius = (AppImageViewCornerRadius==-1?(CGRectGetHeight(imageView.frame)/2):KApplicationCornerRadius(CGRectGetHeight(imageView.frame)));
        imageView.layer.masksToBounds = YES;
        if (!appDM.appLogo || [appDM.appLogo isKindOfClass:[NSNull class]] || [appDM.appLogo isEqual:@""]) {
            imageView.image = [UIImage imageNamed:kImageDefaultIcon];
        } else {
            [imageView setImageWithURL:[NSURL URLWithString:appDM.appLogo] placeholderImage:[UIImage imageNamed:kImageDefaultIcon]];
        }
        [topBG addSubview:imageView];
        
        //应用名称
        appTitle = [[UILabel alloc] init];
        appTitle.frame = CGRectMake(115, 24, 200, 20);
        appTitle.text = appDM.appName;
        appTitle.textColor = BOSCOLORWITHRGBA(0x000000, 1.0);
        appTitle.font = [UIFont systemFontOfSize:16];
        appTitle.backgroundColor = [UIColor clearColor];
        [topBG addSubview:appTitle];
        
        //版本
        if(appDM.appClientVersion)
        {
            appVersion = [[UILabel alloc] init];
            appVersion.frame = CGRectMake(114, 48, 100, 20);
            appVersion.text = appDM.appClientVersion;
            appVersion.font = [UIFont systemFontOfSize:14];
            appVersion.textColor = BOSCOLORWITHRGBA(0x808080, 1.0);
            appVersion.backgroundColor = [UIColor clearColor];
            [topBG addSubview:appVersion];
        }
        
        //添加 按纽
        setupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        setupBtn.frame = CGRectMake(ScreenFullWidth - 15 - 78, 78, 78, 29);
        NSString *btnTitle = ASLocalizedString(@"KDAppDetailViewController_add");
        [setupBtn setTitle:btnTitle forState:UIControlStateNormal];
        [setupBtn setTitle:btnTitle forState:UIControlStateHighlighted];
        [setupBtn setTitleColor:FC3 forState:UIControlStateDisabled];
        [setupBtn setTitleColor:FC6 forState:UIControlStateHighlighted];
        [setupBtn setTitleColor:FC6 forState:UIControlStateNormal];
        setupBtn.titleLabel.font = FS4;
        
        [setupBtn setBackgroundImage:[UIImage imageWithColor:FC5] forState:UIControlStateNormal];
        [setupBtn setBackgroundImage:[UIImage imageWithColor:FC7] forState:UIControlStateHighlighted];
        [setupBtn setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor1]] forState:UIControlStateDisabled];
        setupBtn.layer.cornerRadius = 14.5;
        setupBtn.layer.masksToBounds = YES;
        [setupBtn addTarget:self action:@selector(setupBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [topBG addSubview:setupBtn];
        
        //详情介绍 标题
        detailTitle = [[UILabel alloc] init];
        detailTitle.frame = CGRectMake(15, 147,ScreenFullWidth - 30, 20);
        detailTitle.text = ASLocalizedString(@"KDAppDetailViewController_introduce");
        detailTitle.textColor = BOSCOLORWITHRGBA(0x3F3F3F, 1.0);
        detailTitle.font = [UIFont systemFontOfSize:16];
        detailTitle.backgroundColor = [UIColor clearColor];
        [bgView addSubview:detailTitle];
        
        //详情描述
        detailDescribe = [[UILabel alloc] init];
        detailDescribe.font = [UIFont systemFontOfSize:12];
        detailDescribe.textColor = BOSCOLORWITHRGBA(0x808080, 1.0);
        detailDescribe.backgroundColor = [UIColor clearColor];
        detailDescribe.lineBreakMode = NSLineBreakByWordWrapping;
        detailDescribe.numberOfLines = 0;
        detailDescribe.text = appDM.appDesc;
        CGSize strSize = [detailDescribe.text sizeWithFont:detailDescribe.font constrainedToSize:CGSizeMake(ScreenFullWidth, 500) lineBreakMode:detailDescribe.lineBreakMode];
        detailDescribe.frame = CGRectMake(15, 170, 285, strSize.height + 20);
        [bgView addSubview:detailDescribe];
        int height = detailDescribe.frame.origin.y + strSize.height + 90;
        height = height > MainHeight ? height : MainHeight;
        [bgView setContentSize:CGSizeMake( ScreenFullWidth, height)];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)setupBtnPressed
{
    if (_sourceType == KDAppSourceTypeCentre) {
        [KDEventAnalysis event:event_app_add attributes:@{label_event_app_add_source:label_event_app_add_source_list}];
    }
    else if(_sourceType == KDAppSourceTypeSearch){
        [KDEventAnalysis event:event_app_add attributes:@{label_event_app_add_source:label_event_app_add_source_search}];
    }
    else if(_sourceType == KDAppSourceTypeRecommend){
        [KDEventAnalysis event:event_app_add attributes:@{label_event_app_add_source:label_event_app_add_source_recommend}];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:appDM, @"appDM", nil];
    NSNotification *notification = [NSNotification notificationWithName:@"Personal_App_Add" object:nil userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}*/

- (void)setHasFavorite:(BOOL)hasFavorite
{
    if(_hasFavorite != hasFavorite)
    {
        [setupBtn setEnabled:!hasFavorite];
        NSString * btnTitle = @"";
        if(hasFavorite)
        {
            btnTitle = ASLocalizedString(@"KDAppDetailViewController_added");
            [setupBtn setTitle:btnTitle forState:UIControlStateDisabled];
        }
        else
        {
            btnTitle = ASLocalizedString(@"KDAppDetailViewController_add");
            [setupBtn setTitle:btnTitle forState:UIControlStateNormal];
            [setupBtn setTitle:btnTitle forState:UIControlStateHighlighted];
        }
        _hasFavorite = hasFavorite;
    }
}

#pragma mark - 添加按钮点击，如果有网络就添加，如果没有网络就存放在本地
- (void)setupBtnPressed {
    if ([[KDReachabilityManager sharedManager] isReachable]) {
        DLog(@"KDAppDetailViewController_tips_add");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddApp" object:nil userInfo:[NSDictionary dictionaryWithObject:appDM forKey:@"appDM"]];
        [self storeAndback];
        
    }else {
        DLog(@"KDAppDetailViewController_network_fail");
        [self storeAppToBeAddIntoUserDefault];
    }
}

-(void)storeAppToBeAddIntoUserDefault {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempMutableArray;
    NSArray *tempArray;
    
    tempArray = [ud objectForKey:@"AddNetWorkNotReachable"];
    
    if (tempArray == nil || tempArray == 0) {
        
        //如果按NewWordNotReachable找不到值，创建一个数组加入当前appId
        tempMutableArray = [NSMutableArray array];
        
        if(appDM.appClientID != nil) {
            int appid = [appDM.appClientID intValue] / 100;
            [tempMutableArray addObject:[NSString stringWithFormat:@"%d", appid]];
        }
        
        if (appDM.pid != nil) {
            [tempMutableArray addObject:appDM.pid];
        }
        
    }else {
        
        //如果NSUserDefaults已经有这个被删除的应用直接return
        for (int i = 0; i < tempArray.count; i++) {
            NSString *tempString = tempArray[i];
            
            if(appDM.appClientID != nil) {
                NSString *appid = [NSString stringWithFormat:@"%d", [appDM.appClientID intValue] / 100];
                if ([tempString isEqualToString:appid]) {
                    return;
                }
            }
            if (appDM.pid != nil) {
                if ([tempString isEqualToString:appDM.appID]) {
                    return;
                }
            }
            
        }
        
        tempMutableArray = [NSMutableArray arrayWithArray:tempArray];
        
        if (appDM.appClientID != nil) {
            NSString *appid = [NSString stringWithFormat:@"%d", [appDM.appClientID intValue] / 100];
            [tempMutableArray addObject:appid];
        }
        
        if (appDM.pid != nil) {
            [tempMutableArray addObject:appDM.pid];
        }
        
    }
    
    tempArray = [NSArray arrayWithArray:tempMutableArray];
    
    [ud setObject:tempArray forKey:@"AddNetWorkNotReachable"];
    [ud synchronize];
    
    NSArray *myArray = [ud objectForKey:@"AddNetWorkNotReachable"];
    DLog(@"+++++++++++++++++++++++++++++++++++++++++++++++++\n myArray = %@", myArray);
    
    [self storeAndback];
}

-(void)storeAndback {
    if (_sourceType == KDAppSourceTypeCentre) {
        [KDEventAnalysis event:event_app_add attributes:@{label_event_app_add_source:label_event_app_add_source_list}];
    }
    else if(_sourceType == KDAppSourceTypeSearch){
        [KDEventAnalysis event:event_app_add attributes:@{label_event_app_add_source:label_event_app_add_source_search}];
    }
    else if(_sourceType == KDAppSourceTypeRecommend){
        [KDEventAnalysis event:event_app_add attributes:@{label_event_app_add_source:label_event_app_add_source_recommend}];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:appDM, @"appDM", nil];
    NSNotification *notification = [NSNotification notificationWithName:@"Personal_App_Add" object:nil userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
@end
