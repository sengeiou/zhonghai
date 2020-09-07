//
//  KDSendingStatusFailedMessagePromtView.m
//  kdweibo_common
//
//  Created by Tan Yingqi on 13-12-17.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDSendingStatusFailedMessagePromtView.h"
#import "KDDefaultViewControllerContext.h"

@interface KDSendingStatusFailedMessagePromtView ()
@property(nonatomic,retain)UILabel *messageLabel;
@property(nonatomic,retain)UIImageView *forwardImageView;
@property(nonatomic,retain)UIImageView *separatorView;
@property(nonatomic,retain)UIButton *deleteBtn;
@end

@implementation KDSendingStatusFailedMessagePromtView
@synthesize messageLabel = messageLabel_;
@synthesize forwardImageView = forwardImageView_;
@synthesize separatorView = separatorView_;
@synthesize deleteBtn = deleteBtn_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.bounds = CGRectMake(0, 0, 320, 42);
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage stretchableImageWithImageName:@"message_prompt_bg" resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 10, 5)]];
        backgroundView.frame = self.bounds;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroundView];
//        [backgroundView release];
        //UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
      
        
//        btn.backgroundColor = [UIColor clearColor];
//        btn.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//        [self addSubview:btn];
//        [btn addTarget:self action:@selector(mainBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTouched:)];
        [self addGestureRecognizer:gestureRecognizer];
//        [gestureRecognizer release];
        
        messageLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(16, 30, 190, 17)];
        messageLabel_.backgroundColor = [UIColor clearColor];
        messageLabel_.textColor = [UIColor whiteColor];
        messageLabel_.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:messageLabel_];
        
        forwardImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_prompt_forward"]];
        [self addSubview:forwardImageView_];
        
        separatorView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_prompt_separator"]];
        [self addSubview:separatorView_];
        
        deleteBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
        [deleteBtn_ setImage:[UIImage imageNamed:@"message_prompt_delete"] forState:UIControlStateNormal];
        [deleteBtn_ addTarget:self action:@selector(delegateBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn_];
        
    }
    return self;
}

- (void)selfTouched:(id)recognizer {
    [self performSelector:@selector(delegateBtnTapped:) withObject:nil afterDelay:0.5];
     [[KDDefaultViewControllerContext defaultViewControllerContext] showDraftListViewController:self];
   
}

- (void)delegateBtnTapped:(id)sender {
    [[KDSession globalSession] setUnsendedStatus:nil]; //置为空表示不会出现内容发送出错条。
    [self dismiss:NO];
}

- (void)setUserInfo:(NSDictionary *)userInfo {
    NSString *msg = [userInfo objectForKey:@"message"];
    messageLabel_.text = msg;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [messageLabel_ sizeToFit];
    [forwardImageView_ sizeToFit];
    CGRect frame = messageLabel_.bounds;
    frame.origin.x = 15;
    frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame))*0.5;
    messageLabel_.frame = frame;
    
    frame = forwardImageView_.bounds;
    frame.origin.x = CGRectGetMaxX(messageLabel_.frame) +27;
    frame.origin.y =(CGRectGetHeight(self.bounds) - CGRectGetHeight(frame))*0.5;
    forwardImageView_.frame = frame;
    
    frame = separatorView_.bounds;
    frame.origin.x = CGRectGetWidth(self.bounds)-CGRectGetWidth(frame) - CGRectGetHeight(self.bounds)-4;
    frame.origin.y = 0;
    frame.size.height = CGRectGetHeight(self.bounds);
    separatorView_.frame = frame;
    
    frame = deleteBtn_.bounds;
    
    frame.size = CGSizeMake(CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
    frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(frame);
    frame.origin.y = 0;
    deleteBtn_.frame = frame;
    
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(messageLabel_);
    //KD_RELEASE_SAFELY(forwardImageView_);
    //KD_RELEASE_SAFELY(separatorView_);
    //KD_RELEASE_SAFELY(deleteBtn_);
    //[super dealloc];
}


@end
