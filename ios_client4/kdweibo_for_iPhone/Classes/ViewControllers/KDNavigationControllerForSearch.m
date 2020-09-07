//
//  KDNavigationControllerForSearch.m
//  kdweibo
//
//  Created by shen kuikui on 13-1-10.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDNavigationControllerForSearch.h"
#import "KDSearchViewControllerNew.h"
#import <QuartzCore/QuartzCore.h>

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

@interface KDNavigationControllerForSearch ()
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;  //weak refrence;
    UIView *blackMask;
    
    NSMutableArray *screenShotsList;
}
//
@property(nonatomic, retain) UIView *backgroundView;
@property(nonatomic, retain) NSMutableArray *screenShotsList;

@end

@implementation KDNavigationControllerForSearch

@synthesize backgroundView;
@synthesize screenShotsList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        screenShotsList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

- (void)dealloc{
//    [screenShotsList release];
    
    [backgroundView removeFromSuperview];
//    [backgroundView release];
    
    
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.hidesBottomBarWhenPushed = YES;
    
    if([self viewControllers].count > 0) {
        UIPanGestureRecognizer *gest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];//／／ autorelease];
        [viewController.view addGestureRecognizer:gest];
        [self.screenShotsList addObject:[self capture]];
    }
    
    
    [self setupNavigationItem:viewController];
    [KDWeiboAppDelegate setExtendedLayout:viewController];
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [self.screenShotsList removeLastObject];
    
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    [self.screenShotsList removeAllObjects];
    
    return [super popToRootViewControllerAnimated:animated];
}

- (void)swipeAction:(UISwipeGestureRecognizer *)gest {
    if(gest.direction == UISwipeGestureRecognizerDirectionRight) {
        if(self.viewControllers.count > 1) {
            [self popViewControllerAnimated:YES];
        }
    }
}

- (void)setupNavigationItem:(UIViewController *)viewController {
    UIImage *image = [UIImage imageNamed:@"nav_bar_back_btn_bg.png"];
    UIImage *highlightImage = [UIImage imageNamed:@"nav_bar_back_btn_bg_highlight"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    UIBarButtonItem *leftItem  = [[UIBarButtonItem alloc] initWithCustomView:button];// autorelease];
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //song.wang 2013-12-26

    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];// autorelease];
    negativeSpacer.width = kLeftNegativeSpacerWidth;
    viewController.navigationItem.leftBarButtonItems = [NSArray
                                                        arrayWithObjects:negativeSpacer,leftItem, nil];
}

- (void)goBack:(id)sender {
    [self popViewControllerAnimated:YES];
}

- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)moveViewWithX:(float)x
{
    x = MIN(ScreenFullWidth, x);
    x = MAX(0, x);
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float scale = (x/6400)+0.95;
    float alpha = 0.4 - (x/800);
    
    lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    blackMask.alpha = alpha;
    
}

- (void)panned:(UIPanGestureRecognizer *)panned
{
    CGPoint curLocation = [panned locationInView:KEY_WINDOW];
    if(panned.state == UIGestureRecognizerStateBegan) {
        startTouch = curLocation;
    }else if(panned.state == UIGestureRecognizerStateCancelled | panned.state == UIGestureRecognizerStateEnded | panned.state == UIGestureRecognizerStateFailed) {
        if (curLocation.x - startTouch.x > 50)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:ScreenFullWidth];
            } completion:^(BOOL finished) {
                if(finished) {
                    if([self viewControllers].count == 2) {
                        UIViewController *firstViewController = [[self viewControllers] objectAtIndex:0];
                        if([firstViewController isMemberOfClass:[KDSearchViewControllerNew class]]) {
                            [(KDSearchViewControllerNew *)firstViewController setIsReturnByGesture:YES];
                        }
                    }
                    [self popViewControllerAnimated:NO];
                    CGRect frame = self.view.frame;
                    frame.origin.x = 0;
                    self.view.frame = frame;
                }
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            }];
        }
    }else {
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];//autorelease];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];// autorelease];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];// autorelease];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
        [self moveViewWithX:curLocation.x - startTouch.x];
    }
}

@end
