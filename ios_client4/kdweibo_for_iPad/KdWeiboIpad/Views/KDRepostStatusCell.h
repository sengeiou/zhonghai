//
//  KDRepostStatusCell.h
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-5-9.
//
//

#import <UIKit/UIKit.h>
#import "KDStatus.h"
@interface KDRepostStatusCell : UITableViewCell
@property(nonatomic,retain)KDStatus *repostedStatus;
+(KDRepostStatusCell *)cell;
@end
