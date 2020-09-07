//
//  KDDiscoveryViewController.h
//  kdweibo
//
//  Created by Tan Yingqi on 14-4-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDRefreshTableView.h"
typedef NS_ENUM(NSUInteger, KDDiscoveryViewSection) {
    KDDiscoveryViewSectionCompany = 0,
    KDDiscoveryViewSectionCompanyExtra,
    KDDiscoveryViewSectionTopic,
    KDDiscoveryViewSectionExtraTopic
};

@interface KDDiscoveryViewController : UIViewController

@property (nonatomic, retain) KDRefreshTableView *refreshTableView;

//testData
@property (nonatomic, retain) NSArray *topicsArray;
@end
