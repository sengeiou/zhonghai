//
//  NetworkUserController.h
//  TwitterFon
//
//  Created by apple on 10-11-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDNetworkUserCell.h"
#import "KDRefreshTableView.h"

#import "KDUserDataLoaderProtocol.h"
#import "KDRequestWrapper.h"

@interface NetworkUserController : UIViewController<KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, KDUserDataLoader, KDRequestWrapperDelegate> {
	
	KDNetworkUserCell *userCell;
	
	NSMutableArray *contacts_;
	KDUser * owerUser;
	BOOL isFollowee;
	
	NSInteger currentPage_;
    
    BOOL _haveFootView;
    BOOL isLoadingMore_;
}

@property(nonatomic, retain) KDRefreshTableView *tableView;
@property(nonatomic,assign)BOOL haveFootView;
@property(nonatomic,assign)BOOL isLoadingMore;

@property(nonatomic, retain) NSMutableArray *contacts;
@property(nonatomic, retain) KDUser * owerUser;
@property(nonatomic, assign) BOOL isFollowee;
@property(nonatomic, assign) NSInteger currentPage;

@property(nonatomic,retain) NSMutableArray *filteredArray;

@property(nonatomic, retain) NSString *subTitle; //title

- (void)showTipsOrNot;
- (void)getUserTimeline;
- (void)getUserTimeline_next;
-(void)dataSourceDidFinishLoadingNewData;

@end
