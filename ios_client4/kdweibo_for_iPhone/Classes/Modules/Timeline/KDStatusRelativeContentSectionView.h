//
//  KDStatusRelativeContentSectionView.h
//  kdweibo
//
//  Created by laijiandong on 12-10-16.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDStatus;

@protocol KDStatusRelativeContentSectionViewDelegate;

@interface KDStatusRelativeContentSectionView : UIView {
@private
//    id<KDStatusRelativeContentSectionViewDelegate> delegate_; // weak reference
    
    UIImageView *topDividerImageView_; // at top
    UIImageView *bottomDividerImageView_;//at bottom
    UIView *verticalDividerView_; // between two buttons
    UIButton *commentsBtn_;
    UIButton *forwardsBtn_;
    UIButton *likersBtn_;
    UIImageView *cursorView_;
    
    NSInteger selectedIndex_;
    NSInteger lastSelectedIndex_;
    
    BOOL isAnimation_;
}

@property(nonatomic, assign) id<KDStatusRelativeContentSectionViewDelegate> delegate;
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, assign) BOOL hideForward; //是否隐藏转发微博

- (id)initWithFrame:(CGRect)frame selectedIndex:(NSInteger)selectedIndex hideForward:(BOOL)hide;

- (id)initWithFrame:(CGRect)frame selectedIndex:(NSInteger)selectedIndex;

- (void)updateWithStatus:(KDStatus *)status;


@end

@protocol KDStatusRelativeContentSectionViewDelegate <NSObject>
@optional

- (void)statusSectionView:(KDStatusRelativeContentSectionView *)sectionView clickedAtIndex:(NSUInteger)index;

@end


