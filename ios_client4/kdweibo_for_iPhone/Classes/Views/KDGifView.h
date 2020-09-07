//
//  KDGifView.h
//  kdweibo
//
//  Created by bird on 13-9-2.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDImageSourceProtocol.h"
#import "KDProgressIndicatorView.h"

@protocol KDGifViewDelegate;

@interface KDGifView : UIWebView <KDImageSourceLoader>
{
    id<KDImageDataSource> imageSource_;
    KDProgressIndicatorView *progressView_;
    BOOL downloading_;
    float downloadsFinishedPercent_;

    UIControl *control_;
//    id<KDGifViewDelegate> demoDelegate_;
    BOOL isReload_;
}
@property (nonatomic, retain, readonly) NSData *data;
@property (nonatomic, retain) id<KDImageDataSource> imageSource;
@property (nonatomic, retain, readonly) UIControl *control;
@property (nonatomic, assign) id<KDGifViewDelegate> demoDelegate;

@end

@protocol KDGifViewDelegate <NSObject>
@optional

- (void)gifViewLayOut;

@end
