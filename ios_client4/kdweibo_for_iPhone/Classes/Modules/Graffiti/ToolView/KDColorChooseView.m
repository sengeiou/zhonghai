//
//  KDColorChooseView.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDColorChooseView.h"

@interface KDColorChooseView()

@property (nonatomic, strong) NSMutableArray *colorArr;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *lastTapImageView;

@end

@implementation KDColorChooseView

#define returnBtnWidth 36

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:0.1];
        self.colorArr = [NSMutableArray array];
    }
    
    return self;
}

- (void)layoutSubviews {
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
    
    [self.colorArr removeAllObjects];
    if (self.hiddenMosaic) {
        [self.colorArr addObjectsFromArray:@[[UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor],[UIColor blueColor],[UIColor purpleColor],[UIColor blackColor],[UIColor whiteColor]]];
    } else {
        [self.colorArr addObjectsFromArray:@[[UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor],[UIColor blueColor],[UIColor purpleColor],[UIColor blackColor],[UIColor whiteColor],[UIColor colorWithPatternImage:[UIImage imageNamed:@"msk4"]]]];
    }
    
    CGFloat scrollViewW = 0;
    if (self.hiddenReturn) {
        scrollViewW = self.frame.size.width - 12*2;
    } else {
        scrollViewW = self.frame.size.width - 12*2 - returnBtnWidth;
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(12, 0, scrollViewW, self.frame.size.height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    CGFloat imgW = 20;
    CGFloat imgH = 20;
    CGFloat imgY = 8;
    CGFloat margin = 12;
    
    for (NSInteger i=0; i < self.colorArr.count; i ++) {
        CGFloat imgX = (margin+imgW)*i;
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, imgY, imgW, imgH)];
        img.tag = i;
        img.backgroundColor = self.colorArr[i];
        img.userInteractionEnabled = YES;
        img.layer.cornerRadius = 3;
        img.layer.masksToBounds = YES;
        if (i == 0) {
            img.layer.borderColor = [UIColor orangeColor].CGColor;
            self.lastTapImageView = img;
        } else {
            img.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        img.layer.borderWidth = 1.0;
        [_scrollView addSubview:img];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorTap:)];
        [img addGestureRecognizer:tap];
    }
    _scrollView.contentSize = CGSizeMake((margin+imgW)*self.colorArr.count,0);
    
    
    // 返回按钮
    UIButton *returnBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_scrollView.frame), 0, returnBtnWidth, self.frame.size.height)];
    self.returnBtn = returnBtn;
    [returnBtn setImage:[UIImage imageNamed:@"icon_undo_selected"] forState:UIControlStateNormal];
    [returnBtn setImage:[UIImage imageNamed:@"icon_undo"] forState:UIControlStateDisabled];
    [returnBtn addTarget:self action:@selector(clickReturn:) forControlEvents:UIControlEventTouchUpInside];
    if (!self.hiddenReturn) {
        [self addSubview:returnBtn];
    }
}


- (void)colorTap:(UITapGestureRecognizer*)tap {
    if (self.lastTapImageView) {
        self.lastTapImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    UIImageView *imageView = (UIImageView *)tap.view;
    imageView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.lastTapImageView = imageView;
    UIColor *color = imageView.backgroundColor;
    if (self.delegate && [self.delegate respondsToSelector:@selector(chooseColorWithColor:)]) {
        [self.delegate chooseColorWithColor:color];
    }

}
- (void)clickReturn:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickReturn)]) {
        [self.delegate clickReturn];
    }
}

- (void)setHiddenReturn:(BOOL)hiddenReturn {
    _hiddenReturn = hiddenReturn;
    [self layoutIfNeeded];
}

- (void)setHiddenMosaic:(BOOL)hiddenMosaic {
    _hiddenMosaic = hiddenMosaic;
    [self layoutSubviews];
}

@end
