//
//  KDRefreshTableViewSideViewTopForiPad.h
//  kdweibo_common
//
//  Created by shen kuikui on 12-10-26.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDRefreshTableViewSideView.h"
@interface KDRefreshTableViewSideViewTopForiPad : UIView
{
@private
    KDPullRefreshState state_;
    
    UILabel *lastUpdatedLabel_;
    UIImageView *cloudImageView_;
    CALayer *arrowImage_;
    UIActivityIndicatorView *activity_;
}
@end