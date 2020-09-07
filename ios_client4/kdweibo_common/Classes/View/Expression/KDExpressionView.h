//
//  KDExpressionView.h
//  kdweibo_common
//
//  Created by shen kuikui on 13-2-25.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDBaseScrollView.h"

@protocol KDExpressionViewDelegate;
@protocol KDExpressionViewDataSource;

@class KDExpressionNoteView;

typedef struct{
    NSUInteger page;
    NSUInteger row;
    NSUInteger column;
}KDExpressionViewPostion;

NS_INLINE KDExpressionViewPostion KDMakeExpressionViewPostion(NSUInteger page, NSUInteger row, NSUInteger column) {
    KDExpressionViewPostion pos;
    pos.row = row;
    pos.column = column;
    pos.page = page;
    
    return pos;
}

@interface KDExpressionView : UIView <UIScrollViewDelegate> {
@private
    UIPageControl *pageControl_;
    
    
    NSMutableArray *views_;
    
    BOOL pageControlUsed_;
    
    KDExpressionNoteView *noteView_;
}

@property (nonatomic, assign) id<KDExpressionViewDelegate> delegate;
@property (nonatomic, assign) id<KDExpressionViewDataSource> datasource;

@property (nonatomic, strong) KDBaseScrollView  *scrollView;

@end


@protocol KDExpressionViewDataSource <NSObject>

- (NSUInteger)numberOfPagesInExpressionView:(KDExpressionView *)expView;
- (NSUInteger)expressionView:(KDExpressionView *)expView numberOfRowsInPage:(NSUInteger)page;
- (NSUInteger)expressionView:(KDExpressionView *)expView numberOfColumnsInRow:(NSUInteger)row ofPage:(NSUInteger)page;

- (UIImage *)expressionView:(KDExpressionView *)expView imageForPosition:(KDExpressionViewPostion)pos;

- (NSString *)expressionView:(KDExpressionView *)expView titleForPosition:(KDExpressionViewPostion)pos;

- (NSString *)expressionView:(KDExpressionView *)expView codeStringAtPosition:(KDExpressionViewPostion)pos;


@end

@protocol KDExpressionViewDelegate <NSObject>

- (void)expressionView:(KDExpressionView *)expView didTapOnPostion:(KDExpressionViewPostion)position;
- (void)expressionViewDidSwipeLeft:(KDExpressionView *)expView;

@end