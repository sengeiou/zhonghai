//
//  KWIPeopleVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/7/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDUser.h"
#import "KWIRPanelVCtrl.h"

@interface KWIPeopleVCtrl : UIViewController <KWICardlikeVCtrl>

// act as mpanel requiring this attr exists
@property (retain, nonatomic) UITableView *tableView;

+ (KWIPeopleVCtrl *)vctrlWithUser:(KDUser *)user;
+ (KWIPeopleVCtrl *)vctrlForProfile;

- (NSString *)userId;

- (void)shadowOn;
- (void)shadowOff;

@end
