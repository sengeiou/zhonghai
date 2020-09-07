//
//  KWIGroupLsVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/5/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWIGroupLsVCtrl : UIViewController

@property (retain, nonatomic) UITableView *tableView;

+ (KWIGroupLsVCtrl *)vctrl;

- (void)updateUnreadCount:(NSDictionary *)inf;

- (void)refresh;

@end
