//
//  KWIGroupCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/5/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDGroup;

@interface KWIGroupCell : UITableViewCell

@property (retain, nonatomic) KDGroup *group;

+ (KWIGroupCell *)cellWithGroup:(KDGroup *)group;

@end
