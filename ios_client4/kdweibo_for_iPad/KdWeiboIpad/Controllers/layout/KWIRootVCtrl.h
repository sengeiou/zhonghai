//
//  KWIRootVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/20/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface KWIRootVCtrl : UIViewController

+ (KWIRootVCtrl *)vctrl;

+ (KWIRootVCtrl *)curInst;
- (void)onRemoveViewController:(UIViewController *)controller animaion:(BOOL)animation;
- (void)fullScreening:(UIViewController *)controller;
- (void)showCommunitySelectionTutroial;
@end
