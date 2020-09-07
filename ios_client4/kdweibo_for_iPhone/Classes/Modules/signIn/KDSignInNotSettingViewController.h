//
//  KDSignInNotSettingViewController.h
//  kdweibo
//
//  Created by weihao_xu on 14-5-20.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^DidTryUseLocationBlock)(void) ;
@interface KDSignInNotSettingViewController : UIViewController
@property (nonatomic,copy) DidTryUseLocationBlock didTryUseBlock;
@end
