//
//  KDImageAlertView.h
//  kdweibo
//
//  Created by kingdee on 2017/8/29.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^EditImageBlock)();
typedef void(^ClickConfirmBlock)();

@interface KDImageAlertView : UIView

@property (nonatomic, strong)EditImageBlock editImageBlock;
@property (nonatomic, strong)ClickConfirmBlock clickConfirmBlock;

- (instancetype)initWithTitle:(NSString *)title Image:(UIImage *)image;

- (void)showImageAlert;
- (void)hideImageAlert;

@end
