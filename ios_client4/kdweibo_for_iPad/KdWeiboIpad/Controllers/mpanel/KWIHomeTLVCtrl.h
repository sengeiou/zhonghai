//
//  KWIHometlVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/25/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"

#import "KWIMPanelVCtrl.h"


#import "KDStatusBaseViewController.h"

@interface KWIHomeTLVCtrl : UIViewController

- (BOOL)isPublic;

//refresh status List
- (void)refreshStatus; 

@end
