//
//  KDItemWithValueCell.m
//  kdweibo
//
//  Created by shen kuikui on 12-12-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDItemWithValueCell.h"

@interface KDItemWithValueCell () {
    KDItemWithValueCellStyle style_;
}

@end

@implementation KDItemWithValueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}

- (id)initWithKDStyle:(KDItemWithValueCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if(self) {
        style_ = style;
        
        [self setupLabels];
    }
    
    return self;
}

- (void)setupLabels {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel *)itemLabel {
    return self.textLabel;
}

- (UILabel *)valueLabel {
    return self.detailTextLabel;
}

- (CGRect)frameForItemLabelWithStyle:(KDItemWithValueCellStyle)style {
    CGRect rect;
    
    //TODO:
    
    return rect;
}

- (CGRect)frameForValueLabelWithStyle:(KDItemWithValueCellStyle)style {
    CGRect rect;
    
    //TODO:
    
    return rect;
}
@end
