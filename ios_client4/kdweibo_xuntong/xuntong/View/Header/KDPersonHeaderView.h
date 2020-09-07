//
//  KDPersonHeaderView.h
//  kdweibo
//
//  Created by wenbin_su on 15/9/8.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDPersonHeaderView : UIView

@property (nonatomic, strong, readonly) UIImageView *photoView;
@property (nonatomic, strong, readonly) UILabel *nameLabel;

- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset;

@end
