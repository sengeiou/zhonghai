//
//  KDCheckBoxAlertView.h
//  kdweibo
//
//  Created by 王 松 on 13-9-10.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDCheckBoxAlertView : UIAlertView

@property (nonatomic, copy) NSString *errorMsg;

@property (nonatomic, assign) BOOL boxChecked;

-(id)initWithTitle:(NSString *)title message:(NSString *)message chkBoxMsg:(NSString *)chkMsg delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
