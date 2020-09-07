//
//  KDAdsManager.h
//  kdweibo
//
//  Created by lichao_liu on 16/1/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "KDAdDetailModel.h"
typedef NS_ENUM(NSInteger,AnimationType) {
    ADAnimationTypeSlideUp = 10,
    ADAnimationTypeSlideDown,
    ADAnimationTypeSlideLeft,
    ADAnimationTypeSlideRight,
    ADAnimationTypeCurlUp,
    ADAnimationTypeSlowDisappear,
    ADAnimationTypeZoom
};

@interface AdvertisementView : UIView

- (void)closeAction;

@property (nonatomic,assign)AnimationType AdAnimationType;

@property (nonatomic,copy)dispatch_block_t block;

- (void)setAdsModel:(KDAdDetailModel *)adsModel timeout:(NSTimeInterval)timeout;
@end
