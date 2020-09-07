//
//  KDPersonDetailCell.h
//  kdweibo
//
//  Created by shen kuikui on 14-4-22.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "PersonDataModel.h"
#import <UIKit/UIKit.h>

@protocol KDPersonDetailCellDelegate;

@interface KDPersonDetailCell : KDTableViewCell

@property (nonatomic, assign) id<KDPersonDetailCellDelegate> delegate;
@property (nonatomic, retain) ContactDataModel *contact;
@property (nonatomic, readonly) UIImageView *accessoryImageView;
@property (nonatomic, readonly) UILabel *nameLabel;

@property (nonatomic, assign, setter = setBottom:) BOOL isBottom;

@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

@property (nonatomic, retain) UIImageView *pressImageView;

@property (nonatomic, assign) NSInteger dataIndex;

@property (nonatomic, assign) BOOL showOrganization;

@end


@protocol KDPersonDetailCellDelegate <NSObject>

- (void)personDetailCellMessageButtonPressed:(KDPersonDetailCell *)cell;
- (void)personDetailCellPhoneButtonPressed:(KDPersonDetailCell *)cell;
- (void)personDetailCellEmailButtonPressed:(KDPersonDetailCell *)cell;

@end