//
//  KDRefreshTableViewSideViewBottomForiPhone.h
//  Test
//
//  Created by shen kuikui on 12-8-30.
//  Copyright (c) 2012年 shen kuikui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDRefreshTableViewSideView.h"

@interface KDRefreshTableViewSideViewBottomForiPhone : UIView <KDRefreshTableViewSideView>
{
@private
    KDPullRefreshState state_;
    
    UILabel *statusLabel_;
    UIActivityIndicatorView *activity_;
}

@end
