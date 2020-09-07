//
//  KDABPersonCell.h
//  kdweibo
//
//  Created by laijiandong on 12-11-7.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDUserAvatarView.h"

@class KDABPerson;

@interface KDABPersonCell : UITableViewCell

@property(nonatomic, retain) KDABPerson *person;

@property(nonatomic, retain, readonly) KDUserAvatarView *avatarView;
@property(nonatomic, retain, readonly) UILabel *nameLabel;
@property(nonatomic, retain, readonly) UILabel *departmentLabel;
@property(nonatomic, retain, readonly) UILabel *stateLabel;

- (void)update:(BOOL)showFavoritedState;

@end
