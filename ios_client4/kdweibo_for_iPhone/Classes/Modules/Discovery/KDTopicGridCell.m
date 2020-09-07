//
//  KDTopicGridCell.m
//  kdweibo
//
//  Created by Tan Yingqi on 14-4-17.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDTopicGridCell.h"

#define TEXT_SIZE  15.0f
#define TEXT_COLOR  0x3e3e3e
#define MAX_TEXT_LABEL_WIDTH 122.0f

@interface KDTopicGridCell () {
    UILabel *prefixLabel_;
    UILabel *postfixLabel_;
    UILabel *textLabel_;
}

@end

@implementation KDTopicGridCell
@synthesize text = text_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        prefixLabel_ = [self label];// retain];
        prefixLabel_.text = @"#";
        [prefixLabel_ sizeToFit];
        [self addSubview:prefixLabel_];
        
                        textLabel_ = [self label];/// retain];
        textLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:textLabel_];
        
                                      postfixLabel_ = [self label] ;//retain];
         postfixLabel_.text = @"#";
        [postfixLabel_ sizeToFit];
        [self addSubview:postfixLabel_];
        
        self.textAlignment = NSTextAlignmentLeft;
        
        
    }
    return self;
}

- (void)layoutSubviews {
    if (KD_IS_BLANK_STR(text_)) {
        prefixLabel_.text = @"";
        postfixLabel_.text = @"";
        return;
    }
    [textLabel_ sizeToFit];
    CGRect rect ;
    rect = textLabel_.bounds;
    rect.size.width =  MIN(CGRectGetWidth(rect), MAX_TEXT_LABEL_WIDTH);
    textLabel_.bounds = rect;
    if (self.textAlignment == NSTextAlignmentLeft) {
        rect = prefixLabel_.bounds;
        rect.origin.x = 10;
        rect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(rect)) *0.5;
        prefixLabel_.frame = rect;
        
        rect = textLabel_.bounds;
        rect.origin.x = CGRectGetMaxX(prefixLabel_.frame);
        rect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(rect)) *0.5;
        textLabel_.frame = rect;
        
        rect = postfixLabel_.bounds;
        rect.origin.x = CGRectGetMaxX(textLabel_.frame);
        rect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(rect)) *0.5;
        postfixLabel_.frame = rect;

        
        
    }else if (self.textAlignment == NSTextAlignmentCenter) {
        CGFloat centX = CGRectGetMidX(self.bounds) ;
        CGFloat centY =  CGRectGetMidY(self.bounds);
       
        textLabel_.center = CGPointMake(centX, centY);
        
        rect = prefixLabel_.bounds;
        
        centX = CGRectGetMinX(textLabel_.frame) - CGRectGetWidth(rect) *0.5;
        
        prefixLabel_.center = CGPointMake(centX, centY);
        
        
        rect = postfixLabel_.bounds;
        
        centX = CGRectGetMaxX(textLabel_.frame) +CGRectGetWidth(rect) *0.5;
        
        postfixLabel_.center = CGPointMake(centX, centY);
    }
  
}

- (UILabel *)label {
    UILabel *aLabel = [[UILabel alloc] init];// autorelease];
    aLabel.font = [UIFont systemFontOfSize:TEXT_SIZE];
    aLabel.textColor = UIColorFromRGB(TEXT_COLOR);
    aLabel.backgroundColor = [UIColor clearColor];
    return aLabel;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat textWidth = MIN(CGRectGetWidth(textLabel_.bounds), MAX_TEXT_LABEL_WIDTH);
    textWidth+= 2*CGRectGetWidth(prefixLabel_.bounds);
    return CGSizeMake(textWidth, CGRectGetHeight(prefixLabel_.bounds));
}

- (void)setText:(NSString *)text {
    if (text_ != text) {
//        [text_ release];
        text_ = [text copy];
        textLabel_.text = text_;
        [textLabel_ sizeToFit];
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(text_ );
    //KD_RELEASE_SAFELY(prefixLabel_);
    //KD_RELEASE_SAFELY(textLabel_);
    //KD_RELEASE_SAFELY(postfixLabel_);
    //[super dealloc];
}
@end
