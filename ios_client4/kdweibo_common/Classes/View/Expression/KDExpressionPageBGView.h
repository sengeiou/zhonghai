//
//  KDExpressionPageBGView.h
//  kdweibo
//
//  Created by Darren Zheng on 7/8/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDExpressionPageBGView : UIView
@property (nonatomic, copy) void (^onTouchUpInside)(CGPoint location);
@property (nonatomic, copy) void (^onTouchesLongPress)(CGPoint location);
@property (nonatomic, copy) void (^onTouchesMoved)(CGPoint location);
@property (nonatomic, copy) void (^onTouchesEnded)(CGPoint location);
@property (nonatomic, copy) void (^onTouchesBegan)(CGPoint location);

@end
