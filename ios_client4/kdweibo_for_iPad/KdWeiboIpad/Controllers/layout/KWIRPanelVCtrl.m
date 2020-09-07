//
//  KWIRPanelVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/20/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIRPanelVCtrl.h"

#import <QuartzCore/QuartzCore.h>

#import "Logging.h"

#import "UIDevice+KWIExt.h"
#import "SCPLocalKVStorage.h"

#import "KWIStatusVCtrl.h"
#import "KWIRootVCtrl.h"
#import "KWITutorialCardV.h"
#import "KDCommonHeader.h"

static const unsigned int _SCROLL_V_MARGIN = 0;
static const unsigned int _SCROLL_V_PADDING = 10;
static const unsigned int _CARD_WIDTH = 420;
static const unsigned int _SCORLL_V_WIDTH = _CARD_WIDTH + _SCROLL_V_PADDING * 2;
static const unsigned int _SCORLL_V_X_PORTRAIT_ADJUSTMENT = 18;

#pragma mark -

@interface KWIRPanelVCtrl () <UIScrollViewDelegate>
{
    BOOL isAdding_;
    BOOL isRemoving_;
}

@property (retain, nonatomic) NSMutableArray *pages;

@end

@implementation KWIRPanelVCtrl
{   
    UIScrollView *_scrollV;
    NSUInteger _curPgIdx;
    BOOL _stopAfterAnim;
    
    CGRect _rpanelFrame;
    CGRect _rpanelStandbyFrame;
    CGRect _scrollVFrame;
    CGSize _contentSize;
    CGRect _cardFrame;
    
    UIViewController *_curPgVCtrl;
    NSUInteger _offsetAtDraggingStart;
}

@synthesize pages = _pages;

#pragma mark -
- (BOOL)containsViewController:(UIViewController *)vc {
    return [self.pages containsObject:vc];
}
+ (KWIRPanelVCtrl *)rpanelWithFrame:(CGRect)frame rootVCtrl:(UIViewController *)vctrl animated:(BOOL)animated
{    
    KWIRPanelVCtrl *rpanel = [[[self alloc] initWithFrame:frame] autorelease];
    
    [rpanel pushViewControllerToRPanelVCtrol:vctrl animated:animated];
    
    return rpanel;
}

- (KWIRPanelVCtrl *)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {        
        self.pages = [NSMutableArray array];
        
        _rpanelFrame = frame;        
        self.view.frame = _rpanelFrame;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.view.backgroundColor = [UIColor clearColor];
        
        _scrollV = [[[UIScrollView alloc] initWithFrame:self.scrollVFrame] autorelease];
        _scrollV.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _scrollV.pagingEnabled = YES;
        _scrollV.directionalLockEnabled = YES;
        _scrollV.showsHorizontalScrollIndicator = NO;
        _scrollV.showsVerticalScrollIndicator = NO;
        _scrollV.clipsToBounds = NO;
        _scrollV.delegate = self;
    
        [self.view addSubview:_scrollV];
        
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc addObserver:self selector:@selector(_onStatusDeleted:) name:@"KWStatus.remove" object:nil];
        [dnc addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
        [dnc addObserver:self selector:@selector(_onOrientationWillChange:) name:@"UIInterfaceOrientationWillChange" object:nil];
        
        
        isAdding_ = NO;
        isRemoving_ = NO;
        //UIPinchGestureRecognizer *pgr = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_onPinch:)] autorelease];
        //[self.view addGestureRecognizer:pgr];
    }
    return self;
}

- (void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_pages release];    

    [super dealloc];
}

#pragma mark -

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor greenColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
}
- (void)pushViewControllerToRPanelVCtrol:(UIViewController<KWICardlikeVCtrl> *)vctrl animated:(BOOL)animated
{
    if(isRemoving_ || isAdding_) return;
    
    isAdding_ = YES;
    // drop all views in forward stack on push
    while (self.pages.count > _curPgIdx + 1) {
        UIViewController *_e = [self.pages lastObject];
        [_e.view removeFromSuperview];
        [self.pages removeObject:_e];
    }
    
    UIViewController *lastVCtrl = nil;
    if (self.pages.count) {
        lastVCtrl = [self.pages lastObject];
        
        if (lastVCtrl) {
            [vctrl shadowOff];
            
            if ([UIDevice isPortrait]) {
                CGRect frmInScrollV = lastVCtrl.view.frame;
              

                CGRect frmInRPanel = [self.view convertRect:frmInScrollV fromView:_scrollV];
                [self.view insertSubview:lastVCtrl.view belowSubview:_scrollV];
                lastVCtrl.view.frame = frmInRPanel;
            }
        }
    }
    
    [self.pages addObject:vctrl];
    _curPgIdx = self.pages.count - 1;
    vctrl.view.frame = [self _getCurCardFrame];
    
    if(self.pages.count <= 1)
    {
        vctrl.view.center = CGPointMake(vctrl.view.center.x + vctrl.view.frame.size.width, vctrl.view.center.y);
        vctrl.view.alpha = 0.0f;
    }
    
    _scrollV.contentSize = CGSizeMake(_SCORLL_V_WIDTH * (self.pages.count + 1), CGRectGetHeight(self.scrollVFrame));
    [_scrollV addSubview:vctrl.view];
    //[_scrollV setContentOffset:[self _getCurContentOffset] animated:(self.pages.count > 1)];
    [_scrollV setContentOffset:[self _getCurContentOffset] animated:animated?(self.pages.count>1):NO];
    if(self.pages.count <= 1) {
//        [_scrollV setContentOffset:[self _getCurContentOffset]];
        
        [UIView animateWithDuration:animated?0.65f:0.0f animations:^(void) {
            vctrl.view.center = CGPointMake(vctrl.view.center.x - vctrl.view.frame.size.width, vctrl.view.center.y);
            vctrl.view.alpha = 1.0f;
        }completion:^(BOOL isFinished) {
           if(isFinished)
               isAdding_ = NO;
        }];
    } else {
//        [UIView animateWithDuration:0.65f animations:^(void){
//            [_scrollV setContentOffset:[self _getCurContentOffset]];
//        }completion:^(BOOL finished) {
//            if(finished)
//                isAdding_ = NO;
//        }];
        isAdding_ = NO;
    }
     
}


- (void)_calculateFrames
{
    
    _rpanelStandbyFrame = _rpanelFrame;
    _rpanelStandbyFrame.origin.x = CGRectGetMaxX(_rpanelFrame);
    
    _scrollVFrame = CGRectMake((CGRectGetWidth(_rpanelFrame) - _SCORLL_V_WIDTH) / 2, 0, _SCORLL_V_WIDTH, CGRectGetHeight(_rpanelFrame));
    if ([UIDevice isPortrait]) {
        _scrollVFrame.origin.x += _SCORLL_V_X_PORTRAIT_ADJUSTMENT;
    }
    
    unsigned int cardHeight = CGRectGetHeight(_rpanelFrame) - 28;
    _cardFrame = CGRectMake(_SCROLL_V_PADDING, (CGRectGetHeight(_rpanelFrame) - cardHeight) / 2.0, _CARD_WIDTH, cardHeight);
    //_cardFrame = CGRectMake(_SCROLL_V_PADDING,0, _CARD_WIDTH, CGRectGetHeight(_rpanelFrame));

}

- (CGRect)_getCurCardFrame
{
    CGRect frame = self.cardFrame;
  
    frame.origin.x = _SCORLL_V_WIDTH * (_curPgIdx + 1) + _SCROLL_V_PADDING;
    return frame;
}

- (CGPoint)_getCurContentOffset
{
    CGPoint offset = self.scrollVFrame.origin;
    offset.x = _SCORLL_V_WIDTH * (_curPgIdx + 1);
    return offset;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
   
    [self _scorllViewDidEndScrolling:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{  
    [self _scorllViewDidEndScrolling:scrollView];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
}
- (void)_scorllViewDidEndScrolling:(UIScrollView *)scrollView
{
  

    _curPgIdx = floor(scrollView.contentOffset.x / _SCORLL_V_WIDTH);

    if (0 == _curPgIdx) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIRPanelVCtrl.empty" object:nil];
    } else {
        _curPgIdx -= 1;
    }
    
    if ([UIDevice isPortrait]) {
        /*for (UIViewController *pgVCtrl in self.pages) {
            if (1 > pgVCtrl.view.alpha) {
                pgVCtrl.view.alpha = 1;
            }
        }*/
        UIViewController *curVCtrl = [self.pages objectAtIndex:_curPgIdx];
        /*if (1 > curVCtrl.view.alpha) {
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 curVCtrl.view.alpha = 1;
                             } 
                             completion:^(BOOL finished) {
                                 //
                             }];
        }*/
        
        if (curVCtrl.view.superview != _scrollV) {
            [_scrollV insertSubview:curVCtrl.view atIndex:_curPgIdx];
            curVCtrl.view.frame = [self _getCurCardFrame];
        }
        
        UIViewController *lastPgVCtrl = [self.pages lastObject];
        while (lastPgVCtrl != curVCtrl) {
            [lastPgVCtrl.view removeFromSuperview];
            [self.pages removeObject:lastPgVCtrl];
            
            lastPgVCtrl = [self.pages lastObject];
        }
        
        CGSize contentSize = _scrollV.contentSize;
        contentSize.width = _SCORLL_V_WIDTH * (self.pages.count + 1);
        _scrollV.contentSize = contentSize;
        
        /*// in case last card not fully turned transparent
        if (0 < _curPgIdx) {
            UIViewController *lastVCtrl = [self.pages objectAtIndex:_curPgIdx - 1];
            if (lastVCtrl && lastVCtrl.view.superview != _scrollV) {
                lastVCtrl.view.alpha = 1;
                lastVCtrl.view.frame = [self.view convertRect:curVCtrl.view.frame fromView:_scrollV];
            }
        }*/
    }
    
   // if (![[SCPLocalKVStorage objectForKey:@"had_tutorial_card_v1.0.0_presented"] boolValue]) {
   
}

- (CGRect)scrollVFrame
{
    if (!CGRectGetWidth(_scrollVFrame)) {
        [self _calculateFrames];
    }
    
    return _scrollVFrame;
}

- (CGRect)cardFrame
{
    if (!CGRectGetWidth(_cardFrame)) {
        
      [self _calculateFrames];
    }

    return _cardFrame;
}

- (void)remove
{
    if(isAdding_ || isRemoving_) return;
    
    isRemoving_ = YES;
    // retain here and release in animate finish callback
    // as foundation animation block may retain `self` and relase at animation finish
    // this may cause zombie when super object release `self` while an animation ongoing
    [self retain];
    
    [UIView animateWithDuration:0.65f
                          delay:0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.frame = _rpanelStandbyFrame;
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         isRemoving_ = NO;
                         [self performSelector:@selector(release) withObject:nil afterDelay:0.0f];
                     }];
    
//    [UIView animateWithDuration:0.25f animations:^(void){
//        self.view.frame = _rpanelStandbyFrame;
////        self.view.alpha = 0;
//    }completion:^(BOOL finished){
//        if(finished) {
//            [self.view removeFromSuperview];
//            
//            isRemoving_ = NO;
//            [self release];
//        }
//    }];
    
}
- (void)popTopViewController:(UIViewController *)viewController {
    
    
}
- (void)removePage:(UIViewController *)toRemove animation:(BOOL)animaition
{
    
    void (^animationBlock)(void) = ^(void){
        CGRect frame = toRemove.view.frame;
        frame.origin.x = CGRectGetMaxX(frame);
        toRemove.view.frame = frame;

    };
    void (^finishedBlock)(void) = ^(void) {
        unsigned int idxRm = [self.pages indexOfObject:toRemove];
        [self.pages removeObject:toRemove];
        [toRemove.view removeFromSuperview];
        
        if (self.pages.count && idxRm <= self.pages.count - 1) {
            for (unsigned int idxAdj = idxRm; idxAdj <= self.pages.count - 1; idxAdj++) {
                CGRect frame = self.cardFrame;
                frame.origin.x = _SCORLL_V_WIDTH * (idxAdj + 1) + _SCROLL_V_PADDING;
                UIViewController *e = [self.pages objectAtIndex:idxAdj];
                e.view.frame = frame;
            }
            [_scrollV setContentOffset:[self _getCurContentOffset] animated:NO];
        }
        
        _scrollV.contentSize = CGSizeMake(_SCORLL_V_WIDTH * (self.pages.count + 1), CGRectGetHeight(self.scrollVFrame));
        
        if (0 == self.pages.count) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIRPanelVCtrl.empty" object:nil];
        }

    };
    if(animaition) {
//        float duration = animaition?0.5f:0.0f;
        [UIView animateWithDuration:0.5 animations:^{
//            CGRect frame = toRemove.view.frame;
//            frame.origin.x = CGRectGetMaxX(frame);
//            toRemove.view.frame = frame;
            animationBlock();
        }completion:^(BOOL finished) {
//            unsigned int idxRm = [self.pages indexOfObject:toRemove];
//            [self.pages removeObject:toRemove];
//            DLog(@"remove");
//            [toRemove.view removeFromSuperview];
//            
//            if (self.pages.count && idxRm <= self.pages.count - 1) {
//                for (unsigned int idxAdj = idxRm; idxAdj <= self.pages.count - 1; idxAdj++) {
//                    CGRect frame = self.cardFrame;
//                    frame.origin.x = _SCORLL_V_WIDTH * (idxAdj + 1) + _SCROLL_V_PADDING;
//                    UIViewController *e = [self.pages objectAtIndex:idxAdj];
//                    e.view.frame = frame;
//                }
//                [_scrollV setContentOffset:[self _getCurContentOffset] animated:NO];
//            }
//            
//            _scrollV.contentSize = CGSizeMake(_SCORLL_V_WIDTH * (self.pages.count + 1), CGRectGetHeight(self.scrollVFrame));
//            
//            if (0 == self.pages.count) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIRPanelVCtrl.empty" object:nil];
//            }
            finishedBlock();
            
        }];

    }
    else {
        animationBlock();
        finishedBlock();
    }
       
   }

- (void)_onStatusDeleted:(NSNotification *)note
{
    KDStatus *status = note.object;
    //unsigned int idx = 0;
    // two loop to avoid mutating self.pages while first loop
    NSMutableArray *vctrls2rm = [NSMutableArray arrayWithCapacity:self.pages.count];    
    for (UIViewController *vctrl in self.pages) {
        if ([vctrl isMemberOfClass:[KWIStatusVCtrl class]]) {
            if ([((KWIStatusVCtrl *)vctrl).data.statusId isEqualToString:status.statusId]) {
                [vctrls2rm addObject:vctrl];
            }
        }
        //idx++;
    }
    
    for (UIViewController *vctrl in vctrls2rm) {
        [self removePage:vctrl animation:NO];
    }
}

/*- (void)_onPinch:(UIPinchGestureRecognizer *)pgr
{
    if (UIGestureRecognizerStateEnded != pgr.state) { return; }
    
    if (0.8 < pgr.scale) { return; }
    
    if (_curPgIdx > self.pages.count - 1) { return; }+ (BOOL)isPortrait
    
    [self _removePage:[self.pages objectAtIndex:_curPgIdx]];
}*/
- (void)_onOrientationWillChange:(NSNotification *)note
{
    NSDictionary *uinf = note.userInfo;
    BOOL isPortrait = [[uinf objectForKey:@"isPortrait"] boolValue];
    double duration = [[uinf objectForKey:@"duration"] doubleValue];
    
    CGRect scrollFrm = _scrollV.frame;
    
    if (isPortrait) {
        scrollFrm.origin.x += _SCORLL_V_X_PORTRAIT_ADJUSTMENT;
        
        if (1 < self.pages.count) {
            UIViewController *curVCtrl = [self.pages objectAtIndex:_curPgIdx];
            CGRect frmInScrollV = curVCtrl.view.frame;
            CGRect frmInRPanel = [self.view convertRect:frmInScrollV fromView:_scrollV];
            frmInRPanel.origin.x += _SCORLL_V_X_PORTRAIT_ADJUSTMENT;
            
            NSUInteger idx = 0;
            for (UIViewController *pgVCtrl in self.pages) {
                if (idx < _curPgIdx) {
                    [self.view insertSubview:pgVCtrl.view belowSubview:_scrollV];
                    pgVCtrl.view.frame = frmInRPanel;
                    // or view content will be partly visible due to _SCORLL_V_X_PORTRAIT_ADJUSTMENT
                    pgVCtrl.view.hidden = YES;
                } else if (idx > _curPgIdx) {
                    [pgVCtrl.view removeFromSuperview];
                    [self.pages removeObject:pgVCtrl];
                }
                
                idx++;
            }
            
            CGSize contentSize = _scrollV.contentSize;
            contentSize.width = _SCORLL_V_WIDTH * (self.pages.count + 1);
            _scrollV.contentSize = contentSize;
        }
    } else {
        scrollFrm.origin.x -= _SCORLL_V_X_PORTRAIT_ADJUSTMENT;
        
        UIViewController *curPgVCtrl = self.pages.lastObject;
        for (UIViewController *pgVCtrl in self.pages) {
            // or view content will be partly visible due to _SCORLL_V_X_PORTRAIT_ADJUSTMENT
            if (pgVCtrl != curPgVCtrl) {
                pgVCtrl.view.hidden = YES;
            }
        }
    }
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _scrollV.frame = scrollFrm;
                     } 
                     completion:^(BOOL finished) {
                         //
                     }];
}

- (void)_onOrientationChanged:(NSNotification *)note
{
   // _rpanelFrame.size.height = CGRectGetHeight(KWIRootVCtrl.curInst.view.frame);
    _rpanelFrame.size.height = [[UIScreen mainScreen]bounds].size.height - 20;
    [self _calculateFrames];
    CGSize scrollVSize = _scrollV.contentSize;
    scrollVSize.height = CGRectGetHeight(_scrollVFrame);
    _scrollV.contentSize = scrollVSize;
    
    if ([UIDevice isPortrait]) {
        //CGRect scrollFrm = _scrollV.frame;
        //scrollFrm.origin.x += _SCORLL_V_X_PORTRAIT_ADJUSTMENT;
        //_scrollV.frame = scrollFrm;
        
        for (UIViewController *pgVCtrl in self.pages) {
            pgVCtrl.view.hidden = NO;
        }
        
    } else {
        //CGRect scrollFrm = _scrollV.frame;
        //scrollFrm.origin.x -= _SCORLL_V_X_PORTRAIT_ADJUSTMENT;
        //_scrollV.frame = scrollFrm;
        
        NSUInteger idx = 0;
        for (UIViewController *pgVCtrl in self.pages) {
            if (pgVCtrl.view.superview != _scrollV) {
                [_scrollV addSubview:pgVCtrl.view];
                CGRect cardFrame = pgVCtrl.view.frame;
                cardFrame.origin.x = _SCORLL_V_WIDTH * (idx + 1) + _SCROLL_V_PADDING;
                pgVCtrl.view.frame = cardFrame;
                pgVCtrl.view.hidden = NO;
                
                if (1 > pgVCtrl.view.alpha) {
                    pgVCtrl.view.alpha = 1;
                }
            }
            
            idx++;
        }
    }
}

- (UIViewController *)rootCardVCtrl
{
    if (self.pages.count) {
        return [self.pages objectAtIndex:0];
    } else {
        return nil;
    }
}

- (UIViewController *)topCardVCtrl
{
    if(self.pages.count) {
        return [self.pages lastObject];
    } else {
        return nil;
    }
}

- (BOOL)isAnimating
{
    return (isAdding_ || isRemoving_);
}

@end
