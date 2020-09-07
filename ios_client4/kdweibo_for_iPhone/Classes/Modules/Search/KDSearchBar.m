//
//  KDSearchBar.m
//  kdweibo
//
//  Created by shen kuikui on 13-1-6.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDSearchBar.h"

#define KD_SEARCH_BAR_TEXTFIELD_HEIGHT 24.0f
#define KD_SEARCH_BAR_TEXTFIELD_FONT_SIZE 14.0f

#define KD_SEARCH_BAR_H_PADDING      10.0f
#define KD_SEARCH_BAR_H_SPACING      5.0f

#define KD_SEARCH_BAR_CANCEL_BUTTON_WIDTH     45.0f
#define KD_SEARCH_BAR_CANCEL_BUTTON_HEIGHT    25.0f

#define KD_SEARCH_BAR_HEIGHT         44.0f

@implementation KDSearchBar

@synthesize delegate = delegate_;
@synthesize scopeBar = scopeBar_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupSearchBar];
    }
    return self;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(searchInputBagImageView_);
    //KD_RELEASE_SAFELY(searchIconImageView_);
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(searchCancelButton_);
    //KD_RELEASE_SAFELY(scopeBar_);
    //KD_RELEASE_SAFELY(bottomLine_);
    //KD_RELEASE_SAFELY(seperator_);
    
    //[super dealloc];
}

- (NSString *)text {
    return searchBar_.text;
}

- (void)setText:(NSString *)text {
    searchBar_.text = text;
}

- (void)setShowsCancelButton:(BOOL)showCancelButton {
    searchBar_.showsCancelButton = showCancelButton;
    [self setNeedsLayout];
}

- (BOOL)showsCancelButton {
    return searchBar_.showsCancelButton;
}

- (NSString *)placeHolder {
    return searchBar_.placeholder;
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    searchBar_.placeholder = placeHolder;
}

- (UITextAutocorrectionType )autocorrectionType {
    return searchBar_.autocorrectionType;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType )autocorrectionType {
    searchBar_.autocorrectionType = autocorrectionType;
}

- (BOOL)canResignFirstResponder {
    return YES;
}

-(void)setCancelButtonTitle:(NSString *)cancelButtonTitle{
    if (cancelButtonTitle && [cancelButtonTitle length] > 0 && ![cancelButtonTitle isEqualToString:_cancelButtonTitle]) {
        _cancelButtonTitle = cancelButtonTitle;
        [searchCancelButton_ setTitle:_cancelButtonTitle forState:UIControlStateNormal];

        
    }
}
-(void)setBottomLineHidden:(BOOL)hidden{
    bottomLine_.hidden = hidden;
}
- (BOOL)resignFirstResponder {
    return [searchBar_ resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return [searchBar_ isFirstResponder];
}

- (BOOL)becomeFirstResponder {
    return [searchBar_ becomeFirstResponder];
}

- (void)setupSearchBar {
//    UIImage *inputImage = [UIImage imageNamed:@"common_img_search_bg"];
//    inputImage = [inputImage stretchableImageWithLeftCapWidth:inputImage.size.width*0.5 topCapHeight:inputImage.size.height*0.5];
//    searchInputBagImageView_ = [[UIImageView alloc] initWithImage:inputImage];
//    searchInputBagImageView_.frame = CGRectMake(10.0f, 7.5, self.bounds.size.width-2*10, KD_SEARCH_BAR_TEXTFIELD_HEIGHT);
//    searchInputBagImageView_.backgroundColor = [UIColor kdBackgroundColor2];
//    [self addSubview:searchInputBagImageView_];
    

//    UIImage *searchImage = [UIImage imageNamed:@"common_btn_search.png"];
//    searchIconImageView_ = [[UIImageView alloc] initWithImage:searchImage];
//    searchIconImageView_.frame = CGRectMake(15.0f,15.5, searchImage.size.width, searchImage.size.height);
//    searchIconImageView_.backgroundColor = [UIColor clearColor];
//    [self addSubview:searchIconImageView_];
    
    searchBar_ = [[UISearchBar alloc] init];
    searchBar_.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [searchBar_ setCustomPlaceholder:ASLocalizedString(@"KDSearchBar_Search")];
    searchBar_.delegate = self;
    [self addSubview:searchBar_];
    
   

    
//    searchCancelButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//    [searchCancelButton_ setTitle:ASLocalizedString(@"Global_Cancel")forState:UIControlStateNormal];
//    [searchCancelButton_ setTitleColor:RGBCOLOR(23, 131, 253) forState:UIControlStateNormal];
//    [searchCancelButton_ setTitleColor:RGBCOLOR(113, 113, 113) forState:UIControlStateDisabled];
//    [searchCancelButton_.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
//    [searchCancelButton_ addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    searchCancelButton_.frame = CGRectMake(ScreenFullWidth - 10 - 45, 7.0f, 45.0f, 26.0f);
//    searchCancelButton_.enabled = YES;
//    [self addSubview:searchCancelButton_];
    
//    scopeBar_ = [[KDSearchBarScopeBar alloc] initWithFrame:CGRectMake(0.0f, KD_SEARCH_BAR_HEIGHT, self.bounds.size.width, self.bounds.size.height - KD_SEARCH_BAR_HEIGHT)];
//    scopeBar_.delegate = self;
//    [self addSubview:scopeBar_];
    
//    seperator_ = [[UIView alloc] initWithFrame:CGRectZero];
//    seperator_.backgroundColor = RGBCOLOR(203, 203, 203);
//    [self addSubview:seperator_];
//    
//    bottomLine_ = [[UIView alloc] initWithFrame:CGRectZero];
//    bottomLine_.backgroundColor = [UIColor kdBackgroundColor1];//BOSCOLORWITHRGBA(0xDDDDDD, 1.0);
//    [self addSubview:bottomLine_];
    
    self.backgroundColor = [UIColor kdBackgroundColor2];//MESSAGE_BG_COLOR;
    self.clipsToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //searchIconImageView_.frame = CGRectMake(15.0f, 15.5, CGRectGetWidth(searchIconImageView_.frame), CGRectGetHeight(searchIconImageView_.frame));
    
    if(searchCancelButton_.hidden) {
        
        searchBar_.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        //searchInputBagImageView_.frame = CGRectMake(10.0f, 7.5, CGRectGetWidth(self.bounds) - 20.0f, searchInputBagImageView_.image.size.height);
    }else {
        //searchCancelButton_.frame = CGRectMake(self.bounds.size.width - KD_SEARCH_BAR_H_PADDING - KD_SEARCH_BAR_CANCEL_BUTTON_WIDTH, (KD_SEARCH_BAR_HEIGHT - KD_SEARCH_BAR_CANCEL_BUTTON_HEIGHT) * 0.5f, KD_SEARCH_BAR_CANCEL_BUTTON_WIDTH, KD_SEARCH_BAR_CANCEL_BUTTON_HEIGHT);
        searchBar_.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        //searchInputBagImageView_.frame = CGRectMake(10.0f, 7.5, CGRectGetMinX(searchCancelButton_.frame) - 10.0 - KD_SEARCH_BAR_H_SPACING, searchInputBagImageView_.image.size.height);
    }
    
 //   scopeBar_.frame = CGRectMake(0.0f, KD_SEARCH_BAR_HEIGHT, self.bounds.size.width, self.bounds.size.height - KD_SEARCH_BAR_HEIGHT);
    
 //   seperator_.frame = CGRectMake(0.0f, CGRectGetMinY(scopeBar_.frame) + 0.5, CGRectGetWidth(self.bounds), 0.5f);
 //   bottomLine_.frame = CGRectMake(0.0f, CGRectGetMaxY(self.frame) - 0.5f, CGRectGetWidth(self.bounds), 0.5f);
}

//- (void)cancelButtonClicked:(id)sender {
//    if(delegate_ && [delegate_ respondsToSelector:@selector(searchBarCancelButtonClicked:)])
//        [delegate_ searchBarCancelButtonClicked:self];
//}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if(delegate_ && [delegate_ respondsToSelector:@selector(searchBarTextDidBeginEditing:)])
        [delegate_ searchBarTextDidBeginEditing:self];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if(delegate_ && [delegate_ respondsToSelector:@selector(searchBarTextDidEndEditing:)])
        [delegate_ searchBarTextDidEndEditing:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if(delegate_ && [delegate_ respondsToSelector:@selector(searchBarSearchButtonClicked:)])
        [delegate_ searchBarSearchButtonClicked:self];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self resignFirstResponder];
    if(delegate_ && [delegate_ respondsToSelector:@selector(searchBar:textDidChange:)])
        [delegate_ searchBar:self textDidChange:@""];
    
    if(delegate_ && [delegate_ respondsToSelector:@selector(searchBarCancelButtonClicked:)])
        [delegate_ searchBarCancelButtonClicked:self];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar_ setShowsCancelButton:YES animated:YES];
    //searchCancelButton_.enabled = YES;
    if(delegate_ && [delegate_ respondsToSelector:@selector(searchBarShouldBeginEditing:)])
        return [delegate_ searchBarShouldBeginEditing:self];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar_ setShowsCancelButton:NO animated:YES];
    //为了在搜索动态，能随便点击取消返回，所以一直保存取消按钮可用   alanwong
    //searchCancelButton_.enabled = YES;
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(delegate_ && [delegate_ respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [delegate_ searchBar:self textDidChange:[searchBar_.text stringByReplacingCharactersInRange:range withString:text]];
    }
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(delegate_ && [delegate_ respondsToSelector:@selector(searchBarTextDidChange:)]) {
        [delegate_ searchBarTextDidChange:self];
    }
}


- (void)kdSearchBarScopeBar:(KDSearchBarScopeBar *)scopeBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if(delegate_ && [delegate_ respondsToSelector:@selector(searchBar:selectedScopeButtonIndexDidChange:)])
        [delegate_ searchBar:self selectedScopeButtonIndexDidChange:selectedScope];
}


@end
