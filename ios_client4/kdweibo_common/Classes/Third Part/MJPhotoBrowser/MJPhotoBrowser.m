//
//  MJPhotoBrowser.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "SDWebImageManager+MJ.h"
#import "MJPhotoView.h"
#import "MJPhotoToolbar.h"
#import "KDPhotoSheetView.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface MJPhotoBrowser () <MJPhotoViewDelegate, MJOriginalViewDelegate,UIActionSheetDelegate>
{
    // 滚动的view
    UIScrollView *_photoScrollView;
    // 所有的图片view
    NSMutableSet *_visiblePhotoViews;
    NSMutableSet *_reusablePhotoViews;
    // 工具条
    MJPhotoToolbar *_toolbar;
    
    // 一开始的状态栏
    BOOL _statusBarHiddenInited;
    
    UITapGestureRecognizer *tapGestureRecognizer;
}

@property (nonatomic, strong)UIButton *picEditorBtn;
@property (nonatomic, strong)KDPhotoSheetView *sheet;
@end

@implementation MJPhotoBrowser

#pragma mark - Lifecycle
- (void)loadView
{
    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
    self.bCanEdit = NO;
    
    if (tapGestureRecognizer) {
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
    
}
- (void)tap:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1.创建UIScrollView
    [self createScrollView];
    
    // 2.创建工具条
    [self createToolbar];
    
    //更多按钮
    [self.view  addSubview:self.buttonMore];
    
    [self.view addSubview:self.picEditorBtn];
}

- (void)show:(UIWindow *) window
{
    //    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    
    if (_currentPhotoIndex == 0) {
        [self showPhotos];
    }
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    
    if (_currentPhotoIndex == 0) {
        [self showPhotos];
    }
}
- (void)hide{
    
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    MJPhotoView *mjView = [self showingPhotoViewAtIndex:_currentPhotoIndex];
    if (mjView) {
        [mjView hide];
    }
    else{
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}
#pragma mark - 私有方法
#pragma mark 创建工具条
- (void)createToolbar
{
    CGFloat barHeight = 40;
    _toolbar = [[MJPhotoToolbar alloc] init];
    _toolbar.photoBrowser = self;
    _toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, barHeight);
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _toolbar.photos = _photos;
    if (self.bHideSavePhotoBtn) {
        _toolbar.canSavePhoto = NO;
    }
    [self.view addSubview:_toolbar];
    
    [self updateTollbarState];
    
    _toolbar.hidden = (_photos.count == 0);
}

#pragma mark -- toolbar display
-(void)hideToolBar
{
    if (_toolbar) {
        _toolbar.hidden = YES;
    }
}

-(void)showToolBar
{
    if (_toolbar) {
        _toolbar.hidden = NO;
    }
}

#pragma mark 创建UIScrollView
- (void)createScrollView
{
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
    _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
    _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _photoScrollView.pagingEnabled = YES;
    _photoScrollView.delegate = self;
    _photoScrollView.showsHorizontalScrollIndicator = NO;
    _photoScrollView.showsVerticalScrollIndicator = NO;
    _photoScrollView.backgroundColor = [UIColor clearColor];
    _photoScrollView.contentSize = CGSizeMake(frame.size.width * _photos.count, 0);
    [self.view addSubview:_photoScrollView];
    _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
    
    
    //长按手势
    UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_photoScrollView addGestureRecognizer:longPressGes];
    self.longPressGes = longPressGes;
    self.bHideMenuBar = self.bHideMenuBar;
}

- (void)setPhotos:(NSArray *)photos
{
    if (tapGestureRecognizer == nil) {
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    }
    
    tapGestureRecognizer.enabled = photos.count == 0;
    self.bHideMenuBar = self.bHideMenuBar;
    
    if (_toolbar) {
        
        _toolbar.hidden = photos.count == 0;
    }
    
    
    _photos = photos;
    
    if (photos.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    
    for (int i = 0; i<_photos.count; i++) {
        MJPhoto *photo = _photos[i];
        photo.index = i;
        photo.firstShow = i == _currentPhotoIndex;
    }
}

-(void)setBHideMenuBar:(BOOL)bHideMenuBar
{
    _bHideMenuBar = bHideMenuBar;
    self.longPressGes.enabled = ((self.photos.count != 0)&&(!self.bHideMenuBar));
    self.buttonMore.hidden = self.bHideMenuBar;
}

- (void)setBCanEdit:(BOOL)bCanEdit {
    if (bCanEdit) {
        self.picEditorBtn.hidden = NO;
    }
}

#pragma mark 设置选中的图片
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    for (int i = 0; i<_photos.count; i++) {
        MJPhoto *photo = _photos[i];
        photo.firstShow = i == currentPhotoIndex;
    }
    
    if ([self isViewLoaded]) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}


#pragma mark - MJPhotoToolbar代理
- (void)originalViewWillDissmiss
{
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    self.view.backgroundColor = [UIColor clearColor];
    
    [_photoScrollView removeFromSuperview];
    
    // 移除工具条
    [_toolbar removeFromSuperview];
}
- (void)originalViewDidDissmiss
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}
#pragma mark - MJPhotoView代理
- (void)photoViewSingleTap:(MJPhotoView *)photoView
{
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    self.view.backgroundColor = [UIColor clearColor];
    
    // 移除工具条
    [_toolbar removeFromSuperview];
}

- (void)photoViewDidEndZoom:(MJPhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView
{
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark 显示照片
- (void)showPhotos
{
    // 只有一张图片
    if (_photos.count <= 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
    int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
    int lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex =(int) _photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = (int)_photos.count - 1;
    
    // 回收不再显示的ImageView
    NSInteger photoViewIndex;
    for (MJPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [_reusablePhotoViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:(int)index];
        }
    }
}

#pragma mark 显示一个图片view
- (void)showPhotoViewAtIndex:(int)index
{
    if ([_photos count] == 0)
        return;
    
    MJPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[MJPhotoView alloc] init];
        photoView.photoViewDelegate = self;
        photoView.bHideMenuBar = self.bHideMenuBar;
    }
    
    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    [photoView prepareForReuse];
    
    
    
    MJPhoto *photo = nil;
    
    if (index < _photos.count) {
        photo = _photos[index];
    }
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
    
    [self loadImageNearIndex:index];
}

#pragma mark 加载index附近的图片
- (void)loadImageNearIndex:(int)index
{
    NSURL *photoUrl = nil;
    SDWebImageScaleOptions option = SDWebImageScalePreView;
    if (index > 0) {
        MJPhoto *photo = _photos[index - 1];
        photoUrl = photo.url;
        if ([photo.isOriginalPic isEqualToString:@"1"] && photo.direction == 0) {
            photoUrl = photo.midPictureUrl;
            option = SDWebImageScaleNone;
        }
        [SDWebImageManager downloadWithURL:photoUrl withImageScale:option];
    }
    
    if (index < _photos.count - 1) {
        MJPhoto *photo = _photos[index + 1];
        photoUrl = photo.url;
        if ([photo.isOriginalPic isEqualToString:@"1"]&& photo.direction == 0) {
            option = SDWebImageScaleNone;
            photoUrl = photo.midPictureUrl;
        }
        [SDWebImageManager downloadWithURL:photoUrl withImageScale:option];
    }
}
#pragma mark index当前显示的view
- (MJPhotoView *)showingPhotoViewAtIndex:(NSUInteger)index {
    for (MJPhotoView *photoView in _visiblePhotoViews) {
        if (kPhotoViewIndex(photoView) == index) {
            return photoView;
        }
    }
    return  nil;
}
#pragma mark index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (MJPhotoView *photoView in _visiblePhotoViews) {
        if (kPhotoViewIndex(photoView) == index) {
            return YES;
        }
    }
    return  NO;
}

#pragma mark 循环利用某个view
- (MJPhotoView *)dequeueReusablePhotoView
{
    MJPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    return photoView;
}

#pragma mark 更新toolbar状态
- (void)updateTollbarState
{
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
    [self updateTollbarState];
}



- (UIButton *)buttonMore
{
    if (!_buttonMore) {
        _buttonMore = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonMore.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-60, [UIScreen mainScreen].bounds.size.height - 40, 50, 30);
        [_buttonMore setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [_buttonMore setTitle:@"更多" forState:UIControlStateNormal];
        //        UIImage *image = [UIImage imageNamed:@"pic_btn_font"];
        //        image = [image stretchedImageWithLeftCapRatio:0.2 topCapRatio:0.2];
        //        [_buttonMore setBackgroundImage:image forState:UIControlStateNormal];
        _buttonMore.layer.borderWidth = 0.5;
        _buttonMore.layer.borderColor = [UIColor whiteColor].CGColor;
        _buttonMore.layer.cornerRadius = 3;
        _buttonMore.layer.masksToBounds = YES;
        [_buttonMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buttonMore.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_buttonMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buttonMore addTarget:self action:@selector(buttonMorePressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonMore;
}

-(void)buttonMorePressed:(UIButton *)btn
{
    [self showMenu];
}

-(void)showMenu
{
    if(_currentPhotoIndex>=_photos.count)
        return;
    
    MJPhoto *photo = _photos[_currentPhotoIndex];
    if(photo == nil)
        return;
    
    
    if (isAboveiOS8) {
        NSMutableArray *actionArray = [NSMutableArray array];
        __weak typeof(self) weakSelf = self;
        if(_bCanTransmit) {
            KDPhotoSheetModel *model = [[KDPhotoSheetModel alloc] initWithTitle:ASLocalizedString(@"转发") tapBlock:^{
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(photoBrowser:transmitWithPhoto:)])
                    [weakSelf.delegate photoBrowser:weakSelf transmitWithPhoto:photo];
            }];
            [actionArray addObject:model];
        }
        if(_bCanCollect) {
            KDPhotoSheetModel *model = [[KDPhotoSheetModel alloc] initWithTitle:ASLocalizedString(@"收藏") tapBlock:^{
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(photoBrowser:collectWithPhoto:)])
                    [weakSelf.delegate photoBrowser:weakSelf collectWithPhoto:photo];
            }];
            [actionArray addObject:model];
        }
        if(!_bHideToolBar || !_bHideSavePhotoBtn) {
            KDPhotoSheetModel *model = [[KDPhotoSheetModel alloc] initWithTitle:ASLocalizedString(@"保存到手机") tapBlock:^{
                [_toolbar saveImage];
            }];
            [actionArray addObject:model];
        }
        if([photo isQRCodeImage]) {
            KDPhotoSheetModel *model = [[KDPhotoSheetModel alloc] initWithTitle:ASLocalizedString(@"Scan_QRCode") tapBlock:^{
                NSString *url = [photo scanQRWithImage:photo.image];
                if(url.length > 0)
                {
                    if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(photoBrowser:scanWithresult:)])
                        [weakSelf.delegate photoBrowser:weakSelf scanWithresult:url];
                }
            }];
            [actionArray addObject:model];
        }
        
        
        if (actionArray.count == 0) {
            return;
        }
        KDPhotoSheetView *sheet = [[KDPhotoSheetView alloc] initWithPhotoSheetModelArray:actionArray];
        self.sheet = sheet;
        [sheet showPhotoSheet];
    } else {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
        if(_bCanTransmit)
            [actionSheet addButtonWithTitle:ASLocalizedString(@"转发")];
        if(_bCanCollect)
            [actionSheet addButtonWithTitle:ASLocalizedString(@"收藏")];
        if(!_bHideToolBar || !_bHideSavePhotoBtn)
            [actionSheet addButtonWithTitle:ASLocalizedString(@"保存到手机")];
        if([photo isQRCodeImage])
            [actionSheet addButtonWithTitle:ASLocalizedString(@"Scan_QRCode")];
        
        if([actionSheet buttonTitleAtIndex:0])
            [actionSheet showInView:[UIApplication sharedApplication].delegate.window];
    }
}

-(void)longPress:(UILongPressGestureRecognizer *)ges
{
    if(ges.state == UIGestureRecognizerStateBegan)
    {
        [self showMenu];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(_currentPhotoIndex>=_photos.count)
        return;
    
    MJPhoto *photo = _photos[_currentPhotoIndex];
    if(photo == nil)
        return;
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:ASLocalizedString(@"Scan_QRCode")])
    {
        NSString *url = [photo scanQRWithImage:photo.image];
        if(url.length > 0)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:scanWithresult:)])
                [self.delegate photoBrowser:self scanWithresult:url];
        }
    }
    else if([title isEqualToString:ASLocalizedString(@"转发")])
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:transmitWithPhoto:)])
            [self.delegate photoBrowser:self transmitWithPhoto:photo];
    }
    else if([title isEqualToString:ASLocalizedString(@"收藏")])
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:collectWithPhoto:)])
            [self.delegate photoBrowser:self collectWithPhoto:photo];
    }
    else if([title isEqualToString:ASLocalizedString(@"保存到手机")])
    {
        [_toolbar saveImage];
    }
}

- (UIButton *)picEditorBtn {
    if (!_picEditorBtn) {
        _picEditorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _picEditorBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 110, [UIScreen mainScreen].bounds.size.height - 40, 36, 30);
        [_picEditorBtn setImage:[UIImage imageNamed:@"icon_edit_picture_click"] forState:UIControlStateNormal];
        [_picEditorBtn setImage:[UIImage imageNamed:@"icon_edit_picture"] forState:UIControlStateHighlighted];
        _picEditorBtn.hidden = YES;
        [_picEditorBtn addTarget:self action:@selector(picEditorBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _picEditorBtn;
}

- (void)picEditorBtnClick {
    DLog(@"点击了图片编辑按钮");
    if(self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:sendAgainWithPhoto:)]) {
        MJPhoto *photo;
        MJPhotoView *mjView = [self showingPhotoViewAtIndex:_currentPhotoIndex];
        if (!mjView) {
            photo = [self.photos objectAtIndex:_currentPhotoIndex];
        } else {
            photo = mjView.photo;
        }
        [self.delegate photoBrowser:self sendAgainWithPhoto:photo];
    }
}

@end