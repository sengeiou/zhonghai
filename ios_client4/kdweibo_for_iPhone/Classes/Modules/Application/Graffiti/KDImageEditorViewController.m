//
//  KDImageEditorViewController.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDImageEditorViewController.h"
#import "UIView+Frame.h"
// toolView
#import "KDColorChooseView.h"
#import "KDGraffitiToolView.h"
#import "KDTextEditView.h"
// board
#import "FingerDrawLine.h"
#import "KKTextView.h"
#import "KKCutTool.h"

@interface KDImageEditorViewController ()<KDColorChooseViewDelegate, KDGraffitiToolViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) KKImageToolBase *currentTool;
@property (nonatomic, strong) KDGraffitiToolView *graffitiTool;
@property (nonatomic, strong) UIColor *currentChooseColor;

@property (nonatomic, strong) FingerDrawLine *drawingLineView; // 涂鸦
@property (nonatomic, strong) UIView *workingView;       // 文本上层工作区
@property (nonatomic, strong) KDTextEditView *textEditView;  //文字编辑textView
@property (nonatomic, strong) KKTextView *textView; // 文本

@end

@implementation KDImageEditorViewController{
    UIImage *_originalImage;
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithNibName:nil bundle:nil];
    if (self){
        self.view.backgroundColor = [UIColor blackColor];
        self.currentChooseColor = [UIColor redColor];
    }
    return self;
}


- (instancetype)initWithImage:(UIImage*)image delegate:(id<KKImageEditorDelegate>)delegate{
    self = [self init];
    if (self){
        _originalImage = [image copy];
        self.delegate = delegate;
        
        
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
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(imageEditCancelClick)];
    
    self.title = @"编辑";
    [self initMenuView];
    [self initImageScrollView];
    [self initToolSettings];
    [self initNavigationBar];
    
    if(_imageView==nil){
        _imageView = [UIImageView new];
        [_scrollView addSubview:_imageView];
        [self refreshImageView];
    }
    
    _textEditView = [[KDTextEditView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width,136)];
    __weak KDImageEditorViewController *weakSelf = self;
    _textEditView.editTextComplete = ^(UITextView *textView) {
        [weakSelf textSaveBtnWithTextView:textView];
    };
    [self.view addSubview:_textEditView];
    
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self refreshImageView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"KDImageEditorViewController dealloc");
}

#pragma -mark view init

- (void)setUpDrawBoard {
    
    // 文字
    _workingView = [[UIView alloc] initWithFrame:self.imageView.bounds];
    _workingView.clipsToBounds = YES;
    _workingView.backgroundColor = [UIColor cyanColor];
    [self.imageView addSubview:_workingView];
    
    // 涂鸦
    _drawingLineView = [[FingerDrawLine alloc] initWithFrame:self.imageView.bounds];
    _drawingLineView.currentPaintBrushColor = [UIColor redColor];
    _drawingLineView.currentPaintBrushWidth = 4;
    [self.imageView addSubview:_drawingLineView];
    
    self.imageView.userInteractionEnabled = YES;
    self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
}


//底部工具view
- (void)initMenuView{
    if (_menuView == nil) {
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 80, self.view.width, 80)];
        _menuView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self.view addSubview:_menuView];
    }
}

//底层ScrollView
- (void)initImageScrollView
{
    if(_scrollView==nil){
//        UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
        UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 80 - 64)];
        
        imageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageScroll.showsHorizontalScrollIndicator = NO;
        imageScroll.showsVerticalScrollIndicator = NO;
        imageScroll.delegate = self;
        imageScroll.clipsToBounds = NO;
        
        [self.view insertSubview:imageScroll atIndex:0];
        _scrollView = imageScroll;
    }
}

//init工具 item
- (void)initToolSettings{
    
    KDColorChooseView *colorView = [[KDColorChooseView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 36)];
    colorView.delegate = self;
    colorView.hiddenReturn = NO;
    [_menuView addSubview:colorView];
    
    KDGraffitiToolView *toolView = [[KDGraffitiToolView alloc] initWithFrame:CGRectMake(0, 36, [UIScreen mainScreen].bounds.size.width, 44)];
    toolView.delegate = self;
    self.graffitiTool = toolView;
    [_menuView addSubview:toolView];
    
}

- (void)initNavigationBar{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(imageEditCancelClick)];
}

- (UIScrollView*)scrollView
{
    return _scrollView;
}

#pragma mark -- KDColorChooseViewDelegate
- (void)chooseColorWithColor:(UIColor *)color {
    self.currentChooseColor = color;
    if (self.drawingLineView) {
        self.drawingLineView.currentPaintBrushColor = [self convertColor:color];
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
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor))==kCGColorSpaceModelPattern) {
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
    if (!self.drawingLineView) {
        _drawingLineView = [[FingerDrawLine alloc] initWithFrame:self.imageView.bounds];
        [self.imageView addSubview:_drawingLineView];
        
        self.imageView.userInteractionEnabled = YES;
        self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
        self.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
        self.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    } else {
        [self.imageView bringSubviewToFront:self.drawingLineView];
    }
    _drawingLineView.currentPaintBrushColor = [self convertColor:self.currentChooseColor];
    
    if (self.textView) {
        [self.textView setAvtive:NO];
    }
    
    self.graffitiTool.drawBtn.selected = YES;
    self.graffitiTool.textBtn.selected = NO;
}
- (void)chooseText {
    // 文字容器的画板放到最上层
    if (!self.workingView) {
        _workingView = [[UIView alloc] initWithFrame:self.imageView.bounds];
        _workingView.clipsToBounds = YES;
        [self.imageView addSubview:_workingView];
        self.imageView.userInteractionEnabled = YES;
    } else {
        [self.imageView bringSubviewToFront:self.workingView];
    }
    
    // 添加文字
    if (_textView.label.text.length > 0) {
        
        [self showTextEditView:_textView.label.text];
    } else {
        [self showTextEditView:@""];
    }
    
    self.graffitiTool.textBtn.selected = YES;
    self.graffitiTool.drawBtn.selected = NO;
    
}
- (void)chooseCut {
    if (self.textView) {
        [self.textView setAvtive:NO];
    }
    
    UIImage *tmpImage = [self buildImage];
    [self refreshImageViewWith:tmpImage];
    
    KKCutTool *cutTool = [[KKCutTool alloc] initWithImageEditor:self];
    cutTool.tmpImage = tmpImage;
    self.currentTool = cutTool;
    
    if (self.drawingLineView) {
        self.drawingLineView.hidden = YES;
    }
    if (self.workingView) {
        self.workingView.hidden = YES;
    }
}
- (void)send {
    if (self.textView) {
        [self.textView setAvtive:NO];
    }
    
    UIImage *image = [self buildImage];
    if (image) {
        _originalImage = image;
    }
    
    __weak __typeof(self) weakSelf = self;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if([weakSelf.delegate respondsToSelector:@selector(imageDidFinishEdittingWithImage:)]){
            [weakSelf.delegate imageDidFinishEdittingWithImage:_originalImage];
        }
    }];
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
        return;
    }
    
    if (self.textView) {
        [self.textView removeFromSuperview];
    }
    
    KKTextView *view = [[KKTextView alloc] initWithEditor:self];
    self.textView = view;
    view.center = CGPointMake(_workingView.width/2, _workingView.height/2);
    
    [view setLableText:textView.text];
    [view setLableTextColor:textView.textColor];
    
    [_workingView addSubview:view];
    [KKTextView setActiveTextView:view];
    
}

- (UIImage *)buildImage {
    UIGraphicsBeginImageContextWithOptions(self.imageView.image.size, NO, self.imageView.image.scale);
    
    [self.imageView.image drawAtPoint:CGPointZero];
    
    if (self.drawingLineView) {
        [_drawingLineView.image drawInRect:CGRectMake(0, 0, self.imageView.image.size.width,self.imageView.image.size.height)];
    }
    
    if (self.textView) {
        CGFloat scale = self.imageView.image.size.width / _workingView.width;
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
        [_workingView.layer renderInContext:UIGraphicsGetCurrentContext()];
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
        
        _imageView.frame = CGRectMake(MAX(0, (_scrollView.width-W)/2), MAX(0, (_scrollView.height-H)/2), W, H);
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
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
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
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    if (self.workingView) {
        [self.workingView removeFromSuperview];
        self.workingView = nil;
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
                             _menuView.transform = CGAffineTransformMakeTranslation(0, self.view.height-_menuView.top);
                         }
                         else{
                             _menuView.transform = CGAffineTransformIdentity; //复位
                         }
                     }
     ];
    if(self.currentTool){
        [self updateNavigationItem];
    }else{
        self.navigationItem.hidesBackButton = NO;
        [self initNavigationBar];
    }

}

- (void)updateNavigationItem{
    UINavigationItem *item  = self.navigationItem;
    item.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(pushedCancelBtn:)];
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
    [UIView animateWithDuration:kImageToolAnimationDuration animations:^{
        _textEditView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 136);
    }];
}

@end
