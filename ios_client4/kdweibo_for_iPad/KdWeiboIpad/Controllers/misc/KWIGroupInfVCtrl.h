//
//  KWIGroupInfVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/6/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KWIRPanelVCtrl.h"

@class KDGroup;

@interface KWIGroupInfVCtrl : UIViewController <KWICardlikeVCtrl>

@property (retain, nonatomic) KDGroup *group;
@property (retain, nonatomic) UITableView *tableView;

+ (KWIGroupInfVCtrl *)vctrlWithGroup:(KDGroup *)group;

- (void)shadowOn;
- (void)shadowOff;

@end
