//
//  KDUnderLineButton.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-7-16.
//
//

#import "KDUnderLineButton.h"

@implementation KDUnderLineButton

@synthesize underLineColor = underLineColor_;
@synthesize lineSpace = lineSpace_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        lineSpace_ = 0.0f;
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(underLineColor_);
    
    //[super dealloc];
}

- (void) drawRect:(CGRect)rect {

    CGRect textRect = self.titleLabel.frame;
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    // set to same colour as text
    UIColor *lineColor = underLineColor_ ? underLineColor_ : self.titleLabel.textColor;
    
    CGContextSetStrokeColorWithColor(contextRef, lineColor.CGColor);
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender + lineSpace_);
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender + lineSpace_);
    CGContextClosePath(contextRef);
    CGContextDrawPath(contextRef, kCGPathStroke);
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
