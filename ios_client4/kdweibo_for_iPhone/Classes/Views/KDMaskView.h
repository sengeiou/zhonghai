//
//  KDMaskView.h
//  kdweibo
//
//  Created by shen kuikui on 13-11-28.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDMaskView;

@protocol KDMaskViewDelegate <NSObject>

- (void)maskView:(KDMaskView *)maskView touchedInLocation:(CGPoint)location;

@end

@interface KDMaskView : UIView

@property (nonatomic, assign) id<KDMaskViewDelegate> delegate;

@end
