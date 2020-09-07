//
//  KDProfileTabItem.m
//  kdweibo
//
//  Created by shen kuikui on 13-11-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDProfileTabItem.h"

@implementation KDProfileTabItem

@synthesize valueAboveName = valueAboveName_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        valueAboveName_ = YES;
        [self setupView];
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(tabValueLabel_);
    //KD_RELEASE_SAFELY(tabNameLabel_);
    
    //[super dealloc];
}

- (void)setupView
{
    tabValueLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    tabValueLabel_.backgroundColor = [UIColor clearColor];
    tabValueLabel_.font = [UIFont systemFontOfSize:16.0f];
    tabValueLabel_.textColor = RGBCOLOR(62, 62, 62);
    [self addSubview:tabValueLabel_];
    
    tabNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    tabNameLabel_.backgroundColor = [UIColor clearColor];
    tabNameLabel_.font = [UIFont systemFontOfSize:13.0f];
    tabNameLabel_.textColor = RGBCOLOR(109, 109, 109);
    [self addSubview:tabNameLabel_];
    
    self.backgroundColor = RGBCOLOR(255, 255, 255);
}

- (void)setName:(NSString *)name
{
    tabNameLabel_.text = name;
    [tabNameLabel_ sizeToFit];
}

- (void)setValue:(NSString *)value
{
    tabValueLabel_.text = value;
    [tabValueLabel_ sizeToFit];
}

- (NSString *)value
{
    return tabValueLabel_.text;
}

- (NSString *)name
{
    return tabNameLabel_.text;
}

- (void)setSelected:(BOOL)selected
{
    if(selected_ != selected) {
        selected_ = selected;
        if(selected_) {
            self.backgroundColor = RGBCOLOR(241, 244, 247);
        }else {
            self.backgroundColor = RGBCOLOR(255, 255, 255);
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize valueSize = tabValueLabel_.bounds.size;
    CGSize nameSize = tabNameLabel_.bounds.size;
    
    //spacing between value label and name label
    //one of them is zero, spacing is no need.
    CGFloat spacing = (valueSize.height * nameSize.height == 0 ? 0 : 2.0f);
    
    CGFloat topMinY = (CGRectGetHeight(self.bounds) - valueSize.height - spacing - nameSize.height) * 0.5f;
    CGFloat bottomMinY = topMinY + spacing + (valueAboveName_ ? valueSize.height : nameSize.height);
    
    tabValueLabel_.frame = CGRectMake((CGRectGetWidth(self.bounds) - valueSize.width) * 0.5f, valueAboveName_ ? topMinY : bottomMinY, valueSize.width, valueSize.height);
    
    tabNameLabel_.frame = CGRectMake((CGRectGetWidth(self.bounds) - nameSize.width) * 0.5f, valueAboveName_ ? bottomMinY : topMinY, nameSize.width, nameSize.height);
}

@end
