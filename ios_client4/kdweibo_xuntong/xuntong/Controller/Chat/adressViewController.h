//
//  adressViewController.h
//  kdweibo
//
//  Created by mark on 8/18/14.
//  Copyright (c) 2014 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDLocationData.h"
#import "KDLocationOptionViewController.h"
#import <MAMapKit/MAMapKit.h>

@class KDLocationOptionViewController;
@protocol KDLocationOptionViewControllerDelegate <NSObject>

- (void)determineLocation:(KDLocationData *)locationData
           viewController:(KDLocationOptionViewController *)viewController;

- (void)deleteCurrentLocationData;

@optional
- (void)backToPreView;
@end

@interface adressViewController : UIViewController <KDLocationOptionViewControllerDelegate> {

}

@property (nonatomic, retain)NSArray *locationDataArray;
@property (nonatomic, retain) KDLocationData *currentLocationData;

@property(nonatomic,weak)id<KDLocationOptionViewControllerDelegate> delegate;

@property(nonatomic,retain)UITableView *tableView;
@property(nonatomic,assign)BOOL shouldHideDeleteLocationBtn;

- (void)addAnnotation;

- (void)setCenterRegion;

@end
