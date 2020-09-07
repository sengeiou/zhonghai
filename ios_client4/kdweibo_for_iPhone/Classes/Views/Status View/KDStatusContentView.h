//
//  KDStatusContentView.h
//  kdweibo
//
//  Created by laijiandong on 12-9-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDStatusHeaderView.h"
#import "KDStatusBodyView.h"
#import "KDStatusFooterView.h"

@interface KDStatusContentView : UIView {
 @private
    KDStatusHeaderView *headerView_;
    KDStatusBodyView *bodyView_;
    KDStatusFooterView *footerView_;
}

@property(nonatomic, retain, readonly) KDStatusHeaderView *headerView;
@property(nonatomic, retain, readonly) KDStatusBodyView *bodyView;
@property(nonatomic, retain, readonly) KDStatusFooterView *footerView;

- (void)updateWithStatus:(KDStatus *)status;

+ (CGFloat)calculateStatusContentHeight:(KDStatus *)status bodyViewPosition:(KDStatusBodyViewDisplayPosition)p;
+ (CGFloat)calculateStatusContentHeight:(KDStatus *)status;

@end
