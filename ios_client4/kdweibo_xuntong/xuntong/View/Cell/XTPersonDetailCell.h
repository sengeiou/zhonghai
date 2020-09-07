//
//  XTPersonDetailCell.h
//  XT
//
//  Created by Gil on 13-7-24.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonDataModel.h"

@interface XTPersonDetailCell : UITableViewCell

@property (nonatomic, strong, readonly) UIImageView *iconImageView;
@property (nonatomic, strong, readonly) UILabel *contactTextLabel;
@property (nonatomic, strong, readonly) UIImageView *separateLineImageView;

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) ContactDataModel *contact;

@end
