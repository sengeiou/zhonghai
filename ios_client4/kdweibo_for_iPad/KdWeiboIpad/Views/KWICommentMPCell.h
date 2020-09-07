//
//  KWICommentMPCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/16/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDCommentMeStatus;

@interface KWICommentMPCell : UITableViewCell

@property (retain, nonatomic) KDCommentMeStatus *data;

+ (KWICommentMPCell *)cell;

@end
