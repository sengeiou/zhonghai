//
//  XTChatBannerView.h
//  kdweibo
//
//  Created by DarrenZheng on 14-8-1.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XTChatBannerViewDelegate <NSObject>

@optional
- (void)chatBannerViewButtonDeletePressed;
- (void)chatBannerViewButtonConfirmPressed;

@end

@interface XTChatBannerView : UIView

@property (nonatomic, assign) id <XTChatBannerViewDelegate> delegate;

- (void)show;
- (void)hide;
- (void)setText:(NSString *)text;

@end
