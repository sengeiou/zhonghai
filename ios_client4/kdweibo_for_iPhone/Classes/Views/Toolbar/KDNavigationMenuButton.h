//
//  KDNavigationMenuButton.h
//  kdweibo
//
//  Created by Tan yingqi on 13-11-20.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDNavigationMenuButton : UIButton
@property(nonatomic, retain)UIImageView *iconImageView;
@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, retain)UIImageView *arrow;
@property(nonatomic, assign)BOOL isActive;
@end
