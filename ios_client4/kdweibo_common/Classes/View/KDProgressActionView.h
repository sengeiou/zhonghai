//
//  KDProgressActionView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-3.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KDProgressActionView : UIView {
@private
    UIImageView *backgroundImageView_;
    
    UILabel *titleLabel_;
    UILabel *progressLabel_;
    UIProgressView *progressView_;
    
    UIImageView *dividerImageView_;
    UIActivityIndicatorView *activityView_;
}

@property (nonatomic, retain, readonly) UIImageView *backgroundImageView;

@property (nonatomic, retain, readonly) UILabel *titleLabel;
@property (nonatomic, retain, readonly) UILabel *progressLabel;
@property (nonatomic, retain, readonly) UIProgressView *progressView;

- (void) activeActivityView:(BOOL)active;

@end

