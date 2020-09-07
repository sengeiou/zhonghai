//
//  UITableView+DZCategory.m
//  kdweibo
//
//  Created by Darren Zheng on 15/11/6.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "UITableView+DZCategory.h"

@implementation UITableView (DZCategory)

- (void)insertRowsWithCount:(int)count withRowAnimation:(UITableViewRowAnimation)animation
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < count; i++)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadDataAnimated:(void(^)())completion
{
    if (self.dataSource)
    {
        NSRange range = NSMakeRange(0, [self.dataSource numberOfSectionsInTableView:self]);
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
        [CATransaction begin];
        [self beginUpdates];
        if (completion)
        {
            [CATransaction setCompletionBlock:completion];
        }
        [self reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
        [self endUpdates];
        [CATransaction commit];
    }
}



@end
