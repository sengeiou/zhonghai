//
//  XTPublicListViewController.h
//  XT
//
//  Created by mark on 14-1-11.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppView.h"
#import "MBProgressHUD.h"
#import "AppsClient.h"

@interface XTPublicListViewController : UIViewController<AppViewDelegate>
{
    AppsClient *_getAppClient;
    NSString *token;
    UIScrollView *appBgScrollView;
    UISwitch *displaySwitch;
    UIImageView *customImageView;
    //NSMutableArray *authAppArr;
    UISegmentedControl *sc;
    MBProgressHUD *hud;
    UIView *buttonBackGroundView;
    UIButton *leftButton;
    UIButton *rightButton;
    UIButton *refreshButton;
}
@property(nonatomic,retain)NSMutableArray*attentionArr;
@property(nonatomic,retain)NSMutableArray*publiclist;
@property(nonatomic,retain)MBProgressHUD *hud;
@end
