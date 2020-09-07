//
//  KWIPeopleStreamVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDUser;

@interface KWIPeopleStreamVCtrl : UIViewController

+ (KWIPeopleStreamVCtrl *)vctrlForUser:(KDUser *)user
                             container:(UIView *)container 
                                 frame:(CGRect)frame;

// for diff behavior when this vctrl included by peopleVCtrl under profile mod
- (void)setProfileMod;

@end
