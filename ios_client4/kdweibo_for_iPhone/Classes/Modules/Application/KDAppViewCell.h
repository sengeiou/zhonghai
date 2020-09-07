//
//  KDAppViewCell.h
//  kdweibo
//
//  Created by 王 松 on 13-11-30.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDImageView.h"

@interface KDAppViewCell : UITableViewCell

@property (nonatomic,retain) KDImageView *iconImageView;

- (void)reset;

@end
