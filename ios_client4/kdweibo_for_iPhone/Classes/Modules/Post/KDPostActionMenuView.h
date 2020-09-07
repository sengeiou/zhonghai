//
//  KDPostActionMenuView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-22.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
typedef enum:NSUInteger {
    KDPostActionMenuViewLocate = 100,
    KDPostActionMenuViewPic,
    KDPostActionMenuViewAt,
    KDPostActionMenuViewTopic,
    KDPostActionMenuViewExpression,
    KDPostActionMenuViewVideo

}KDPostActionMenuViewTag;

typedef enum:NSUInteger  {
    KDPostActionMenuViewAlignCenter = 0,
    KDPostActionMenuViewAlignLeft,
    KDPostActionMenuViewAlignRight,
}KDPostActionMenuViewAlign;

@protocol KDPostActionMenuViewDelegate;

@interface KDPostActionMenuView : UIView {
 @private
//    id<KDPostActionMenuViewDelegate> delegate_;
    
    CALayer *backgroundLayer_;
    NSArray *menuItems_;
    
    CALayer *thumbnailBGLayer_;
    CALayer *thumbnailLayer_;
    
    id userInfo_; // user info must be an object
}

@property(nonatomic, assign) id<KDPostActionMenuViewDelegate> delegate;

@property(nonatomic, retain, readonly) NSArray *menuItems;

@property(nonatomic, retain) id userInfo;

@property(nonatomic, assign)KDPostActionMenuViewAlign align;

- (UIButton *)menuButtonItemAtIndex:(NSUInteger)index;

- (void)menuButtonWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage atIndex:(NSUInteger)index;

- (void)menuButtonItemEnabled:(BOOL)enabled atIndex:(NSUInteger)index;
- (void)menuButtonItemHidden:(BOOL)hidden atIndex:(NSUInteger)index;

- (void)pickedImageThumbnailVisible:(BOOL)visible content:(UIImage *)image;
- (void)setImageButtonHighlighted:(BOOL)highlighted;
- (void)setVideoHighlighted:(BOOL)highlighted;
- (void)setExpressButtonHighlighted:(BOOL)highlighted;
- (void)explicitlyStopVedioAnimation;
- (void)startVedioAnimation;
- (void)stopVedioAnimation;
@end



@protocol KDPostActionMenuViewDelegate <NSObject>
@optional

- (void) postActionMenuView:(KDPostActionMenuView *)postActionMenuView clickOnMenuItem:(UIButton *)menuItem;

@end