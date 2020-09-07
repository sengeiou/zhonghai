//
//  UITableView+DZCategory.h
//  kdweibo
//
//  Created by Darren Zheng on 15/11/6.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (DZCategory)

- (void)insertRowsWithCount:(int)count withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadDataAnimated:(void(^)())completion; // if you only have section 0 in use


@end
