//
//  KDPreInviteCell.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-28.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDPreInviteCell.h"

@implementation KDPreInviteCell
{
    UIImageView *seperator_;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addSeperator];
    }
    return self;
}


- (void)addSeperator
{
    UIImage *image = [UIImage imageNamed:@"phone_contact_seperator"];
    seperator_ = [[UIImageView alloc] initWithImage:image];
    [self.contentView addSubview:seperator_];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    seperator_.frame = CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame) - 1.0f, CGRectGetWidth(self.contentView.frame), 1.0f);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
