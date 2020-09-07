//
//  XTPromptCell.m
//  XT
//
//  Created by Gil on 13-7-30.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTPromptCell.h"

@implementation XTPromptCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = [UIFont systemFontOfSize:14.0];
        self.textLabel.textColor = BOSCOLORWITHRGBA(0xAEADAD, 1.0);
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        
        self.detailTextLabel.text = nil;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    self.textLabel.frame = CGRectMake(15.0, (CGRectGetHeight(rect) - 16.0)/2, CGRectGetWidth(rect) - 30, 16.0);
}

@end
