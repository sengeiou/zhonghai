//
//  CleanDataTableViewCell.h
//  kdweibo
//
//  Created by wenjie_lee on 15/7/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTSelectStateView.h"


@class CleanDataTableViewCell;

@protocol CleanDataTableViewCellDelegate <NSObject>

- (void)didSelectedCell:(CleanDataTableViewCell *)cell;

@end
@interface CleanDataTableViewCell : KDTableViewCell
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, readonly) XTSelectStateView *selectStateView;

- (void)setChecked:(BOOL)checked;
- (void)setChecked:(BOOL)checked animated:(BOOL)animated;
-(void)displayWithText:(NSString *)text Image:(NSString *)image andSize:(NSString*)size;
@end