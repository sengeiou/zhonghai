//
//  NJKWebViewProgressView+YZJ.h
//  kdweibo
//
//  Created by Gil on 15/11/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "NJKWebViewProgressView.h"

@interface NJKWebViewProgressView (YZJ)

- (void)setProgress:(float)progress animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end
