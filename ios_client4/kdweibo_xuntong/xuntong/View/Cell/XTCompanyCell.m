//
//  XTCompanyCell.m
//  XT
//
//  Created by Ad on 14-3-31.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import "XTCompanyCell.h"
#import "XTSelectStateView.h"

@interface XTCompanyCell()
@property (nonatomic, strong) XTSelectStateView *selectStateView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation XTCompanyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        XTSelectStateView *selectStateView = [[XTSelectStateView alloc] initWithFrame:CGRectMake(15.0, 0.0, 30.0, 45.0)];
        self.selectStateView = selectStateView;
        [self addSubview:selectStateView];
        
        //公司名称
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, 300, 16)];
        self.nameLabel.font = [UIFont systemFontOfSize:16.0];
        self.nameLabel.textColor = BOSCOLORWITHRGBA(0x06A3EC, 1.0);
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated
{
    _checked = checked;
    
    [self.selectStateView setSelected:checked animated:animated];
    
    [self setNeedsLayout];
}

- (void)setChecked:(BOOL)checked
{
    [self setChecked:checked animated:NO];
}

- (void)setCompanyName:(NSString *)companyName
{
    _companyName = companyName;
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nameLabel.text = self.companyName;
}

@end
