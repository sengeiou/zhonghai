//
//  KKCutConer.h
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 裁剪网格的4个角
 */

typedef enum : NSUInteger {
    LeftTop = 1,
    LeftBottom,
    RightTop,
    RightBottom,
} KDConerLocation;

@interface KKCutConer : UIView

- (instancetype)initWithFrame:(CGRect)frame location:(KDConerLocation)location;

@end
