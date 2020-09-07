//
//  KWIFollowingsVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIRelationsVCtrl.h"

@class KDUser;

@interface KWIFollowingsVCtrl : KWIRelationsVCtrl

+ (KWIFollowingsVCtrl *)vctrlForUser:(KDUser *)user 
                          container:(UIView *)container 
                              frame:(CGRect)frame;

@end
