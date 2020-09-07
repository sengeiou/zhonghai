//
//  KDPersonHeaderBar.h
//  kdweibo
//
//  Created by Gil on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDPersonHeaderBarDelegate;
@interface KDPersonHeaderBar : UIView

@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UIImageView *backgroundView;

@property (nonatomic, assign) id<KDPersonHeaderBarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame backBtnTitle:(NSString *)backBtnTitle;

@end

@protocol KDPersonHeaderBarDelegate <NSObject>
@optional
- (void)personHeaderBarBackButtonPressed:(UIView *)view;
@end