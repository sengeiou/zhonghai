//
//  KDMaskView.m
//  kdweibo
//
//  Created by shen kuikui on 13-11-28.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDMaskView.h"

@implementation KDMaskView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.exclusiveTouch = NO;
       
    }
    return self;
}

- (void)dealloc
{
    //[super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_delegate && [_delegate respondsToSelector:@selector(maskView:touchedInLocation:)]) {
        [_delegate maskView:self touchedInLocation:[[touches anyObject] locationInView:self]];
    }
}

@end
