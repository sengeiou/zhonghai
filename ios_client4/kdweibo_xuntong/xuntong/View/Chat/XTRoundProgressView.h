//
//  XTRoundProgressView.h
//  XT
//
//  Created by Gil on 13-12-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XTRoundProgressView;
@protocol XTRoundProgressViewDelegate <NSObject>
- (void)progressFinished:(XTRoundProgressView *)roundProgressView;
@end

@interface XTRoundProgressView : UIView

/**
 * Progress (0.0 to 1.0)
 */
@property (nonatomic, assign) float progress;

/**
 * Indicator progress color.
 * Defaults to white [UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *progressTintColor;

/**
 * Indicator background (non-progress) color.
 * Defaults to translucent white (alpha 0.1)
 */
@property (nonatomic, strong) UIColor *backgroundTintColor;

@property (nonatomic, strong) NSDate *progressStartTime;
@property (nonatomic, assign) int effectiveDuration;
@property (nonatomic, weak) id<XTRoundProgressViewDelegate> delegate;

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *personPublicId;
@property (nonatomic, copy) NSString *msgId;

- (void)startTimer;
- (void)cancelTimer;

@end
