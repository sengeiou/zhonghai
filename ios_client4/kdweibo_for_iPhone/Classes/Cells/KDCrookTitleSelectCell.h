//
//  KDCrookTitleSelectCell.h
//  kdweibo
//
//  Created by bird on 14-4-22.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDCrookTitleSelectCell : UITableViewCell

@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) UILabel *companyIdLabel;

- (void)setIsSelected:(BOOL)selected;
- (void)hideCrookView:(BOOL)hidden;
@end
