//
//  KDRefreshTableViewSideView.h
//  Test
//
//  Created by shen kuikui on 12-8-28.
//  Copyright (c) 2012年 shen kuikui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+Additions.h"

typedef enum{
	KDPullRefreshNormal = 0,
	KDPullRefreshPulling ,
    KDPullRefreshProgress,
	KDPullRefreshLoading
} KDPullRefreshState;

#define KD_REFRESHTABLEVIEW_SIDEVIEW_TEXT_COLOR	 [UIColor colorWithRed:0x6d/255.0 green:0x6d/255.0 blue:0x6d/255.0 alpha:1.0]
#define KD_REFRESHTABLEVIEW_SIDEVIEW_BORDER_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define KD_REFRESHTABLEVIEW_FLIP_ANIMATION_DURATION 0.18f

//static NSString *formatDate(NSDate *inDate)
//{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"MM-dd HH:mm"];
//    
//    return [formatter stringFromDate:inDate];
//}
#define FORMATEDATE(data)  [data formatWithFormatter:KD_MOUNTH_BRIFE_FORMAT]
@protocol KDRefreshTableViewSideView <NSObject>

@required

//设置视图的三种状态
- (void)setStatus:(KDPullRefreshState)state;
//判断当前是否处于“加载中”
- (BOOL)isLoading;

- (CGFloat)respondHeight;

@optional

//刷新时间
- (void)refreshUpdatedTime:(NSDate *)date;
- (void)updateProgress:(int)p inTotal:(int)total;
- (KDPullRefreshState)status;
@end
