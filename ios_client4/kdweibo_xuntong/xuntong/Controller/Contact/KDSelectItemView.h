//
//  SelectItemView.h
//  kdweibo
//
//  Created by KongBo on 15/9/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define itemTitleHeight 25

typedef NS_ENUM(NSUInteger, KDSelectItemViewStyle) {
    SelectItemViewStyleNormal,
    SelectItemViewStyleNormalLast,
    SelectItemViewStyleNormalFirst,
};

@class KDSelectItemView;
@protocol KDSelectItemViewDelegate <NSObject>
- (void)SelectItemView:(KDSelectItemView *)view  didSelectedAtIndex:(NSUInteger)index;

@end

@interface KDSelectItemView : UIView
@property (nonatomic, weak) id<KDSelectItemViewDelegate>delegate;

- (instancetype)initWithViewStyle:(KDSelectItemViewStyle)viewStyle viewTitle:(NSString *)title atIndex:(NSUInteger)index;
- (CGSize)getItemViewSize;

@end
