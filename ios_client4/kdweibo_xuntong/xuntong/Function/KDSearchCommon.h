//
//  KDSearchCommon.h
//  kdweibo
//
//  Created by Gil on 15/8/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#ifndef kdweibo_KDSearchCommon_h
#define kdweibo_KDSearchCommon_h

//----------------搜索类型---------------//
typedef NS_ENUM(NSInteger, KDSearchType){
    kSearchTypeContact = 1, //文件
    kSearchTypeGroup = 2,//会话
    KSearchTypeText = 3,//文本
    kSearchTypeFile = 4,//文件
    kSearchTypePublic = 5//订阅
};
//-----------------------------------------//


#define KDMoreSearchCellRow 3
#define KSearchTimeInterval 0.0
#define KDSearchCellContentTextMaxWidth (ScreenFullWidth - 44.0 - (3 * [NSNumber kdDistance1]))


#endif
