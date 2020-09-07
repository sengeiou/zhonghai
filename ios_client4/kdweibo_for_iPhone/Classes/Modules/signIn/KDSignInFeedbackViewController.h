//
//  KDSignInFeedbackViewController.h
//  kdweibo
//
//  Created by 张培增 on 2016/11/2.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSignInRecord.h"

typedef void(^KDSignInFeedbackJSBridgeBlock)(void);

@interface KDSignInFeedbackViewController : UIViewController

@property (nonatomic, strong) KDSignInRecord                    *signInRecord;
@property (nonatomic, strong) KDSignInFeedbackJSBridgeBlock     jsBridgeBlock;

@end
