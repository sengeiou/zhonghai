//
//  KDStatusFooterView.h
//  kdweibo
//
//  Created by laijiandong on 12-9-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDStatus.h"
#import "KDProgressIndicatorView.h"

@class KDStatusFooterAttributeView;

@interface KDStatusFooterView : UIView {
 @private
//    UILabel *sourceLabel_;
    KDStatusFooterAttributeView *commentAttrView_;
    KDStatusFooterAttributeView *forwardAttrView_;
//    UILabel *timeLabel_;
    BOOL showAccurateGroupName_;
    BOOL isUsingNormalCommentsIcon_;
    KDProgressIndicatorView *sendingProgress_;
    
//    UIView *menuView_; //weak
//    UIView *maskView_; //weak
}

@property(nonatomic, assign) BOOL showAccurateGroupName;

- (void)updateWithStatus:(KDStatus *)status;

+ (CGFloat)optimalStatusFooterHeight;

@end
