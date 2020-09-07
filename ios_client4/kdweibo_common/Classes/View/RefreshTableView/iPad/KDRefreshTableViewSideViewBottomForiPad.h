//
//  KDRefreshTableViewSideViewBottomForiPad.h
//  kdweibo_common
//
//  Created by shen kuikui on 12-10-26.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDRefreshTableViewSideView.h"

@interface KDRefreshTableViewSideViewBottomForiPad : UIView<KDRefreshTableViewSideView>
{
@private
    KDPullRefreshState state_;
    
    UILabel *statusLabel_;
    UIImageView *indicatorBackground_;
    UIActivityIndicatorView *activity_;
}
@end
