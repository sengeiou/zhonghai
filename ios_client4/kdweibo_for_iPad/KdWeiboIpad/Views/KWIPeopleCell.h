//
//  KWIPeopleCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDUser;

@interface KWIPeopleCell : UITableViewCell

@property (retain, nonatomic) KDUser *data;

+ (KWIPeopleCell *)cell;

@end
