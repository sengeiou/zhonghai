//
//  KDPhontSignIntroduceController.m
//  kdweibo
//
//  Created by lichao_liu on 1/22/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDPhotoSignIntroduceController.h"

@interface KDPhotoSignIntroduceController ()
{
    NSArray *_titlesArray;
    NSArray *_contentArray;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation KDPhotoSignIntroduceController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = ASLocalizedString(@"拍照签到说明");
    self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(backAction:)];
    
    CGRect frame = self.view.bounds;
    frame.origin.y = 5;
    frame.size.height = CGRectGetHeight(frame)-5;
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    [self.view addSubview:_scrollView];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _titlesArray = @[ASLocalizedString(@"1、什么叫拍照签到？"),ASLocalizedString(@"2、拍照签到记录，是否需要管理员审核？"),ASLocalizedString(@"3、如果保证数据的准确性，及防止员工作弊？"),ASLocalizedString(@"4、管理员如何进行有效的管理呢？")];
    _contentArray = @[ASLocalizedString(@"wifi定位等紧急情况下，通过实地图片来证明你在某一地点的签到，它是正常签到的一种补充。"),ASLocalizedString(@"拍照签到相当于事前的补签，是一种事前授权、事后审核的员工自主、人性化的考勤方式，不需要管理员审核。"),ASLocalizedString(@"1）拍照签到需要实地拍照，并加水印，不能调取本机图片；\n 2）通过定时器校正手机本地时间，防止员工人为调整手机的作弊行为； 管理员可通过查看图片与填写的地点，以及查看离线签到的频率来检查作弊，一旦发现作弊通过行政手段进行处罚。"),ASLocalizedString(@"如果有需要，管理员可登陆网页端（yunzhijia.com）在【应用】-【签到】的签到设置页签，输入拍照签到的次数，及生效日期，来进行相应的约束，设置后会通知到所有员工。")];
    [self addImageViewToScrllView:_scrollView  imageCount:_titlesArray.count];
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
}

-(void)addImageViewToScrllView:(UIScrollView *)scrollView imageCount:(NSUInteger)imageCount
{
    
    float heignt = 5;
    for (NSInteger i = 1 ; i <= imageCount; i++) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        
        titleLabel.text = _titlesArray[i-1];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectMake(10, heignt+ 10 , CGRectGetWidth(titleLabel.frame), CGRectGetHeight(titleLabel.frame));
        heignt +=CGRectGetHeight(titleLabel.frame);
        [scrollView addSubview:titleLabel];
        
        UILabel *detailLabel = [[UILabel alloc] init];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textColor = [UIColor lightGrayColor];
        detailLabel.textAlignment = NSTextAlignmentLeft;
        detailLabel.numberOfLines = 0;
        detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        detailLabel.font = [UIFont systemFontOfSize:14.f];
        detailLabel.text = _contentArray[i-1];
        if(i == 2)
        {
            detailLabel.textColor = [UIColor redColor];
        }
        CGSize labelSize = [detailLabel.text sizeWithFont:[UIFont systemFontOfSize:14]
                                        constrainedToSize:CGSizeMake(scrollView.frame.size.width, 200)
                                            lineBreakMode:NSLineBreakByCharWrapping];
        detailLabel.frame = CGRectMake(10, heignt+ 15, self.view.bounds.size.width - 20, labelSize.height);
        
        heignt += labelSize.height + 25;
        
        [scrollView addSubview:detailLabel];
    }
    
    [scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, heignt)];
}



- (void)backAction:(id)sender {
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
