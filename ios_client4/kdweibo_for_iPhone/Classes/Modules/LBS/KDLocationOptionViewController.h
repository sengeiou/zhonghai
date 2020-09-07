//
//  KDLocationOptionViewController.h
//  kdweibo
//
//  Created by Tan yingqi on 13-2-21.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDLocationData.h"
#import <MAMapKit/MAMapKit.h>
#import "KDRefreshTableView.h"

@class KDLocationOptionViewController;

@protocol KDLocationOptionViewControllerDelegate <NSObject>

- (void)determineLocation:(KDLocationData *)locationData
           viewController:(KDLocationOptionViewController *)viewController beginTimeInterval:(NSTimeInterval)beginTimeInterval;
@end

typedef void(^locationOptionPhotoSignInBlock)(void);

@interface KDLocationOptionViewController : UIViewController

@property (nonatomic, assign) id <KDLocationOptionViewControllerDelegate> delegate;
@property (nonatomic, copy) locationOptionPhotoSignInBlock locationOptionPhotoSignInBlock;

@property (nonatomic, strong) KDRefreshTableView *tableView;

@property (nonatomic, strong) NSArray *optionsArray;
@property (nonatomic, strong) KDLocationData *locationData;

@property (nonatomic, assign) BOOL shouldHideBottomView;
@property (nonatomic, assign) BOOL isFromSignInVC;

@end
