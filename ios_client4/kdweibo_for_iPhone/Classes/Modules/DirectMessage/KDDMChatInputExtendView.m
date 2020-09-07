//
//  KDDMChatInputExtendView.m
//  kdweibo
//
//  Created by Tan Yingqi on 14-1-9.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDDMChatInputExtendView.h"
#import "UIButton+KDV6.h"

@implementation KDDMChatInputExtendView

@synthesize backgroundImageView=backgroundImageView_;
@synthesize checkBoxButton=checkBoxButton_;
@synthesize textLabel=textLabel_;
@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self setupDMChatInputExtendView];
        
         self.exclusiveTouch = YES;
    }
    
    return self;
}

- (void)setupDMChatInputExtendView {

    self.backgroundColor = [UIColor kdBackgroundColor2];//RGBACOLOR(247.f, 247.f, 247.f, 1.0);
    
    // check box button
    checkBoxButton_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    [checkBoxButton_ setImage:[UIImage imageNamed:@"choose-circle-o"] forState:UIControlStateNormal];
    [checkBoxButton_ setImage:[UIImage imageNamed:@"choose_circle_n"] forState:UIControlStateSelected];
    [checkBoxButton_ sizeToFit];
    
    [checkBoxButton_ addTarget:self action:@selector(checkBoxStateDidChange:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:checkBoxButton_];
    
    // text label
    textLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel_.backgroundColor = [UIColor clearColor];
    textLabel_.font = [UIFont systemFontOfSize:16.0];
    
   // textLabel_.text = NSLocalizedString(@"DM_SNED_MESSAGE_WITH_EMAIL", @"");
    
    [self addSubview:textLabel_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    backgroundImageView_.frame = self.bounds;
    
    CGFloat offsetX = 13.0;
    CGRect rect = checkBoxButton_.bounds;
    rect.origin.x = offsetX;
    //rect.origin.y = (self.bounds.size.height - rect.size.height) * 0.5;
    checkBoxButton_.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.height*0.7, rect.size.height*0.7);
    checkBoxButton_.center = CGPointMake(checkBoxButton_.center.x, self.frame.size.height/2);
    
    offsetX += rect.size.height*0.7 + 6.0;
    rect = CGRectMake(offsetX, 0.0, self.bounds.size.width - offsetX, self.bounds.size.height);
    textLabel_.frame = rect;
}

- (void)checkBoxStateDidChange:(UIButton *)btn {
    checkBoxButton_.selected = !checkBoxButton_.selected;
    if (delegate_ && [delegate_ respondsToSelector:@selector(checkButtonTapped:)]) {
        [delegate_ checkButtonTapped:btn];
    }
}

- (void)setChecked:(BOOL)checked {
    checkBoxButton_.selected = checked;
}

- (BOOL)checked {
    return checkBoxButton_.selected;
}

#pragma border delegate

- (CGFloat)borderWidth
{
    return 1.f;
}

- (UIColor *)borderColor
{
    return RGBCOLOR(174.f, 174.f, 174.f);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(backgroundImageView_);
    //KD_RELEASE_SAFELY(checkBoxButton_);
    //KD_RELEASE_SAFELY(textLabel_);
    
    //[super dealloc];
}

@end
