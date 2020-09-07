//
//  KDPhoneContactCell.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-24.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDPhoneContactCell : UITableViewCell

@property (nonatomic) BOOL picked;

@property (nonatomic, copy) NSString *pickedImageName;
@property (nonatomic, copy) NSString *normalImageName;

@property (nonatomic, readonly) UILabel *nameLabel;

@property (nonatomic, readonly) UILabel *stateLabel;

- (void)setShowStateLabel:(BOOL)show;

@end
