//
//  XTInvitePhoneContactCell.m
//  XT
//
//  Created by chen qicheng on 14-3-31.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import "XTInvitePhoneContactCell.h"
#import "XTSelectStateView.h"

@interface XTInvitePhoneContactCell ()
@property (nonatomic, strong) XTSelectStateView *selectStateView;
@end

@implementation XTInvitePhoneContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        XTSelectStateView *selectStateView = [[XTSelectStateView alloc] initWithFrame:CGRectMake(11.0, 4.0, 30.0, 45.0)];
        self.selectStateView = selectStateView;
        [self addSubview:self.selectStateView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 19, 300, 16)];
        self.nameLabel.font = [UIFont systemFontOfSize:16.0];
        self.nameLabel.textColor = BOSCOLORWITHRGBA(0x7A7A7A, 1.0);
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

@end
