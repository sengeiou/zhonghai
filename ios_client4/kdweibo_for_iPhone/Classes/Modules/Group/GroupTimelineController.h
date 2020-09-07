//
//  GroupTimelineController.h
//  TwitterFon
//
//  Created by  on 11-11-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDGroup.h"
#import "KDRefreshTableView.h"
#import "KDRequestWrapper.h"

@class KDStatus;

@interface GroupTimelineController : UIViewController<KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, KDRequestWrapperDelegate> {
    
    KDRefreshTableView *_tableView;
    int insertPosition;
    BOOL _haveFootView;
    BOOL _bFirstInit;
    int newStatusCount;
}

@property(nonatomic)BOOL haveFootView;
@property(nonatomic)int newStatusCount;
@property(nonatomic,retain) KDGroup *currentGorup;

- (id)initWithGroup:(KDGroup *)group;
- (void)reloadTableViewDataSource:(UIScrollView *)scrollView;

- (void)restoreGroupStatus;
- (void)removeStatus:(KDStatus *)status;


@end
