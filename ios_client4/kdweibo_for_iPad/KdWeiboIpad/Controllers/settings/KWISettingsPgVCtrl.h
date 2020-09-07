//
//  KWISettingsPgVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/2/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWISettingsPgVCtrl : UIViewController

- (UIBarButtonItem *)makeBarButtonWithLabel:(NSString *)label 
                                      image:(UIImage *)image 
                                     target:(id)target 
                                     action:(SEL)action;
- (void)configTitle:(NSString *)title;

@end
