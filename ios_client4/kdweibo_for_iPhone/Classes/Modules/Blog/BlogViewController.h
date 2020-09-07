//
//  BlogViewController.h
//  TwitterFon
//
//  Created by apple on 11-6-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"
#import "RefreshTableFootView.h"

#import "KDUserDataLoaderProtocol.h"
#import "KDRequestWrapper.h"

#import "KDRefreshTableView.h"

@protocol BlogViewControllerDelegate;
@class KDStatusTimelineProvider;

@interface BlogViewController : UIViewController <KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, KDUserDataLoader, KDRequestWrapperDelegate>

@property(nonatomic, assign) id<BlogViewControllerDelegate> delegate;
@property(nonatomic, retain) KDUser *user;
@property(nonatomic, retain) NSString *subTitle;

- (void)getUserTimeline;
- (void)reloadTableViewDataSource;

@end

@protocol BlogViewControllerDelegate <NSObject>
@optional
- (void)blogViewController:(BlogViewController *)blogViewController withStatusCount:(NSInteger)count;

@end
