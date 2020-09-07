//
//  KDChangeTeamTableViewCell.h
//  kdweibo
//
//  Created by kingdee on 16/7/11.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"

@interface KDChangeTeamTableViewCell : KDTableViewCell
@property (nonatomic, strong)UIImageView *teamHeadView;
@property (nonatomic, strong)UILabel *teamNameLabel;

/**
 *  @return 重用标识符
 */
+ (NSString *)reuseIdentifier;

/**
 *  @return Cell的高度
 */
+ (CGFloat)rowHeight;


@end
