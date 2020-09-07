//
//  KWITutorialVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 8/10/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWITutorialVCtrl.h"

//#import "SCPLocalKVStorage.h"

#import "KWIRootVCtrl.h"
#import "KDCommonHeader.h"

@interface KWITutorialVCtrl () <UIScrollViewDelegate>

@end

@implementation KWITutorialVCtrl
{
    IBOutlet UIScrollView *_scrollV;
    IBOutlet UIPageControl *_pgCtrl;    
    IBOutlet UIButton *_doneBtn;
}

+ (KWITutorialVCtrl *)vctrl
{
    return [[[self alloc] initWithNibName:self.description bundle:nil] autorelease];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGSize contentSize = _scrollV.frame.size;
    contentSize.width *= 4;
    _scrollV.contentSize = contentSize;
}

- (void)viewDidUnload
{
    [_pgCtrl release];
    _pgCtrl = nil;
    [_scrollV release];
    _scrollV = nil;
    [_doneBtn release];
    _doneBtn = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[SCPLocalKVStorage setObject:[NSNumber numberWithBool:YES] forKey:@"had_tutorial_v1.0.0_presented"];
    [[KDSession globalSession] saveProperty:@(YES) forKey:@"had_tutorial_v1.0.0_presented" storeToMemoryCache:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [_pgCtrl release];
    [_scrollV release];
    [_doneBtn release];
    [super dealloc];
}

#pragma mark
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pgCtrl.currentPage = ceil(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds));
}

- (IBAction)_onDoneBtnTapped:(id)sender 
{
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[KWIRootVCtrl curInst] showCommunitySelectionTutroial];
        }];
         
    } else {
        [[KWIRootVCtrl curInst] dismissModalViewControllerAnimated:YES];
        [[KWIRootVCtrl curInst] performSelector:@selector(showCommunitySelectionTutroial) withObject:nil afterDelay:0.5];
        
    }
}

@end
