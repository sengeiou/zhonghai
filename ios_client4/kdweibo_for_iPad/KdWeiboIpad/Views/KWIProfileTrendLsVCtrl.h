//
//  KWIProfileTrendLsVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/4/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDUser;

@interface KWIProfileTrendLsVCtrl : UIViewController

@property (retain, nonatomic) KDUser *user;

+ (KWIProfileTrendLsVCtrl *)vctrlWithUser:(KDUser *)user;

@end
