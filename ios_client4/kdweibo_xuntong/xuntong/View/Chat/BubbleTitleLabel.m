//
//  BubbleTitleLabel.m
//  XT
//
//  Created by Gil on 13-7-8.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "BubbleTitleLabel.h"
#import "UIImage+XT.h"

@interface BubbleTitleLabel ()
@property (nonatomic, strong) UIImageView *line1;
@property (nonatomic, strong) UIImageView *line2;
@end

@implementation BubbleTitleLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.font = [UIFont systemFontOfSize:12.0];
        self.textColor = BOSCOLORWITHRGBA(0xB5B5B5, 1.0);
        self.textAlignment = NSTextAlignmentCenter;
        
        
        
        self.line1 = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0xCFCFCF, 1.0)]];
        self.line1.frame = CGRectMake(0.0, 0.0, 33.0, 1.0);
        [self addSubview:self.line1];
        
        self.line2 = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0xCFCFCF, 1.0)]];
        self.line2.frame = CGRectMake(0.0, 0.0, 33.0, 1.0);
        [self addSubview:self.line2];
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    
    self.line1.center = CGPointMake(self.line1.bounds.size.width / 2, frame.size.height / 2);
    self.line2.center = CGPointMake(frame.size.width - self.line2.bounds.size.width / 2, frame.size.height / 2);
    
}

- (void)setBHideLines:(BOOL)bHideLines
{
    if (bHideLines) {
        self.line1.hidden = YES;
        self.line2.hidden = YES;
        self.textAlignment = NSTextAlignmentLeft;
    }
}

@end
