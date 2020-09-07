//
//  KDQRScanView.h
//  kdweibo
//
//  Created by Gil on 15/1/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDQRScanDelegate <NSObject>
- (void)changeLightStatue:(UIButton *)button;
@end

@interface KDQRScanView : UIView

@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, strong) NSString *displayedMessage;
@property (nonatomic, strong) UIButton *startLight;
@property (nonatomic, strong) UILabel *lightLabel;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) id <KDQRScanDelegate> delegate;

- (void)startImgaeAnimation;

@end