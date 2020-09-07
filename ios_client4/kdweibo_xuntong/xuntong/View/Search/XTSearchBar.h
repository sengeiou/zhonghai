//
//  XTSearchBar.h
//  XT
//
//  Created by Gil on 13-7-12.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _XTSearchBarType
{
    XTSearchBarNormal = 0,
    XTSearchBarShouldSearch
}XTSearchBarType;

@protocol XTSearchBarDelegate;
@interface XTSearchBar : UISearchBar <UISearchBarDelegate>

@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;
@property (nonatomic, weak, readonly) UITextField *xtSearchField;
@property (nonatomic, weak, readonly) UIButton *xtCancelButton;

@property (nonatomic, weak) id<XTSearchBarDelegate> searchDelegate;

- (void)setEnabled:(BOOL)enabled;

@end


@protocol XTSearchBarDelegate <NSObject>

@optional
- (void)searchBarCancelButtonClicked:(XTSearchBar *)searchBar;
- (void)searchBarBookmarkButtonClicked:(XTSearchBar *)searchBar;
- (void)searchBarChangeKeyboardButtonClicked:(XTSearchBar *)searchBar;
- (BOOL)searchBar:(XTSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
@end