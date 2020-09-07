//
//  KDPhotoSignInTipView.h
//  kdweibo
//
//  Created by lichao_liu on 6/23/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SigninPhotoTipBlock)();
@interface KDPhotoSignInTipView : UIView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title block:(SigninPhotoTipBlock)block;
@end
