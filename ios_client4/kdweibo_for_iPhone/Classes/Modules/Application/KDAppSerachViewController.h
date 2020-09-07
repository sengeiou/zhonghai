//
//  KDAppSerachViewController.h
//  kdweibo
//
//  Created by 郑学明 on 14-4-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDAppSerachViewController : UIViewController
- (id)initWithSearch;
@property (nonatomic, assign) NSArray *favoriteAppArr;    //已添加的应用数据模型 KDAppDataModel
@property (nonatomic, assign) id openAppDelegate;
@property (nonatomic, assign) KDWebViewController *webVC;
@end
