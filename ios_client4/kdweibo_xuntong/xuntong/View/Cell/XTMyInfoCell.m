//
//  XTMyInfoCell.m
//  XT
//
//  Created by kingdee eas on 13-12-5.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTMyInfoCell.h"

@implementation XTMyInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.detailTextLabel.text.length > 0) {
        CGRect rect = self.detailTextLabel.frame;
        rect.origin.x = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 15.0;
        rect.origin.y -= 2.0;
        self.detailTextLabel.frame = rect;
    }
}

@end
