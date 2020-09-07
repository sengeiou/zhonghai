//
//  KWIStatusCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/24/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDStatus;

@interface KWIStatusCell : UITableViewCell

@property (retain, nonatomic) KDStatus *data;

@property (retain, nonatomic) IBOutlet UIView *contentV;

+ (KWIStatusCell *)cell;
+ (KWIStatusCell *)cardCell;

- (void)showOperations;
- (void)hideOperations;

@end
