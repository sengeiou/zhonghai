//
//  KDTaskShareViewController.h
//  kdweibo
//
//  Created by Tan yingqi on 13-7-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDTaskShareViewControllerDelegate <NSObject>

- (void)tashShareRangeDidSelected:(NSDictionary *)dic;

@end

@interface KDTaskShareViewController : UIViewController
@property(nonatomic,retain)NSDictionary *shareRangeDic;
@property(nonatomic,weak)id<KDTaskShareViewControllerDelegate> delegate;
@end
