//
//  KDSearchViewController.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-16.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDSearchViewControllerNewDelegate;
@class KDUser;

enum {
    KDSearchNewMaskTypeNone = 0,
    KDSearchNewMaskTypeStatuses = 1 << 0,
    KDSearchNewMaskTypeUsers = 1 << 1,
    KDSearchNewMaskTypeTrends = 1 << 2
};

typedef NSUInteger KDSearchNewMaskType;


@interface KDSearchViewControllerNew : UIViewController

@property (nonatomic, assign) id<KDSearchViewControllerNewDelegate> delegate;
@property (nonatomic, assign) KDSearchNewMaskType searchMaskType;
@property (nonatomic, assign) BOOL shouldDelayShowKeyBoard;
@property (nonatomic, readwrite, assign) BOOL isReturnByGesture;

@property (nonatomic, copy) NSString *keywords;

- (id)initWithSearchMaskType:(KDSearchNewMaskType)searchMaskType;

@end


@protocol KDSearchViewControllerNewDelegate <NSObject>
@optional

- (void)searchViewControllerNew:(KDSearchViewControllerNew *)svcn didSelectUser:(KDUser *)user;
- (void)searchViewControllerNew:(KDSearchViewControllerNew *)svcn didSelectTopicText:(NSString *)topicText;
- (void)searchViewControllerNew:(KDSearchViewControllerNew *)svcn didSelectStatus:(KDStatus *)status;
- (void)searchViewControllerNewDidCancel:(KDSearchViewControllerNew *)svcn;

@end
