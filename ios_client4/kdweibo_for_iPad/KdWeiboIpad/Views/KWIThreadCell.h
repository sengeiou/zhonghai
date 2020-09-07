//
//  KWIThreadCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/18/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDDMThread ;

@interface KWIThreadCell : UITableViewCell

@property (retain, nonatomic)  KDDMThread *data;

+ (KWIThreadCell *)cell;

//+ (NSUInteger)calculateHeightWithThread:(KWThread *)thread;

@end
