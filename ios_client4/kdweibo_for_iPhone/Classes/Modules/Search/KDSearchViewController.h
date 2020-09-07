//
//  KDSearchViewController.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-16.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDSearchViewControllerDelegate;
@class KDUser;

enum {
    KDSearchMaskTypeNone = 0,
    KDSearchMaskTypeStatuses = 1 << 0,
    KDSearchMaskTypeUsers = 1 << 1,
    KDSearchMaskTypeTrends = 1 << 2
};

typedef NSUInteger KDSearchMaskType;


@interface KDSearchViewController : UIViewController

@property (nonatomic, assign) id<KDSearchViewControllerDelegate> delegate;
@property (nonatomic, assign) KDSearchMaskType searchMaskType;

@property (nonatomic, copy) NSString *keywords;

- (id)initWithSearchMaskType:(KDSearchMaskType)searchMaskType;

@end


@protocol KDSearchViewControllerDelegate <NSObject>
@optional

- (void)searchViewController:(KDSearchViewController *)svc didSelectUser:(KDUser *)user;
- (void)searchViewController:(KDSearchViewController *)svc didSelectTopicText:(NSString *)topicText;

@end
