//
//  KDErrorDisplayView.h
//  kdweibo_common
//
//  Created by shen kuikui on 12-9-19.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDErrorDisplayView : UIView

+ (void)showErrorMessage:(NSString *)errorMsg inView:(UIView *)superView;

@end
