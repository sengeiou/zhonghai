//
//  KWIGroupMemberCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/6/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDUser;

@interface KWIGroupMemberCell : UITableViewCell

@property (retain, nonatomic) KDUser *user;

+ (KWIGroupMemberCell *)cell;

@end
