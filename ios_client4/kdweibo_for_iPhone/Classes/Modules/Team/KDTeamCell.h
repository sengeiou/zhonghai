//
//  KDTeamCell.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDAvatarView.h"
#import "KDCommunity.h"

@interface KDTeamCell : UITableViewCell

@property (nonatomic, retain) KDCommunity *community;
@property (nonatomic, readonly) UILabel   *teamNameLabel;
@property (nonatomic, readonly) UILabel   *teamNumberLabel;
@property (nonatomic, readonly) KDAvatarView *avatarView;
@property (nonatomic, readonly) UIView    *menuView;
@property (nonatomic, readonly) UIView    *frontView;
@property (nonatomic, readonly) UILabel   *addButtonLabel;

@property (nonatomic, assign) BOOL showAddButton;
@property (nonatomic, assign) BOOL showTeamNumber;
@property (nonatomic, assign) BOOL canSlide;
@property (nonatomic, assign) BOOL needBottomSeperator;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

+ (CGFloat)defaultHeight;

- (void)update;

@end
