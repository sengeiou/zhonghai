//
//  XTContactEmployeesView.h
//  XT
//
//  Created by Gil on 13-7-17.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTPersonHeaderView.h"

@protocol XTContactEmployeesViewDelegate <NSObject>

- (void)personHeaderClicked:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person;

@end

@interface XTContactEmployeesView : UIView <XTPersonHeaderViewDelegate>

@property (nonatomic, strong) NSArray *personIds;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, weak) id <XTContactEmployeesViewDelegate> delegate;

//- (id)initWithPersonIds:(NSArray *)personIds;

@end

