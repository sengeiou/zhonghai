//
//  KDStatusActionToolbar.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-28.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface KDStatusActionToolbar : UIView {
@private
    CAGradientLayer *shadowLayer_;
    CALayer *backgroundLayer_;
    
    NSArray *barItems_;
}

@property (nonatomic, retain) NSArray *barItems;

- (UIButton *) toolbarItemWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName;

- (void) toolbarItemEnabled:(BOOL)enabled atIndex:(NSUInteger)index;
- (void) toolbarItemHidden:(BOOL)hidden atIndex:(NSUInteger)index;

@end
