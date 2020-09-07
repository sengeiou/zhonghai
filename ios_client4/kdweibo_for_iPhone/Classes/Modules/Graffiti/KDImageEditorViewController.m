//
//  KDImageEditorViewController.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDImageEditorViewController.h"

// toolView
#import "KDColorChooseView.h"
#import "KDGraffitiToolView.h"
#import "KDTextEditView.h"
// board
#import "FingerDrawLine.h"
#import "KKTextView.h"
#import "KKCutTool.h"

//CGFloat const deleteViewH = 64.0;

@interface KDImageEditorViewController ()<KDColorChooseViewDelegate, KDGraffitiToolViewDelegate, UITextViewDelegate, KKTextViewDelegate>

@property (nonatomic, strong) KKImageToolBase *currentTool;
@property (nonatomic, strong) KDGraffitiToolView *graffitiTool;
@property (nonatomic, strong) KDColorChooseView *colorChooseView;
@property (nonatomic, strong) UIColor *currentChooseColor;

@property (nonatomic, strong) FingerDrawLine *drawingLineView; // 涂鸦
@property (nonatomic, strong) UIView *workingView;       // 文本上层工作区
@property (nonatomic, strong) KDTextEditView *textEditView;  //文字编辑textView
@property (nonatomic, strong) KKTextView *textView; // 文本
@property (nonatomic, strong) UIView *deleteView;

@property (nonatomic, strong) UIView *topNaviView;
@property (nonatomic, strong) UIButton *leftButton;

@end

@implementation KDImageEditorViewController{
    UIImage *_originalImage;
    
}

- (UIView *)deleteView {
    if (!_deleteView) {
        _deleteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kd_StatusBarAndNaviHeight)];
        _deleteView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
//        [[UIApplication sharedApplication].windows.firstObject addSubview:_deleteView];
        
        UIImageView *deleteImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        deleteImage.image = [UIImage imageNamed:@"message_popup_delete"];
        deleteImage.center = _deleteView.center;
        [_deleteView addSubview:deleteImage];
    }
    return _deleteView;
}

- (instancetype)init
{
    self = [super init];
    if (self){
        self.view.backgroundColor = [UIColor blackColor];
        self.currentChooseColor = [UIColor redColor];
        self.type = Draw;
        self.isFromCamera = NO;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage*)image delegate:(id<KKImageEditorDelegate>)delegate{
    self = [self init];
    if (self){
        _originalImage = [image copy];
        _delegate = delegate;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [self init];
    if (self) {
        _originalImage = [image copy];
    }
    
    return self;
}

#pragma mark- view life
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
    
//    self.title = ASLocalizedString(@"KDOrganiztionCell_Edit");
    
    [self setupView];
    [self initNavigationBar];
    
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self setNavigationCustomStyleWithColor:[UIColor blackColor]];
    
    [self refreshImageView];
    // 默认设置
    [self setUpDrawBoard];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self setNavigationStyle:KDNavigationStyleNormal];
    
    if (self.workingView) {
        [self.workingView removeFromSuperview];
        self.workingView = nil;
    }
    if (self.textEditView) {
        [self.textEditView removeFromSuperview];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma -mark view init

- (void)setupView {
    self.topNaviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, kd_StatusBarAndNaviHeight)];
    self.topNaviView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.topNaviView];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton = leftButton;
    [leftButton setTitle:ASLocalizedString(@"Global_Cancel") forState:UIControlStateNormal];
    leftButton.titleLabel.font = FS3;
    [leftButton setTitleColor:FC6 forState:UIControlStateNormal];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [leftButton addTarget:self action:@selector(imageEditCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topNaviView addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.topNaviView.left).with.offset(12);
        make.centerY.equalTo(self.topNaviView).with.offset(kd_StatusBarHeight/2);
        
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = ASLocalizedString(@"KDOrganiztionCell_Edit");;
    titleLabel.font = FS1;
    titleLabel.textColor = FC6;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.topNaviView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
        make.centerX.equalTo(self.topNaviView);
        make.centerY.equalTo(self.topNaviView).with.offset(kd_StatusBarHeight/2);
        
    }];
    
    UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, ScreenFullHeight - 80 - kd_StatusBarAndNaviHeight - kd_BottomSafeAreaHeight)];
    imageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageScroll.showsHorizontalScrollIndicator = NO;
    imageScroll.showsVerticalScrollIndicator = NO;
    imageScroll.delegate = self;
    imageScroll.clipsToBounds = NO;
    [self.view addSubview:imageScroll];
    _scrollView = imageScroll;
    
    if(_imageView==nil){
        _imageView = [UIImageView new];
        _imageView.userInteractionEnabled = YES;
        [_scrollView addSubview:_imageView];
        [self refreshImageView];
    }
    
    // 添加文字的工作空间
    self.workingView = [[UIView alloc] init];
    // 注意这里的位置要和scrollView保持一样
    self.workingView.frame = CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, ScreenFullHeight - 80 - kd_StatusBarAndNaviHeight - kd_BottomSafeAreaHeight);
    self.workingView.userInteractionEnabled = NO;
    [self.view addSubview:_workingView];
    
    // set up menu
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollView.frame), self.view.frame.size.width, 80)];
    _menuView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:_menuView];
    
    [self initToolSettings];
    
    // 文本输入框
    _textEditView = [[KDTextEditView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width,136)];
    __weak KDImageEditorViewController *weakSelf = self;
    _textEditView.editTextComplete = ^(UITextView *textView) {
        [weakSelf textSaveBtnWithTextView:textView];
    };
    [self.view addSubview:_textEditView];
}

- (void)setUpDrawBoard {
    if (self.drawingLineView) {
        [self.imageView addSubview:_drawingLineView];
        return;
    }
    self.type = Draw;
    _drawingLineView = [[FingerDrawLine alloc] initWithFrame:self.imageView.bounds];
    _drawingLineView.userInteractionEnabled = YES;
    [self.imageView addSubview:_drawingLineView];
    
    self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    [self.imageView bringSubviewToFront:self.drawingLineView];
    self.graffitiTool.drawBtn.selected = YES;
    self.colorChooseView.hidden = NO;
}

//init工具 item
- (void)initToolSettings{
    KDColorChooseView *colorView = [[KDColorChooseView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 36)];
    colorView.delegate = self;
    colorView.hiddenReturn = NO;
    colorView.hiddenMosaic = NO;
    self.colorChooseView = colorView;
    [_menuView addSubview:colorView];
    
    KDGraffitiToolView *toolView = [[KDGraffitiToolView alloc] initWithFrame:CGRectMake(0, 36, [UIScreen mainScreen].bounds.size.width, 44)];
    toolView.delegate = self;
    self.graffitiTool = toolView;
    [_menuView addSubview:toolView];
    
}

- (void)initNavigationBar{
    [self.leftButton removeTarget:self action:@selector(pushedCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.isFromCamera) {
        [self.leftButton setTitle:ASLocalizedString(@"Global_Rerecord") forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(imageEditCancelClick) forControlEvents:UIControlEventTouchUpInside];
        
        
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Rerecord") style:UIBarButtonItemStylePlain target:self action:@selector(imageEditCancelClick)];
    } else {
        [self.leftButton setTitle:ASLocalizedString(@"Global_Cancel") forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(imageEditCancelClick) forControlEvents:UIControlEventTouchUpInside];
        
        
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(imageEditCancelClick)];
    }
}

- (UIScrollView*)scrollView
{
    return _scrollView;
}

- (void)setIsFromCamera:(BOOL)isFromCamera {
    _isFromCamera = isFromCamera;
    if (isFromCamera) {
        [self.leftButton setTitle:ASLocalizedString(@"Global_Rerecord") forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(imageEditCancelClick) forControlEvents:UIControlEventTouchUpInside];
        
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Rerecord") style:UIBarButtonItemStylePlain target:self action:@selector(imageEditCancelClick)];
    }
}

#pragma mark -- KDColorChooseViewDelegate
- (void)chooseColorWithColor:(UIColor *)color {
    self.currentChooseColor = color;
    if (self.drawingLineView) {
        self.drawingLineView.currentPaintBrushColor = [self convertColor:color];
    }
    
    if (self.type == Text && self.textView) {
        self.textView.label.textColor = color;
    }
}
- (void)clickReturn {
    if (self.drawingLineView) {
        if (self.drawingLineView.allMyDrawPaletteLineInfos.count > 0) {
            [self.drawingLineView cleanFinallyDraw];
        }
    }
}

- (UIColor *)convertColor:(UIColor *)color {
    UIColor *tmpColor;
    // 马赛克
    if
        (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor))==kCGColorSpaceModelPattern) {
        tmpColor = [UIColor colorWithPatternImage:[self pixellateImage]];
        self.drawingLineView.currentPaintBrushWidth = 8.0;
    } else {
        tmpColor = color;
        self.drawingLineView.currentPaintBrushWidth = 4.0;
    }
    return tmpColor;
}

- (UIImage *)pixellateImage {
    CIImage *ciImage = [[CIImage alloc] initWithImage:[self pixellateBackGroundImage]];
    //生成马赛克
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setValue:ciImage  forKey:kCIInputImageKey];
    //马赛克像素大小
    [filter setValue:@(10) forKey:kCIInputScaleKey];
    CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outImage fromRect:[outImage extent]];
    UIImage *showImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return showImage;
}

- (UIImage *)pixellateBackGroundImage {
    
    UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, NO, self.imageView.image.scale);
    
    [self.imageView.image drawInRect:CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tmp;
}

#pragma mark - KDGraffitiToolViewDelegate
- (void)choosePencil {
    self.type = Draw;
    if (!self.drawingLineView) {
        _drawingLineView = [[FingerDrawLine alloc] initWithFrame:self.imageView.bounds];
        [self.imageView addSubview:_drawingLineView];
        
        _drawingLineView.userInteractionEnabled = YES;
        self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
        self.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
        self.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    } else {
        _drawingLineView.hidden = NO;
        _drawingLineView.userInteractionEnabled = YES;
        if (self.workingView) {
            self.workingView.userInteractionEnabled = NO;
        }
    }
    _drawingLineView.currentPaintBrushColor = [self convertColor:self.currentChooseColor];
    
    self.colorChooseView.hiddenReturn = NO;
    self.colorChooseView.hiddenMosaic = NO;
    self.colorChooseView.returnBtn.hidden = NO;
    self.graffitiTool.drawBtn.selected = YES;
    self.graffitiTool.textBtn.selected = NO;
    self.colorChooseView.hidden = NO;
}
- (void)chooseText {
    self.type = Text;
    self.workingView.hidden = NO;
    self.workingView.userInteractionEnabled = YES;
    if (self.drawingLineView) {
        self.drawingLineView.userInteractionEnabled = NO;
    }
    
    // 添加文字
    if (_textView.label.text.length > 0) {
        [self showTextEditView:_textView.label.text];
    } else {
        [self showTextEditView:@""];
    }
    
    self.colorChooseView.hiddenReturn = YES;
    self.colorChooseView.hiddenMosaic = YES;
    self.colorChooseView.returnBtn.hidden = YES;
    self.graffitiTool.textBtn.selected = YES;
    self.graffitiTool.drawBtn.selected = NO;
    self.colorChooseView.hidden = YES;
}
- (void)chooseCut {
    self.type = Cut;
    
    UIImage *tmpImage = [self buildImage];
    [self refreshImageViewWith:tmpImage];
    
    KKCutTool *cutTool = [[KKCutTool alloc] initWithImageEditor:self];
    cutTool.tmpImage = tmpImage;
    self.currentTool = cutTool;
    
    if (self.drawingLineView) {
        self.drawingLineView.hidden = YES;
        self.drawingLineView.userInteractionEnabled = NO;
    }
    if (self.workingView) {
        self.workingView.hidden = YES;
        self.workingView.userInteractionEnabled = NO;
    }
    self.colorChooseView.hidden = YES;
}
- (void)send {
    
    UIImage *image = [self buildImage];
    if (image) {
        _originalImage = image;
    }
    
    __weak __typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if([weakSelf.delegate respondsToSelector:@selector(imageDidFinishEdittingWithImage:)]){
            [weakSelf.delegate imageDidFinishEdittingWithImage:_originalImage];
        }
    }];
}

#pragma mark - KKTextViewDelegate
- (void)handelPanGestureView:(KKTextView *)textView withGR:(UIPanGestureRecognizer *)pan {
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.workingView.layer.mask = nil;
        [[UIApplication sharedApplication].windows.firstObject addSubview:self.deleteView];
        self.topNaviView.hidden = YES;
    }
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        if ([self isDeleteRange]) {
            self.deleteView.backgroundColor = [[UIColor colorWithHexRGB:@"0xEA5950"] colorWithAlphaComponent:0.6];
        } else {
            self.deleteView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        }
        
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        if ([self isDeleteRange]) {
            [self deleteTextView];
        }
        
//        UIBezierPath *pathh = [UIBezierPath bezierPathWithRect:CGRectMake(1, 1, self.drawingLineView.frame.size.width - 2, self.drawingLineView.frame.size.height - 2)];
        UIBezierPath *pathh = [UIBezierPath bezierPathWithRect:self.imageView.frame];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = pathh.CGPath;
        _workingView.layer.mask = maskLayer;
        
        if (self.deleteView) {
            [self.deleteView removeFromSuperview];
        }
        
        self.topNaviView.hidden = NO;
    }
}

- (BOOL)isDeleteRange{
    if (self.textView.center.y < -(self.workingView.frame.origin.y - kd_StatusBarAndNaviHeight) || self.textView.center.y > (CGRectGetHeight(self.workingView.frame))) {
        return YES;
    }
    return NO;
}

- (void)deleteTextView {
    self.textView.label.text = nil;
    [self.textView removeFromSuperview];
    self.textView = nil;
}

//文字编辑view
- (void)showTextEditView:(NSString *)text{
    if (text) {
        [_textEditView.textView setText:text];
    }
    [_textEditView.textView becomeFirstResponder];
}

- (void)textSaveBtnWithTextView:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        if (self.textView) {
            [self deleteTextView];
        }
        return;
    }
    
    
    CGPoint center = CGPointMake(_workingView.frame.size.width/2, _workingView.frame.size.height/2);
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (self.textView) {
        center = self.textView.center;
        transform = self.textView.transform;
        [self.textView removeFromSuperview];
    }
    
    KKTextView *view = [[KKTextView alloc] initWithEditor:self];
    view.delegate = self;
    self.textView = view;
    view.center = center;
    __weak KDImageEditorViewController *weakSelf = self;
    view.tapTextBlock = ^{
        [weakSelf showTextEditView:weakSelf.textView.label.text];
    };
    
    [view setLableText:textView.text];
    [view setLableTextColor:textView.textColor];
    view.center = center;
    view.transform = transform;
    [_workingView addSubview:view];
    [KKTextView setActiveTextView:view];
    
}

- (UIImage *)buildImage {
    // 还没想到更好的办法，暂时先这样处理吧
    UIGraphicsBeginImageContextWithOptions(self.workingView.bounds.size, NO, 1);
    
    if (self.textView) {
        [_workingView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *resultTextImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(textImage.CGImage, self.imageView.frame)];
    
    
    UIGraphicsBeginImageContextWithOptions(self.imageView.image.size, NO, self.imageView.image.scale);
    
    [self.imageView.image drawAtPoint:CGPointZero];
    
    if (self.drawingLineView) {
        [_drawingLineView.image drawInRect:CGRectMake(0, 0, self.imageView.image.size.width,self.imageView.image.size.height)];
    }
    if (resultTextImage) {
        CGFloat scale = self.imageView.image.size.width / resultTextImage.size.width;
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
        [resultTextImage drawAtPoint:CGPointZero];
    }
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tmp;
}


#pragma -mark FrameChange
- (void)resetImageViewFrame
{
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width * _scrollView.zoomScale;
        CGFloat H = ratio * size.height * _scrollView.zoomScale;
        
        _imageView.frame = CGRectMake(MAX(0, (_scrollView.frame.size.width-W)/2), MAX(0, (_scrollView.frame.size.height-H)/2), W, H);
    }
}

- (void)fixZoomScaleWithAnimated:(BOOL)animated
{
    CGFloat minZoomScale = _scrollView.minimumZoomScale;
    _scrollView.maximumZoomScale = 0.95*minZoomScale;
    _scrollView.minimumZoomScale = 0.95*minZoomScale;
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}

- (void)resetZoomScaleWithAnimated:(BOOL)animated
{
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 1;//MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}

- (void)refreshImageView
{
    _imageView.image = _originalImage;
    
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
}

- (void)refreshImageViewWith:(UIImage *)rotateImage
{
    _imageView.image = rotateImage;
    
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
}

- (BOOL)shouldAutorotate
{
    return NO;
}


#pragma -mark Tap Action
- (void)imageEditCancelClick {
    if (self.type == Text && [self.textEditView.textView isFirstResponder]) {
        [self.textEditView.textView resignFirstResponder];
        
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushedCancelBtn:(id)sender
{
    if (self.drawingLineView) {
        self.drawingLineView.hidden = NO;
    }
    if (self.workingView) {
        self.workingView.hidden = NO;
    }
    
    _imageView.image = _originalImage;
    [self resetImageViewFrame];
    
    self.currentTool = nil;
}

- (void)pushedDoneBtn:(id)sender
{
    self.view.userInteractionEnabled = NO;
    
    [self.currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        if(error){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if(image){
            _originalImage = image;
            _imageView.image = image;
            
            [self resetImageViewFrame];
            self.currentTool = nil;
        }
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)clearBoard {
    if (self.drawingLineView) {
        [self.drawingLineView removeFromSuperview];
        self.drawingLineView = nil;
    }
    if (self.textView) {
        [self deleteTextView];
    }
    if (self.currentChooseColor) {
        self.currentChooseColor = [UIColor redColor];
    }
}

//初始化当前工具
- (void)setCurrentTool:(KKImageToolBase *)currentTool
{
    if (currentTool == nil) {
        self.graffitiTool.drawBtn.selected = NO;
        self.graffitiTool.textBtn.selected = NO;
    }
    if(currentTool != _currentTool){
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
        
        [self swapToolBarWithEditting:(_currentTool!=nil)];
    }
}

//修改工具栏和导航栏
- (void)swapToolBarWithEditting:(BOOL)editting
{
    [UIView animateWithDuration:kImageToolAnimationDuration
                     animations:^{
                         if(editting){
                             _menuView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height-_menuView.frame.origin.y);
                         }
                         else{
                             _menuView.transform = CGAffineTransformIdentity; //复位
                         }
                     }
     ];
    if(self.currentTool){
        [self updateNavigationItem];
    }else{
//        self.navigationItem.hidesBackButton = NO;
        [self initNavigationBar];
    }

}

- (void)updateNavigationItem{
    [self.leftButton setTitle:ASLocalizedString(@"Global_Cancel") forState:UIControlStateNormal];
    [self.leftButton removeTarget:self action:@selector(imageEditCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton addTarget:self action:@selector(pushedCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    
//    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(pushedCancelBtn:)];
//    item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(pushedDoneBtn:)];
//    self.navigationItem.hidesBackButton = YES;
}

#pragma mark- ScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _imageView.frame.size.width;
    CGFloat H = _imageView.frame.size.height;
    
    CGRect rct = _imageView.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _imageView.frame = rct;
}

#pragma mark - 键盘监听
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    self.workingView.userInteractionEnabled = NO;
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        _textEditView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - height - 136, [UIScreen mainScreen].bounds.size.width, 136);
    }];
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
    self.workingView.userInteractionEnabled = YES;
    [UIView animateWithDuration:kImageToolAnimationDuration animations:^{
        _textEditView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 136);
    }];
}

@end
