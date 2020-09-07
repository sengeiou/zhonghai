//
//  KDRegexObjc.h
//  kdweibo
//
//  Created by Darren Zheng on 16/5/31.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// 聊天气泡的关键字类型集合, 为objc调用, 自动转换成swift的OptionSetType
typedef NS_OPTIONS(NSInteger, KDRegexPatternOption) {
    KDRegexPatternOptionEmotion = 1 << 0,
    KDRegexPatternOptionURL = 1 << 1,
    KDRegexPatternOptionAt = 1 << 3,
    KDRegexPatternOptionKeyword = 1 << 4,
    KDRegexPatternOptionPhone = 1 << 5,
};

