#import "StatusBarOverlay.h"
void mt_dispatch_sync_on_main_thread(dispatch_block_t block);

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMinimumMessageVisibleTime				0.4f
#define kNextStatusAnimationDuration			0.6f
#define kAppearAnimationDuration				0.5f
#define kStatusLabelSize				13.f
#define kWidthSmall						26.f

@interface StatusBarOverlay ()
@property (nonatomic, strong) UIImageView *statusBarBackgroundImageView;
@property (nonatomic, strong) UILabel *statusLabel2;
@property (nonatomic, unsafe_unretained) UILabel *hiddenStatusLabel;
@property (unsafe_unretained, nonatomic, readonly) UILabel *visibleStatusLabel;
@property (assign, getter=isActive) BOOL active;
@property (nonatomic, readonly, getter=isReallyHidden) BOOL reallyHidden;
@property (nonatomic, strong) NSMutableArray *messageQueue;
@property (nonatomic, assign) BOOL forcedToHide;
@end

@implementation StatusBarOverlay
@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
 		statusBarFrame.size.height = 40;
        self.windowLevel = UIWindowLevelAlert;
        self.frame = CGRectMake(statusBarFrame.origin.x,  64 , CGRectGetWidth(statusBarFrame), CGRectGetHeight(statusBarFrame));
		self.alpha = 0.f;
		self.hidden = NO;
		_animation = StatusBarOverlayAnimationNone;
		_active= NO;
         _forcedToHide = NO;
         _backgroundView= [[UIView alloc] initWithFrame:statusBarFrame];
		_backgroundView.clipsToBounds = YES;
		_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _statusBarBackgroundImageView = [[UIImageView alloc] initWithFrame:_backgroundView.frame];
		_statusBarBackgroundImageView.backgroundColor = [UIColor blackColor];
		_statusBarBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubviewToBackgroundView:_statusBarBackgroundImageView];
        
        UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 26, 26)];
        leftImageView.image = [UIImage imageNamed:@"app_img_qiandao"];
        [self addSubviewToBackgroundView:leftImageView];
        
 		_statusLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(25, _backgroundView.frame.size.height,_backgroundView.frame.size.width - 35 - 50 , _backgroundView.frame.size.height-1.f)];
		_statusLabel2.shadowOffset = CGSizeMake(0.f, 1.f);
		_statusLabel2.backgroundColor = [UIColor clearColor];
		_statusLabel2.font = [UIFont boldSystemFontOfSize:kStatusLabelSize];
		_statusLabel2.textAlignment = NSTextAlignmentCenter;
		_statusLabel2.numberOfLines = 1;
        _statusLabel2.textColor = [UIColor whiteColor];
		_statusLabel2.lineBreakMode = NSLineBreakByTruncatingTail;
		_statusLabel2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self addSubviewToBackgroundView:_statusLabel2];
 		_hiddenStatusLabel= _statusLabel2;
		_messageQueue = [[NSMutableArray alloc] init];
        
        _backgroundView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewClicked:)];
        [_backgroundView addGestureRecognizer:tapGestureRecognizer];
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setImage:[UIImage imageNamed:@"autoSignIn_rightBtn"] forState:UIControlStateNormal];
        rightBtn.frame = CGRectMake(CGRectGetWidth(statusBarFrame)-30 , 7, 26, 26);
        [rightBtn addTarget:self action:@selector(whenRightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubviewToBackgroundView:rightBtn];
        
        [self addSubview:_backgroundView];
        self.userInteractionEnabled = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
    }
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationWillResignActiveNotification];
	delegate_ = nil;
}

- (void)addSubviewToBackgroundView:(UIView *)view {
	[self.backgroundView addSubview:view];
}

- (void)postMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    [self postMessage:message  duration:duration animated:animated immediate:NO];
}

- (void)postMessage:(NSString *)message  duration:(NSTimeInterval)duration animated:(BOOL)animated immediate:(BOOL)immediate {
    mt_dispatch_sync_on_main_thread(^{
        if (message.length == 0) {
            return;
        }
        
        NSDictionary *messageDictionaryRepresentation = [NSDictionary dictionaryWithObjectsAndKeys:message, kMTStatusBarOverlayMessageKey,
                                                          [NSNumber numberWithDouble:duration], kMTStatusBarOverlayDurationKey,
                                                         [NSNumber numberWithBool:animated],  kMTStatusBarOverlayAnimationKey,
                                                         [NSNumber numberWithBool:immediate], kMTStatusBarOverlayImmediateKey, nil];
        
        @synchronized (self.messageQueue) {
            [self.messageQueue insertObject:messageDictionaryRepresentation atIndex:0];
        }
        if (!self.active) {
            [self showNextMessage];
        }
    });
}

- (void)showNextMessage {
    if (self.forcedToHide) {
        return;
    }
    @synchronized(self.messageQueue) {
		if([self.messageQueue count] < 1) {
			self.active = NO;
			return;
		}
	}
    self.active = YES;
	NSDictionary *nextMessageDictionary = nil;
	@synchronized(self.messageQueue) {
		nextMessageDictionary = [self.messageQueue lastObject];
	}
	NSString *message = [nextMessageDictionary valueForKey:kMTStatusBarOverlayMessageKey];
	NSTimeInterval duration = (NSTimeInterval)[[nextMessageDictionary valueForKey:kMTStatusBarOverlayDurationKey] doubleValue];
	BOOL animated = [[nextMessageDictionary valueForKey:kMTStatusBarOverlayAnimationKey] boolValue];
	if (!self.reallyHidden && [self.visibleStatusLabel.text isEqualToString:message]) {
		@synchronized(self.messageQueue) {
            if (self.messageQueue.count > 0)
                [self.messageQueue removeLastObject];
		}
		[self showNextMessage];
		return;
	}
    
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    if (duration > 0.) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:duration];
    }
    if (self.reallyHidden) {
		self.visibleStatusLabel.text = @"";
        [UIView animateWithDuration:kAppearAnimationDuration
						 animations:^{
							 [self setHidden:NO useAlpha:YES];
						 }];
	}
    if (animated) {
         self.statusLabel2.text = message;
         self.statusLabel2.frame = CGRectMake(self.statusLabel2.frame.origin.x,
                                               64 ,
                                                  self.statusLabel2.frame.size.width,
                                                  self.statusLabel2.frame.size.height);
        [UIView animateWithDuration:kNextStatusAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.statusLabel2.frame = CGRectMake(self.statusLabel2.frame.origin.x,
                                                                  0,
                                                                  self.statusLabel2.frame.size.width,
                                                                  self.statusLabel2.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                            @synchronized(self.messageQueue) {
                                 if (self.messageQueue.count > 0)
                                     [self.messageQueue removeLastObject];
                             }

                             [self performSelector:@selector(showNextMessage) withObject:nil afterDelay:kMinimumMessageVisibleTime];
                         }];
    }else {
         self.visibleStatusLabel.text = message;
         @synchronized(self.messageQueue) {
            if (self.messageQueue.count > 0)
                [self.messageQueue removeLastObject];
        }
         [self performSelector:@selector(showNextMessage) withObject:nil afterDelay:kMinimumMessageVisibleTime];
    }
}

- (void)hide {
	self.statusLabel2.text = @"";
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
     [UIView animateWithDuration: kAppearAnimationDuration animations:^{
		[self setHidden:YES useAlpha:YES];
	} completion:^(BOOL finished) {}];
}

- (void)hideTemporary {
    self.forcedToHide = YES;
    [UIView animateWithDuration:kAppearAnimationDuration animations:^{
		[self setHidden:YES useAlpha:YES];
	}];
}

- (void)show {
    self.forcedToHide = NO;
    if (self.reallyHidden) {
        if (self.visibleStatusLabel.text.length > 0) {
            [UIView animateWithDuration:  kAppearAnimationDuration animations:^{
                [self setHidden:NO useAlpha:YES];
            }];
        }
        [self showNextMessage];
    }
}

- (UILabel *)visibleStatusLabel {
	if (self.hiddenStatusLabel != self.statusLabel2) {
		return self.statusLabel2;
	}
	return nil;
}

- (void)contentViewClicked:(UIGestureRecognizer *)gestureRecognizer {
		if ([self.delegate respondsToSelector:@selector(statusBarOverlayDidRecognizeGesture:)]) {
			[self.delegate statusBarOverlayDidRecognizeGesture:gestureRecognizer];
		}
    [self hide];
}

- (void)whenRightBtnClicked:(UIButton *)sender
{
    if([delegate_ respondsToSelector:@selector(statusBarOverlayDidBtnClicked:)])
    {
    [delegate_ statusBarOverlayDidBtnClicked:sender];
    }
    [self hide];
}

- (void)applicationWillResignActive:(NSNotification *)notifaction {
//    [self hideTemporary];
}

- (void)applicationDidBecomeActive:(NSNotification *)notifaction {
    [self show];
}

- (void)setHiddenUsingAlpha:(BOOL)hidden {
	[self setHidden:hidden useAlpha:YES];
}

- (void)setHidden:(BOOL)hidden useAlpha:(BOOL)useAlpha {
	if (useAlpha) {
		self.alpha = hidden ? 0.f : 0.8f;
	} else {
		self.hidden = hidden;
	}
}

- (BOOL)isReallyHidden {
	return self.alpha == 0.f || self.hidden;
}

+ (StatusBarOverlay *)sharedInstance {
    static dispatch_once_t pred;
    __strong static StatusBarOverlay *sharedOverlay = nil;
    dispatch_once(&pred, ^{ 
        sharedOverlay = [[StatusBarOverlay alloc] init];
    });
	return sharedOverlay;
}

-(BOOL)runningiOS7{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if (currSysVer.floatValue >= 7.0) {
        return YES;
    }
    return NO;
}
@end
void mt_dispatch_sync_on_main_thread(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}
