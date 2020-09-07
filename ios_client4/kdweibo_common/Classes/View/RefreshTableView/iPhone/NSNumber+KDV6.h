//
//  NSNumber+KDV6.h
//  kdweibo
//
//  Created by Gil on 15/7/1.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (KDV6)
+ (CGFloat)kdDistance1; /**< 12 */
+ (CGFloat)kdDistance2; /**< 8 */

+ (CGFloat)kdLeftItemDistance;
+ (CGFloat)kdRightItemDistance;

@end

@interface NSNumber (KDV7)

+ (CGFloat)kdInputViewLeftRightDistance_V7;

/** 类似消息页签列表这种的cell的高度 68 */
+ (CGFloat)kd_CellForTableViewHeight68;

/** 类似通讯录页签这种的cell 或者是双行文字不带头像的cell的高度 60 */
+ (CGFloat)kd_CellForTableViewHeight60;

/** 类似我页签这种的带小图片或者不带图片的cell的高度 44 */
+ (CGFloat)kd_CellForTableViewHeight44;

@end
