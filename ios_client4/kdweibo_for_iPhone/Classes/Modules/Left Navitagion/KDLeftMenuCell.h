//
//  KDLeftMenuCell.h
//  KDLeftMenu
//
//  Created by 王 松 on 14-4-16.
//  Copyright (c) 2014年 Song.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDLeftMenuButton;

extern const int kKDLeftMenuCellButtonPerRow;

@protocol KDLeftMenuCellDelegate;

@interface KDLeftMenuCell : UITableViewCell

@property (nonatomic, copy) NSArray *models;

@property (nonatomic, weak) id<KDLeftMenuCellDelegate> delegate;

@end

@protocol KDLeftMenuCellDelegate <NSObject>

@optional
- (void)leftMenuCell:(KDLeftMenuCell *)leftMenuCell sender:(KDLeftMenuButton *)sender atIndex:(NSUInteger)index;

@end
