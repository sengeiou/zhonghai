//
//  KDTrendCell.m
//  kdweibo
//
//  Created by shen kuikui on 13-12-24.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTrendCell.h"

@implementation KDTrendCell
{
    //weak
    UIImageView *seperator_;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSeperator];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self addSeperator];
    }
    
    return self;
}

- (void)addSeperator
{
    UIImage *image = [UIImage imageNamed:@"trend_edit_seperator_v3.png"];
    image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5f topCapHeight:image.size.height * 0.5f];
    seperator_ = [[UIImageView alloc] initWithImage:image];
    [self.contentView addSubview:seperator_];
//    [seperator_ release];
    
    self.textLabel.textColor = RGBCOLOR(31, 31, 31);
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont systemFontOfSize:16.0f];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(seperator_) {
        seperator_.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - 1.0f, CGRectGetWidth(self.contentView.bounds), 1.0f);
    }
    
    [self.textLabel sizeToFit];
    self.textLabel.frame = CGRectMake(14.0f, (CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight(self.textLabel.frame)) * 0.5f, CGRectGetWidth(self.contentView.frame) - 24.0f, CGRectGetHeight(self.textLabel.frame));
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
