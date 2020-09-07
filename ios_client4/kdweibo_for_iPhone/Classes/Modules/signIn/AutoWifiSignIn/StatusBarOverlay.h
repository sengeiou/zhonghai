#import <UIKit/UIKit.h>

typedef enum StatusBarOverlayAnimation {
	StatusBarOverlayAnimationNone,
	StatusBarOverlayAnimationShrink,
	StatusBarOverlayAnimationFallDown
} StatusBarOverlayAnimation;

#define kMTStatusBarOverlayMessageKey			@"MessageText"
#define kMTStatusBarOverlayDurationKey			@"MessageDuration"
#define kMTStatusBarOverlayAnimationKey			@"MessageAnimation"
#define kMTStatusBarOverlayImmediateKey			@"MessageImmediate"
@protocol StatusBarOverlayDelegate;
@interface StatusBarOverlay : UIWindow

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) StatusBarOverlayAnimation animation;
@property (nonatomic, unsafe_unretained) id<StatusBarOverlayDelegate> delegate;
+ (StatusBarOverlay *)sharedInstance;
- (void)postMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated;
- (void)hide;
- (void)hideTemporary;
- (void)show;
@end

@protocol StatusBarOverlayDelegate <NSObject>
@optional
- (void)statusBarOverlayDidRecognizeGesture:(UIGestureRecognizer *)gestureRecognizer;
- (void)statusBarOverlayDidBtnClicked:(id)sender;
@end
