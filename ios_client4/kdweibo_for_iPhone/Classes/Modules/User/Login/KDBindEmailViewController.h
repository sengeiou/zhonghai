//
//  KDBindEmailViewController.h
//  kdweibo
//
//  Created by bird on 14-5-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDBindEmailViewControllerDelegate <NSObject>

- (void)finishBindEmail;

@end

@interface KDBindEmailViewController : UIViewController

@property (nonatomic, assign) id<KDBindEmailViewControllerDelegate> delegate;
@property (nonatomic, assign) int fromType; 
@end
