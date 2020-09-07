//
//  KWITutorialNetworkV.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 8/14/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWITutorialNetworkV.h"

@implementation KWITutorialNetworkV
{
    IBOutlet UIImageView *_imgV;    
}

+ (KWITutorialNetworkV *)view
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.description owner:nil options:nil];
    KWITutorialNetworkV *view = (KWITutorialNetworkV *)[nib objectAtIndex:0];  
    
    return [view setUp];
}

- (id)setUp
{
    [self addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTutorialVTapped:)] autorelease]];
    return self;
}

- (void)dealloc {
    [_imgV release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSUInteger left = CGRectGetMaxX(_imgV.frame);
    NSUInteger top = 0;
    NSUInteger right = 1024;
    NSUInteger bottom = CGRectGetMaxY(_imgV.frame);        
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, left, top);
    CGContextAddLineToPoint(context, right, top);
    CGContextAddLineToPoint(context, right, bottom);
    CGContextAddLineToPoint(context, left, bottom);
    CGContextAddLineToPoint(context, left, top);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor);
    CGContextFillPath(context);
    
    left = 0;
    top = CGRectGetMaxY(_imgV.frame);
    right = 1024;
    bottom = 1004;        
    context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, left, top);
    CGContextAddLineToPoint(context, right, top);
    CGContextAddLineToPoint(context, right, bottom);
    CGContextAddLineToPoint(context, left, bottom);
    CGContextAddLineToPoint(context, left, top);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor);
    CGContextFillPath(context);
}



- (void)_onTutorialVTapped:(UIGestureRecognizer *)gr
{
    [gr.view removeFromSuperview];
}
@end
