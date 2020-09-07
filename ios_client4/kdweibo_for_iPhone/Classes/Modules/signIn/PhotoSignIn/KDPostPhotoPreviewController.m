//
//  KDPostPhotoPreviewController.m
//  kdweibo
//
//  Created by 王 松 on 13-7-22.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDPostPhotoPreviewController.h"
#import "KDTileView.h"
#import "KDPhotoTileViewCell.h"

#import <QuartzCore/QuartzCore.h>


#define isEdgeVertical(d) (!((d) & 1))
#define isEdgeNegative(d) (((d) & 2))
#define axisForEdge(d) ((BCAxis)isEdgeVertical(d))
#define perpAxis(d) ((BCAxis)(!(BOOL)d))

typedef NS_ENUM(NSInteger, BCAxis) {
    BCAxisX = 0,
    BCAxisY = 1
};

typedef union BCPoint
{
    struct { double x, y; };
    double v[2];
}
BCPoint;

static inline BCPoint BCPointMake(double x, double y)
{
    BCPoint p; p.x = x; p.y = y; return p;
}

typedef union BCTrapezoid {
    struct { BCPoint a, b, c, d; };
    BCPoint v[4];
} BCTrapezoid;


typedef struct BCSegment {
    BCPoint a;
    BCPoint b;
} BCSegment;

static inline BCSegment BCSegmentMake(BCPoint a, BCPoint b)
{
    BCSegment s; s.a = a; s.b = b; return s;
}

typedef BCSegment BCBezierCurve;


@interface KDPostPhotoPreviewController ()<KDTileViewDataSource, UIScrollViewDelegate>

@property (nonatomic, retain) UIToolbar *bottomView;

@property (nonatomic, retain) KDTileView *tileView;

- (void)setViews;

- (void)finish:(id)sender;

@end

@implementation KDPostPhotoPreviewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setViews];
}

#define kDoneBtnTag (int)1001
#define kCancelBtnTag (int)1002
#define kanimitionVIewTag (int)1003

- (void)setViews
{
    CGRect bottomRect = CGRectMake(0.0f, self.view.frame.size.height - 60.0f, self.view.frame.size.width, 60.f);
    _bottomView = [[UIToolbar alloc] initWithFrame:bottomRect];
    _bottomView.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:_bottomView];
    
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish:)];
    doneItem.tag = kDoneBtnTag;
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(finish:)];
    
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhoto:)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [_bottomView setItems:@[cancelItem, flex, deleteItem, flex, doneItem] animated:NO];
//    [deleteItem release];
//    [doneItem release];
//    [cancelItem release];
//    [flex release];
    
    // init title view
    
    CGSize size = self.view.bounds.size;
    
    _tileView = [[KDTileView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height - 60.f) style:KDTileViewStyleGridPage cellWidth:size.width paddingWidth:20.f];
    _tileView.dataSource = self;
    _tileView.delegate = self;
    [self.view addSubview:_tileView];
    
    [_tileView scrollToColumn:_currentIndex];
}

- (void)finish:(UIBarButtonItem *)sender
{
    BOOL isDone = sender.tag == kDoneBtnTag;
    if ([self.delegate respondsToSelector:@selector(postPhotoPreview:done:userInfo:)]) {
        [self.delegate postPhotoPreview:self done:isDone userInfo:[self userInfo]];
    }
}

- (void)removeLast
{
    if ([self.delegate respondsToSelector:@selector(postPhotoPreview:done:userInfo:)]) {
        [self.delegate postPhotoPreview:self done:YES userInfo:[self userInfo]];
    }
}

- (NSDictionary *)userInfo
{
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:_cachedImageURLs, @"CachedImageURLs", _cachedAssetURLs, @"CachedAssetURLs", nil];
    return info;
}

- (void)deletePhoto:(UIBarButtonItem *)sender
{
    if (_currentIndex < [_cachedImageURLs count]) {
        [self removeCurrentViewAnimated];
        [_cachedImageURLs removeObjectAtIndex:_currentIndex];
        [_cachedAssetURLs removeObjectAtIndex:_currentIndex];
    }
    
    if ([_cachedImageURLs count] > 0) {
        [self shouldScrollToIndex];
        [_tileView reloadData];
        _tileView.dataSource = nil;
        _tileView.dataSource = self;
        [_tileView scrollToColumn:_currentIndex];
    }else {
        [self removeLast];
    }
    
}

- (NSUInteger)shouldScrollToIndex
{
    if (_currentIndex >= [_cachedImageURLs count]) {
        _currentIndex = _currentIndex - 1;
    }
    return _currentIndex;
}

#pragma mark
#pragma mark KDTileView delegate

- (NSUInteger)numberOfColumnsAtTileView:(KDTileView *)tileView
{
    return [_cachedImageURLs count];
}

- (KDTileViewCell *)tileView:(KDTileView *)tileView cellForColumn:(NSInteger)column
{
    static NSString *CellIdentifier = @"Cell";
    KDPhotoPreviewTileViewCell *cell = (KDPhotoPreviewTileViewCell *)[tileView dequeueReuseableCellWithIndentifier:CellIdentifier];
    if(cell == nil){
        cell = [[KDPhotoPreviewTileViewCell alloc] initWithIdentifier:CellIdentifier];// autorelease];
    }
    
    NSString *url = [_cachedImageURLs objectAtIndex:column];
    
    UIImage *image = [self imageAtIndex:column];
    
    cell.userInfo = url;
    [cell displayImage:image imageType:KDTileViewCellImageTypePreview];
    
    return cell;
}

- (UIImage *)imageAtIndex:(NSUInteger)index
{
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:[_cachedImageURLs objectAtIndex:index]] ;//'//'autorelease];
    
    return [UIImage imageWithData:data];
    
}

#pragma mark

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self didScrollTileView];
}

- (void)didScrollTileView {
    KDTileViewCell *centerCell = [_tileView centerTileViewCell];
    if(centerCell != nil){
        NSInteger index = [[_tileView visibleCells] indexOfObject:centerCell];
        NSInteger column = [[[_tileView visibleColumns] objectAtIndex:index] integerValue];
        
        if(_currentIndex != column){
            _currentIndex = column;
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
        }
    }
}

- (void)setCachedImageURLs:(NSMutableArray *)cachedImageURLs
{
    if (_cachedImageURLs != cachedImageURLs) {
//        [_cachedImageURLs release];
        _cachedImageURLs = [cachedImageURLs mutableCopy];
    }
}

- (void)setCachedAssetURLs:(NSMutableArray *)cachedAssetURLs
{
    if (_cachedAssetURLs != cachedAssetURLs) {
//        [_cachedAssetURLs release];
        _cachedAssetURLs = [cachedAssetURLs mutableCopy];
    }
}
static CGFloat DEGREES_TO_RADIANS(CGFloat degrees) {return degrees * M_PI / 180;};
- (void)removeCurrentViewAnimated
{
    UIImage *currentImage = [self imageAtIndex:_currentIndex];
    
    UIImageView *temp = (UIImageView *)[self.view viewWithTag:kanimitionVIewTag];
    
    CGRect frame = self.tileView.frame;
    
    frame.size.width -= 20.f;
    frame.origin.x = 10.f;
    temp.frame = frame;
    temp = [[UIImageView alloc] initWithFrame:frame];
    
    temp.image = currentImage;
    
    [self.view.layer addSublayer:temp.layer];
    
    transitionLayer = temp.layer;
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:transitionLayer.position];
    positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_tileView.frame.size.width, _tileView.frame.size.height)];
    
    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithCGRect:transitionLayer.bounds];
    boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectZero];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.5];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:2 * M_PI];
    rotateAnimation.toValue =  [NSNumber numberWithFloat:0 * M_PI];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.beginTime = CACurrentMediaTime() + 0.25;
    group.duration = 0.5;
    group.animations = [NSArray arrayWithObjects:positionAnimation, boundsAnimation, opacityAnimation, rotateAnimation, nil];
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    
    [transitionLayer addAnimation:group forKey:@"remove"];
    
//    [temp release];
//
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if ([theAnimation isKindOfClass:[CAAnimationGroup class]] && transitionLayer.superlayer == self.view.layer) {
        [transitionLayer removeAllAnimations];
        [transitionLayer removeFromSuperlayer];
        transitionLayer = nil;
    }
}



- (void)dealloc
{
    //KD_RELEASE_SAFELY(_bottomView);
    //KD_RELEASE_SAFELY(_cachedImageURLs);
    //KD_RELEASE_SAFELY(_tileView);
    //[super dealloc];
}

@end
