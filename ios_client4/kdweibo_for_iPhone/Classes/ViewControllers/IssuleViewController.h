//
//  IssuleViewController.h
//  TwitterFon
//
//  Created by  on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface IssuleViewController : UIViewController<UITextViewDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) NSString *text;

@property(nonatomic, retain) IBOutlet UITextView *issuleTextView;

@end
