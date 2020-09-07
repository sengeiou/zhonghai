//
//  KDExpressionView.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-2-25.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDExpressionView.h"
#import "KDExpressionViewDefaultDataSource.h"
#import "KDExpressionPageBGView.h"

#define KD_EXPRESSION_VIEW_PAGE_CONTROL_HEIGHT 31.0

@interface KDExpressionCellView : UIImageView
@property (nonatomic, assign) KDExpressionViewPostion cellPosition;
@end
@implementation KDExpressionCellView
@synthesize cellPosition;
@end

@interface KDExpressionView()
@property (nonatomic, strong) KDCustomPopover *popover;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) KDEmotionPreviewView *previewView;
@property (nonatomic, strong) KDExpressionCellView *currentItemView;
@end

@implementation KDExpressionView

@synthesize delegate = delegate_;
@synthesize datasource = datasource_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (KDEmotionPreviewView *)previewView
{
    if (!_previewView) {
        _previewView = [KDEmotionPreviewView new];
        _previewView.frame = CGRectMake(0,0,164,150);
        _previewView.backgroundColor = [UIColor whiteColor];
    }
    return _previewView;
}


- (NSMutableArray *)items
{
    if (!_items) {
        _items = [NSMutableArray new];
    }
    return _items;
}

- (void)setDatasource:(id <KDExpressionViewDataSource>)datasource {
    if (datasource != datasource_) {
        datasource_ = datasource;
        [self configScrollViewAndPageControl];
    }
}

- (NSUInteger)pageCount {
    if (datasource_ && [datasource_ respondsToSelector:@selector(numberOfPagesInExpressionView:)]) {
        return [datasource_ numberOfPagesInExpressionView:self];
    }
    
    return 0;
}

- (NSUInteger)rowCountOfPage:(NSUInteger)pageIndex {
    if (datasource_ && [datasource_ respondsToSelector:@selector(expressionView:numberOfRowsInPage:)]) {
        return [datasource_ expressionView:self numberOfRowsInPage:pageIndex];
    }
    
    return 0;
}

- (NSUInteger)columnCountInRow:(NSUInteger)rowIndex ofPage:(NSUInteger)pageIndex {
    if (datasource_ && [datasource_ respondsToSelector:@selector(expressionView:numberOfColumnsInRow:ofPage:)]) {
        return [datasource_ expressionView:self numberOfColumnsInRow:rowIndex ofPage:pageIndex];
    }
    
    return 0;
}

- (UIImage *)imageForExpressionViewPosition:(KDExpressionViewPostion)pos {
    if (datasource_ && [datasource_ respondsToSelector:@selector(expressionView:imageForPosition:)]) {
        return [datasource_ expressionView:self imageForPosition:pos];
    }
    
    return nil;
}

- (NSString *)codeStringForExpressionViewPosition:(KDExpressionViewPostion)pos {
    if (datasource_ && [datasource_ respondsToSelector:@selector(expressionView:codeStringAtPosition:)]) {
        return [datasource_ expressionView:self codeStringAtPosition:pos];
    }
    
    return nil;
}

- (NSString *)titleForExpressionViewPosition:(KDExpressionViewPostion)pos {
    if (datasource_ && [datasource_ respondsToSelector:@selector(expressionView:codeStringAtPosition:)]) {
        return [datasource_ expressionView:self titleForPosition:pos];
    }
    
    return nil;
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
    
    pageControlUsed_ = NO;
    
    self.scrollView = [[KDBaseScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height - KD_EXPRESSION_VIEW_PAGE_CONTROL_HEIGHT)];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = self.backgroundColor;
    
    [self addSubview:self.scrollView];
    
    pageControl_ = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height - KD_EXPRESSION_VIEW_PAGE_CONTROL_HEIGHT, self.bounds.size.width, KD_EXPRESSION_VIEW_PAGE_CONTROL_HEIGHT)];
    pageControl_.pageIndicatorTintColor = UIColorFromRGB(0xBDBDBD);
    pageControl_.currentPageIndicatorTintColor = UIColorFromRGB(0x3CBAFF);
    pageControl_.backgroundColor = self.backgroundColor;
    [pageControl_ addTarget:self action:@selector(pageControlValueChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:pageControl_];
    
    UIGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [self addGestureRecognizer:recognizer];
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeRecognizer {
    if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (delegate_ && [delegate_ respondsToSelector:@selector(expressionViewDidSwipeLeft:)]) {
            [delegate_ expressionViewDidSwipeLeft:self];
        }
    }
}

- (void)configScrollViewAndPageControl {
    NSUInteger pageCount = [self pageCount];
    
    if (pageCount == 0) {
        return;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * pageCount, self.scrollView.bounds.size.height);
    [self loadScrollViewWithPage:0];
    
    if (pageCount > 1) {
        [self loadScrollViewWithPage:1];
    }
    
    pageControl_.numberOfPages = pageCount;
    pageControl_.currentPage = 0;
}

- (void)loadScrollViewWithPage:(NSUInteger)page {
    if (page > [self pageCount] - 1) {
        return;
    }
    
    UIView *view = [self viewForPage:page];
    
    if (view.superview == nil) {
        [self.scrollView addSubview:view];
    }
}

- (UIView *)viewForPage:(NSUInteger)page {
    if (views_ == nil) {
        views_ = [[NSMutableArray alloc] initWithCapacity:[self pageCount]];
    }
    KDExpressionPageBGView *view = nil;
    
    if (views_.count > page) {
        view = [views_ objectAtIndex:page];
    }
    
    if (!view) {
        view = [[KDExpressionPageBGView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.size.width * page, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        __weak __typeof(self) weakSelf = self;
        __weak __typeof(KDExpressionPageBGView) *weakView = view;
        
        view.onTouchUpInside = ^(CGPoint location) {
            [weakSelf.popover hide];
            for (KDExpressionCellView *itemView in weakView.subviews) {
                if (CGRectContainsPoint(itemView.frame, location)) {
                    [weakSelf buttonTouchUpInside:itemView];
                    break;
                }
            }
        };
        
        if (![self.datasource isKindOfClass:[KDExpressionViewDefaultDataSource class]]) {
            
            void (^previewBlock)(CGPoint) =  ^(CGPoint location) {
                for (KDExpressionCellView *itemView in weakView.subviews) {
                    if (CGRectContainsPoint(itemView.frame, location)) {
                        NSString *strTitle = [weakSelf titleForExpressionViewPosition:itemView.cellPosition];
                        FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithFileName:strTitle];
                        if (animatedImage != nil) {
                            weakSelf.previewView.previewImageView.image = nil;
                            weakSelf.previewView.previewImageView.animatedImage = animatedImage;
                        } else {
                            UIImage *btnImage = [self imageForExpressionViewPosition:itemView.cellPosition];
                            weakSelf.previewView.previewImageView.image = btnImage;
                            weakSelf.previewView.previewImageView.animatedImage = nil;
                        }
                        [weakSelf.popover showAtView:itemView contentView:weakSelf.previewView inView: itemView.inputView];
                        weakSelf.currentItemView = itemView;
                        break;
                    }
                }
            };
            
            view.onTouchesLongPress = previewBlock;
            
            
            
            view.onTouchesEnded = ^(CGPoint location) {
                [weakSelf.popover hide];
            };
            
            view.onTouchesMoved = ^(CGPoint location) {
                
                BOOL contain = NO;
                
                for (KDExpressionCellView *itemView in weakView.subviews) {
                    if (CGRectContainsPoint(itemView.frame, location)) {
                        if (weakSelf.currentItemView != itemView) {
                            NSString *strTitle = [weakSelf titleForExpressionViewPosition:itemView.cellPosition];
                            FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithFileName:strTitle];
                            if (animatedImage != nil) {
                                weakSelf.previewView.previewImageView.image = nil;
                                weakSelf.previewView.previewImageView.animatedImage = animatedImage;
                            } else {
                                UIImage *btnImage = [self imageForExpressionViewPosition:itemView.cellPosition];
                                weakSelf.previewView.previewImageView.image = btnImage;
                                weakSelf.previewView.previewImageView.animatedImage = nil;
                            }
                            [weakSelf.popover showAtView:itemView contentView:weakSelf.previewView inView: itemView.inputView];
                        }
                        
                        contain = YES;
                        weakSelf.currentItemView = itemView;
                        break;
                    }
                }
                if (!contain) {
                    [weakSelf.popover hide];
                }
            };
        }
        
        view.clipsToBounds = NO;
        [views_ insertObject:view atIndex:page];
        
        //set view's content
        NSUInteger rowCount = [self rowCountOfPage:page];
        CGFloat cellHeight = 29;
        NSInteger spaceCount = 1; // 3
        NSInteger startCount = 1; // 2
        if (![self.datasource isKindOfClass:[KDExpressionViewDefaultDataSource class]]) {
            cellHeight = 65.0;
            spaceCount = 1;
            startCount = 1;
        }
        CGFloat cellWidth = cellHeight;
        CGFloat rowSpace = (view.frame.size.height - cellHeight * rowCount) / (rowCount + spaceCount - startCount);
        
        for (NSUInteger row = 0; row < rowCount; row++) {
            
            NSUInteger columnCount = [self columnCountInRow:row ofPage:page];
            CGFloat cellSpace = (view.frame.size.width - cellWidth * columnCount) / (columnCount + spaceCount);
            
            for (NSUInteger column = 0; column < columnCount; column++) {
                
                UIImage *btnImage = [self imageForExpressionViewPosition:KDMakeExpressionViewPostion(page, row, column)];
                NSString *strTitle = [self codeStringForExpressionViewPosition:KDMakeExpressionViewPostion(page, row, column)];
                
                if (btnImage) {
                    KDExpressionCellView *itemView = [KDExpressionCellView new];
                    itemView.frame = CGRectMake(cellSpace * (column + startCount) + cellWidth * column, rowSpace * (row + startCount) + cellHeight * row, cellWidth, cellHeight);
                    itemView.cellPosition = KDMakeExpressionViewPostion(page, row, column);
                    
                    if (![self.datasource isKindOfClass:[KDExpressionViewDefaultDataSource class]]) {
                        UIImageView *itemImageView = [UIImageView new];
                        itemImageView.image = btnImage;
                        itemImageView.contentMode = UIViewContentModeScaleAspectFit;
                        itemImageView.frame = CGRectMake(0, 0, cellWidth, cellHeight - 12);
                        [itemView addSubview:itemImageView];
                        itemView.contentMode = UIViewContentModeScaleAspectFit;
                        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(0, cellHeight - 12, cellWidth, 12)];
                        labelName.text = strTitle;
                        labelName.textColor = UIColorFromRGB(0x3F3F3F);
                        labelName.backgroundColor = [UIColor clearColor];
                        labelName.font = [UIFont systemFontOfSize:10];
                        labelName.textAlignment = NSTextAlignmentCenter;
                        [itemView addSubview:labelName];
                    } else {
                        itemView.image = btnImage;
                    }
                    
                    itemView.userInteractionEnabled = YES;
                    [view addSubview:itemView];
                }
            }
        }
    }
    
    return view;
}

- (KDCustomPopover *)popover
{
    if (!_popover) {
        _popover = [KDCustomPopover new];
        _popover.dxPopover.animationIn = 0;
        _popover.dxPopover.animationOut = 0;
        _popover.dxPopover.layer.shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7].CGColor;
        _popover.dxPopover.layer.shadowOffset = CGSizeMake(0, 1);
        _popover.dxPopover.layer.shadowOpacity = 0.2;
    }
    return _popover;
}

#pragma mark - button methods
- (void)buttonTouchDown:(id)sender {
    //TODO:show the tips view with expression image
}

- (void)buttonTouchUpInside:(id)sender {
    KDExpressionCellView *btn = (KDExpressionCellView *)sender;
    
    //TODO:remove the tips view with expression image
    
    if (delegate_ && [delegate_ respondsToSelector:@selector(expressionView:didTapOnPostion:)]) {
        [delegate_ expressionView:self didTapOnPostion:btn.cellPosition];
    }
}

#pragma mark - method for page control value change
- (void)pageControlValueChange:(id)sender {
    NSInteger page = pageControl_.currentPage;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0.0f;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    pageControlUsed_ = YES;
}

#pragma mark - uiscrollview delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (pageControlUsed_) {
        return;
    }
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page == pageControl_.currentPage) {
        return;
    }
    
    pageControl_.currentPage = page;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed_ = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed_ = NO;
}

@end
