//
//  KDInputAlertView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-1.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDInputAlertView.h"


////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDDefaultInputCenterView class


@interface KDDefaultInputCenterView ()

@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) HPGrowingTextView *textView;
@property (nonatomic, assign) CGFloat lastTextViewHeight;
@end


@implementation KDDefaultInputCenterView

@synthesize backgroundImageView=backgroundImageView_;
@synthesize textView=textView_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        
        backgroundImageView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addSubview:backgroundImageView_];
        
        textView_ = [[HPGrowingTextView alloc] initWithFrame:CGRectZero];
		textView_.editable = YES;
		textView_.internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView_.internalTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textView_.maxNumberOfLines = 6;
        textView_.minNumberOfLines = 1;
        textView_.internalTextView.internalInset = UIEdgeInsetsMake(-3.0f, 0.f, 3.0f, 0.f);
        
        textView_.scrollEnabled = NO;
        textView_.contentInset = UIEdgeInsetsZero;
		textView_.font = [UIFont systemFontOfSize:16];
		textView_.backgroundColor = [UIColor clearColor];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];// autorelease];
        bgView.tag  = 10001;
        bgView.backgroundColor = [UIColor whiteColor];
        [textView_ addSubview:bgView];
        [textView_ sendSubviewToBack:bgView];
        bgView.layer.cornerRadius = 5.0f;
        bgView.layer.masksToBounds = YES;
        bgView.layer.borderColor = RGBCOLOR(203.f, 203.f, 203.f).CGColor;
        bgView.layer.borderWidth= 0.6f;
        textView_.returnKeyType = UIReturnKeySend;
		
        textView_.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:textView_];
    }
    
    return self;
}

#define kLineHeight (float)30.f
- (void)layoutSubviews {
    [super layoutSubviews];
    //只需在未设置宽度活高度时，设置，其后高度由组件自行设置
    if (CGRectGetHeight(textView_.frame) == 0 || CGRectGetWidth(textView_.frame) == 0) {
        CGRect rect = self.frame;
        rect.origin.y = (CGRectGetHeight(self.frame) - kLineHeight) * 0.5f - 1.f;
        rect.origin.x = 10.f;
        rect.size.width = CGRectGetWidth(rect) - 20.f;
        textView_.frame = rect;
        textView_.contentInset = UIEdgeInsetsZero;
    }
    UIView *view = [textView_ viewWithTag:10001];
    CGRect frame = textView_.bounds;
    CGRect textFrame = textView_.frame;
    if (CGRectGetHeight(frame) <= 36.f) {
        frame.size.height = kLineHeight;
        frame.origin.y = 1.f;
        textFrame.origin.y = (CGRectGetHeight(self.frame) - kLineHeight) * 0.5f - 1.f;;
        textView_.frame = textFrame;
        textView_.internalTextView.internalInset = UIEdgeInsetsMake(-3.0f, 0.f, 3.0f, 0.f);
        [textView_.internalTextView setContentInset:UIEdgeInsetsMake(-3.0f, 0.f, 3.0f, 0.f)];
        self.lastTextViewHeight = CGRectGetHeight(textFrame);
    }else if (self.lastTextViewHeight != CGRectGetHeight(frame)){
        frame.size.height -= 8.f;
        textFrame.size.height -= 8.f;
        textFrame.origin.y = CGRectGetHeight(self.frame) - 9.f - textFrame.size.height;
        textView_.frame = textFrame;
        if (CGRectGetHeight(textView_.frame) + 8.f < textView_.maxHeight) {
            textView_.internalTextView.internalInset = UIEdgeInsetsMake(-4.5f, 0.f, 4.5f, 0.f);
            [textView_.internalTextView setContentInset:UIEdgeInsetsMake(-4.5f, 0.f, 4.5f, 0.f)];
        }
        self.lastTextViewHeight = CGRectGetHeight(textFrame);
    }
    view.frame = frame;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(backgroundImageView_);
    //KD_RELEASE_SAFELY(textView_);
    //[super dealloc];
}

@end


////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDInputAlertView class


@interface KDInputAlertView  ()

@property (nonatomic, retain) UIView *centerView;

@end


@implementation KDInputAlertView

@dynamic topView;
@dynamic leftView;
@synthesize centerView=centerView_;
@dynamic rightView;

@dynamic backgroundView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        leftView_ = nil;
        rightView_ = nil;
        
        [super.contentView addSubview:backgroundView_];
        
        // center view
        centerView_ = [[UIView alloc] initWithFrame:CGRectZero];
        [super.contentView addSubview:centerView_];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    CGRect rect = CGRectZero;
    CGFloat width = super.contentView.bounds.size.width;
    CGFloat height = super.contentView.bounds.size.height;
    
    CGFloat centerWidth = width;
    
    if (topView_ != nil) {
        topView_.frame = CGRectMake(0.0, offsetY, width, topView_.bounds.size.height);
        offsetY += topView_.bounds.size.height;
    }
    
    if(backgroundView_ != nil){
        backgroundView_.frame = CGRectMake(0.0, offsetY, width, height);
    }
    
    if(leftView_ != nil){
        rect = CGRectMake(10.0, offsetY, leftView_.bounds.size.width, height);
        leftView_.frame = rect;
        
        offsetX = leftView_.bounds.size.width;
        
        centerWidth -= offsetX;
    }
    
    if(rightView_ != nil){
        rect = CGRectMake(width - rightView_.bounds.size.width - 10, offsetY, rightView_.bounds.size.width, height);
        rightView_.frame = rect;
        
        centerWidth -= rect.size.width;
    }
    
    centerView_.frame = CGRectMake(offsetX, offsetY, centerWidth, height);
}


////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Setter and Getter methods

- (void)setTopView:(UIView *)topView {
    if(topView_ != topView){
        if(topView_ != nil){
            if(topView_.superview != nil){
                [topView_ removeFromSuperview];
            }
            
//            [topView_ release];
        }
        
        topView_ = topView ;//retain];
        
        if(topView_ != nil){
            [super.contentView addSubview:topView_];
        }
        
        [self setNeedsLayout];
    }
}

- (UIView *)topView {
    return topView_;
}

- (void)setLeftView:(UIView *)leftView {
    if(leftView_ != leftView){
        if(leftView_ != nil){
            if(leftView_.superview != nil){
                [leftView_ removeFromSuperview];
            }
            
//            [leftView_ release];
        }
        
        leftView_ = leftView;// retain];
        
        if(leftView_ != nil){
            [super.contentView addSubview:leftView_];
        }
        
        [self setNeedsLayout];
    }
}

- (UIView *)leftView {
    return leftView_;
}

- (void)setRightView:(UIView *)rightView {
    if(rightView_ != rightView){
        if(rightView_ != nil){
            if(rightView_.superview != nil){
                [rightView_ removeFromSuperview];
            }
            
//            [rightView_ release];
        }
        
        rightView_ = rightView ;//retain];
        
        if(rightView_ != nil){
            [super.contentView addSubview:rightView_];
        }
        
        [self setNeedsLayout];
    }
}

- (UIView *)rightView {
    return rightView_;
}

- (void)setBackgroundView:(UIImageView *)backgroundView {
    if(backgroundView_ != backgroundView){
        if(backgroundView_ != nil){
            if(backgroundView_.superview != nil){
                [backgroundView_ removeFromSuperview];
            }
//            [backgroundView_ release];
        }
        
        backgroundView_ = backgroundView;// retain];
        
        if(backgroundView_ != nil){
            [super.contentView addSubview:backgroundView_];
        }
        
        [self setNeedsLayout];
    }
}

- (UIImageView *)backgroundView {
    return backgroundView_;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(topView_);
    //KD_RELEASE_SAFELY(leftView_);
    //KD_RELEASE_SAFELY(centerView_);
    //KD_RELEASE_SAFELY(rightView_);
    
    //KD_RELEASE_SAFELY(backgroundView_);
    
    //[super dealloc];
}

@end
