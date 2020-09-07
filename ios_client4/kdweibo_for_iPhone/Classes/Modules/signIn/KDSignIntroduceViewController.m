//
//  KDSignIntroduceViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 13-9-4.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDSignIntroduceViewController.h"
#import "KDSheet.h"

@interface KDSignIntroduceViewController ()
@property(nonatomic,retain)UIScrollView *scrollView;
@property(nonatomic,retain)KDSheet * sheet;
@end

@implementation KDSignIntroduceViewController
@synthesize scrollView = scrollView_;

- (void)dealloc {
    //KD_RELEASE_SAFELY(scrollView_);
    //[super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = ASLocalizedString(@"KDSignInSettingViewController_functionCell_leftLabel_text");
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
    CGRect frame = self.view.bounds;
    frame.origin.y = 12;
    frame.size.height = CGRectGetHeight(frame)-12;
    scrollView_ = [[UIScrollView alloc] initWithFrame:frame];
    [self.view addSubview:scrollView_];
    scrollView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addImageViewToScrllView:scrollView_ imageNameFormat:@"sgin_img_pic" imageCount:6];
}

-(void)setupRightBarButtonItem{
    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0.0, 0.0, 50, 50)];
    
    [rightButton setBackgroundImage:[UIImage imageNamed:@"status_detail_navigationbar_more"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(showShareActionSheet) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)showShareActionSheet{
    NSData * imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"app_img_qiandao"], 0.3);
    

    KDSheetShareType shareType =(KDSheetShareWayQQ | KDSheetShareWayWeibo | KDSheetShareWayWechat |KDSheetShareWayMoment |KDSheetShareWayQzone);
    KDSheet * sheel = [[KDSheet alloc]initMediaWithShareWay:shareType title:[NSString stringWithFormat:ASLocalizedString(@"%@移动签到，不花一分钱，轻松实现企业的考勤管理和分析。功能、体验都是杠杠的，推荐你也用下。"),KD_APPNAME] description:@"" thumbData:imageData webpageUrl:@"http://kdweibo.com/home/download/" viewController:self];
    _sheet = sheel;
    [sheel share];
    
}
-(void)addImageViewToScrllView:(UIScrollView *)scrollView imageNameFormat:(NSString * )imageNameFormat imageCount:(NSUInteger)imageCount{
    if (scrollView == nil || imageNameFormat == nil || imageCount == 0) {
        return;
    }

    float heignt = 0;
    for (NSInteger i = 1 ; i <= imageCount; i++) {
        NSString * imageName = [NSString stringWithFormat:@"%@%ld",imageNameFormat,(long)i];
        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        CGRect frame = imageView.bounds;
        frame.origin.y = heignt;
        imageView.frame = frame;
        [scrollView addSubview:imageView];
        heignt = CGRectGetMaxY(imageView.frame);
    }
    [scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, heignt)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	// Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [btn setTitle:ASLocalizedString(@"Global_GoBack") forState:UIControlStateNormal];
    
    [btn setBackgroundImage:[UIImage imageNamed:@"navigationItem_back.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"navigationItem_back_hl.png"] forState:UIControlStateHighlighted];
    
    [btn sizeToFit];
    
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
     //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];// autorelease];
    negativeSpacer.width = kLeftNegativeSpacerWidth;
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:negativeSpacer,leftItem, nil];
    
//    [leftItem release];
    [self setupRightBarButtonItem];


}
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
