//
//  KDMessageViewCell.h
//  kdweibo
//
//  Created by 王 松 on 13-11-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDMessageViewCell : UITableViewCell

@property (nonatomic, retain) NSString *title;

@property (nonatomic, retain) NSString *content;

@property (nonatomic, retain) NSString *date;

@property (nonatomic, retain) UIImage *image;

@property (nonatomic, assign) NSInteger badgeValue;

@property (nonatomic, assign, getter = isShowbadgeTips) BOOL showbadgeTips;

@end
