//
//  KDStatusFromGroupTipView.h
//  kdweibo
//
//  Created by Tan yingqi on 13-11-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDStatusFromGroupTipView : UIView
{

    UILabel     *groupNameLabel_;
    UIImageView *lock_;
    UIImageView *background_;
}
- (id)initWithGroupName:(NSString *)groupName;
- (void)setupViewWithGroupName:(NSString *)groupName;
+ (CGSize)sizeWithText:(NSString *)text constrainedWidth:(CGFloat) width;
@end
