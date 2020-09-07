//
//  KDViewPlayerController.h
//  kdweibo
//
//  Created by 王 松 on 13-7-15.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDStatus.h"

#import "KDVideoPlayerManager.h"

@interface KDVideoPlayerController : UIViewController

@property (nonatomic, assign) id<KDVideoPlayerManagerDelegate> delegate;

@property (nonatomic, retain) KDStatus *weiboStatus;

@property (nonatomic, retain) NSString *localFileURL;

//2013.11.30 by Tan Yingqi 直接传文档进来
@property (nonatomic, retain)NSArray *attachments;

@property (nonatomic, copy)NSString * dataId;

@end
