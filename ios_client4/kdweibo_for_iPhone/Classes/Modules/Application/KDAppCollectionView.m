//
//  KDAppCollectionView.m
//  kdweibo
//
//  Created by Joyingx on 16/9/5.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDAppCollectionView.h"
// :: Other ::
#import "KDAppCollectionViewCell.h"
#import "KDAppCollectionViewLayout.h"
#import "KDApplicationCommon.h"

@interface KDAppCollectionView ()

@property (nonatomic, strong) UIView *snapshotView;

@property (nonatomic, strong) NSIndexPath *snapshotIndexPath;
@property (nonatomic, assign) CGPoint snapshotPanPoint;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;

@end

@implementation KDAppCollectionView

+ (UICollectionViewLayout *)layout {
    UICollectionViewFlowLayout *layout = [[KDAppCollectionViewLayout alloc] init];
    layout.itemSize = [KDAppCollectionViewCell size];
    layout.minimumLineSpacing = kTopMargin;
    CGFloat spacing = (ScreenFullWidth - layout.itemSize.width * MAX_COUNT_INLINE - 16) / (MAX_COUNT_INLINE + 1) - 1;
    if (spacing < 0) {
        spacing = 0;
    }
    layout.minimumInteritemSpacing = spacing;
    layout.sectionInset = UIEdgeInsetsMake(kTopMargin, 8 + spacing, 8, 8 + spacing);
    
    return layout;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectZero collectionViewLayout:[KDAppCollectionView layout]];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp {
    self.backgroundColor = [UIColor clearColor];
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    [self registerClass:[KDAppCollectionViewCell class] forCellWithReuseIdentifier:@"KDAppCollectionViewCell"];
}

- (void)longPressRecognizer:(UILongPressGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:location];
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
    
    if (!self.isSorting && [cell isKindOfClass:[KDAppCollectionViewCell class]]) {
        if (indexPath && self.kdDelegate && [self.kdDelegate respondsToSelector:@selector(cellDidLongPressed:)]) {
            [self.kdDelegate cellDidLongPressed:(KDAppCollectionViewCell *)cell];
        }
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            if (!indexPath || ![cell isKindOfClass:[KDAppCollectionViewCell class]]) {
                return;
            }
            
            // 开始状态，隐藏Cell、生成Cell截图
            self.snapshotView = [cell snapshotViewAfterScreenUpdates:YES];
            self.snapshotView.center = cell.center;
            [self addSubview:self.snapshotView];
            cell.contentView.alpha = 0;
            
            [UIView animateWithDuration:0.2 animations:^{
                self.snapshotView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                self.snapshotView.alpha = 0.5;
            }];
            
            // 移动截图
            self.snapshotPanPoint = location;
            self.snapshotIndexPath = indexPath;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = CGPointMake(location.x - self.snapshotPanPoint.x,
                                              location.y - self.snapshotPanPoint.y);
            CGPoint center = CGPointMake(self.snapshotView.center.x + translation.x,
                                         self.snapshotView.center.y + translation.y);
            
            // 移动截图
            [self moveSnapshotViewWithCenter:center];
            self.snapshotPanPoint = location;
            
            if ([self isPanningNearEdge]) {
                [self startCountingIfNeed];
                break;
            } else if (self.displayLink) {
                [self stopCounting];
            }
            
            // 如果移动到某个Cell位置，则调整布局
            if (indexPath && self.snapshotIndexPath != indexPath) {
                BOOL moveResult = NO;
                if (self.kdDelegate && [self.kdDelegate respondsToSelector:@selector(moveItemAtIndexPath:toIndexPath:)]) {
                    moveResult = [self.kdDelegate moveItemAtIndexPath:self.snapshotIndexPath toIndexPath:indexPath];
                }
                
                if (moveResult) {
                    UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
                    cell.contentView.alpha = 0;
                    self.snapshotIndexPath = indexPath;
                }
            }
        }
            break;
        default: {
            // 完成、失败或中断都恢复原位
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:self.snapshotIndexPath];
            [UIView animateWithDuration:0.2 animations:^{
                self.snapshotView.center = cell.center;
                self.snapshotView.transform = CGAffineTransformIdentity;
                self.snapshotView.alpha = 1.0;
            } completion:^(BOOL finished) {
                // 显示Cell并移除截图
                cell.contentView.alpha = 1.0;
                [self.snapshotView removeFromSuperview];
                self.snapshotView = nil;
                [self reloadData];
            }];
            
            self.snapshotIndexPath = nil;
            self.snapshotPanPoint = CGPointZero;
            
        }
            break;
    }
}

- (BOOL)isPanningNearEdge {
    CGFloat panningLocationY = self.snapshotView.center.y - self.contentOffset.y;
    if (fabs(panningLocationY) <= 40 || fabs(panningLocationY - self.bounds.size.height) <= 40) {
        return YES;
    }
    
    return NO;
}

- (void)startCountingIfNeed {
    if (self.displayLink) {
        return;
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollUpOrDown)];
    self.displayLink.frameInterval = 3;  // 1秒60帧，3帧为1/20秒
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopCounting {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)scrollUpOrDown {
    if (![self isPanningNearEdge]) {
        [self stopCounting];
        return;
    }
    
    CGFloat panningLocationY = self.snapshotView.center.y - self.contentOffset.y;
    CGPoint contentOffset = self.contentOffset;
    // 滚到上一页或下一页
    if (fabs(panningLocationY) <= 40 && self.contentOffset.y > 0) {
        contentOffset.y -= 20.0f;
        
    } else if (fabs(panningLocationY - self.bounds.size.height) <= 40
               && self.contentOffset.y + self.bounds.size.height < self.contentSize.height) {
        contentOffset.y += 20.0f;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self.contentOffset = contentOffset;
    }];
    [self longPressRecognizer:self.longPressRecognizer];
}

- (void)moveSnapshotViewWithCenter:(CGPoint)center {
    [UIView animateWithDuration:0.1 animations:^{
        self.snapshotView.center = center;
    }];
}

#pragma mark - Setters and Getters

- (void)setEnableSorting:(BOOL)enableSorting {
    _enableSorting = enableSorting;
    if (enableSorting) {
        [self addGestureRecognizer:self.longPressRecognizer];
    } else {
        [self removeGestureRecognizer:self.longPressRecognizer];
    }
}

- (UILongPressGestureRecognizer *)longPressRecognizer {
    if (!_longPressRecognizer) {
        _longPressRecognizer =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)];
    }
    
    return _longPressRecognizer;
}

- (NSIndexPath *)currentMovingIndexPath {
    return self.snapshotIndexPath;
}

@end
