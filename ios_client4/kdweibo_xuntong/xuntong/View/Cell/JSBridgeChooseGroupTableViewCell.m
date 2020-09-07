//
//  JSBridgeChooseGroupTableViewCell.m
//  kdweibo
//
//  Created by wenbin_su on 15/6/1.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "JSBridgeChooseGroupTableViewCell.h"

@implementation JSBridgeChooseGroupTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSome];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self initSome];
}

-(void)initSome {
    self.selectStateView = [[XTSelectStateView alloc]initWithFrame:CGRectMake(12, 0, 30, 65)];
    [self addSubview:self.selectStateView];
    
    self.groupLabelOne = [[UILabel alloc]initWithFrame:CGRectMake(12+30+5, 0, ScreenFullWidth - (12+30+5) - 50, 65)];
    self.groupLabelOne.font = [UIFont systemFontOfSize:17];
    [self addSubview:self.groupLabelOne];
    
    self.actionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenFullWidth - 50 + 12, 26, 8, 12)];
    self.actionImageView.image = [UIImage imageNamed:@"arrow_normal"];
    [self addSubview:self.actionImageView];
    
    self.childGroupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.childGroupButton.frame = CGRectMake(ScreenFullWidth - 50, 0, 50, 65);
    [self.childGroupButton addTarget:self action:@selector(childGroupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.childGroupButton];
    [self bringSubviewToFront:self.childGroupButton];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated
{
    _checked = checked;
    
    [self.selectStateView setSelected:checked animated:animated];
    
}

- (void)setChecked:(BOOL)checked
{
    [self setChecked:checked animated:NO];
}

-(void)childGroupButtonClicked:(UIButton *)sender {
    [self.delegate childGroupButtonClickedMessage:self];
}
@end
