//
//  KDPicturePickedPreviewViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 13-6-4.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDPicturePickedPreviewViewController.h"
#import "UIButton+Additions.h"
@interface KDPicturePickedPreviewViewController ()

@end

@implementation KDPicturePickedPreviewViewController
@synthesize imageView = imageView_;
@synthesize toobar = toobar_;
@synthesize image = image_;
@synthesize delegate = delegate_;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.image = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    CGRect frame = self.view.bounds;
    frame.size.height -=44;
    imageView_ = [[UIImageView alloc] initWithFrame:frame];
    imageView_.contentMode = UIViewContentModeScaleAspectFit;
    imageView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:imageView_];
    
    toobar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView_.frame), self.view.bounds.size.width, 44)];
    toobar_.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:toobar_];
    
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];// autorelease];
    
//    // done
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    backBtn.frame = CGRectMake(0.0, 5.0, 60.0, 30.0);
//    [backBtn addImageWithName:@"segment_black_button_bg.png" forState:UIControlStateNormal isBackground:YES];
//    [backBtn addImageWithName:@"segment_black_button_highlighted_bg.png" forState:UIControlStateHighlighted isBackground:YES];
//    
//    [backBtn setTitle:ASLocalizedString(@"Global_Cancel")forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
     UIBarButtonItem *cancleBtnItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Cancel")style:UIBarButtonItemStyleBordered  target:self action:@selector(backBtnTapped:)];
    
    // title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 240.0, 40.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = ASLocalizedString(@"KDPicturePickedPreviewViewController_Preview");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];// autorelease];
//    [titleLabel release];
    

    UIBarButtonItem *actionBtnItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDPicturePickedPreviewViewController_Use")style:UIBarButtonItemStyleDone  target:self action:@selector(actionBtnTapped:)];
    toobar_.items = [NSArray arrayWithObjects:cancleBtnItem,// autorelease],
                        flexibleSpaceItem, titleItem, flexibleSpaceItem,
                    actionBtnItem ,//autorelease]
                      nil];
    //toobar_ setItems:<#(NSArray *)#>
    
}
- (void)backBtnTapped:(id)sender {
    if(delegate_ && [delegate_ respondsToSelector:@selector(cancleSelected)]) {
        [delegate_ cancleSelected];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)actionBtnTapped:(id)sender {
    if(delegate_ && [delegate_ respondsToSelector:@selector(confirmSeleted:)]) {
        [delegate_ confirmSeleted:self.image];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    //KD_RELEASE_SAFELY(imageView_);
    //KD_RELEASE_SAFELY(toobar_);
    //KD_RELEASE_SAFELY(image_);
    //[super dealloc];
}
@end
