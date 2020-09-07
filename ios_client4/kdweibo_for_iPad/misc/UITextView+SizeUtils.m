//
//  UITextView+SizeUtils.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/22/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "UITextView+SizeUtils.h"

@implementation UITextView (SizeUtils)

+ (NSUInteger)calulateSizeForText:(NSString *)text withFontsize:(NSInteger)fontsize width:(NSUInteger)width
{
    static UITextView *sample;    
    if (nil == sample) {
        sample = [[self alloc] init];
    }    
    
    CGRect frame = CGRectMake(-1000, -1000, width, 1);
    sample.frame = frame;    
     
    sample.font = [UIFont systemFontOfSize:fontsize];
    
    sample.text = text;
    
    [[[[[UIApplication sharedApplication] keyWindow] rootViewController] view] addSubview:sample];      
    NSUInteger height = sample.contentSize.height;
    [sample removeFromSuperview];
    
    return height;
}

- (NSUInteger)calulateSizeForText:(NSString *)text
{
    // dont want to change self, so call class method
    return [[self class] calulateSizeForText:text 
                                withFontsize:self.font.pointSize 
                                       width:self.frame.size.width];
}

- (void)adjustHeightToFitContent
{
    CGRect frame = self.frame;
    frame.size.height = self.contentSize.height;
    self.frame = frame;
}

@end
