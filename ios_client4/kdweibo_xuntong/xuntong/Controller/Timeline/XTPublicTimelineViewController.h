//
//  PubGroupListViewController.h
//  ContactsLite
//
//  Created by Gil on 12-12-25.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTTimelineCell.h"

@interface XTPublicTimelineViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
//,XTGroupHeaderImageViewDelegate> 不再需要点击头像进入详情，先保留代码

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) UITableView *tableView;

@end
