//
//  KDColorChooseView.h
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDColorChooseViewDelegate <NSObject>
- (void)chooseColorWithColor:(UIColor*)color;

@optional
- (void)clickReturn;
@end

// 高36
@interface KDColorChooseView : UIView

@property(nonatomic, weak)id <KDColorChooseViewDelegate> delegate;

@property (nonatomic, assign)BOOL hiddenReturn;
@property (nonatomic, assign)BOOL hiddenMosaic;

@end
