//
//  KDItemWithValueCell.h
//  kdweibo
//
//  Created by shen kuikui on 12-12-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    KDItemWithValueCellStyle1 = 0x00
}KDItemWithValueCellStyle;

@interface KDItemWithValueCell : UITableViewCell

@property (nonatomic, readonly) UILabel *itemLabel;
@property (nonatomic, readonly) UILabel *valueLabel;

- (id)initWithKDStyle:(KDItemWithValueCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
