//
//  KDMeIconTableViewCell.h
//  kdweibo
//
//  Created by DarrenZheng on 14-10-10.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDMeIconTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imageViewIcon;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UILabel *labelSubTitle;

@property (nonatomic, assign) BOOL bAdmin;

@end
