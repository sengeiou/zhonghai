//
//  FriendsTimelineDataSource.h
//  TwitterFon
//
//  Created by kaz on 12/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "KDRequestWrapper.h"
#import "KDStatusDataset.h"
#import "KDSession.h"

@class FriendsTimelineController;
@protocol FriendsTimelineDataSourceDelegate;

@interface FriendsTimelineDataSource : NSObject < KDRequestWrapperDelegate> {
    FriendsTimelineController *controller; // weak reference
}

@property(nonatomic, assign) FriendsTimelineController *controller;

@property(nonatomic, assign, readonly) BOOL reloading;

@property(nonatomic, retain, readonly) KDStatusDataset *dataset;

@property(nonatomic, assign) KDTLStatusType timelineType;

- (id)initWithController:(UIViewController*)controller type:(KDTLStatusType)type;

- (BOOL) hasStatuses;
- (void)loadLatestStatus;
- (void)loadEarlierStatus;
- (void)reloadTableViewDataSource;
- (void)cancelAllGetRequests;
- (void)restore;
@end

