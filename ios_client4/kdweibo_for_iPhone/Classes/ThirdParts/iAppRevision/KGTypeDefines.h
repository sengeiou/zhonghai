//
//  KGTypeDefines.h
//  iAppRevision
//
//  Created by A449 on 16/1/15.
//  Copyright © 2016年 com.kinggrid. All rights reserved.
//

/** KGPublics包版本更新信息
 *
 * 版本：V3.1.1.0
 * 更新：2017-01-16
 */

/** 文件更新信息
 *
 * 更新于：2016-09-14
 */

#ifndef KGTypeDefines_h
#define KGTypeDefines_h

#import <Foundation/Foundation.h>

/** 签名类型 */
typedef NS_ENUM(NSInteger, KGSignatureType) {
    
    KGSignatureTypeHandwriting = 0,   //手写
    KGSignatureTypeText,              //文字
    KGSignatureTypeSeal,              //图章
};

/** 笔刷类型 */
typedef NS_ENUM(NSInteger, KGHandwritingType) {
    
    KGHandwritingTypeBrush = 0,                        //毛笔
    KGHandwritingTypePen,                              //钢笔
    KGHandwritingTypePencil,                           //铅笔
    KGHandwritingTypeWaterColor,                       //水彩笔
    KGHandwritingTypeFluorescent NS_UNAVAILABLE        //荧光笔
};

/** 水印位置 */
typedef NS_ENUM(NSInteger, KGWatermarkPosition) {
    
    KGWatermarkPositionDefault = 0,   //默认，右下
    KGWatermarkPositionTopLeft,       //左上
    KGWatermarkPositionTop,           //中上
    KGWatermarkPositionTopRight,      //右上
    KGWatermarkPositionLeft,          //左中
    KGWatermarkPositionCenter,        //中心
    KGWatermarkPositionRight,         //右中
    KGWatermarkPositionBottomLeft,    //左下
    KGWatermarkPositionBottom,        //中下
    KGWatermarkPositionBottomRight = KGWatermarkPositionDefault,
};

/** 数字签名模式 */
typedef NS_ENUM(NSInteger, KGDigitalSignatureMode) {
    KGDigitalSignatureModeNone = 0,      //不进行数字签名，普通签名
    KGDigitalSignatureModemTokenK5,      //龙脉
    KGDigitalSignatureModeGDCA,          //广东
    KGDigiTalSignatureModeDFCA,          //东方
};

#endif /* KGTypeDefines_h */
