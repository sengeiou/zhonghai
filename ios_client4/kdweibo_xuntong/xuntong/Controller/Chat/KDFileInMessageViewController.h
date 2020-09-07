//
//  KDFileInMessageViewController.h
//  kdweibo
//
//  Created by janon on 15/3/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJPhotoBrowser.h"

@class XTChatViewController;
typedef NS_ENUM(NSInteger, KDFileInMessageType) {
    KDFileInMessageType_recent,
    KDFileInMessageType_file,
    KDFileInMessageType_picture,
    KDFileInMessageType_other
};

@interface KDFileInMessageViewController : UIViewController
@property(nonatomic, strong) NSString *groupId;
@property(nonatomic, strong) XTChatViewController *chatViewController;
@property(nonatomic, assign) KDFileInMessageType fileInMessageType;

- (void)setRedPointCountWithMutableArray:(NSInteger)count;
- (void)upload:(id)sender;
@end
