//
//  KDAboutViewController.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-19.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class KDAppVersionUpdates;

@interface KDAboutViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
@private
    KDAppVersionUpdates *versionUpdates_;
    BOOL hasNewVersion_;
    
    UITableView *tableView_;
}

@end
