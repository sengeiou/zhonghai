//
//  KDSearchBarScopeBar.m
//  kdweibo
//
//  Created by shen kuikui on 13-1-6.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDSearchBarScopeBar.h"

NSString * const KDSearchBarScopeBarAttributeFont = @"KD_SEARCH_BAR_SCOPE_BAR_ATTRIBUTE_FONT";
NSString * const KDSearchBarScopeBarAttributeTextColor = @"KD_SEARCH_BAR_SCOPE_BAR_ATTRIBUTE_TEXT_COLOR";
NSString * const KDSearchBarScopeBarAttributeBackgroundImage = @"KD_SEARCH_BAR_SCOPE_BAR_ATTRIBUTE_BACKGROUND_IMAGE";
NSString * const KDSearchBarScopeBarAttributeImage = @"KD_SEARCH_BAR_SCOPE_BAR_ATTRIBUTE_IMAGE";

@interface KDSearchBarScopeBar () {
    UIView *buttonsBgView_;
    NSMutableArray *buttons_;
}

@end

@implementation KDSearchBarScopeBar

@synthesize delegate = delegate_;
@synthesize selectedScopeButtonIndex = selectedScopeButtonIndex_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(buttonsBgView_);
//    if(buttons_) [buttons_ release];
    
    //[super dealloc];
}

- (void)setAttributes:(NSDictionary *)attributes forState:(KDSearchBarScopeBarState)state {
    for(UIButton *btn in buttons_) {
        UIFont *font = [attributes objectForKey:KDSearchBarScopeBarAttributeFont];
        if(font)
            [btn.titleLabel setFont:font];
        
        UIColor *color = [attributes objectForKey:KDSearchBarScopeBarAttributeTextColor];
        if(color)
            [btn setTitleColor:color forState:state];
        
        UIImage *backgroundImage = [attributes objectForKey:KDSearchBarScopeBarAttributeBackgroundImage];
        if(backgroundImage) {
            [btn setBackgroundImage:backgroundImage forState:state];
        }
        
        UIImage *image = [attributes objectForKey:KDSearchBarScopeBarAttributeImage];
        if(image) {
            [btn setImage:image forState:state];
        }
    }
}

- (void)setScopeButtonTitles:(NSArray *)scopeButtonTitles {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [buttons_ removeAllObjects];
    
    NSUInteger count = scopeButtonTitles.count;
    
    
    if(!buttons_) {
        buttons_ = [[NSMutableArray alloc] initWithCapacity:count];
    }
    
    if(!buttonsBgView_) {
        buttonsBgView_ = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 7.5f, 10.0f)];
        buttonsBgView_.layer.cornerRadius = 5.0f;
        buttonsBgView_.layer.masksToBounds = YES;
        buttonsBgView_.layer.borderColor = RGBCOLOR(144, 143, 143).CGColor;
        buttonsBgView_.layer.borderWidth = 0.5f;
        buttonsBgView_.backgroundColor = [UIColor clearColor];
        [self addSubview:buttonsBgView_];
    }
    
    selectedScopeButtonIndex_ = NSNotFound;
    
    CGFloat    widthPerButton = CGRectGetWidth(buttonsBgView_.frame) / count;
    
    for(NSUInteger index = 0; index < count; index ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(index * widthPerButton, 0.0f, widthPerButton, CGRectGetHeight(buttonsBgView_.frame))];
        [btn setTitle:[scopeButtonTitles objectAtIndex:index] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //normal
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:RGBCOLOR(237, 237, 237)];
        //selected
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        
        [buttons_ addObject:btn];
        
        [buttonsBgView_ addSubview:btn];
    }
    
    [self setSelectedScopeButtonIndex:0];
}


- (void)buttonClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    [self setSelectedScopeButtonIndex:[buttons_ indexOfObject:btn]];
    
    if(delegate_ && [delegate_ respondsToSelector:@selector(kdSearchBarScopeBar:selectedScopeButtonIndexDidChange:)])
        [delegate_ kdSearchBarScopeBar:self selectedScopeButtonIndexDidChange:[buttons_ indexOfObject:btn]];
}

- (void)setSelectedScopeButtonIndex:(NSUInteger)selectedScopeButtonIndex {
    if(selectedScopeButtonIndex > [buttons_ count]) return;
    if(selectedScopeButtonIndex == selectedScopeButtonIndex_) return;
    
    UIButton *currentSelected = [buttons_ objectAtIndex:selectedScopeButtonIndex];
    if(currentSelected) {
        currentSelected.selected = YES;
        currentSelected.backgroundColor = RGBCOLOR(147, 150, 154);
    }
    
    if(selectedScopeButtonIndex_ != NSNotFound) {
        UIButton *lastSelected = [buttons_ objectAtIndex:selectedScopeButtonIndex_];
        if(lastSelected) {
            lastSelected.selected = NO;
            lastSelected.backgroundColor = RGBCOLOR(237, 237, 237);
        }
    }
    
    selectedScopeButtonIndex_ = selectedScopeButtonIndex;
}


@end
