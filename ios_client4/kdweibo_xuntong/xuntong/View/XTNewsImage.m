//
//  XTNewsImage.m
//  XT
//
//  Created by mark on 13-9-18.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTNewsImage.h"
#import "RecordDataModel.h"
#define PersonHeader_Default_Frame CGRectMake(0.0, 0.0, 270, 130)

@interface XTNewsImage ()
@end

@implementation XTNewsImage
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:PersonHeader_Default_Frame];
}

- (id)initWithImage:(UIImage *)image
{
    return [self initWithFrame:PersonHeader_Default_Frame];
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    return [self initWithFrame:PersonHeader_Default_Frame];
}

- (id)initWithPlaceholderImage:(UIImage *)anImage
{
    return [self initWithFrame:PersonHeader_Default_Frame];
}

- (void)setImagev:(MessageNewsEachDataModel *)imagev
{
    if (_imagev != imagev) {
        _imagev = imagev;
    }
    
    [self layout];
}
- (void)layout
{
    if (self.imagev == nil) {
        [self setImageWithURL:nil];
    } else {
        [self setImageWithURL:[self.imagev hasHeaderPicture] ? [NSURL URLWithString:self.imagev.name] : nil];
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
}


@end
