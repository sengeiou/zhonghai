//
//  KDSelectStatueView.h
//  kdweibo
//
//  Created by Guohuan Xu on 5/10/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SELECT_STATUE_VIEW_WIDHT 22.0

enum  
{
    SelectViewStatueUnSelected,
    SelectViewStatueHasSelected
}typedef SelectViewStatue;

@interface KDSelectStatueView : UIImageView
+(KDSelectStatueView *)makeDefaultSelectStatueView;
-(void)setViewSelectStatueWith:(SelectViewStatue)selectViewStatue;

@end
