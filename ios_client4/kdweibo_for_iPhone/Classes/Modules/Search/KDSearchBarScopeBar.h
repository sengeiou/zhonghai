//
//  KDSearchBarScopeBar.h
//  kdweibo
//
//  Created by shen kuikui on 13-1-6.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const KDSearchBarScopeBarAttributeFont;
extern NSString * const KDSearchBarScopeBarAttributeTextColor;
extern NSString * const KDSearchBarScopeBarAttributeBackgroundImage;
extern NSString * const KDSearchBarScopeBarAttributeImage;

enum {
    KDSearchBarScopeBarStateNormal = UIControlStateNormal,
    KDSearchBarScopeBarStateSelected = UIControlStateSelected
};

typedef NSInteger KDSearchBarScopeBarState;

@protocol KDSearchBarScopeBarDelegate;

@interface KDSearchBarScopeBar : UIView

@property (nonatomic, assign) NSUInteger selectedScopeButtonIndex;
@property (nonatomic, assign) id<KDSearchBarScopeBarDelegate> delegate;

- (void)setAttributes:(NSDictionary *)attributes forState:(KDSearchBarScopeBarState)state;
- (void)setScopeButtonTitles:(NSArray *)scopeButtonTitles;

@end


@protocol KDSearchBarScopeBarDelegate <NSObject>

@optional

- (void)kdSearchBarScopeBar:(KDSearchBarScopeBar *)scopeBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope;

@end