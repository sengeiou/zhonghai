//
//  GestureDescView.m
//  DynamicCode
//
//  Created by 曾昭英 on 13-11-29.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "GestureDescView.h"
#import <QuartzCore/QuartzCore.h>
#import "Global.h"

#define kColor_success [UIColor colorWithRed:252./255. green:190./255. blue:45./255. alpha:1.00f]

#define kDotW 8
#define DOT_DIAMETER 10.0f

//#define kGapW 8

@implementation GestureDescView

- (void)setPw:(NSString *)pw
{
    
    UIImage * whiteDot = [UIImage imageNamed:@"login_btn_lock_normal"];
    UIImage * blueDot = [UIImage imageNamed:@"login_btn_lock_press"];
    [_dots enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIImageView*)obj setImage:whiteDot];
    }];
    
    if (pw==nil||pw.length==0) {
        return;
    }
    
    for (int i = 0; i < pw.length; i++) {
        int num = [[pw substringWithRange:NSMakeRange(i, 1)] intValue];
        UIImageView *dot = [_dots objectAtIndex:num];
        dot.image = blueDot;
    }
    
}

- (void)initDots
{
    
    CGFloat distanceX = (self.bounds.size.width - 3 * DOT_DIAMETER) / 2;
    CGFloat distanceY = (self.bounds.size.height - 3 * DOT_DIAMETER) / 2;
    _dots = [NSMutableArray new];
    UIImage * image = [UIImage imageNamed:@"login_btn_lock_normal"];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIImageView * dot = [[UIImageView alloc] initWithImage:image];
            [dot sizeToFit];
            [dot setFrame:CGRectMake(j * (DOT_DIAMETER + distanceX), i * (distanceY + DOT_DIAMETER), DOT_DIAMETER, DOT_DIAMETER)];
            [self addSubview:dot];
            [_dots addObject:dot];
        }
    }
}

- (void)awakeFromNib
{
    [self initDots];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initDots];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}



@end
