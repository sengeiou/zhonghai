//
//  KDCommentCell.h
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-5-8.
//
//

#import <UIKit/UIKit.h>
#import "KDCommentStatus.h"
@interface KDCommentCell : UITableViewCell

@property(nonatomic,retain)KDCommentStatus *comment;
+(KDCommentCell *)cell;
@end
