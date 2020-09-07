//
//  KDChooseDepartmentTableViewCell.h
//  kdweibo
//
//  Created by DarrenZheng on 14-7-10.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDChooseDepartmentModel.h"

@protocol KDChooseDepartmentTableViewCellDelegate;

@interface KDChooseDepartmentTableViewCell : KDTableViewCell

@property(nonatomic, weak) id <KDChooseDepartmentTableViewCellDelegate> delegate;
@property(nonatomic, assign) int index;
@property(nonatomic, strong) UILabel *labelDepartment;
@property (strong , nonatomic) UILabel *labelPersonCount;
@property(nonatomic, assign) BOOL checked;
@property(nonatomic, assign) BOOL bShouldShowAccessoryIndicator;
@property (nonatomic, strong) KDChooseDepartmentModel *model;

@end

@protocol KDChooseDepartmentTableViewCellDelegate <NSObject>

- (void)buttonCheckboxPressed:(KDChooseDepartmentModel *)model index:(NSInteger)modelIndex title:(NSString *)title;

@end