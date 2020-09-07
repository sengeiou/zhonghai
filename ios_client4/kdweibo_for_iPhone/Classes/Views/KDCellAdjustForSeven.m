//
//  KDCellAdjustForSeven.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-16.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDCellAdjustForSeven.h"

@implementation KDCellAdjustForSeven

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame {
    float inset = 0.0f;
//    if(isAboveiOS7) {
        inset = 10.0f;
//    }
    
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    
    [super setFrame:frame];
}

@end
