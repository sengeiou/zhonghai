//
//  KWILoadMoreVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/9/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWILoadMoreVCtrl.h"

@interface KWILoadMoreVCtrl ()

@property (retain, nonatomic) IBOutlet UIView *defaultV;
@property (retain, nonatomic) IBOutlet UIView *loadingV;
@property (retain, nonatomic) IBOutlet UIButton *loadBtn;
@property (retain, nonatomic) NSString *label;

@end

@implementation KWILoadMoreVCtrl
@synthesize defaultV;
@synthesize loadingV;
@synthesize loadBtn;
@synthesize label = _label;

+ (KWILoadMoreVCtrl *)vctrl
{
    KWILoadMoreVCtrl *vctrl = [[[self alloc] initWithNibName:@"KWILoadMoreVCtrl" bundle:nil] autorelease];
    return vctrl;
}

+ (KWILoadMoreVCtrl *)vctrlWithLabel:(NSString *)label
{
    KWILoadMoreVCtrl *vctrl = [self vctrl];
    vctrl.label = label;
    return vctrl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.label) {
        [self.loadBtn setTitle:self.label forState:UIControlStateNormal];    
    } else {
        self.label = [self.loadBtn titleForState:UIControlStateNormal];
    }
}

- (void)viewDidUnload
{
    [self setLoadingV:nil];
    [self setDefaultV:nil];
    [self setLoadBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc {
    [loadingV release];
    [defaultV release];
    [loadBtn release];
    [super dealloc];
}

#pragma mark -
- (void)setStateDefault
{
    self.defaultV.hidden = NO;
    self.loadingV.hidden = YES;
    self.loadBtn.enabled = YES;
    [self.loadBtn setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateNormal];
    [self.loadBtn setTitle:self.label forState:UIControlStateNormal];
}

- (void)setStateLoading
{
    self.defaultV.hidden = YES;
    self.loadingV.hidden = NO;
}

- (void)setStateNoMore
{
    self.defaultV.hidden = NO;
    self.loadingV.hidden = YES;
    self.loadBtn.enabled = NO;
    [self.loadBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.loadBtn setTitle:@"没了" forState:UIControlStateNormal];
}

- (BOOL)isAvailable
{
    return self.loadBtn.enabled;
}

- (IBAction)loadmoreBtnTapped:(id)sender
{
    [self setStateLoading];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWILoadMoreVCtrl.load" object:self];
}

- (void)trigger
{
    [self loadmoreBtnTapped:self.loadBtn];
}

@end
