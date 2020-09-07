//
//  TrendStatusViewController.h
//  TwitterFon
//
//  Created by apple on 11-6-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDTopic.h"
#import "KDRequestWrapper.h"
#import "KDRefreshTableView.h"
#import "KDMenuView.h"

@class KDStatusTimelineProvider;

@interface TrendStatusViewController : UIViewController<KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, KDRequestWrapperDelegate, KDMenuViewDelegate>

@property(nonatomic, retain) KDStatus *topicStatus;

- (id)initWithTopic:(KDTopic *)topic;
- (void)getTopicMessage:(BOOL)isLoadMore;
- (void)beginGetTimeline;



@end
