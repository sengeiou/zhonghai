//
//  KDLocationView.m
//  kdweibo
//
//  Created by Tan yingqi on 13-1-30.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//


#import "KDLocationView.h"

#define ICON_LEFT_MARGIN  14.0f
#define ICON_RIGHT_MARGIN 14.0f

#define TRIANGLE_LEFT_MARGIN 7.0f
#define TRIANGLE_RIGHT_MARGIN 10.0f

@interface KDLocationView()
@property(nonatomic,retain)UIImageView *backgroundImageView;
@property(nonatomic,retain)UIImageView *iconImageView;

@property(nonatomic,retain)UIImageView *triangleImageView;

@property(nonatomic,retain)UILabel *label;
@property(nonatomic,retain)UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic,retain)UILabel *noticeLabel;
@end

@implementation KDLocationView
@synthesize backgroundImageView = backgroundImageView_;
@synthesize iconImageView = iconImageView_;
@synthesize triangleImageView = triangleImageView_;

@synthesize label = label_;
@synthesize activityIndicatorView = activityIndicatorView_;
@synthesize noticeLabel = noticeLabel_;


//点击背景才有效
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!CGRectContainsPoint(backgroundImageView_.frame, point)) {
        return nil;
    }else {
        return [super hitTest:point withEvent:event];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"status_group_flag_bg"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
        backgroundImageView_ = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImageView_.image = image;
        backgroundImageView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:backgroundImageView_];
        
        iconImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location_icon"]];
        [self addSubview:iconImageView_];
        
        label_ = [[UILabel alloc] initWithFrame:CGRectZero];
        label_.font = [UIFont systemFontOfSize:13.0f];
        label_.textColor = MESSAGE_DATE_COLOR;
        label_.backgroundColor = [UIColor clearColor];
        label_.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:label_];
    
        
        triangleImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_group_flag_arrow"]];
        [self addSubview:triangleImageView_];
        
        activityIndicatorView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView_.frame = CGRectMake(10, 6, 15, 15);
        [self addSubview:activityIndicatorView_];
        activityIndicatorView_.hidesWhenStopped = YES;
        
        noticeLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(28, 8, 160, 12)];
        noticeLabel_.font = [UIFont systemFontOfSize:13];
        noticeLabel_.textColor = MESSAGE_NAME_COLOR;
        noticeLabel_.backgroundColor = [UIColor clearColor];
        
        [self addSubview:noticeLabel_];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [iconImageView_ sizeToFit];
    [label_ sizeToFit];
    [triangleImageView_ sizeToFit];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    
    CGRect frame = iconImageView_.frame;
    frame.origin.x = ICON_LEFT_MARGIN;
    frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame))*0.5;
    iconImageView_.frame = frame;

    
    frame = label_.frame;
    frame.origin.x = CGRectGetMaxX(iconImageView_.frame) + ICON_RIGHT_MARGIN;
    frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame))*0.5;
    frame.size.width = MIN(CGRectGetWidth(frame), width - (CGRectGetWidth(iconImageView_.frame) +
                                                           ICON_LEFT_MARGIN + ICON_RIGHT_MARGIN +
                                                            TRIANGLE_LEFT_MARGIN + CGRectGetWidth(triangleImageView_.frame)+
                                                           TRIANGLE_RIGHT_MARGIN));
    label_.frame = frame;
    
    
//    CGSize textSize = [label_.text sizeWithFont:label_.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, frame.size.height) lineBreakMode:NSLineBreakByTruncatingMiddle];
//    textSize.width = MAX(textSize.width, label_.frame.size.width);
//    textSize.width += CGRectGetMaxX(frame) +14.f + 7.f + 10 + CGRectGetWidth(triangleImageView_.frame);
//    frame = backgroundImageView_.frame;
//    frame.size.width = textSize.width;
//    backgroundImageView_.frame = frame;
    
    
    frame = triangleImageView_.frame;
    frame.origin.x = CGRectGetMaxX(label_.frame)+ TRIANGLE_LEFT_MARGIN;
    frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame))*0.5;
    triangleImageView_.frame = frame;
    
    frame = backgroundImageView_.frame;
    frame.size.height = CGRectGetHeight(self.bounds);
    frame.size.width = CGRectGetMaxX(triangleImageView_.frame) + TRIANGLE_RIGHT_MARGIN;
    backgroundImageView_.frame = frame;
    
   
    
}


- (void)hideMainView {
    backgroundImageView_.hidden = YES;
    iconImageView_.hidden = YES;
    triangleImageView_.hidden = YES;
    noticeLabel_.hidden = NO;
}

- (void)showMainView {
    backgroundImageView_.hidden = NO;
    iconImageView_.hidden = NO;
    triangleImageView_.hidden = NO;
    noticeLabel_.hidden = YES;
}

//- (void)startLocating {
//    
//}

- (void)stopIndicatorAnimating {
    if ([activityIndicatorView_ isAnimating]) {
        [activityIndicatorView_ stopAnimating];
    }
}

- (void)startIndicatorAnimating {
    if (![activityIndicatorView_ isAnimating]) {
        [activityIndicatorView_ startAnimating];
    }
}

- (void)setAddrText:(NSString *)text {
    [self stopIndicatorAnimating];
    [self showMainView];
     self.label.text = text;
    [self setNeedsLayout];
}

- (void)showErrowMessage {
    [self stopIndicatorAnimating];
    [self hideMainView];
     noticeLabel_.text = ASLocalizedString(@"KDLocationView_cannot_location");
}

- (void)showInitMessag {
    [self hideMainView];
    self.label.text = nil;
    noticeLabel_.text = ASLocalizedString(@"KDLocationView_init");
    [self startIndicatorAnimating];
}

- (void)showStartMessage {
    [self hideMainView];
    self.label.text = nil;
    noticeLabel_.text = ASLocalizedString(@"KDLocationView_get_location");
    [self startIndicatorAnimating];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(noticeLabel_);
    //KD_RELEASE_SAFELY(backgroundImageView_);
    //KD_RELEASE_SAFELY(iconImageView_);
    //KD_RELEASE_SAFELY(triangleImageView_);
    //KD_RELEASE_SAFELY(label_);
    //KD_RELEASE_SAFELY(activityIndicatorView_);
    //[super dealloc];
}

@end
