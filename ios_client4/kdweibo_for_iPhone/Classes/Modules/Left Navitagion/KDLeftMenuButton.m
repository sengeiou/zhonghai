//
//  KDLetfMenuButton.m
//  KDLeftMenu
//
//  Created by 王 松 on 14-4-16.
//  Copyright (c) 2014年 Song.wang. All rights reserved.
//

#import "KDLeftMenuButton.h"

static CGFloat spacing = 8.f;

@implementation KDLeftMenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:16.f];
        self.titleLabel.textColor = UIColorFromRGB(0xFFFFFF);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (instancetype)buttonWithModel:(KDLeftMenuButtonModel *)model
{
    return [[self class] buttonWithTitle:model.title image:model.normalImage highlightedImage:model.highlightedImage];
}

+ (instancetype)buttonWithTitle:(NSString *)title image:(UIImage *)image
{
    return [[self class] buttonWithTitle:title image:image highlightedImage:nil];
}

+ (instancetype)buttonWithTitle:(NSString *)title image:(UIImage *)image highlightedImage:(UIImage *)hImage
{
    KDLeftMenuButton *button = [[self class] buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:hImage forState:UIControlStateHighlighted];
    
    [button setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x999da5) forState:UIControlStateHighlighted];
    button.titleLabel.numberOfLines = 0;
    
    [button sizeToFit];
    
    CGSize imageSize = button.imageView.frame.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + spacing), 0.0);
    
    CGSize titleSize = button.titleLabel.frame.size;
    button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    [button resetButtonHeight];
    return button;
}

- (void)resetButtonHeight
{
    CGRect rect = self.frame;
    CGFloat maxWidth = MAX(CGRectGetWidth(self.imageView.frame), CGRectGetWidth(self.titleLabel.frame));
    rect.size.height = self.imageView.frame.size.height + self.titleLabel.frame.size.height + spacing * 3;
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage] isEqualToString:@"en"]) {
        // 减一点点宽，来让小屏换行
        rect.size.width = maxWidth - 5;
    }else{
        rect.size.width = maxWidth;
    }

    self.frame = rect;
}

- (void)dealloc
{
    //[super dealloc];
}

@end

@implementation KDLeftMenuButtonModel

+ (instancetype)model
{
    return [[[self class] alloc] init];// autorelease];
}

- (void)dealloc
{
//    [_highlightedImage release];
//    [_normalImage release];
//    [_title release];
    //[super dealloc];
}

@end
