//
//  KDChooseDepartmentBottomBarView.h
//  kdweibo
//
//  Created by DarrenZheng on 14-7-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDChooseDepartmentModel.h"
#import "KDSelectItemView.h"

@protocol KDChooseDepartmentBottomBarViewDelegate;

@interface KDChooseDepartmentBottomBarView : UIView

@property (nonatomic, strong , readonly) NSMutableArray *departmentModels;
@property(nonatomic, strong) UILabel *labelDepartment;
@property(nonatomic, weak) id <KDChooseDepartmentBottomBarViewDelegate> delegate;
@property (assign , nonatomic) BOOL isMutil;
- (void)updateButtonColor;
- (void)updateButtonColorWithConfirm:(BOOL)confirm;

- (void)reloadDataWithDepartments:(NSArray *)departments;
@end


@protocol KDChooseDepartmentBottomBarViewDelegate <NSObject>

- (void)buttonConfirmPressed;

@end