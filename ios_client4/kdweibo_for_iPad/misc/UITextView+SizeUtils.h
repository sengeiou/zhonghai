//
//  UITextView+SizeUtils.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/22/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (SizeUtils)

+ (NSUInteger)calulateSizeForText:(NSString *)text withFontsize:(NSInteger)fontsize width:(NSUInteger)width;

- (NSUInteger)calulateSizeForText:(NSString *)text;
- (void)adjustHeightToFitContent;

@end
