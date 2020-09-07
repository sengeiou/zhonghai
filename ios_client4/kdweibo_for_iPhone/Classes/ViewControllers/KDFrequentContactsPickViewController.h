//
//  KDFrequentContactsPickViewController.h
//  kdweibo
//
//  Created by shen kuikui on 13-8-1.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSearchBar.h"

typedef enum {
    KDFrequentContactsType_At = 0,
    KDFrequentContactsType_DM,
    KDFrequentContactsType_DM_ADD_PEOPLE
}KDFrequentContactsType;

@class KDFrequentContactsPickViewController;

@protocol KDFrequentContactsPickViewControllerDelegate <NSObject>

- (void)frequentContactsPickViewController:(KDFrequentContactsPickViewController *)fcpvc pickedUsers:(NSArray *)users;
- (void)cancelContactsPickViewController;

@end

@interface KDFrequentContactsPickViewController : UIViewController<KDSearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, copy)   NSArray *alreadyExistsUserIds;
@property(nonatomic, assign) id<KDFrequentContactsPickViewControllerDelegate> delegate;
- (void)addPickedUsers:(NSArray *)users;
- (id)initWithType:(KDFrequentContactsType)type;
@end
