//
//  KDSignInViewController+Photo.h
//  kdweibo
//
//  Created by shifking on 16/4/21.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController.h"

@interface KDSignInViewController (Photo)
@property (strong , nonatomic) UIImagePickerController *picker;
- (void)addTipViewWithTip:(NSString *)tip;
- (void)presentImagePickerController;
@end
