//
//  KDInvitePhoneContactView.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-31.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KDInvitePhoneContactViewClickedBlock)(id sender);

@interface KDInvitePhoneContactView : UIView

- (id)initWithFrame:(CGRect)frame andClickedBlock:(KDInvitePhoneContactViewClickedBlock)block;

+ (CGSize)defaultSize;

@end
