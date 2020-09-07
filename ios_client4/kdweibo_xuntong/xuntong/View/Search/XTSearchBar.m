//
//  XTSearchBar.m
//  XT
//
//  Created by Gil on 13-7-12.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSearchBar.h"
#import "UIImage+XT.h"
#import <QuartzCore/QuartzCore.h>

@interface XTSearchBar ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation XTSearchBar


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
  
        [[[self class] appearance] setSearchFieldBackgroundImage:[UIImage imageNamed:@"task_input_search"] forState:UIControlStateNormal];
        
        [[[self class] appearance] setImage:[XTImageUtil searchBarIconDeleteImageWithState:UIControlStateNormal] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
        [[[self class] appearance] setImage:[XTImageUtil searchBarIconDeleteImageWithState:UIControlStateHighlighted] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
        
//        [[[self class]appearance]setImage:[UIImage imageNamed:@"task_icon_search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];

//        [[self class]appearance]set
//        [[[self class] appearance] setImage:[XTImageUtil searchBarIconVoiceImageWithState:UIControlStateNormal] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
//        [[[self class] appearance] setImage:[XTImageUtil searchBarIconVoiceImageWithState:UIControlStateHighlighted] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateHighlighted];
        self.showsBookmarkButton = NO;
        //TODO:
        //暂时先屏蔽
        /*
        [[[self class] appearance] setImage:[XTImageUtil searchBarIconVoiceImageWithState:UIControlStateNormal] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
        [[[self class] appearance] setImage:[XTImageUtil searchBarIconVoiceImageWithState:UIControlStateHighlighted] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateHighlighted];
        self.showsBookmarkButton = YES;
>>>>>>> .r6608
         */
    
        self.tintColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[XTImageUtil searchBarBackgroundImage]];
        backgroundImageView.frame = self.bounds;
        self.backgroundImageView = backgroundImageView;
        UIView *backGroundView = [[UIView alloc]initWithFrame:self.bounds];
        backGroundView.backgroundColor = UIColorFromRGB(0xe8e8e8);
        backGroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:backGroundView atIndex:1];
        
//        if (isAboveiOS7) {
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:cancelButton];
            cancelButton.hidden = YES;
            cancelButton.tag = 10054;

            _xtCancelButton = cancelButton;
//        }
        
        self.tag = XTSearchBarNormal;
    }
    return self;
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    __block UITextField *searchField;
    __block UIButton *cancelButton;
    id subviews = self.subviews;
//    if (isAboveiOS7) {
        subviews = ((UIView *)[self.subviews objectAtIndex:0]).subviews;
//    }
    [subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UITextField class]]) {

            searchField = (UITextField *)obj;
//            searchField.returnKeyType = UIReturnKeyDone;
            NSArray *textFieldSubviews = searchField.subviews;
            [textFieldSubviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if([obj isKindOfClass:NSClassFromString(@"UISearchBarTextFieldLabel")]){
                    UILabel *textLabel = (UILabel*)obj;
                    textLabel.textColor = UIColorFromRGB(0xcbcbcb);
                    *stop = YES;
                }
            }];

            
            
        } else if ([obj isKindOfClass:[UIButton class]]) {
            
            cancelButton = (UIButton *)obj;
            [cancelButton setFrame:CGRectMake(265.0, 7.0, 50.0, 30.0)];
            [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
            [cancelButton setTitle:ASLocalizedString(@"Global_GoBack")forState:UIControlStateNormal];
            cancelButton.titleLabel.textColor = BOSCOLORWITHRGBA(0x6d6d6d, 1.f);
            [cancelButton setTitleColor:BOSCOLORWITHRGBA(0x6d6d6d, 1.0) forState:UIControlStateNormal];
            [cancelButton setTitleColor:BOSCOLORWITHRGBA(0xD3E4F0, 1.0) forState:UIControlStateHighlighted];
            [cancelButton setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(232, 232, 232)] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(232, 232, 232)] forState:UIControlStateHighlighted];
        
        } else if ([obj isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            
            [obj removeFromSuperview];
        
        }
     
    }];
    
    
    if (self.tag == XTSearchBarNormal) {
        
        UIImageView *searchIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"task_icon_search"]];
        searchField.leftView = searchIcon;
        
        searchField.leftViewMode = UITextFieldViewModeAlways;
        
    } else {
        UIImageView *leftView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"task_icon_search"]];
        [leftView sizeToFit];
        
        [searchField setLeftView:leftView];
        
//        UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [changeBtn setTag:0];
//        [changeBtn setFrame:CGRectMake(0.0, 0.0, 30, 21)];
//        [changeBtn setBackgroundImage:[XTImageUtil searchBarIconChangeKeyBoardImageWithTag:changeBtn.tag state:UIControlStateNormal] forState:UIControlStateNormal];
//        [changeBtn setBackgroundImage:[XTImageUtil searchBarIconChangeKeyBoardImageWithTag:changeBtn.tag state:UIControlStateHighlighted] forState:UIControlStateHighlighted];
//        [changeBtn addTarget:self action:@selector(changeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//        searchField.leftView = changeBtn;
//        searchField.leftViewMode = UITextFieldViewModeAlways;
    }
    
    _xtSearchField = searchField;
//    if(cancelButton.tag == 10054){
////    _xtCancelButton = cancelButton;
//    }
}

- (void)setSearchDelegate:(id<XTSearchBarDelegate>)searchDelegate
{
    _searchDelegate = searchDelegate;
    
    self.delegate = self;
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(searchBarBookmarkButtonClicked:)]) {
        [self.searchDelegate searchBarBookmarkButtonClicked:self];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.searchDelegate searchBarCancelButtonClicked:self];
    }
}

- (void)changeBtnPressed:(UIButton *)btn
{
    btn.tag = !btn.tag;
    [btn setBackgroundImage:[XTImageUtil searchBarIconChangeKeyBoardImageWithTag:(int)btn.tag state:UIControlStateNormal] forState:UIControlStateNormal];
    [btn setBackgroundImage:[XTImageUtil searchBarIconChangeKeyBoardImageWithTag:(int)btn.tag state:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    
    if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(searchBarChangeKeyboardButtonClicked:)]) {
        [self.searchDelegate searchBarChangeKeyboardButtonClicked:self];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        return [self.searchDelegate searchBar:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)setEnabled:(BOOL)enabled
{
    _xtSearchField.enabled = enabled;
}

@end
