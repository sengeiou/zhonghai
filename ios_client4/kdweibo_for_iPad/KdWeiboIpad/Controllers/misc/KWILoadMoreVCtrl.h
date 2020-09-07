//
//  KWILoadMoreVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/9/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWILoadMoreVCtrl : UIViewController

+ (KWILoadMoreVCtrl *)vctrl;
+ (KWILoadMoreVCtrl *)vctrlWithLabel:(NSString *)label;

- (void)setStateDefault;
- (void)setStateLoading;
- (void)setStateNoMore;

- (BOOL)isAvailable;
- (void)trigger;

@end
