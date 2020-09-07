//
//  KDInviteHint View.h
//  kdweibo
//
//  Created by AlanWong on 14-10-13.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KDInviteHintViewBlock)();

@interface KDInviteHintView : UIView
@property(nonatomic,copy)KDInviteHintViewBlock block;
@end
