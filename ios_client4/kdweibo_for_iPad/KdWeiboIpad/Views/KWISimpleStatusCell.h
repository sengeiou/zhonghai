//
//  KWISimpleStatusCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDStatus;

@interface KWISimpleStatusCell : UITableViewCell

@property (retain, nonatomic) KDStatus *data;

+ (KWISimpleStatusCell *)cell;

@end
