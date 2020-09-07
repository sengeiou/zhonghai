//
//  GroupInfoViewController.h
//  TwitterFon
//
//  Created by  on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDGroupAvatarView.h"
#import "KDGroup.h"
#import "KDRequestWrapper.h"
@class KDAnimationAvatarView;
@interface GroupInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, KDRequestWrapperDelegate> {
@private    
    KDGroup *group_;
    
    UITableView *tableView_;
    KDAnimationAvatarView *groupAvatarView_;
    UILabel *introLabel_;
    
    struct {
        unsigned int didLoadGroupDetails:1;
        unsigned int enterGroup:1;
    }groupDetailsFlags_;
}

@property(nonatomic, retain) KDGroup *group;
@end
