//
//  KDStausCell.h
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"
#import "KDThumbnailView2.h"
#import "KDStatusLayouter.h"

@interface KDStatusCell : UITableViewCell
@property (nonatomic,assign)UIEdgeInsets maskInsets;
- (void)loadThumbanilsImage;
+ (void)loadImagesForVisibleCellsIfNeed:(UITableView *)tableView;
//+ (KDStatusCell *)cellWithStatus:(KDStatus *)status constainedWidth:(CGFloat )width;
@end
