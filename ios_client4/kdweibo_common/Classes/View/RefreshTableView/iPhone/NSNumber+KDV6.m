//
//  NSNumber+KDV6.m
//  kdweibo
//
//  Created by Gil on 15/7/1.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "NSNumber+KDV6.h"

@implementation NSNumber (KDV6)

+ (CGFloat)kdDistance1 {
    return 12.0f;
}

+ (CGFloat)kdDistance2 {
    return 8.0f;
}

+ (CGFloat)kdLeftItemDistance {
    if (isiPhone6Plus) {
        return 0.0f;
    }
    return 4.0f;
}

+ (CGFloat)kdRightItemDistance {
    return -[self kdLeftItemDistance];
}



@end


@implementation NSNumber (KDV7)

+ (CGFloat)kdInputViewLeftRightDistance_V7
{
    return 32.5;
}

+ (CGFloat)kd_CellForTableViewHeight68
{
    return 68.0f;
}

+ (CGFloat)kd_CellForTableViewHeight60
{
    return 60.0f;
}

+ (CGFloat)kd_CellForTableViewHeight44
{
    return 44.0f;
}

@end

