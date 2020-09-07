//
//  KDExpressionInputView.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-4-9.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDExpressionInputView.h"
#import "KDExpressionViewDefaultDataSource.h"
#import "KDExpressionViewDataSourceXiaoluo.h"
#import "KDExpressionViewDataSourceXiaoYun.h"
#import "KDExpressionViewDataSourceYuki.h"

@implementation UIImage (KDExpression)

+ (UIImage *)imageWithUIColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation EmojiModal
@end

@interface KDExpressionInputView ()
{
    KDExpressionView *expressionView_;
    KDExpressionViewDefaultDataSource *defaultExpressionDatasource_;
    
    UIButton *sendButton_;
}

/**
 *  底部的表情类型按钮滚动条
 */
@property (nonatomic, strong) UIScrollView *scrollViewType;

/**
 *  选中的底部表情类型按钮
 */
@property (nonatomic, assign) int iSelectedIndex;

/**
 *  新表情, 小裸, Yuki, XiaoYun
 */
@property (nonatomic, strong) KDExpressionViewDataSourceYuki *dataSourceYuki;
@property (nonatomic, strong) KDExpressionViewDataSourceXiaoluo *dataSourceXiaoluo;
@property (nonatomic, strong) KDExpressionViewDataSourceXiaoYun *dataSourceXiaoYun;

@property (nonatomic, assign) id <KDExpressionViewDataSource> currentDataSource;
@end

@implementation KDExpressionInputView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        [self setupViews];
    }
    return self;
}

- (void)setSendButtonShown:(BOOL)show {
    sendButton_.hidden = !show;
}

- (void)setupViews {
    
    self.backgroundColor = [UIColor clearColor];
    
    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 41.f, CGRectGetWidth(self.frame), 40.f)];
    bottomView.image = [[UIImage imageNamed:@"toolbar_other_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 21)];
    [self addSubview:bottomView];
    
    defaultExpressionDatasource_ = [[KDExpressionViewDefaultDataSource alloc] init];
    [self changeEmojiDataSource:defaultExpressionDatasource_];
    self.currentDataSource = defaultExpressionDatasource_;
    
    sendButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton_ setBackgroundImage:[UIImage imageWithUIColor:UIColorFromRGB(0x3CBAFF)] forState:UIControlStateNormal];
    [sendButton_ setBackgroundImage:[UIImage imageWithUIColor:UIColorFromRGB(0x308EC2)] forState:UIControlStateHighlighted];
    [sendButton_.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [sendButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [sendButton_ setTitle:ASLocalizedString(@"Global_Send")forState:UIControlStateNormal];
    sendButton_.frame = CGRectMake(self.frame.size.width - 80.0f, self.frame.size.height - 40.0f, 80.0f, 40.0f);
    [sendButton_ addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton_];
    
    [self addSubview:self.scrollViewType];
}

#pragma mark - UIButton Response Methods
- (void)sendButtonClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSendInExpressionInputView:)]) {
        [_delegate didTapSendInExpressionInputView:self];
    }
}

- (void)deleteButtonClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didTapDeleteInExpressionInputView:)]) {
        [_delegate didTapDeleteInExpressionInputView:self];
    }
}

#pragma mark - KDExpressionview delegate method
- (void)expressionView:(KDExpressionView *)expView didTapOnPostion:(KDExpressionViewPostion)position {
    NSString *codeString = [self.currentDataSource expressionView:expView codeStringAtPosition:position];
    UIImage *image = [self.currentDataSource expressionView:expView imageForPosition:position];
    
    if ([codeString isEqualToString:@""]) {
        //do nothing
        return;
    }
    else if ([codeString isEqualToString:@"delete"]) {
        [self deleteButtonClicked:nil];
    }
    else if (_delegate && [_delegate respondsToSelector:@selector(expressionInputView:didTapExpression:)]) {
        [_delegate expressionInputView:self didTapExpression:codeString];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(expressionInputView:didTapExpressionImage:)]) {
        if (self.iSelectedEmojiIndex != 0) {
            [_delegate expressionInputView:self didTapExpressionImage:image];
        }
    }
}

- (void)expressionViewDidSwipeLeft:(KDExpressionView *)expView {
    //TODO:
}

/*********************************************************************
 *  added by Darren in 2014.7.28
 *********************************************************************/

/**
 *  切换表情的数据源
 *
 *  @param dataSource 数据源
 */
- (void)changeEmojiDataSource:(id <KDExpressionViewDataSource>)dataSource {
    if (expressionView_) {
        expressionView_.delegate = nil;
        expressionView_.datasource = nil;
        [expressionView_ removeFromSuperview];
        expressionView_ = nil;
    }
    
    if (!expressionView_) {
        expressionView_ = [[KDExpressionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height - 41.0f)];
        expressionView_.delegate = self;
        expressionView_.datasource = dataSource;
        expressionView_.backgroundColor = [UIColor clearColor];
        [self addSubview:expressionView_];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.iSelectedIndex = 0;
    
    for (EmojiModal *modal in self.arrayEmojiModals) {
        int index = (int)[self.arrayEmojiModals indexOfObject:modal];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        
        if (index == 0) {
            button.frame = CGRectMake(0, 0, 40, 40);
            button.backgroundColor = UIColorFromRGB(0xf3f5f9); //默认选第一个
        }
        else {
            button.frame = CGRectMake(index * 40, 0, 40, 40);
            button.backgroundColor = [UIColor whiteColor];
        }
        [button setImage:[UIImage imageNamed:modal.strImageName] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonEmojiTypePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollViewType addSubview:button];
        
        if (index != 0) {
            UIImageView *imageViewButtonSeperator = [[UIImageView alloc] initWithImage:[UIImage imageWithUIColor:UIColorFromRGB(0xDCE1E8)]];
            imageViewButtonSeperator.frame = CGRectMake(index * 40, 0, 1, 40);
            [self.scrollViewType addSubview:imageViewButtonSeperator];
        }
        
        if (index == self.arrayEmojiModals.count - 1) {
            UIImageView *imageViewButtonSeperator = [[UIImageView alloc]initWithImage:[UIImage imageWithUIColor:UIColorFromRGB(0xDCE1E8)]];
            imageViewButtonSeperator.frame = CGRectMake(index * 40 + 39, 0, 1, 40);
            [self.scrollViewType addSubview:imageViewButtonSeperator];
        }
    }
    
    self.scrollViewType.contentSize = CGSizeMake(self.arrayEmojiModals.count * 40, 40);
}

- (UIScrollView *)scrollViewType {
    if (!_scrollViewType) {
        _scrollViewType = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 40.0f, CGRectGetWidth(self.frame) - CGRectGetWidth(sendButton_.bounds), 40)];
        _scrollViewType.backgroundColor = [UIColor clearColor];
        _scrollViewType.showsHorizontalScrollIndicator = NO;
    }
    
    return _scrollViewType;
}

- (KDExpressionViewDataSourceYuki *)dataSourceYuki {
    if (!_dataSourceYuki) {
        _dataSourceYuki = [KDExpressionViewDataSourceYuki new];
    }
    return _dataSourceYuki;
}

- (KDExpressionViewDataSourceXiaoluo *)dataSourceXiaoluo {
    if (!_dataSourceXiaoluo) {
        _dataSourceXiaoluo = [KDExpressionViewDataSourceXiaoluo new];
    }
    return _dataSourceXiaoluo;
}

- (KDExpressionViewDataSourceXiaoYun *)dataSourceXiaoYun {
    if (!_dataSourceXiaoYun) {
        _dataSourceXiaoYun = [KDExpressionViewDataSourceXiaoYun new];
    }
    return _dataSourceXiaoYun;
}

- (void)buttonEmojiTypePressed:(UIButton *)button {
    /**
     *  单选灭灯/亮灯逻辑
     */
    self.iSelectedIndex = (int)button.tag;
    
    for (UIView *view in self.scrollViewType.subviews) {
        if ([view isMemberOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            if (button.tag != self.iSelectedIndex) {
                button.backgroundColor = [UIColor whiteColor];
            }
            else {
                button.backgroundColor = UIColorFromRGB(0xf3f5f9);
            }
        }
    }
    
    switch (button.tag) {
        case 0:
            [self changeEmojiDataSource:defaultExpressionDatasource_];
            self.currentDataSource = defaultExpressionDatasource_;
            break;
            
        case 1:
            [self changeEmojiDataSource:self.dataSourceXiaoluo];
            self.currentDataSource = self.dataSourceXiaoluo;
            break;
            
        case 2:
            [self changeEmojiDataSource:self.dataSourceYuki];
            self.currentDataSource = self.dataSourceYuki;
            break;
            
        default:
            break;
    }
    
    sendButton_.hidden = button.tag != 0;
    
    self.iSelectedEmojiIndex = (int)button.tag;
}

@end
