//
//  KDABPersonActionCell.h
//  kdweibo
//
//  Created by shen kuikui on 13-8-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDTableViewCell.h"

@interface KDABPersonActionCell : KDTableViewCell

@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *invocations;

- (void)setMenuOffset:(CGSize)menuOffset;

@end
