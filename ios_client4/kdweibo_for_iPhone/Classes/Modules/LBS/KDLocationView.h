//
//  KDLocationView.h
//  kdweibo
//
//  Created by Tan yingqi on 13-1-30.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDLocationData.h"

@interface KDLocationView : UIView
- (void)setAddrText:(NSString *)text;
- (void)showErrowMessage;
- (void)showInitMessag;
- (void)showStartMessage;
@end
