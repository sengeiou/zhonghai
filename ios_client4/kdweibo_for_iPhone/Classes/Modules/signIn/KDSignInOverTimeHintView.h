//
//  KDSignInOverTimeHintView.h
//  kdweibo
//
//  Created by 张培增 on 2017/1/22.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSignInOverTimeModel.h"

typedef void(^KDSignInOverTimeHintViewButtonDidClickBlock)(NSInteger index);

@interface KDSignInOverTimeHintView : UIView

@property (nonatomic, strong) KDSignInOverTimeHintViewButtonDidClickBlock buttonDidClickBlock;

- (instancetype)initWithSignInOverTimeModel:(KDSignInOverTimeModel *)model;

- (void)showHintView;

@end
