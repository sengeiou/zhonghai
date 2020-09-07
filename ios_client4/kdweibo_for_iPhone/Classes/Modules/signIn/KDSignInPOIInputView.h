//
//  KDSignInPOIInputView.h
//  kdweibo
//
//  Created by AlanWong on 14-9-17.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KDSignInPOIInputViewBlock)(NSString * address);

@interface KDSignInPOIInputView : UIView
@property(nonatomic,copy)KDSignInPOIInputViewBlock block;
@end
