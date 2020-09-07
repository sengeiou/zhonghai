//
//  KDSignInOutDoorView.h
//  kdweibo
//
//  Created by 王 松 on 14-1-7.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSignInViewController.h"
#import "KDPhotoUploadTask.h"

typedef void (^KDSignInOutDoorViewBlock)(NSString *content,NSString *photoIds,NSString *cacheStr);

@interface KDSignInOutDoorView : UIView

@property (nonatomic, strong) KDPhotoUploadTask *uploadTask;

- (id)initWithTitle:(NSString *)title controller:(KDSignInViewController *)controller;

- (void)showWithLocation:(NSString *)location block:(KDSignInOutDoorViewBlock) block;

@end
