//
//  KDActivityCell.h
//  kdweibo
//
//  Created by 陈彦安 on 15/4/22.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDActivityCell : UITableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)setActivityAnimate;
@end
