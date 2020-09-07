//
//  KDDropDownView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDDropDownView.h"

@interface KDDropDownView ()

@property(nonatomic, retain) UIView *contentView;
@property(nonatomic, retain) UIView *maskView;

@end


@implementation KDDropDownView

@synthesize delegate=delegate_;

@dynamic backgroundImageView;
@synthesize contentView=contentView_;
@synthesize maskView=maskView_;

@synthesize showInKeyWindow=showInKeyWindow_;

- (void)setupDropDownView {
    // content view
    contentView_ = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:contentView_];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDropDownView];
    }
    
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    if(backgroundImageView_ != nil){
        backgroundImageView_.frame = self.bounds;
    }
    
    contentView_.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
}

- (void)setBackgroundImageView:(UIImageView *)backgroundImageView {
    if(backgroundImageView_ != backgroundImageView){
        if(backgroundImageView_ != nil){
            // remove deprecated background image view
            if(backgroundImageView_.superview != nil){
                [backgroundImageView_ removeFromSuperview];
            }
            
//            [backgroundImageView_ release];
        }
        
        backgroundImageView_ = backgroundImageView;// retain];
        
        if(backgroundImageView_ != nil){
            [self insertSubview:backgroundImageView_ atIndex:0x00];
            [self setNeedsLayout];
        }
    }
}

- (UIImageView *)backgroundImageView {
    return backgroundImageView_;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    UIImageView *imageView = nil;
    if(backgroundImage != nil){
        imageView = [[UIImageView alloc] initWithImage:backgroundImage];// autorelease];
        [imageView sizeToFit];
    }
    
    [self setBackgroundImageView:imageView];
}

- (void)showInWindow:(UIWindow *)window atPoint:(CGPoint)anchorPoint hasMaskView:(BOOL)hasMaskView animated:(BOOL)animated {
    showInKeyWindow_ = YES;
    
    [self dropDownViewWillPresent];
    
    if(delegate_ != nil && [delegate_ respondsToSelector:@selector(willPresentDropDownView:)]){
        [delegate_ willPresentDropDownView:self];
    }
    
    CGRect rect = CGRectZero;
    
    // setup mask view if need
    if(hasMaskView && maskView_ == nil){
        dismissingMaskView_ = NO;
        
        rect = CGRectMake(0.0, 0.0, window.frame.size.width, window.frame.size.height);
        maskView_ = [[UIView alloc] initWithFrame:rect];
        
        // vertical swipe gesture recognizer
        UISwipeGestureRecognizer *vSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeMaskView:)];
        vSwipe.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
        
        [maskView_ addGestureRecognizer:vSwipe];
//        [vSwipe release];
        
        // horizontal swipe gesture recognizer
        UISwipeGestureRecognizer *hSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeMaskView:)];
        hSwipe.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
        
        [hSwipe requireGestureRecognizerToFail:vSwipe];
        [maskView_ addGestureRecognizer:hSwipe];
//        [hSwipe release];
        
        // single tap gesture recognizer
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMaskView:)];
        tapGestureRecognizer.delegate = self;
        
        [tapGestureRecognizer requireGestureRecognizerToFail:hSwipe];
        [maskView_ addGestureRecognizer:tapGestureRecognizer];
//        [tapGestureRecognizer release];
        
        maskView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [window addSubview:maskView_];
    }
    
    rect = self.bounds;
    rect.origin.y = anchorPoint.y;
    CGFloat diff = anchorPoint.x - rect.size.width * 0.5;
    rect.origin.x = (diff < 8.0) ? 8.0 : diff;
    
    self.frame = rect;
    
    if(animated){
        self.alpha = 0.0;
    }
    
    [window addSubview:self];
    
    if(animated){
        [UIView animateWithDuration:0.25 
                         animations:^{
                             self.alpha = 1.0;
                         } 
                         completion:^(BOOL finished){
                             if(delegate_ != nil && [delegate_ respondsToSelector:@selector(didPresentDropDownView:)]){
                                 [delegate_ didPresentDropDownView:self];
                             }
                         }];
    }
}

- (void)shouldRemoveFromSuperView {
    [self removeFromSuperview];
    showInKeyWindow_ = NO;
    
    dismissingMaskView_ = NO;
}

- (void)dismiss:(BOOL)animated {
    [self dropDownViewWillDismiss];
    
    if(delegate_ != nil && [delegate_ respondsToSelector:@selector(willDismissDropDownView:)]){
        [delegate_ willDismissDropDownView:self];
    }
    
    if(maskView_ != nil){
        maskView_.userInteractionEnabled = NO;
        
        [maskView_ removeFromSuperview];
        //KD_RELEASE_SAFELY(maskView_);
    }
    
    if(animated){
        [UIView animateWithDuration:0.25 
                         animations:^{
                             self.alpha = 0.0;
                         } 
                         completion:^(BOOL finished){
                             if(delegate_ != nil && [delegate_ respondsToSelector:@selector(didDismissDropDownView:)]){
                                 [delegate_ didDismissDropDownView:self];
                             }
                             
                             [self shouldRemoveFromSuperView];
                         }];
        
    }else {
        [self shouldRemoveFromSuperView];
    }
}

- (void)didTapMaskView:(UIGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateRecognized){
        [self dismiss:YES];
    }
}

- (void)didSwipeMaskView:(UISwipeGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateRecognized){
        if(!dismissingMaskView_){
            dismissingMaskView_ = YES;
                
            // for iOS 4.3.3
            // The swipe gesture recognizer recognized state event will sned out again 
            // when call removeFromSuperview on it. So the responde method will be call twice.
            // So, Ignore second times
            [self dismiss:YES];
        }
    }
}

// The sub-classes override it if need
- (void)dropDownViewWillPresent {
    // do nothing
}

// The sub-classes override it if need
- (void)dropDownViewWillDismiss {
    // do nothing
}


//////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIGestureRecognizer delegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // If tapped on self, make resign tap event to next event responder
    CGPoint tp = [touch locationInView:touch.view];
    tp = [self convertPoint:tp fromView:touch.view];
    
    return CGRectContainsPoint(self.bounds, tp) ? NO : YES;
}

- (void)dealloc {
    delegate_ = nil;
    
    //KD_RELEASE_SAFELY(backgroundImageView_);
    //KD_RELEASE_SAFELY(contentView_);
    
    //KD_RELEASE_SAFELY(maskView_);
    
    //[super dealloc];
}

@end
