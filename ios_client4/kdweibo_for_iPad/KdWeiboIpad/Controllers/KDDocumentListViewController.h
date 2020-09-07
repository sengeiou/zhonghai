//
//  KDDocumentListViewController.h
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-25.
//
//

#import <UIKit/UIKit.h>


@interface KDDocumentListViewController : UITableViewController
@property (nonatomic,retain)id documentDataSource;
+(CGFloat)heightOfTableViewByStatus:(KDStatus *)status;
+(CGFloat)heightOfTableViewByMessage:(KDDMMessage *)message;
@end
