//
//  RecommendViewController+XT.m
//  XT
//
//  Created by Gil on 13-7-29.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "RecommendViewController+XT.h"
#import "UIButton+XT.h"
#import "RecommendAppDetailViewController+XT.h"

@implementation RecommendViewController (XT)

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.type == RecommendTypeField) {
        UIButton *otherButton = [UIButton buttonWithTitle:ASLocalizedString(@"KDAppSerachViewController_all")];
        [otherButton addTarget:self action:@selector(all) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *otherItem = [[UIBarButtonItem alloc] initWithCustomView:otherButton];
        self.navigationItem.rightBarButtonItem = otherItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)all
{
    RecommendViewController *recommend = [[RecommendViewController alloc] initWithRecommendType:RecommendTypeOther];
    recommend.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recommend animated:YES];
}

@end
