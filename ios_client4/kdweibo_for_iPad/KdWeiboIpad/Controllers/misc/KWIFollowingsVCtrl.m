//
//  KWIFollowingsVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIFollowingsVCtrl.h"

#import "KDUser.h"

@implementation KWIFollowingsVCtrl

+ (KWIFollowingsVCtrl *)vctrlForUser:(KDUser *)user
                          container:(UIView *)container 
                              frame:(CGRect)frame
{
    return (KWIFollowingsVCtrl *)[super vctrlForUser:user container:container frame:frame];
}

- (NSString *)_getApiName
{
    return @"/statuses/:friends";
}

@end
