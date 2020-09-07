//
//  KDSendViewController.h
//  kdweibo
//
//  Created by wenjie_lee on 16/2/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDSendViewControllerDeleagate <NSObject>

- (void)sendLocation:(KDLocationData *)locationData;

@end

@interface KDSendViewController : UIViewController

@property (nonatomic, weak) id <KDSendViewControllerDeleagate> delegate;

@end
