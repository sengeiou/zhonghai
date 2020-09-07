//
//  KDFavoriteStatusesViewController.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-8-1.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDUserDataLoaderProtocol.h"

#import "KDRefreshTableView.h"
#import "KDRequestWrapper.h"

@class KDStatus;
@class KDStatusTimelineProvider;

@interface KDFavoriteStatusesViewController : UIViewController <UIActionSheetDelegate, KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, KDRequestWrapperDelegate, KDUserDataLoader> {
 @private
    KDStatusTimelineProvider *timelineProvider_;
    
    NSMutableArray *statuses_;
    NSInteger pageIndex_;
    KDStatus *selectedStatus_;
    
    KDRefreshTableView *tableView_;
    
    NSCache *cellCache_;
    
    struct {
        unsigned int dismissed:1;
    }statusesViewControllerFlags_;
}

@end
