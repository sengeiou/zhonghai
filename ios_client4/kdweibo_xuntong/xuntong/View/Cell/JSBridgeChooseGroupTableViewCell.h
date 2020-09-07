//
//  JSBridgeChooseGroupTableViewCell.h
//  kdweibo
//
//  Created by wenbin_su on 15/6/1.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTSelectStateView.h"

@class JSBridgeChooseGroupTableViewCell;
@class XTOrgChildrenDataModel;

@protocol JSBridgeChooseGroupTableViewCellDelegate <NSObject>

-(void)childGroupButtonClickedMessage:(JSBridgeChooseGroupTableViewCell *)cell;

@end

@interface JSBridgeChooseGroupTableViewCell : UITableViewCell
@property (nonatomic, strong) id<JSBridgeChooseGroupTableViewCellDelegate> delegate;

@property (nonatomic, assign) BOOL checked;
@property (nonatomic, strong) XTSelectStateView *selectStateView;
@property (nonatomic, strong) UILabel *groupLabelOne;
@property (nonatomic, strong) UIButton *childGroupButton;
@property (nonatomic, strong) UIImageView *actionImageView;
@property (nonatomic, strong) XTOrgChildrenDataModel *model;

- (void)setChecked:(BOOL)checked;
- (void)setChecked:(BOOL)checked animated:(BOOL)animated;
@end