//
//  KDStatusTimelineProvider.h
//  kdweibo
//
//  Created by laijiandong on 12-10-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDThumbnailView2.h"
#import "KDTimelineStatusCell.h"
#import "KDVideoPlayerController.h"

// Combinate this class to specificed view controller for handle load thumbnail
// and present photo grallery. also provide utlity methods to build timeline cell etc.

@interface KDStatusTimelineProvider : NSObject <KDThumbnailViewDelegate2, KDVideoPlayerManagerDelegate> {
 @private
//    UIViewController *viewController_; // weak reference
    id<KDImageDataSource> imageDataSource_; // weak reference
    
    BOOL showAccurateGroupName_; // if the status from some group, then show the group name
}

@property (nonatomic, assign) UIViewController *viewController;
@property (nonatomic, assign) BOOL showAccurateGroupName;

- (id)initWithViewController:(UIViewController *)viewController;

- (CGFloat)calculateStatusContentHeight:(KDStatus *)status inTableView:(UITableView *)tableView bodyViewPosition:(KDStatusBodyViewDisplayPosition)p;

- (CGFloat)calculateStatusContentHeight:(KDStatus *)status inTableView:(UITableView *)tableView;

- (KDTimelineStatusCell *)timelineStatusCellInTableView:(UITableView *)tableView status:(KDStatus *)status bodyViewPosition:(KDStatusBodyViewDisplayPosition)p;

- (KDTimelineStatusCell *)timelineStatusCellInTableView:(UITableView *)tableView status:(KDStatus *)status;

- (void)loadImageSourceInTableView:(UITableView *)tableView;


@end
