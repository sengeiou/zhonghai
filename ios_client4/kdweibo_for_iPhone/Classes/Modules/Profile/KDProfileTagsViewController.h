//
//  KDProfileTagsViewController.h
//  kdweibo
//
//  Created by Gil on 15/2/3.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDProfileTagsViewController;
@protocol KDProfileTagsViewControllerDelegate <NSObject>

- (void)didSelect:(KDProfileTagsViewController *)controller tag:(NSString *)tag;

@end

@interface KDProfileTagsViewController : UIViewController

@property (nonatomic, weak) id<KDProfileTagsViewControllerDelegate> delegate;

- (id)initWithTags:(NSArray *)tags customTags:(NSArray *)customTags currentTag:(NSString *)currentTag;

@end
