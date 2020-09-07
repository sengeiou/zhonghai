//
//  KDProgressIndicatorView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDProgressIndicatorView : UIView {
@private
    UIActivityIndicatorView *activityView_;
    UIProgressView *progressView_;
    UILabel *progressLabel_;
}

@property (nonatomic, retain, readonly) UIActivityIndicatorView *activityView;
@property (nonatomic, retain, readonly) UILabel *progressLabel;

- (void) setAvtivityIndicatorStartAnimation:(BOOL)start;
- (void) setProgressPercent:(float)percent info:(NSString *)info;

@end
