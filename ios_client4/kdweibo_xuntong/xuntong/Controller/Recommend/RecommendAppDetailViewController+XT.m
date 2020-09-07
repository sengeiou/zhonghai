//
//  RecommendAppDetailViewController+XT.m
//  XT
//
//  Created by Gil on 13-7-29.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "RecommendAppDetailViewController+XT.h"
#import "UIButton+XT.h"

@implementation RecommendAppDetailViewController (XT)

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

@end
