//
//  KWICommentCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/6/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDCommentStatus;

@interface KWICommentCell : UITableViewCell

@property (retain, nonatomic) KDCommentStatus *data;
@property (assign, nonatomic) KDStatus *status;//回复所属的status
+ (KWICommentCell *)cell;
+(CGFloat)optimalHeightByConstrainedWidth:(CGFloat)width comment:(KDCommentStatus*)comment;
@end
