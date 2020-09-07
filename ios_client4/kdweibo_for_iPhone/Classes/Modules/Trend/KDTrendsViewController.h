//
//  KDTrendsViewController.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDUserDataLoaderProtocol.h"
//#import "KDSegmentedMenuView.h"

#import "KDWeiboServicesContext.h"
#import "KDRefreshTableView.h"

@class KDUser;

typedef enum {
    KDTrendsViewControllerTypeJoined = 0x01, // The current user joined trends
    KDTrendsViewControllerTypePublic // Public trends, may be recently or weekly trends
    
}KDTrendsViewControllerType;

typedef enum {
    KDTrendsViewControllerContentTypeHot = 0x01,
    KDTrendsViewControllerContentTypeNew
}KDTrendsViewControllerContentType;


@interface KDTrendsViewController : UIViewController <KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, KDRequestWrapperDelegate, KDUserDataLoader> {
@private
    KDTrendsViewControllerType type_;
    KDTrendsViewControllerContentType contentType_;
    KDUser *user_;
    
    NSArray *trends_; // joined trends and weekly trends use same data source variable
    NSArray *recentlyTrends_;
    
    KDRefreshTableView *tableView_;
    
    BOOL reloading_;
    
    NSInteger pageCursor_;
    
    struct {
        unsigned int initilization:1;
        unsigned int viewDidUnload:1;
        unsigned int presentingSubViewController:1;
    }trendsViewControllerFlags_;
}

- (id) initWithTrendsType:(KDTrendsViewControllerType)type;

@property (nonatomic, assign) KDTrendsViewControllerType type;
@property (nonatomic, retain) KDUser *user;

@end
