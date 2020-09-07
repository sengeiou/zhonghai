//
//  KDRefreshTableViewSideViewTopForiPhone.h
//  Test
//
//  Created by shen kuikui on 12-8-29.
//  Copyright (c) 2012年 shen kuikui. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDRefreshTableViewSideView.h"

@interface KDRefreshTableViewSideViewTopForiPhone : UIView <KDRefreshTableViewSideView>
{
@private
    KDPullRefreshState state_;
    
    UILabel *lastUpdatedLabel_;
    UILabel *tipInfoLabel_;
    CALayer *arrowImage_;
    UIActivityIndicatorView *activity_;
}
/**
 *  王松
 *  2013-12-24
 */

//正常状态显示的text
@property (nonatomic, retain) NSString *normalText;

//pulling状态显示的text
@property (nonatomic, retain) NSString *pullingText;

//是否显示更新时间
@property (nonatomic, assign) BOOL showUpdataTime;

@end
