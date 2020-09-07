//
//  ProfileViewDetailController.h
//  TwitterFon
//
//  Created by apple on 11-4-1.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDMenuView.h"

@class KDUser;


@interface ProfileViewDetailController : UITabBarController <UITabBarControllerDelegate, KDMenuViewDelegate>
{
    KDMenuView *menuView_;
}

@property(nonatomic, retain) KDUser *currentUser;

- (void)setSelectedTabIndex:(NSUInteger)selectedIndex;

@end
