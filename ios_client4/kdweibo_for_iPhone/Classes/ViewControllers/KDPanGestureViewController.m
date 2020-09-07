//
//  KDPanGestureViewController.m
//  kdweibo
//
//  Created by bird on 14-1-6.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDPanGestureViewController.h"

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

@interface KDPanGestureViewController ()
{
    CGPoint startTouch;
    
    //weak
    UIImageView *lastScreenShotView;
    UIView *blackMask;
    
    NSMutableArray *screenShotsList;
    
    BOOL isMoving;
}
@property(nonatomic, retain) UIView *backgroundView;
@property(nonatomic, retain) NSMutableArray *screenShotsList;
@end

@implementation KDPanGestureViewController
@synthesize screenShotsList = screenShotsList;
@synthesize backgroundView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.screenShotsList = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
        
        UIPanGestureRecognizer *gest = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)] autorelease];
        [self.view addGestureRecognizer:gest];
        [self.screenShotsList addObject:[self capture]];
    
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.screenShotsList removeLastObject];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    [backgroundView removeFromSuperview];
    KD_RELEASE_SAFELY(backgroundView);
    KD_RELEASE_SAFELY(screenShotsList);
    
    [super dealloc];
}

- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
- (void)panned:(UIPanGestureRecognizer *)panned
{
    CGPoint curLocation = [panned locationInView:KEY_WINDOW];
    if(panned.state == UIGestureRecognizerStateBegan) {
        startTouch = curLocation;
        isMoving = NO;
    }else if(panned.state == UIGestureRecognizerStateCancelled | panned.state == UIGestureRecognizerStateEnded | panned.state == UIGestureRecognizerStateFailed) {
        if (curLocation.x - startTouch.x > 50)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                if(finished) {
                    [self.view removeFromSuperview];
                    if(self.backgroundView.superview) {
                        [self.backgroundView removeFromSuperview];
                    }
                    CGRect frame = self.view.frame;
                    frame.origin.x = 0;
                    self.view.frame = frame;
                    
                    isMoving = NO;
                }
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                if(finished) {
                    isMoving = NO;
                    if(self.backgroundView.superview) {
                        [self.backgroundView removeFromSuperview];
                    }
                }
            }];
        }
    }else {
        if(!isMoving) {
            if(curLocation.x - startTouch.x > 10) {
                isMoving = YES;
                
                if (!self.backgroundView)
                {
                    CGRect frame = self.view.window.frame;
                    
                    self.backgroundView = [[[UIView alloc]initWithFrame:CGRectMake(0,0,frame.size.width , frame.size.height)] autorelease];
                    self.backgroundView.backgroundColor = [UIColor blackColor];
                    blackMask = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)] autorelease];
                    blackMask.backgroundColor = [UIColor blackColor];
                    [self.backgroundView addSubview:blackMask];
                }
                
                if(!self.backgroundView.superview) {
                    self.backgroundView.frame = [UIScreen mainScreen].bounds;
                    [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
                }
                
                UIImage *lastScreenShot = [self.screenShotsList lastObject];
                if(lastScreenShotView) {
                    lastScreenShotView.image = lastScreenShot;
                }else {
                    lastScreenShotView = [[[UIImageView alloc]initWithImage:lastScreenShot] autorelease];
                }
                
                [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
            }
        }
        
        if(isMoving) {
            [self moveViewWithX:curLocation.x - startTouch.x];
        }
    }
}
- (void)moveViewWithX:(float)x
{
    x = MIN(320, x);
    x = MAX(0, x);
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float scale = (x/6400)+0.95;
    float alpha = 0.4 - (x/800);
    
    lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    blackMask.alpha = alpha;
    
}

@end
