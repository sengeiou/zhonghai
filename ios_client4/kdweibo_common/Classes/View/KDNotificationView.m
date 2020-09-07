//
//  KDNotificationView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-03.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KDNotificationView.h"

#define KD_NOTIFICATION_VIEW_ANIMATION_DURATION		0.25

static KDNotificationView * globalNotificationView_ = nil;


//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDNotificationRenderView class

@interface KDNotificationRenderView : UIView {
@private
    KDNotificationView *_notificationView;  // weak reference
    
    UIImageView *bgImageView_;
    UIImageView *typeImageView_;
    UILabel *messageLabel_;
    
    UIEdgeInsets contentEdgeInsets_;
}

@property (nonatomic, assign) KDNotificationView *notificationView;

@property (nonatomic, retain, readonly) UIImageView *bgImageView;
@property (nonatomic, retain, readonly) UILabel *messageLabel;
@property (nonatomic, retain, readonly) UIImageView *typeImageView;

@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

- (void)changeToBackgroundImage:(UIImage *)image;

@end



@implementation KDNotificationRenderView

@synthesize notificationView=notificationView_;
@synthesize bgImageView=bgImageView_;
@synthesize messageLabel=messageLabel_;
@synthesize typeImageView=typeImageView_;

@synthesize contentEdgeInsets=contentEdgeInsets_;

- (void)setupNotificationRenderView {
    // background image view
    [self changeToBackgroundImage:nil];
    
    // notification type image
    typeImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:typeImageView_];
    
    // message label
    messageLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    messageLabel_.backgroundColor = [UIColor clearColor];
    messageLabel_.font = [UIFont systemFontOfSize:14.0];
    messageLabel_.textColor = [UIColor whiteColor];
    messageLabel_.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:messageLabel_];
}

- (id)initWithFrame:(CGRect)frame notificationView:(KDNotificationView *)notificationView {
    self = [super initWithFrame:frame];
    if(self){
        notificationView_ = notificationView;
        contentEdgeInsets_ = UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0);
        
        [self setupNotificationRenderView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    
    if (bgImageView_ != nil && bgImageView_.image != nil) {
        bgImageView_.frame = self.bounds;
    }
    
    CGFloat offsetX = contentEdgeInsets_.left;
    CGFloat offsetY = contentEdgeInsets_.top;
    
    if(typeImageView_.image != nil){
		rect = typeImageView_.bounds;
		rect = CGRectMake(offsetX, floorf((self.bounds.size.height - rect.size.height) * 0.5), rect.size.width, rect.size.height);
        typeImageView_.frame = rect;
        
        offsetX = rect.origin.x + rect.size.width + 5.0;
    }
    
    messageLabel_.frame = CGRectMake(offsetX, offsetY, self.bounds.size.width - offsetX - contentEdgeInsets_.right, 
									 self.bounds.size.height - contentEdgeInsets_.top - contentEdgeInsets_.bottom);
}

- (void)changeToBackgroundImage:(UIImage *)image {
    UIColor *color = nil;
    CGFloat alpha = 1.0;
    CGFloat cornerRadius = 0.0;
    if (image != nil) {
        color = [UIColor clearColor];
        
        if (bgImageView_ == nil) {
            bgImageView_ = [[UIImageView alloc] initWithImage:image];
             
            [self insertSubview:bgImageView_ atIndex:0x00];
        }
        
    } else {
        color = [UIColor blackColor];
        alpha = 0.8;
        cornerRadius = 5.0;
    }
    
    self.backgroundColor = color;
    self.layer.cornerRadius = cornerRadius;
    self.alpha = alpha;
}

- (void)dealloc {
    _notificationView = nil;
    
    //KD_RELEASE_SAFELY(bgImageView_);
    //KD_RELEASE_SAFELY(typeImageView_);
    //KD_RELEASE_SAFELY(messageLabel_);
    
    //[super dealloc];
}

@end


//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDNotificationView class


@implementation KDNotificationView

@dynamic message;
@dynamic messageLabel;

@synthesize type=type_;
@synthesize visibleTimeInterval=visibleTimeInterval_;

@synthesize marginEdgeInsets=marginEdgeInsets_;
@dynamic contentEdgeInsets;

- (void) setupNotificationView {
    dismissing_ = NO;
    
    type_ = KDNotificationViewTypeNormal;
    visibleTimeInterval_ = 2.0;
    contentSize_ = CGSizeZero;
    
    marginEdgeInsets_ = UIEdgeInsetsMake(0.0, 0.0, 60.0, 0.0); // default margin edge insets
    
    renderView_ = [[KDNotificationRenderView alloc] initWithFrame:CGRectZero notificationView:self];
    [self addSubview:renderView_];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupNotificationView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame type:(KDNotificationViewType)type visibleTimeInterval:(NSTimeInterval)visibleTimeInterval {
    self = [self initWithFrame:frame];
    if (self) {
        type_ = type;
        visibleTimeInterval_ = visibleTimeInterval;    
    }
    
    return self;
}

+ (id)defaultMessageNotificationView {
    if(globalNotificationView_ == nil){
        globalNotificationView_ = [[KDNotificationView alloc] initWithFrame:CGRectZero];
    }
    
    return globalNotificationView_;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    renderView_.frame = self.bounds;
}

- (CGSize)stageContentSize {
    return CGSizeMake(240.0, 160.0);
}

- (void)calculateContentSize {
    NSString *message = self.message;
    CGSize size = CGSizeZero;
    if(message != nil){
        size = [message sizeWithFont:renderView_.messageLabel.font constrainedToSize:[self stageContentSize]];
		CGFloat pointSize = [renderView_.messageLabel.font pointSize];
		
        renderView_.messageLabel.numberOfLines = floor(size.height / pointSize) + 1;
    }
    
    if(renderView_.typeImageView.image != nil){
        size.width += renderView_.typeImageView.image.size.width + 5.0;
        
        if(size.height < renderView_.typeImageView.image.size.height)
            size.height = renderView_.typeImageView.image.size.height; 
    }
    
    UIEdgeInsets edgeInsets = renderView_.contentEdgeInsets;
    size.width += (edgeInsets.left + edgeInsets.right);
    size.height += (edgeInsets.top + edgeInsets.bottom);
    
	if(size.width < 160.0)
		size.width = 160.0;
	
    contentSize_ = size;
}

- (void)setMessage:(NSString *)message {
    renderView_.messageLabel.text = message;
}

- (NSString *)message {
    return renderView_.messageLabel.text;
}

- (UILabel *)messageLabel {
    return renderView_.messageLabel;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    renderView_.contentEdgeInsets = contentEdgeInsets;
}

- (UIEdgeInsets)contentEdgeInsets {
    return renderView_.contentEdgeInsets;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    [renderView_ changeToBackgroundImage:backgroundImage];
    [self setNeedsLayout];
}

- (void)invalidVisibleTimer {
    if(visibleTimer_ != nil){
        [visibleTimer_ invalidate];
        visibleTimer_ = nil;
    }
}

- (void)restartVisibleTimer {
	[self invalidVisibleTimer];
	visibleTimer_ = [NSTimer scheduledTimerWithTimeInterval:visibleTimeInterval_ target:self selector:@selector(visibleTimerFire:) userInfo:nil repeats:NO];
}

- (void)visibleTimerFire:(NSTimer *)timer {
    [self invalidVisibleTimer];
    
    [self dismiss];
}

- (void)setVisibleTimeInterval:(NSTimeInterval)visibleTimeInterval {
    if(visibleTimeInterval_-0.1 < visibleTimeInterval || visibleTimeInterval_+0.1 > visibleTimeInterval){
        visibleTimeInterval_ = visibleTimeInterval;
        if(visibleTimeInterval_ < 0.01)
            visibleTimeInterval_ = 0.5;
        
        if(self.superview != nil)
			[self restartVisibleTimer];
    }
}

- (void)setType:(KDNotificationViewType)type {
    if(type_ != type){
        type_ = type;
        
        NSString *imageName = nil;
        if(KDNotificationViewTypeInfo == type_){
            imageName = @"notification_info.png";
            
        }else if(KDNotificationViewTypeWarning == type_){
            imageName = @"warning_yellow.png";
            
        }else if(KDNotificationViewTypeError == type_){
            imageName = @"warning_red.png";
        }
        
		UIImage *image = nil;
        if(imageName != nil){
            image = [UIImage imageNamed:imageName];
			renderView_.typeImageView.bounds = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
		}
		
		renderView_.typeImageView.image = image;
	}
}

- (void)adjustNotificationViewFrame {
    CGFloat offsetX = floorf((self.superview.bounds.size.width - contentSize_.width)*0.5) + marginEdgeInsets_.left - marginEdgeInsets_.right;
    CGFloat offsetY = floorf(self.superview.bounds.size.height - contentSize_.height) + marginEdgeInsets_.top - marginEdgeInsets_.bottom;
    
    self.frame = CGRectMake(offsetX, offsetY, contentSize_.width, contentSize_.height);
}

- (void)showInView:(UIView *)inView message:(NSString *)message type:(KDNotificationViewType)type {
    if(message == nil || inView == nil) return;
    
    self.type = type;
    self.message = message;
    
    [self showInView:inView];
}

// dynamic calculate content size and adjust the frame
- (void)showInView:(UIView *)inView {
    [self calculateContentSize];
	
	if(self.superview == nil){
        self.alpha = 0.0;
//		self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        
        [inView addSubview:self];
        [self adjustNotificationViewFrame];
		
		[UIView animateWithDuration:KD_NOTIFICATION_VIEW_ANIMATION_DURATION animations:^{
			self.alpha = 1.0;
		}];
        
    }else {
        [self adjustNotificationViewFrame];
    }
	
    [self restartVisibleTimer];
}

- (void)showAsStaticInView:(UIView *)inView {
    if(inView == nil) return;
    
    if(self.superview != nil){
        [self removeFromSuperview];
    }
    
    self.alpha = 0.0;
    [inView addSubview:self];
    [UIView animateWithDuration:KD_NOTIFICATION_VIEW_ANIMATION_DURATION 
                     animations:^{
                        self.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         [self restartVisibleTimer];
                     }];
}

- (void)didDismiss {
    if(self.superview != nil)
        [self removeFromSuperview];
    
    if(self == globalNotificationView_){
//        [globalNotificationView_ release];
        globalNotificationView_ = nil;
    }
    
    dismissing_ = NO;
}

- (void)dismiss {
    if(dismissing_) return;
    
    dismissing_ = YES;
    
    [UIView animateWithDuration:KD_NOTIFICATION_VIEW_ANIMATION_DURATION 
                     animations:^{
                         self.alpha = 0.0;
                     } 
                     completion:^(BOOL finished){
                         [self didDismiss];
                     }];
}


////////////////////////////////////////////////////////////////////////////////


- (void)dealloc {
    [self invalidVisibleTimer];
    
    //KD_RELEASE_SAFELY(renderView_);
    
    //[super dealloc];
}

@end



