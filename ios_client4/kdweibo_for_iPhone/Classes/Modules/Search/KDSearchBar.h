//
//  KDSearchBar.h
//  kdweibo
//
//  Created by shen kuikui on 13-1-6.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSearchBarScopeBar.h"

@protocol KDSearchBarDelegate;

@interface KDSearchBar : UIView<UISearchBarDelegate, KDSearchBarScopeBarDelegate> {
@private
    UIImageView *searchInputBagImageView_;
    UIImageView *searchIconImageView_;
    //UITextField *searchInputTextField_;
    UISearchBar *searchBar_;
    UIButton    *searchCancelButton_;
    KDSearchBarScopeBar *scopeBar_;
    
    UIView      *seperator_;
    UIView      *bottomLine_;
}

@property (nonatomic, readwrite, assign) NSString *text;
@property (nonatomic, readwrite, assign) NSString *placeHolder;
@property (nonatomic, assign) id<KDSearchBarDelegate> delegate;
@property (nonatomic, readwrite, assign) UITextAutocorrectionType autocorrectionType;

@property (nonatomic, assign) BOOL showsCancelButton;
@property (nonatomic, readonly) KDSearchBarScopeBar *scopeBar;

@property (nonatomic, retain) NSString * cancelButtonTitle;
//设置要不要显示底线
-(void)setBottomLineHidden:(BOOL)hidden;
@end

@protocol KDSearchBarDelegate <NSObject>

@optional

- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar;
- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar;

- (void)searchBar:(KDSearchBar *)searchBar textDidChange:(NSString *)searchText;
- (BOOL)searchBarShouldBeginEditing:(KDSearchBar *)searchBar;

- (void)searchBarCancelButtonClicked:(KDSearchBar *)searchBar;
- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar;

- (void)searchBar:(KDSearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope;

- (void)searchBarTextDidChange:(KDSearchBar *)searchBar;

@end