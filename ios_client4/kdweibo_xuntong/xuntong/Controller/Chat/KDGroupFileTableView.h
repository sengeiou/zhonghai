//
//  KDGroupFileTableView.h
//  kdweibo
//
//  Created by lichao_liu on 9/15/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDFileInMessageTableViewCell.h"
#import "KDFileInMessageViewController.h"
typedef NS_ENUM(NSInteger, KDGroupFileSource) {
    KDGroupFileSource_recent = -1,
    KDGroupFileSource_document = 0,
    KDGroupFileSource_picture = 1,
    KDGroupFileSource_other = 4
};
@interface KDGroupFileTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) KDGroupFileSource fileSource;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, assign) id<KDFileInMessageTableViewCellDelegate> cellDelegate;
@property (nonatomic, assign) KDFileInMessageViewController *controller;
- (void)loadData;

@end
