//
//  KDWebView+WebViewAdditions.m
//  kdweibo
//
//  Created by shifking on 16/3/11.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDWebView+WebViewAdditions.h"

@implementation KDWebView (WebViewAdditions)
- (CGSize)windowSize
{
    CGSize size;
    
    NSString *innerWidthString = @"window.innerWidth";
    NSString *innerHeightString = @"window.innerHeight";
    
    size.width = [[self stringByEvaluatingJavaScriptFromString:innerWidthString]  integerValue];
    size.height = [[self stringByEvaluatingJavaScriptFromString:innerHeightString] integerValue];
    return size;

}

- (CGPoint)scrollOffset
{
    CGPoint pt;
    pt.x = [[self stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] integerValue];
    pt.y = [[self stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
    return pt;
}
@end
