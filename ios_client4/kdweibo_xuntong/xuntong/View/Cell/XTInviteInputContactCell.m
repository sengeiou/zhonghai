//
//  XTInviteInputContactCell.m
//  XT
//
//  Created by chen qicheng on 14-4-2.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import "XTInviteInputContactCell.h"
#import "UIButton+XT.h"

@interface XTInviteInputContactCell ()
@end

@implementation XTInviteInputContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 19, 300, 16)];
        self.phoneNumberLabel.font = [UIFont systemFontOfSize:16.0];
        self.phoneNumberLabel.textColor = BOSCOLORWITHRGBA(0x7A7A7A, 1.0);
        self.phoneNumberLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.phoneNumberLabel];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(280, 17.0, 22.0, 24.0)];
        [btn setBackgroundImage:[XTImageUtil deleteButtonImageWithState:UIControlStateNormal] forState:UIControlStateNormal];
        [btn setBackgroundImage:[XTImageUtil deleteButtonImageWithState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        self.deleteBtn = btn;
        [self.contentView addSubview:self.deleteBtn];
        
    }
    return self;
}

@end
