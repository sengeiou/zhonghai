//
//  KDDocumentListView.h
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-5-22.
//
//

#import <UIKit/UIKit.h>

@interface KDDocumentListView : UITableView
@property (nonatomic,retain)id documentDataSource;
+(CGFloat)heightOfTableViewByAttachemts:(NSArray *)attachemts;
@end
