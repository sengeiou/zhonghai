//
//  KDChooseInviteHintVIew.h
//  kdweibo
//
//  Created by AlanWong on 14-10-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDChooseInviteHintView;
@protocol KDChooseInviteHintViewDelegate <NSObject>

- (void)buttonPressedWithView:(KDChooseInviteHintView *)view;

@end

typedef void (^ChooseHandleBlock)();
@interface KDChooseInviteHintView : UIView
@property (nonatomic, assign) id <KDChooseInviteHintViewDelegate>delegate;
@property(nonatomic, copy)ChooseHandleBlock handleBlock;

@end
