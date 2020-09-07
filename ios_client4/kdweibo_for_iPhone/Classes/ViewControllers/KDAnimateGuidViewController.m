//
//  KDAnimateGuidViewController.m
//  kdweibo
//
//  Created by gordon_wu on 13-12-18.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDAnimateGuidViewController.h"

#import "KDCommon.h"
#import "KDWeiboServicesContext.h"
#import "KDWeiboAppDelegate.h"
#import "UIButton+Additions.h"
#import "KDVersion.h"
#import "SMPageControl.h"
#define NUMBER_OF_PAGES 6

#define timeForPage(page) (self.view.frame.size.width * (page - 1))
#define xForPage(page) timeForPage(page)

@interface KDAnimateGuidViewController ()
@property (nonatomic,retain) UIImageView * page1_applicationImageView;
@property (nonatomic,retain) UIImageView * page1_colleagueImageView;
@property (nonatomic,retain) UIImageView * page1_dynamicImageView;
@property (nonatomic,retain) UIImageView * page1_messageImageView;
@property (nonatomic,retain) UIImageView * page1_workImageView;

@property (nonatomic,retain) UIImageView * page2_saoyisaoImageView;
@property (nonatomic,retain) UIImageView * page2_xieweiboImageView;
@property (nonatomic,retain) UIImageView * page2_duorenImageView;
@property (nonatomic,retain) UIImageView * page2_yaoqingImageView;

@property (nonatomic,retain) UIImageView * page3_messageImageView;
@property (nonatomic,retain) UIImageView * page3_colleagueImageView;
@property (nonatomic,retain) UIImageView * page3_bgImageView;

@property (nonatomic,retain) UIImageView * page4_workImageView;
@property (nonatomic,retain) UIImageView * page4_applicationImageView;


@property (nonatomic,retain) UIImageView * page5_applicationImageView;
@property (nonatomic,retain) UIImageView * page5_colleagueImageView;
@property (nonatomic,retain) UIImageView * page5_dynamicImageView;
@property (nonatomic,retain) UIImageView * page5_messageImageView;
@property (nonatomic,retain) UIImageView * page5_workImageView;
@property (nonatomic,retain) UIImageView * page5_boxImageView;
@property (nonatomic,retain) SMPageControl * pageControl;
@property (nonatomic, assign) UIButton  * startBtn;

@property (nonatomic, assign) BOOL isInApp;

@end

@implementation KDAnimateGuidViewController
@synthesize page1_applicationImageView = page1_applicationImageView_;
@synthesize page1_colleagueImageView   = page1_colleagueImageView_;
@synthesize page1_dynamicImageView     = page1_dynamicImageView_;
@synthesize page1_messageImageView     = page1_messageImageView_;
@synthesize page1_workImageView        = page1_workImageView_;

@synthesize page2_duorenImageView      = page2_duorenImageView_;
@synthesize page2_saoyisaoImageView    = page2_saoyisaoImageView_;
@synthesize page2_xieweiboImageView    = page2_xieweiboImageView_;
@synthesize page2_yaoqingImageView     = page2_yaoqingImageView_;

@synthesize page3_messageImageView     = page3_messageImageView_;
@synthesize page3_colleagueImageView   = page3_colleagueImageView_;
@synthesize page3_bgImageView          = page3_bgImageView_;

@synthesize page4_applicationImageView = page4_applicationImageView_;
@synthesize page4_workImageView        = page4_workImageView_;

@synthesize page5_applicationImageView = page5_applicationImageView_;
@synthesize page5_colleagueImageView   = page5_colleagueImageView_;
@synthesize page5_dynamicImageView     = page5_dynamicImageView_;
@synthesize page5_messageImageView     = page5_messageImageView_;
@synthesize page5_workImageView        = page5_workImageView_;
@synthesize page5_boxImageView         = page5_boxImageView_;
@synthesize startBtn                   = startBtn_;

@synthesize pageControl                = pageControl_;
- (id)initWithInApp:(BOOL)isInApp
{
    self = [super init];
    
    if (self) {
        
        self.view.backgroundColor   = [UIColor whiteColor];
        
        self.scrollView.contentSize = CGSizeMake(
                                                 NUMBER_OF_PAGES * self.view.frame.size.width,
                                                 self.view.frame.size.height
                                                 );
        
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        
        _isInApp = isInApp;
        [self placeViews];
        [self configureAnimation];

    }
    
    return self;
}

- (id)init
{
    return [self initWithInApp:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_delegate) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
     [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
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

- (void) dealloc
{
    //KD_RELEASE_SAFELY(page1_applicationImageView_);
    //KD_RELEASE_SAFELY(page1_colleagueImageView_);
    //KD_RELEASE_SAFELY(page1_dynamicImageView_);
    //KD_RELEASE_SAFELY(page1_messageImageView_);
    //KD_RELEASE_SAFELY(page1_workImageView_);
    
    //KD_RELEASE_SAFELY(page2_duorenImageView_);
    //KD_RELEASE_SAFELY(page2_saoyisaoImageView_);
    //KD_RELEASE_SAFELY(page2_xieweiboImageView_);
    //KD_RELEASE_SAFELY(page2_yaoqingImageView_);
    
    //KD_RELEASE_SAFELY(page3_bgImageView_);
    //KD_RELEASE_SAFELY(page3_colleagueImageView_);
    //KD_RELEASE_SAFELY(page3_messageImageView_);
    
    //KD_RELEASE_SAFELY(page5_applicationImageView_);
    //KD_RELEASE_SAFELY(page5_boxImageView_);
    //KD_RELEASE_SAFELY(page5_colleagueImageView_);
    //KD_RELEASE_SAFELY(page5_dynamicImageView_);
    //KD_RELEASE_SAFELY(page5_messageImageView_);
    //KD_RELEASE_SAFELY(page5_workImageView_);
    
    //KD_RELEASE_SAFELY(pageControl_);
    //[super dealloc];
}

- (BOOL)isHighScreenHeight
{
    return [UIDevice isRunningOveriPhone5];
}

- (BOOL)shouldAdjustLayout
{
    return ![self isHighScreenHeight] && self.isInApp;
}

- (CGFloat)adjustOffsetY1
{
    if([self shouldAdjustLayout]) {
        return -44.0f;
    }
    
    return 0.0f;
}

- (CGFloat)adjustOffsetY2
{
    if([self shouldAdjustLayout]) {
        return -40.0f;
    }
    
    return 0.0f;
}

- (CGFloat)adjustOffsetY3
{
    if([self shouldAdjustLayout]) {
        return -25.0f;
    }
    
    return 0.0f;
}

- (CGFloat)adjustOffsetY4
{
    if([self shouldAdjustLayout]) {
        return -40.0f;
    }
    
    return 0.0f;
}

- (CGFloat)adjustOffsetY5
{
    if([self shouldAdjustLayout]) {
        return -31.0f;
    }
    
    return 0.0f;
}

- (void) placeViews
{
    BOOL shouldAdjust = [self shouldAdjustLayout];
    CGFloat offsetY1 = [self adjustOffsetY1];
    CGFloat offsetY2 = [self adjustOffsetY2];
    CGFloat offsetY4 = [self adjustOffsetY4];
    
    UIImage * page1_bg = nil;
    if([self isHighScreenHeight]){
        page1_bg = [UIImage imageNamed:@"page1_bg.png"];
    }
    else{
        page1_bg = [UIImage imageNamed:@"page1_bg1.png"];
    }
    
    
    UIImageView * page1ImageView = [[UIImageView alloc] initWithImage:page1_bg];
    page1ImageView.frame         = CGRectMake(0, offsetY1, self.view.frame.size.width, page1_bg.size.height);
    [self.scrollView addSubview:page1ImageView];
    
    UIImageView * page2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page2_bg.png"]];
    [page2ImageView sizeToFit];
    page2ImageView.center        = CGPointMake(self.view.center.x, 150.0f);
    page2ImageView.frame         = CGRectOffset(page2ImageView.frame, xForPage(2), 0 + (shouldAdjust ? -40.0f : 0.0f));
    [self.scrollView addSubview:page2ImageView];
    
    UIImageView * page4ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page4_bg.png"]];
    page4ImageView.center        = CGPointMake(self.view.center.x, self.view.center.y - ([self shouldAdjustLayout] ? 80.0f : 50.0f));
    page4ImageView.frame         = CGRectOffset(page4ImageView.frame, xForPage(4), 0);
    [self.scrollView addSubview:page4ImageView];
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     *  page 1 placed image
     */
    
    
    UIImage * page1_applicationImage       = [UIImage imageNamed:@"page1_application.png"];
    page1_applicationImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page1_applicationImage.size.width,page1_applicationImage.size.height)];
    self.page1_applicationImageView.image  = page1_applicationImage;
    self.page1_applicationImageView.frame  =  CGRectOffset(
                                                           self.page1_applicationImageView.frame,
                                                           31,
                                                           180 + offsetY1
                                                           );
    [self.scrollView addSubview:self.page1_applicationImageView];
    
    
//    UIImage * page1_messageImage       = [UIImage imageNamed:@"page1_message.png"];
//    page1_messageImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page1_messageImage.size.width,page1_messageImage.size.height)];
//    self.page1_messageImageView.image  = page1_messageImage;
//    self.page1_messageImageView.frame  =  CGRectOffset(
//                                                       self.page1_messageImageView.frame,
//                                                       240,
//                                                       77 + offsetY1
//                                                       );
//    [self.scrollView addSubview:self.page1_messageImageView];
    
    
    UIImage * page1_dynamicImage       = [UIImage imageNamed:@"page1_dynamic.png"];
    page1_dynamicImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page1_dynamicImage.size.width,page1_dynamicImage.size.height)];
    self.page1_dynamicImageView.image  = page1_dynamicImage;
    self.page1_dynamicImageView.frame  =  CGRectOffset(
                                                       self.page1_dynamicImageView.frame,
                                                       42,
                                                       287 + offsetY1
                                                       );
    [self.scrollView addSubview:self.page1_dynamicImageView];
    
    
    UIImage * page1_colleagueImage       = [UIImage imageNamed:@"page1_colleague.png"];
    page1_colleagueImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page1_colleagueImage.size.width,page1_colleagueImage.size.height)];
    self.page1_colleagueImageView.image  = page1_colleagueImage;
    self.page1_colleagueImageView.frame  =  CGRectOffset(
                                                         self.page1_colleagueImageView.frame,
                                                         237,
                                                         190 + offsetY1
                                                         );
    [self.scrollView addSubview:self.page1_colleagueImageView];
    
    
    UIImage * page1_workImage       = [UIImage imageNamed:@"page1_work.png"];
    page1_workImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page1_workImage.size.width,page1_workImage.size.height)];
    self.page1_workImageView.image  = page1_workImage;
    self.page1_workImageView.frame  =  CGRectOffset(
                                                    self.page1_workImageView.frame,
                                                    246,
                                                    246 + offsetY1
                                                    );
    [self.scrollView addSubview:self.page1_workImageView];
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     *  page 2 placed image
     */
    UIImage     * page2_labelImage        = [UIImage imageNamed:@"page2_label.png"];
    UIImageView * page2_labelImageView    = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page2_labelImage.size.width,page2_labelImage.size.height)];
    page2_labelImageView.image  = page2_labelImage;
    page2_labelImageView.center = CGPointMake(self.view.center.x,65);
    page2_labelImageView.frame  = CGRectOffset(page2_labelImageView.frame, xForPage(2),0 + offsetY2);
    [self.scrollView addSubview:page2_labelImageView];
    
    page2_duorenImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page2_duoren.png"]];
    page2_duorenImageView_.center = CGPointMake(self.view.center.x, 0.0f);
    page2_duorenImageView_.frame = CGRectOffset(page2_duorenImageView_.frame, xForPage(2), -CGRectGetHeight(page2_duorenImageView_.bounds) * 0.5f);
    [self.scrollView addSubview:page2_duorenImageView_];
    
    page2_xieweiboImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page2_xieweibo.png"]];
    page2_xieweiboImageView_.center = CGPointMake(self.view.center.x, 0.0f);
    page2_xieweiboImageView_.frame = CGRectOffset(page2_xieweiboImageView_.frame, xForPage(2), -CGRectGetHeight(page2_xieweiboImageView_.bounds) * 0.5f);
    [self.scrollView addSubview:page2_xieweiboImageView_];
    
    page2_saoyisaoImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page2_saoyisao.png"]];
    page2_saoyisaoImageView_.center = CGPointMake(self.view.center.x, 0.0f);
    page2_saoyisaoImageView_.frame = CGRectOffset(page2_saoyisaoImageView_.frame, xForPage(2), -CGRectGetHeight(page2_saoyisaoImageView_.bounds) * 0.5f);
    [self.scrollView addSubview:page2_saoyisaoImageView_];
    
    page2_yaoqingImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page2_yaoqing.png"]];
    page2_yaoqingImageView_.center = CGPointMake(self.view.center.x, 0.0f);
    page2_yaoqingImageView_.frame = CGRectOffset(page2_yaoqingImageView_.frame, xForPage(2), -CGRectGetHeight(page2_yaoqingImageView_.bounds) * 0.5f);
    [self.scrollView addSubview:page2_yaoqingImageView_];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     *  page 3 placed image
     */
    page3_bgImageView_                   = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page3_bg.png"]];
    self.page3_bgImageView.center        = CGPointMake(0,self.view.frame.size.height + self.page3_bgImageView.frame.size.height/2);
    self.page3_bgImageView.frame         = CGRectOffset(self.page3_bgImageView.frame, xForPage(3),0);
    [self.scrollView addSubview:self.page3_bgImageView];
    
    UIImage * page3_messageImage       = [UIImage imageNamed:@"page3_message.png"];
    page3_messageImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page3_messageImage.size.width,page3_messageImage.size.height)];
    self.page3_messageImageView.image  = page3_messageImage;
    self.page3_messageImageView.center = CGPointMake(0,self.view.frame.size.height+page3_messageImageView_.frame.size.height/2);
    self.page3_messageImageView.frame  = CGRectOffset(self.page3_messageImageView.frame, xForPage(3),0);
    self.page3_messageImageView.alpha  = 0.0f;
    [self.scrollView addSubview:self.page3_messageImageView];
    
    
    UIImage * page3_colleageImage        = [UIImage imageNamed:@"page3_colleague.png"];
    page3_colleagueImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page3_colleageImage.size.width,page3_colleageImage.size.height)];
    self.page3_colleagueImageView.image  = page3_colleageImage;
    self.page3_colleagueImageView.center = CGPointMake(0,self.view.frame.size.height+self.page3_messageImageView.frame.size.height/2);
    self.page3_colleagueImageView.frame  = CGRectOffset(self.page3_colleagueImageView.frame, xForPage(3),0);
    self.page3_colleagueImageView.alpha  = 0.0f;
    [self.scrollView addSubview:self.page3_colleagueImageView];
    
    
    
    
    
    UIImage     * page3_labelImage        = [UIImage imageNamed:@"page3_label.png"];
    UIImageView * page3_labelImageView    = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page3_labelImage.size.width,page3_labelImage.size.height)];
    page3_labelImageView.image  = page3_labelImage;
    page3_labelImageView.center = CGPointMake(self.view.center.x,65);
    page3_labelImageView.frame  = CGRectOffset(page3_labelImageView.frame, xForPage(3),0 + (shouldAdjust ? -40.0f : 0.0f));
    [self.scrollView addSubview:page3_labelImageView];
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     *  page 4 placed image
     */
    UIImage     * page4_labelImage        = [UIImage imageNamed:@"page4_label.png"];
    UIImageView * page4_labelImageView    = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page4_labelImage.size.width,page4_labelImage.size.height)];
    page4_labelImageView.image  = page4_labelImage;
    page4_labelImageView.center = CGPointMake(self.view.center.x, 65);
    page4_labelImageView.frame  = CGRectOffset(page4_labelImageView.frame, xForPage(4), offsetY4);
    [self.scrollView addSubview:page4_labelImageView];

    
    UIImage * page4_applicationImage       = [UIImage imageNamed:@"page4_application.png"];
    page4_applicationImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page4_applicationImage.size.width,page4_applicationImage.size.height)];
    self.page4_applicationImageView.image  = page4_applicationImage;
    self.page4_applicationImageView.center = self.view.center;
    self.page4_applicationImageView.alpha  = 0.0f;
    self.page4_applicationImageView.frame  = CGRectOffset(self.page4_applicationImageView.frame, xForPage(4),0);
//    self.page4_applicationImageView.frame  = CGRectOffset(self.page4_applicationImageView.frame, 0.0f, 0);
    [self.scrollView addSubview:self.page4_applicationImageView];
    
//    UIImage * page4_workImage       = [UIImage imageNamed:@"page4_work.png"];
//    page4_workImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page4_workImage.size.width,page4_workImage.size.height)];
//    self.page4_workImageView.image  = page4_workImage;
//    self.page4_workImageView.center = self.view.center;
//    self.page4_workImageView.alpha  = 0.0f;
//    self.page4_workImageView.frame  = CGRectOffset(self.page4_workImageView.frame, xForPage(4),0);
//    [self.scrollView addSubview:self.page4_workImageView];

    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     *  page 5 placed image
     */
    
    UIImageView * page5ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page5_bg.png"]];
    page5ImageView.center        = CGPointMake(self.view.center.x,65);
    page5ImageView.frame         = CGRectOffset(page5ImageView.frame, xForPage(5),0);
    [self.scrollView addSubview:page5ImageView];
    
    
    UIImage * page5_boxImage       = [UIImage imageNamed:@"page5_box.png"];
    page5_boxImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page5_boxImage.size.width,page5_boxImage.size.height)];
    self.page5_boxImageView.image  = page5_boxImage;
    self.page5_boxImageView.center = CGPointMake(0,self.view.frame.size.height+self.page5_boxImageView.frame.size.height/2);
    self.page5_boxImageView.alpha  = 0.0f;
    self.page5_boxImageView.frame  = CGRectOffset(self.page5_boxImageView.frame, xForPage(5),0);
    [self.scrollView addSubview:self.page5_boxImageView];
    
    
    UIImage * page5_applicationImage       = [UIImage imageNamed:@"page5_application.png"];
    page5_applicationImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page5_applicationImage.size.width,page5_applicationImage.size.height)];
    self.page5_applicationImageView.image  = page5_applicationImage;
    self.page5_applicationImageView.center = CGPointMake(0,self.view.frame.size.height+self.page5_applicationImageView.frame.size.height/2);
    self.page5_applicationImageView.alpha  = 0.0f;
    self.page5_applicationImageView.frame  = CGRectOffset(self.page5_applicationImageView.frame, xForPage(5),0);
    [self.scrollView addSubview:self.page5_applicationImageView];
    
    
//    UIImage * page5_messageImage       = [UIImage imageNamed:@"page5_message.png"];
//    page5_messageImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page5_messageImage.size.width,page5_messageImage.size.height)];
//    self.page5_messageImageView.image  = page5_messageImage;
//    self.page5_messageImageView.center = CGPointMake(0,self.view.frame.size.height+self.page5_messageImageView.frame.size.height/2);
//    self.page5_messageImageView.alpha  = 0.0f;
//    self.page5_messageImageView.frame  = CGRectOffset(self.page5_messageImageView.frame, xForPage(5),0);
//    [self.scrollView addSubview:self.page5_messageImageView];
    
    
    UIImage * page5_dynamicImage       = [UIImage imageNamed:@"page5_dynamic.png"];
    page5_dynamicImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page5_dynamicImage.size.width,page5_dynamicImage.size.height)];
    self.page5_dynamicImageView.image  = page5_dynamicImage;
    self.page5_dynamicImageView.center = CGPointMake(0,self.view.frame.size.height+self.page5_dynamicImageView.frame.size.height/2);
    self.page5_dynamicImageView.alpha  = 0.0f;
    self.page5_dynamicImageView.frame  = CGRectOffset(self.page5_dynamicImageView.frame, xForPage(5),0);
    [self.scrollView addSubview:self.page5_dynamicImageView];
    
    
    UIImage * page5_colleagueImage       = [UIImage imageNamed:@"page5_colleague.png"];
    page5_colleagueImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page5_colleagueImage.size.width,page5_colleagueImage.size.height)];
    self.page5_colleagueImageView.image  = page5_colleagueImage;
    self.page5_colleagueImageView.center = CGPointMake(0,self.view.frame.size.height+self.page5_colleagueImageView.frame.size.height/2);
    self.page5_colleagueImageView.alpha  = 0.0f;
    self.page5_colleagueImageView.frame  = CGRectOffset(self.page5_colleagueImageView.frame, xForPage(5),0);
    [self.scrollView addSubview:self.page5_colleagueImageView];
    
    
    UIImage * page5_workImage       = [UIImage imageNamed:@"page5_work.png"];
    page5_workImageView_            = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,page5_workImage.size.width,page5_workImage.size.height)];
    self.page5_workImageView.image  = page5_workImage;
    self.page5_workImageView.center = CGPointMake(0,self.view.frame.size.height+self.page5_workImageView.frame.size.height/2);
    self.page5_workImageView.alpha  = 0.0f;
    self.page5_workImageView.frame  = CGRectOffset(self.page5_workImageView.frame, xForPage(5),0);
    [self.scrollView addSubview:self.page5_workImageView];
    
    startBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    [startBtn_ addImageWithName:@"page5_btn" forState:UIControlStateNormal isBackground:YES];
    [startBtn_ addImageWithName:@"page5_btn" forState:UIControlStateHighlighted isBackground:YES];
    
    [startBtn_ addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat startBtnOffset = 124 - ([self shouldAdjustLayout] ? 0.0f : 30.0f);
    if([self isHighScreenHeight]) {
        startBtnOffset += 20.0f;
    }
    startBtn_.frame = CGRectMake(xForPage(5)+self.view.center.x-55.5f,self.view.frame.size.height - startBtnOffset, 111.0f, 22.0f);
    startBtn_.alpha = 0;
    [self.scrollView addSubview:self.startBtn];
    
    
    SMPageControl *pageControl = [[SMPageControl alloc] initWithFrame:CGRectZero];
    pageControl_.backgroundColor = [UIColor redColor];
    self.pageControl = pageControl;
//    [pageControl release];

    CGSize stageSize = self.view.bounds.size;
    
    pageControl_.indicatorMargin = 6.0;
    pageControl_.pageIndicatorImage = [UIImage imageNamed:@"dot_gray.png"];
    pageControl_.currentPageIndicatorImage = [UIImage imageNamed:@"dot_black.png"];
    
    pageControl_.numberOfPages = 5;
    pageControl_.currentPage = 0;
    
    CGSize size = [pageControl_ sizeForNumberOfPages:5];
   
    CGFloat offsetToBottom = [self shouldAdjustLayout] ? 75.0f : 20.0f;
    if([self isHighScreenHeight]) {
        offsetToBottom += 50.0f;
    }
    pageControl_.frame = CGRectMake((stageSize.width - size.width) * 0.5,self.view.frame.size.height-size.height-offsetToBottom, size.width, size.height);;
    
    [self.view addSubview:pageControl_];
    
    
    
    UIImage * page6_bg = nil;
    if([self isHighScreenHeight]){
        page6_bg = [UIImage imageNamed:@"page6_h.png"];
    }
    else{
        page6_bg = [UIImage imageNamed:@"page6_s.png"];
    }
    
    UIImageView *page6ImgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    page6ImgeView.image        = page6_bg;
    page6ImgeView.tag = 1000;
    page6ImgeView.frame        = CGRectOffset(page6ImgeView.frame, xForPage(6),0);
    [self.scrollView addSubview:page6ImgeView];
    
    
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,30,30)];
    activityView.color                     = [UIColor grayColor];
    activityView.center                    = self.view.center;
    activityView.frame                     = CGRectOffset(activityView.frame, xForPage(6),0);
    [activityView startAnimating];
    
    [self.scrollView addSubview:activityView];
    
    
    
    
    
    //KD_RELEASE_SAFELY(page6ImgeView);
    //KD_RELEASE_SAFELY(activityView);
    
    //KD_RELEASE_SAFELY(page1ImageView);
    //KD_RELEASE_SAFELY(page2ImageView);
    //KD_RELEASE_SAFELY(page4ImageView);
    //KD_RELEASE_SAFELY(page5ImageView);
    //KD_RELEASE_SAFELY(page3_labelImageView);
    //KD_RELEASE_SAFELY(page2_labelImageView);
    //KD_RELEASE_SAFELY(page4_labelImageView);
}

- (void) configureAnimation
{
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     *  page 1 move animation
     */
    IFTTTFrameAnimation *page1_applicationFrameAnimation = [IFTTTFrameAnimation new];
    page1_applicationFrameAnimation.view = self.page1_applicationImageView;
    [self.animator addAnimation:page1_applicationFrameAnimation];
    [page1_applicationFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1)
                                                                                     andFrame:self.page1_applicationImageView.frame] ];
    [page1_applicationFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2)
                                                                                     andFrame:CGRectOffset(self.page1_applicationImageView.frame, 960, 0)] ];
    
    IFTTTAlphaAnimation *page1_applicationAlphaAnimation = [IFTTTAlphaAnimation new];
    page1_applicationAlphaAnimation.view = self.page1_applicationImageView;
    [self.animator addAnimation:page1_applicationAlphaAnimation];
    
    [page1_applicationAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1) andAlpha:1.0f]];
    [page1_applicationAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2) andAlpha:0.0f]];
    [page1_applicationAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3) andAlpha:0.0f]];
    [page1_applicationAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f]];
    
    //KD_RELEASE_SAFELY(page1_applicationAlphaAnimation);
    //KD_RELEASE_SAFELY(page1_applicationFrameAnimation);
    
    
    IFTTTFrameAnimation *page1_dynamicFrameAnimation = [IFTTTFrameAnimation new];
    page1_dynamicFrameAnimation.view = self.page1_dynamicImageView;
    [self.animator addAnimation:page1_dynamicFrameAnimation];
    [page1_dynamicFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1)
                                                                                 andFrame:self.page1_dynamicImageView.frame]];
    [page1_dynamicFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2)
                                                                                 andFrame:CGRectOffset(self.page1_dynamicImageView.frame, 960, 0)] ];
    
    IFTTTAlphaAnimation *page1_dynamicAlphaAnimation = [IFTTTAlphaAnimation new];
    page1_dynamicAlphaAnimation.view = self.page1_dynamicImageView;
    [self.animator addAnimation:page1_dynamicAlphaAnimation];
    
    [page1_dynamicAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1) andAlpha:1.0f]];
    [page1_dynamicAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2) andAlpha:0.0f] ];
    [page1_dynamicAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3) andAlpha:0.0f] ];
    [page1_dynamicAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f] ];
    
    //KD_RELEASE_SAFELY(page1_dynamicFrameAnimation);
    //KD_RELEASE_SAFELY(page1_dynamicAlphaAnimation);
    
    
//    IFTTTFrameAnimation *page1_messageFrameAnimation = [IFTTTFrameAnimation new];
//    page1_messageFrameAnimation.view = self.page1_messageImageView;
//    [self.animator addAnimation:page1_messageFrameAnimation];
//    [page1_messageFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1)
//                                                                                 andFrame:self.page1_messageImageView.frame]];
//    [page1_messageFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2)
//                                                                                 andFrame:CGRectOffset(self.page1_messageImageView.frame, 960, 0)]];
//    
//    IFTTTAlphaAnimation *page1_messageAlphaAnimation = [IFTTTAlphaAnimation new];
//    page1_messageAlphaAnimation.view = self.page1_messageImageView;
//    [self.animator addAnimation:page1_messageAlphaAnimation];
//    
//    [page1_messageAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1) andAlpha:1.0f]];
//    [page1_messageAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2) andAlpha:0.0f]];
//    [page1_messageAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3) andAlpha:0.0f]];
//    [page1_messageAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f]];
//    
//    //KD_RELEASE_SAFELY(page1_messageFrameAnimation);
//    //KD_RELEASE_SAFELY(page1_messageAlphaAnimation);
    
    
    IFTTTFrameAnimation *page1_colleagueFrameAnimation = [IFTTTFrameAnimation new];
    page1_colleagueFrameAnimation.view = self.page1_colleagueImageView;
    [self.animator addAnimation:page1_colleagueFrameAnimation];
    [page1_colleagueFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1)
                                                                                   andFrame:self.page1_colleagueImageView.frame] ];
    [page1_colleagueFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2)
                                                                                   andFrame:CGRectOffset(self.page1_colleagueImageView.frame, 960, 0)] ];
    
    IFTTTAlphaAnimation *page1_colleagueAlphaAnimation = [IFTTTAlphaAnimation new];
    page1_colleagueAlphaAnimation.view = self.page1_colleagueImageView;
    [self.animator addAnimation:page1_colleagueAlphaAnimation];
    
    [page1_colleagueAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1) andAlpha:1.0f] ];
    [page1_colleagueAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2) andAlpha:0.0f] ];
    [page1_colleagueAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3) andAlpha:0.0f] ];
    [page1_colleagueAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f] ];
    
    //KD_RELEASE_SAFELY(page1_colleagueAlphaAnimation);
    //KD_RELEASE_SAFELY(page1_colleagueFrameAnimation);
    
    
    IFTTTFrameAnimation *page1_workFrameAnimation = [IFTTTFrameAnimation new];
    page1_workFrameAnimation.view = self.page1_workImageView;
    [self.animator addAnimation:page1_workFrameAnimation];
    [page1_workFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1)
                                                                              andFrame:self.page1_workImageView.frame] ];
    [page1_workFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2)
                                                                              andFrame:CGRectOffset(self.page1_workImageView.frame, 960, 0)] ];
    
    IFTTTAlphaAnimation *page1_workAlphaAnimation = [IFTTTAlphaAnimation new];
    page1_workAlphaAnimation.view = self.page1_workImageView;
    [self.animator addAnimation:page1_workAlphaAnimation];
    
    [page1_workAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1) andAlpha:1.0f] ];
    [page1_workAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2) andAlpha:0.0f] ];
    [page1_workAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3) andAlpha:0.0f] ];
    [page1_workAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f] ];
    
    //KD_RELEASE_SAFELY(page1_workAlphaAnimation);
    //KD_RELEASE_SAFELY(page1_workFrameAnimation);
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     *  page 2 move animation
     */
    NSArray *page2AnimationViews = @[page2_duorenImageView_, page2_xieweiboImageView_, page2_saoyisaoImageView_, page2_yaoqingImageView_];
    
    [page2AnimationViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = (UIView *)obj;
        
        //alpha animation
        IFTTTAlphaAnimation *page2_alphaAnimation = [[IFTTTAlphaAnimation alloc] init];
        page2_alphaAnimation.view = view;
        [page2_alphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1) andAlpha:0.0f]];
        [page2_alphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2) andAlpha:1.0f]];
        [self.animator addAnimation:page2_alphaAnimation];
        
        //frame animation
        CGFloat spacing = [self shouldAdjustLayout] ? 65.0f : 75.0f;
        CGFloat offsetY = [self shouldAdjustLayout] ? 180.0f : 230.0f;
        IFTTTFrameAnimation *page2_frameAnimation = [[IFTTTFrameAnimation alloc] init] ;
        page2_frameAnimation.view = view;
        [page2_frameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(1) andFrame:CGRectInset(view.frame, 20.0f, 20.0f)] ];
        [page2_frameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2) andFrame:CGRectOffset(view.frame, 0.0f, offsetY + idx * spacing)] ];
        [self.animator addAnimation:page2_frameAnimation];
    }];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     *  page 3 move animation
     */
    
    IFTTTFrameAnimation *page3_bgFrameAnimation = [IFTTTFrameAnimation new];
    page3_bgFrameAnimation.view = self.page3_bgImageView;
    [self.animator addAnimation:page3_bgFrameAnimation];
    [page3_bgFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2)
                                                                            andFrame:self.page3_bgImageView.frame] ];
    [page3_bgFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3)
                                                                            andFrame:CGRectOffset(self.page3_bgImageView.frame,self.view.frame.size.width/2,-(self.view.frame.size.height/2+self.page3_bgImageView.frame.size.height/2) + 50 + [self adjustOffsetY3])]];
    IFTTTAlphaAnimation *page3_bgAlphaAnimation = [IFTTTAlphaAnimation new];
    page3_bgAlphaAnimation.view = self.page3_bgImageView;
    [self.animator addAnimation:page3_bgAlphaAnimation];
    
    [page3_bgAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2) andAlpha:0.0f] ];
    [page3_bgAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3) andAlpha:1.0f] ];
    
    //KD_RELEASE_SAFELY(page3_bgFrameAnimation);
    //KD_RELEASE_SAFELY(page3_bgAlphaAnimation);
    
    
    IFTTTFrameAnimation *page3_messageFrameAnimation = [IFTTTFrameAnimation new];
    page3_messageFrameAnimation.view = self.page3_messageImageView;
    [self.animator addAnimation:page3_messageFrameAnimation];
    [page3_messageFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2)
                                                                                 andFrame:CGRectInset(self.page3_messageImageView.frame, 30, 30)] ];
    [page3_messageFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3)
                                                                                 andFrame:CGRectOffset(self.page3_messageImageView.frame,self.view.frame.size.width/2-70,-(self.view.frame.size.height/2+self.page3_messageImageView.frame.size.height/2) - 95 + [self adjustOffsetY3])] ];
    
    IFTTTAlphaAnimation *page3_messageAlphaAnimation = [IFTTTAlphaAnimation new];
    page3_messageAlphaAnimation.view = self.page3_messageImageView;
    [self.animator addAnimation:page3_messageAlphaAnimation];
    
    [page3_messageAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2) andAlpha:0.0f] ];
    [page3_messageAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3) andAlpha:1.0f] ];
    
    //KD_RELEASE_SAFELY(page3_messageFrameAnimation);
    //KD_RELEASE_SAFELY(page3_messageAlphaAnimation);
    
    IFTTTFrameAnimation *page3_colleagueFrameAnimation = [IFTTTFrameAnimation new];
    page3_colleagueFrameAnimation.view = self.page3_colleagueImageView;
    [self.animator addAnimation:page3_colleagueFrameAnimation];
    [page3_colleagueFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2)
                                                                                   andFrame:CGRectInset(self.page3_colleagueImageView.frame, 30, 30)] ];
    [page3_colleagueFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3)
                                                                                   andFrame:CGRectOffset(self.page3_colleagueImageView.frame,self.view.frame.size.width/2+70,-(self.view.frame.size.height/2+self.page3_colleagueImageView.frame.size.height/2)-70 + [self adjustOffsetY3])] ];
    IFTTTAlphaAnimation *page3_colleagueAlphaAnimation = [IFTTTAlphaAnimation new];
    page3_colleagueAlphaAnimation.view = self.page3_colleagueImageView;
    [self.animator addAnimation:page3_colleagueAlphaAnimation];
    
    [page3_colleagueAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(2) andAlpha:0.0f] ];
    [page3_colleagueAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3) andAlpha:1.0f] ];
    
    //KD_RELEASE_SAFELY(page3_colleagueFrameAnimation);
    //KD_RELEASE_SAFELY(page3_colleagueAlphaAnimation);
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     *  page 4 move animation
     */
    
//    IFTTTFrameAnimation *page4_workFrameAnimation = [IFTTTFrameAnimation new];
//    page4_workFrameAnimation.view = self.page4_workImageView;
//    [self.animator addAnimation:page4_workFrameAnimation];
//    [page4_workFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3)
//                                                                              andFrame:CGRectInset(self.page4_workImageView.frame, 20, 20)]];
//    [page4_workFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4)
//                                                                              andFrame:CGRectOffset(self.page4_workImageView.frame,-80,110)]];
//    IFTTTAlphaAnimation *page4_workAlphaAnimation = [IFTTTAlphaAnimation new];
//    page4_workAlphaAnimation.view = self.page4_workImageView;
//    [self.animator addAnimation:page4_workAlphaAnimation];
//    
//    [page4_workAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3) andAlpha:0.0f]];
//    [page4_workAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:1.0f]];
//    
//    //KD_RELEASE_SAFELY(page4_workFrameAnimation);
//    //KD_RELEASE_SAFELY(page4_workAlphaAnimation);
    
    IFTTTFrameAnimation *page4_applicationFrameAnimation = [IFTTTFrameAnimation new];
    page4_applicationFrameAnimation.view = self.page4_applicationImageView;
    [self.animator addAnimation:page4_applicationFrameAnimation];
    [page4_applicationFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3)
                                                                              andFrame:CGRectInset(self.page4_applicationImageView.frame, 20, 20)] ];
    [page4_applicationFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4)
                                                                                     andFrame:CGRectOffset(self.page4_applicationImageView.frame, 0,100 + ([self shouldAdjustLayout] ? -10.0f : 25.0f))] ];
    IFTTTAlphaAnimation *page4_applicationAlphaAnimation = [IFTTTAlphaAnimation new];
    page4_applicationAlphaAnimation.view = self.page4_applicationImageView;
    [self.animator addAnimation:page4_applicationAlphaAnimation];
    
    [page4_applicationAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(3) andAlpha:0.0f] ];
    [page4_applicationAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:1.0f] ];
    
    //KD_RELEASE_SAFELY(page4_applicationFrameAnimation);
    //KD_RELEASE_SAFELY(page4_applicationAlphaAnimation);
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     *  page 5 move animation
     */
    
    IFTTTFrameAnimation *page5_workFrameAnimation = [IFTTTFrameAnimation new];
    page5_workFrameAnimation.view = self.page5_workImageView;
    [self.animator addAnimation:page5_workFrameAnimation];
    [page5_workFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4)
                                                                              andFrame:CGRectInset(self.page5_workImageView.frame, 20, 20)]];
    [page5_workFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5)
                                                                              andFrame:CGRectOffset(self.page5_workImageView.frame,70+self.page5_workImageView.frame.size.width/2,-(self.view.frame.size.height-179) + [self adjustOffsetY5])] ];
    IFTTTAlphaAnimation *page5_workAlphaAnimation = [IFTTTAlphaAnimation new];
    page5_workAlphaAnimation.view = self.page5_workImageView;
    [self.animator addAnimation:page5_workAlphaAnimation];
    
    [page5_workAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f]];
    [page5_workAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5) andAlpha:1.0f] ];
    
    //KD_RELEASE_SAFELY(page5_workFrameAnimation);
    //KD_RELEASE_SAFELY(page5_workAlphaAnimation);
    
    
    IFTTTFrameAnimation *page5_dynamicFrameAnimation = [IFTTTFrameAnimation new];
    page5_dynamicFrameAnimation.view = self.page5_dynamicImageView;
    [self.animator addAnimation:page5_dynamicFrameAnimation];
    [page5_dynamicFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4)
                                                                                 andFrame:CGRectInset(self.page5_dynamicImageView.frame, 20, 20)] ];
    [page5_dynamicFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5)
                                                                                 andFrame:CGRectOffset(self.page5_dynamicImageView.frame,self.view.frame.size.width/2 + 70,-(self.view.frame.size.height-156) + [self adjustOffsetY5])] ];
    IFTTTAlphaAnimation *page5_dynamicAlphaAnimation = [IFTTTAlphaAnimation new];
    page5_dynamicAlphaAnimation.view = self.page5_dynamicImageView;
    [self.animator addAnimation:page5_dynamicAlphaAnimation];
    
    [page5_dynamicAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f] ];
    [page5_dynamicAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5) andAlpha:1.0f] ];
    
    //KD_RELEASE_SAFELY(page5_dynamicFrameAnimation);
    //KD_RELEASE_SAFELY(page5_dynamicAlphaAnimation);
    
    
    
    IFTTTFrameAnimation *page5_colleagueFrameAnimation = [IFTTTFrameAnimation new];
    page5_colleagueFrameAnimation.view = self.page5_colleagueImageView;
    [self.animator addAnimation:page5_colleagueFrameAnimation];
    [page5_colleagueFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4)
                                                                                   andFrame:CGRectInset(self.page5_colleagueImageView.frame, 20, 20)] ];
    [page5_colleagueFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5)
                                                                                   andFrame:CGRectOffset(self.page5_colleagueImageView.frame,179+self.page5_colleagueImageView.frame.size.width/2,-(self.view.frame.size.height-238) + [self adjustOffsetY5])]];
    IFTTTAlphaAnimation *page5_colleagueAlphaAnimation = [IFTTTAlphaAnimation new];
    page5_colleagueAlphaAnimation.view = self.page5_colleagueImageView;
    [self.animator addAnimation:page5_colleagueAlphaAnimation];
    
    [page5_colleagueAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f] ];
    [page5_colleagueAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5) andAlpha:1.0f] ];
    
    //KD_RELEASE_SAFELY(page5_colleagueFrameAnimation);
    //KD_RELEASE_SAFELY(page5_colleagueAlphaAnimation);
    
    
    IFTTTFrameAnimation *page5_applicationFrameAnimation = [IFTTTFrameAnimation new];
    page5_applicationFrameAnimation.view = self.page5_applicationImageView;
    [self.animator addAnimation:page5_applicationFrameAnimation];
    [page5_applicationFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4)
                                                                                     andFrame:CGRectInset(self.page5_applicationImageView.frame, 10, 10)] ];
    [page5_applicationFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5)
                                                                                     andFrame:CGRectOffset(self.page5_applicationImageView.frame,105+self.page5_colleagueImageView.frame.size.width/2,-(self.view.frame.size.height-258) + [self adjustOffsetY5])] ];
    IFTTTAlphaAnimation *page5_applicationAlphaAnimation = [IFTTTAlphaAnimation new];
    page5_applicationAlphaAnimation.view = self.page5_applicationImageView;
    [self.animator addAnimation:page5_applicationAlphaAnimation];
    
    [page5_applicationAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f] ];
    [page5_applicationAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5) andAlpha:1.0f] ];
    
    //KD_RELEASE_SAFELY(page5_applicationFrameAnimation);
    //KD_RELEASE_SAFELY(page5_applicationAlphaAnimation);
    
    
//    IFTTTFrameAnimation *page5_messageFrameAnimation = [IFTTTFrameAnimation new];
//    page5_messageFrameAnimation.view = self.page5_messageImageView;
//    [self.animator addAnimation:page5_messageFrameAnimation];
//    [page5_messageFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4)
//                                                                                 andFrame:CGRectInset(self.page5_messageImageView.frame, 10, 10)]];
//    [page5_messageFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5)
//                                                                                 andFrame:CGRectOffset(self.page5_messageImageView.frame,189+self.page5_messageImageView.frame.size.width/2,-(self.view.frame.size.height-255) + [self adjustOffsetY5])]];
//    IFTTTAlphaAnimation *page5_messageAlphaAnimation = [IFTTTAlphaAnimation new];
//    page5_messageAlphaAnimation.view = self.page5_messageImageView;
//    [self.animator addAnimation:page5_messageAlphaAnimation];
//    
//    [page5_messageAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f]];
//    [page5_messageAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5) andAlpha:1.0f]];
//    
//    //KD_RELEASE_SAFELY(page5_messageFrameAnimation);
//    //KD_RELEASE_SAFELY(page5_messageAlphaAnimation);
    
    IFTTTFrameAnimation *page5_boxFrameAnimation = [IFTTTFrameAnimation new];
    page5_boxFrameAnimation.view = self.page5_boxImageView;
    [self.animator addAnimation:page5_boxFrameAnimation];
    [page5_boxFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4)
                                                                             andFrame:self.page5_boxImageView.frame] ];
    [page5_boxFrameAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5)
                                                                             andFrame:CGRectOffset(self.page5_boxImageView.frame,self.view.frame.size.width/2,-(self.view.frame.size.height/2+self.page5_boxImageView.frame.size.height/2) + [self adjustOffsetY5])] ];
    IFTTTAlphaAnimation *page5_boxAlphaAnimation = [IFTTTAlphaAnimation new];
    page5_boxAlphaAnimation.view = self.page5_boxImageView;
    [self.animator addAnimation:page5_boxAlphaAnimation];
    
    [page5_boxAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f]];
    [page5_boxAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5) andAlpha:1.0f] ];
    
    //KD_RELEASE_SAFELY(page5_boxFrameAnimation);
    //KD_RELEASE_SAFELY(page5_boxAlphaAnimation);
    
    
    IFTTTAlphaAnimation *page5_btnAlphaAnimation = [IFTTTAlphaAnimation new];
    page5_btnAlphaAnimation.view = self.startBtn;
    [self.animator addAnimation:page5_btnAlphaAnimation];
    
    [page5_btnAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(4) andAlpha:0.0f]];
    [page5_btnAlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5) andAlpha:1.0f] ];
    
    //KD_RELEASE_SAFELY(page5_btnAlphaAnimation);
    
    
    IFTTTAlphaAnimation *pageControl_AlphaAnimation = [IFTTTAlphaAnimation new];
    pageControl_AlphaAnimation.view = pageControl_;
    [self.animator addAnimation:pageControl_AlphaAnimation];
    
    [pageControl_AlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(5) andAlpha:1.0f] ];
    [pageControl_AlphaAnimation addKeyFrame:[[IFTTTAnimationKeyFrame alloc] initWithTime:timeForPage(6) andAlpha:0.0f] ];
    
    //KD_RELEASE_SAFELY(pageControl_AlphaAnimation);

   
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIScrollView delegate methods

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    NSInteger index = floor(scrollView.contentOffset.x / scrollView.bounds.size.width);
//    if(pageControl_.currentPage != index){
//            pageControl_.currentPage = index;
//            
//    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(ceil(scrollView.contentOffset.x / scrollView.bounds.size.width) > 4){
        [self start:nil];
    }
    
    [pageControl_ updatePageNumberForScrollView:scrollView];
}

#pragma mark --
#pragma mark btnClick
- (void) start:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(animateGuidView:scrollToLast:)]) {
        [_delegate animateGuidView:self scrollToLast:YES];
        return;
    }
    [self startKDWeibo];
}

/**
 *  是否显示教程：规则
 *  1.如果上次版本小于当前版本，并且版本号最后一位为0
 *  2.如果没有版本号
 */
+ (BOOL)shouldShowGuideView {
    NSString *lastShowVersionString = [[KDSession globalSession] getPropertyForKey:KD_LAST_SHOW_GUIDE_VERSION_KEY fromMemoryCache:YES];
    NSString *currentVersionString  = [KDCommon clientVersion];
    
    BOOL shouldShow = NO;
    
    
    if(lastShowVersionString) {
        NSComparisonResult result = nil;
        if([KDVersion quickCompareVersionA:lastShowVersionString versionB:currentVersionString results:&result]) {
            if(result == NSOrderedAscending && [KDCommon versionLastBit] == 0) {
                KDVersion *v = [[KDVersion alloc] initWithVersionString:currentVersionString];
                if(v.releaseStatus == Release) {
                    shouldShow = YES;
                }
                
//                [v release];
            }
        }
    }else {
        if([KDCommon versionLastBit] == 0) {
            shouldShow = YES;
        }
    }
    
    if(shouldShow) {
        [[KDSession globalSession] saveProperty:currentVersionString forKey:KD_LAST_SHOW_GUIDE_VERSION_KEY storeToMemoryCache:YES];
    }
    
    return shouldShow;
}

- (void)setDelegate:(id<KDAnimateGuidViewDelegate>)delegate
{
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(animateGuidView:scrollToLast:)]) {
        self.scrollView.contentSize = CGSizeMake(
                                                 (NUMBER_OF_PAGES - 1) * self.view.frame.size.width,
                                                 self.view.frame.size.height
                                                 );
        UIView *view = [self.scrollView viewWithTag:1000];
        [view removeFromSuperview];
    }
}

- (void)startKDWeibo {
    NSString *clientVersion = [KDCommon clientVersion];
    // save current version into local cache
    KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    [userDefaultAdapter storeObject:clientVersion forKey:KDWEIBO_USER_DEFAULTS_PREV_CLIENT_VERSION_KEY];
    
    KDWeiboAppDelegate *appDelegate = (KDWeiboAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate showTimelineViewController];
}

@end
