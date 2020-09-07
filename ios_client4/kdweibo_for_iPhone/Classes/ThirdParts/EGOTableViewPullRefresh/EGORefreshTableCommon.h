//
//  EGORefreshTableCommon.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-3.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
	EGOOPullRefreshPulling = 0,
	EGOOPullRefreshNormal,
	EGOOPullRefreshLoading,	
} EGOPullRefreshState;

#define TEXT_COLOR	 [UIColor colorWithRed:0x11/255.0 green:0x2a/255.0 blue:0x43/255.0 alpha:1.0]
#define BORDER_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f