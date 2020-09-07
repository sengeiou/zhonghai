//
//  KDStatusCellForDetailView.h
//  kdweibo
//
//  Created by shen kuikui on 12-12-13.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDStatus.h"
#import "KDStatusCoreTextDelegate.h"
#import "KDStatusDetailView.h"
#import "UIViewAdditions.h"

@interface KDStatusCellForDetailView : UITableViewCell

@property (nonatomic, retain) KDStatus *status;
@property (nonatomic, assign) id<KDStatusCoreTextDelegate, KDStatusDetailViewDelegate> delegate;

- (void)loadThumbnailViewIfExists;

@end
