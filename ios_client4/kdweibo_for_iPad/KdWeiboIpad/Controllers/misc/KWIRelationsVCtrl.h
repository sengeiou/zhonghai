//
//  KWIPeoplelsVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDUser;

@interface KWIRelationsVCtrl : UIViewController

+ (KWIRelationsVCtrl *)vctrlForUser:(KDUser *)user
                          container:(UIView *)container 
                              frame:(CGRect)frame;

@end
