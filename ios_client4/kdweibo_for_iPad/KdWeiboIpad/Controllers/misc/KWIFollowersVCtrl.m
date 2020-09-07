//
//  KWIFollowersVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIFollowersVCtrl.h"

#import "KDUser.h"

@implementation KWIFollowersVCtrl

+ (KWIFollowersVCtrl *)vctrlForUser:(KDUser *)user
                          container:(UIView *)container 
                              frame:(CGRect)frame
{
    return (KWIFollowersVCtrl *)[super vctrlForUser:user container:container frame:frame];
}

- (NSString *)_getApiName
{
    return @"/statuses/:followers";
}

@end
