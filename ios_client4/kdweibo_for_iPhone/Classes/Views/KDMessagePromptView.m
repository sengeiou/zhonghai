//
//  KDMessagePromptView.m
//  kdweibo_common
//
//  Created by Tan Yingqi on 13-12-17.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDMessagePromptView.h"

@implementation KDMessagePromptView

@synthesize userInfo = userInfo_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (void)showPromptViewInView:(UIView *)view tag:(NSInteger)tag userInfo:(NSDictionary *)info autoDismiss:(BOOL)autoDismiss {
       if (!view ||[view viewWithTag:tag]) {
          return;
       }
        KDMessagePromptView *promptView = [[[self class] alloc] initWithFrame:CGRectZero];
        promptView.tag = tag;
        promptView.userInfo = info;
        CGRect rect  = promptView.bounds;
        rect.size.width = ScreenFullWidth;//promptView.bounds.size.width;
        rect.origin.y = - rect.size.height;
    
        promptView.frame = rect;
    
        [view addSubview:promptView];
       [view bringSubviewToFront:promptView];
//        [promptView release];
        [UIView animateWithDuration:0.6f animations:^(void){
            CGRect frame = promptView.frame;
            frame.origin.y+=frame.size.height;
            promptView.frame = frame;
        }completion:^(BOOL finished) {
            //[self hidePromptView:promptView];
            if (autoDismiss) {
                //[self hide:)
                [promptView dismiss:YES];
            }
        }];
}

- (void)dismiss:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.6f animations:^(void) {
            CGRect frame = self.frame;
            frame.origin.y-=frame.size.height;
            self.frame = frame;
            
        }completion:^(BOOL finished) {
            if ([self superview]) {
                [self removeFromSuperview];
            }
        }];

    }else {
            DLog(@"remval....");
            [self removeFromSuperview];
    }
   
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(userInfo_);
    //[super dealloc];
}

@end
