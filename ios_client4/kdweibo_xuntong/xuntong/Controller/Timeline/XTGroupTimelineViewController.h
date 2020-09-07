//
//  XTGroupTimelineViewController.h
//  XT
//
//  Created by Gil on 13-7-24.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTTimelineCell.h"

@protocol XTGroupTimelineViewControllerDelegate;
@interface XTGroupTimelineViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<XTGroupTimelineViewControllerDelegate> delegate;

@property (nonatomic, strong) XTSelectPersonsView *selectPersonsView;

//语音会议
@property (nonatomic, assign) BOOL inviteFromAgora;
@property (nonatomic, strong) GroupDataModel  *exitedGroup; //已经选择了的参会人员

@end

@protocol XTGroupTimelineViewControllerDelegate <NSObject>

@optional
- (void)groupTimeline:(XTGroupTimelineViewController *)controller group:(GroupDataModel *)group;

@end
