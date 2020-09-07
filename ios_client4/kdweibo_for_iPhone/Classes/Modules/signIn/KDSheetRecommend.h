//
//  KDSheetRecommend.h
//  kdweibo
//
//  Created by janon on 15/2/9.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSheet.h"

typedef NS_ENUM(NSUInteger, KDSheetType) {
    KDSheetTypeNone,
    KDSheetTypeRecommend
};

@interface KDSheetRecommend : KDSheet
@property(nonatomic, assign) KDSheetType sheetType;
@end
