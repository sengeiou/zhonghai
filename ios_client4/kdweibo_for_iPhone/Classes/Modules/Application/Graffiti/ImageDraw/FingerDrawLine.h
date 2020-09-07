//
//  FingerDrawLine.h
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FingerDrawLineInfo.h"

@interface FingerDrawLine : UIImageView

//所有的线条信息，包含了颜色，坐标和粗细信息 @see DrawPaletteLineInfo
@property(nonatomic,strong) NSMutableArray  *allMyDrawPaletteLineInfos;
//从外部传递的 笔刷长度和宽度，在包含画板的VC中 要是颜色、粗细有所改变 都应该将对应的值传进来
@property (nonatomic,strong) UIColor *currentPaintBrushColor;
@property (nonatomic) float currentPaintBrushWidth;



#pragma mark  外部调用的清空画板和撤销上一步

//清空画板
- (void)cleanAllDrawBySelf;
//撤销上一条线条
- (void)cleanFinallyDraw;

@end
