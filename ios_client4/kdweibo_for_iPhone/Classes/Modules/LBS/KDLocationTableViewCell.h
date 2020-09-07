//
//  KDLocationTableViewCell.h
//  kdweibo
//
//  Created by weihao_xu on 14-4-1.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Blur.h"
@interface KDLocationTableViewCell : KDTableViewCell
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UILabel *subLabel;
@property(nonatomic, strong) UIImageView *accessoryImageView;
@end
