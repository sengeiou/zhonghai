//
//  SingleLineScaleLab.m
//  TwitterFon
//
//  Created by Guohuan Xu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleLineScaleLab.h"

@implementation SingleLineScaleLab
@synthesize delegate_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setText:(NSString *)text
{
    [super setText:text];
    CGRect frame=[self textRectForBounds:self.frame
                  limitedToNumberOfLines:1];
    
    float textWidth;

    if (frame.size.width<self.frame.size.width) {
       
        textWidth = frame.size.width;
    }
    else
    {
        textWidth = self.frame.size.width;
    }
    if ([(id)delegate_ respondsToSelector:@selector(singleLineScaleLab:textWidth:)]) {
        [delegate_ singleLineScaleLab:self textWidth:textWidth];
    }
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
