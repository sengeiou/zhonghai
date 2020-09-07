//
//  GroupViewController.h
//  TwitterFon
//
//  Created by apple on 11-1-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDRequestWrapper.h"
#import "KDManagerContext.h"
#import "KDRefreshTableView.h"
#import "KDErrorDisplayView.h"

@interface GroupViewController : UIViewController <KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, KDRequestWrapperDelegate, KDUnreadListener> {
 @private
	NSMutableArray *groupArray;
    
    KDRefreshTableView *tableView_;
    
    struct {
        unsigned int loadingGroups:1;
        unsigned int viewDidUnload:1;
    }groupViewControllerFlags_;
    
    UIImageView *backgroundView;
    
}

@property(nonatomic, retain) NSMutableArray *groupArray;


//获取当前我的小组列表
- (void)getGroupList;
- (void)didChangeGroupBadgeValue;

@end
