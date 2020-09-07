//
//  KWITrendStatusCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/4/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDStatus;

@interface KWITrendStatusCell : UITableViewCell

@property (retain, nonatomic) KDStatus *data;

+ (KWITrendStatusCell *)cellWithStatus:(KDStatus *)status;

@end
