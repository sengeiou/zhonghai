//
//  KDErrorDisplayView.m
//  kdweibo_common
//
//  Created by shen kuikui on 12-9-19.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "KDErrorDisplayView.h"

static BOOL isShown = NO;

@implementation KDErrorDisplayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andErrorMessage:(NSString *)errorMsg {
    self = [self initWithFrame:frame];
    
    if(self) {
        UIView *bg = [[UIView alloc] initWithFrame:self.bounds];
        bg.backgroundColor = [UIColor blackColor];
        bg.alpha = 0.65f;
        
        [self addSubview:bg];
//        [bg release];
        
        UIImage *icon = [UIImage imageNamed:@"warning_icon.png"];
        
        CGSize iconSize = icon.size;
        
        CGRect imageRect = CGRectZero;
        
        UIFont *msgFont = [UIFont systemFontOfSize:14.0f];
        CGSize messageSize = [errorMsg sizeWithFont: msgFont constrainedToSize:CGSizeMake(frame.size.width - 10.0f, 300)];
        
        CGFloat padding = frame.size.height * 0.125f;
        
        imageRect.origin = CGPointMake((frame.size.width - iconSize.width) * 0.5f, frame.size.height * 0.5f - iconSize.height);
        
        imageRect.size = iconSize;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
        [imageView setImage:icon];
        [self addSubview:imageView];
//        [imageView release];
        
        CGRect messageRect = CGRectZero;
        
        messageRect.origin.y = imageRect.origin.y + imageRect.size.height + padding;

        messageRect.origin.x = 5.0f;
        
        messageRect.size = CGSizeMake(frame.size.width - 10.0f, messageSize.height);
        
        UILabel *msgLabel = [[UILabel alloc] initWithFrame:messageRect];
        msgLabel.font = msgFont;
        msgLabel.backgroundColor = [UIColor clearColor];
        msgLabel.textColor = [UIColor whiteColor];
        msgLabel.numberOfLines = 0;
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.text = errorMsg;
        
        [self addSubview:msgLabel];
//        [msgLabel release];
    }
    
    return self;
}

- (void)showInView:(UIView *)superView {
    [superView addSubview:self];
    self.alpha = 0;
    
    isShown = YES;
    
    [UIView animateWithDuration:0.5f animations:^(void) {
        self.alpha = 1.0f;
    }];
    
    [superView addSubview:self];
    [superView bringSubviewToFront:self];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
}

- (void)dismiss {
    isShown = NO;
    
    [UIView animateWithDuration:0.5f animations:^(void) {
        self.alpha = 0.0f;
    }completion:^(BOOL finished) {
        if(finished)
            [self removeFromSuperview];
    }];
}


+ (void)showErrorMessage:(NSString *)errorMsg inView:(UIView *)superView {
    
    if (isShown) return;
    
    //calculate the frame
//    CGRect superFrame = superView.frame;
//    
//    CGSize subSize = CGSizeMake(superFrame.size.width * 0.3f, superFrame.size.height * 0.3f);
//    
//    if(subSize.width < subSize.height) {
//        subSize.width = subSize.height * 4 / 3;
//    }
//
    CGSize  subSize = CGSizeMake(156, 156);
    CGPoint subOrigin = CGPointMake((superView.frame.size.width - subSize.width) * 0.5f, 135.0f);
    
    KDErrorDisplayView *nInstance = [[KDErrorDisplayView alloc] initWithFrame:(CGRect){subOrigin,subSize} andErrorMessage:errorMsg];
    
    nInstance.layer.cornerRadius = 5.0f;
    nInstance.layer.masksToBounds = YES;
    [nInstance setBackgroundColor:[UIColor clearColor]];
    
    [nInstance showInView:superView];
    
//    [nInstance release];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    //[super dealloc];
}

@end
