//
//  KDStatusExpressionLabel.h
//  kdweibo
//
//  Created by Tan Yingqi on 14-3-14.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDExpressionLabel.h"
@interface KDStatusExpressionLabel : KDExpressionLabel
- (void)setNumberOfLines:(NSUInteger)numberOfLines;

+ (CGSize)sizeWithString:(NSString *)content constrainedToSize:(CGSize)size withType:(KDExpressionLabelType)type textAlignment:(NSTextAlignment)alignment textColor:(UIColor *)color textFont:(UIFont *)font limitLineNumber:(NSUInteger)limitLineNumber moreThanLimit:(BOOL *)moreThanLimit;
@end
