//
//  XTBlueStyleCell.m
//  XT
//
//  Created by kingdee eas on 13-12-18.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTBlueStyleCell.h"
#import "UIImage+XT.h"

@interface XTBlueStyleCell()

@property (nonatomic,retain) UIImageView *topLineImageView;
@property (nonatomic,retain) UIImageView *bottomLineImageView;

@end

@implementation XTBlueStyleCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.textLabel.font = [UIFont systemFontOfSize:16.0];
        self.textLabel.textColor = BOSCOLORWITHRGBA(0x06A3EC, 1.0);
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        self.detailTextLabel.textColor = BOSCOLORWITHRGBA(0x06A3EC, 1.0);
        self.detailTextLabel.highlightedTextColor = self.detailTextLabel.textColor;
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.accessoryType = UITableViewCellAccessoryNone;
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xE5E5E5, 1.0);
        self.selectedBackgroundView = bgColorView;
        
        self.topLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 10.0, ScreenFullWidth, 1.0)];
        self.topLineImageView.image = [UIImage imageWithColor:BOSCOLORWITHRGBA(0xFFFFFF, 1.0)];
        [self.contentView addSubview:self.topLineImageView];
        
        self.bottomLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 59.0, ScreenFullWidth, 1.0)];
        self.bottomLineImageView.image = [UIImage imageWithColor:BOSCOLORWITHRGBA(0xCCCCCC, 1.0)];
        [self.contentView addSubview:self.bottomLineImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    
    if (self.textLabel.text.length > 0) {
        rect = self.textLabel.frame;
        rect.origin.x = 15.0;
        rect.origin.y += 5.0;
        self.textLabel.frame = rect;
    }
    
    if (self.detailTextLabel.text.length > 0) {
        rect = self.detailTextLabel.frame;
        rect.origin.x = self.bounds.size.width - rect.size.width - 15.0;
        rect.origin.y += 5.0;
        self.detailTextLabel.frame = rect;
    }
    
    rect = self.selectedBackgroundView.frame;
    rect.origin.y += 11.0;
    rect.size.height -= 11.0;
    self.selectedBackgroundView.frame = rect;
}


@end
