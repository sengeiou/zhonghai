//
//  KDCommonHintView.m
//  kdweibo
//
//  Created by shifking on 15/11/21.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//
#define Image_Width_height_Ratio (124.0/75.0)   //header image 宽高比例
#define HintView_Width_Ratio 0.775 //hintView所占大屏宽比例
#define HintView_Height_Ratio (359.0/568.0) //hintView所占大屏高比例

#import "KDCommonHintView.h"
#import "UILabel+StringFrame.h"

@interface KDCommonHintView()
@property (strong , nonatomic) UIButton     *iknowButton;
@property (strong , nonatomic) UIButton     *checkMoreButton;
@property (strong , nonatomic) UIImageView  *headerImageView;
@property (strong , nonatomic) UIView       *buttonLine;
@property (strong , nonatomic) UIView       *viewLine;
@property (strong , nonatomic) UIView       *bgView;

@property (strong , nonatomic) UIView       *contentView;
@property (strong , nonatomic) UIScrollView *scrollView;
@property (strong , nonatomic) UIView       *scrollContentView;
@property (strong , nonatomic) UILabel      *titleLabel;
@property (strong , nonatomic) UILabel      *contentLabel;

@property (weak , nonatomic) UIView *fatherView;

@property (strong , nonatomic) UIButton *closeButton;
@end


@implementation KDCommonHintView
- (id)initWithFatherView:(UIView *)fatherView {
    _fatherView = fatherView;
    return [self init];
}

- (id)init {
    self = [super init];
    if (self) {
        [self addSubview:self.headerImageView];
        [self addSubview:self.contentView];
        [self addSubview:self.iknowButton];
        [self addSubview:self.checkMoreButton];
        [self addSubview:self.viewLine];
        [self addSubview:self.buttonLine];
        
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.scrollContentView];
        [self.scrollContentView addSubview:self.titleLabel];
        
        self.backgroundColor    = [UIColor whiteColor];
        self.hidden             = NO;
        self.layer.cornerRadius = 6;
        self.clipsToBounds = YES;
    }
    
    return self;
}


- (void)show{
    if (_fatherView) {
        [_fatherView addSubview:self.bgView];

        [_fatherView addSubview:self];
        [_fatherView addSubview:self.closeButton];
        [self masMakeInView:_fatherView];
    }
    else {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.bgView];
        [window addSubview:self];
        [window addSubview:self.closeButton];
        [self masMakeInView:window];
    }
    
}

- (void)setupTitle:(NSString *)title image:(UIImage *)image contentText:(NSString *)content {
    [self.scrollContentView addSubview:self.contentLabel];
    self.titleLabel.text = title;
    self.contentLabel.text = content;
    if (image && [image isKindOfClass:[UIImage class]]) {
        self.headerImageView.image = image;
    }
    if (content) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [content length])];
        self.contentLabel.attributedText = attributedString;
    }
   
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (!title ||title.length ==0) {
            make.top.mas_equalTo(self.scrollContentView).with.offset(22);
        }
        else {
            make.top.mas_equalTo(self.titleLabel.bottom).with.offset(22);
        }
        make.left.mas_equalTo(self.scrollContentView).with.offset(22);
        make.right.mas_equalTo(self.scrollContentView).with.offset(-22);
        make.bottom.mas_equalTo(self.scrollView).with.offset(-22);
    }];
}


- (void)setupTitle:(NSString *)title image:(UIImage *)image pointTexts:(NSArray *)items {
    self.titleLabel.text = title;
    if(!title){
        self.titleLabel.hidden = YES;
    }
    if (image && [image isKindOfClass:[UIImage class]]) {
        self.headerImageView.image = image;
    }
    
    UILabel *lastLab = nil;
    for (NSInteger i = 0 ; i < items.count ; i++) {
        NSString *itemName = items[i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sign_tip_dot"]];
        [self.scrollContentView addSubview:imageView];
        
        UILabel *itemLab = [[UILabel alloc] init];
        itemLab.font = FS5;
        itemLab.textColor = FC2;
        itemLab.numberOfLines = 0;
        itemLab.text = itemName;
        [self.scrollContentView addSubview:itemLab];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastLab) {
                make.top.mas_equalTo(lastLab.bottom).with.offset(6 + 5);
            }
            else {
                if(title){
                make.top.mas_equalTo(self.titleLabel.bottom).with.offset(22 + 5);
                }else{
                make.top.mas_equalTo(self.scrollContentView).with.offset(30+5);
                }
            }
            
            make.left.mas_equalTo(self.scrollContentView).with.offset(22);
            make.width.height.mas_equalTo(5);
        }];
        
        [itemLab mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastLab) {
                make.top.mas_equalTo(lastLab.bottom).with.offset(6);
            }
            else {
                if(title){
                make.top.mas_equalTo(self.titleLabel.bottom).with.offset(22);
                }else{
                make.top.mas_equalTo(self.scrollContentView).with.offset(30);
                }
            }
            make.left.mas_equalTo(imageView.right).with.offset(12);
            make.right.mas_equalTo(self.scrollContentView).with.offset(-22);
            
            if (i == items.count - 1) {
                make.bottom.mas_equalTo(self.scrollView).with.offset(-22);
            }
        }];

        lastLab = itemLab;
    }
}

- (void)masMakeInView:(UIView *)view {
    CGFloat width      = [UIApplication sharedApplication].keyWindow.screen.bounds.size.width;
    CGFloat height     = [UIApplication sharedApplication].keyWindow.screen.bounds.size.height;
    CGFloat selfwidth  = width * HintView_Width_Ratio;
    CGFloat selfheight = height * HintView_Height_Ratio;
    CGFloat contentHeight = selfheight - (selfwidth/Image_Width_height_Ratio) - 44;
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(selfwidth, selfheight));
        make.center.mas_equalTo(view);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.right).with.offset(-10);
        make.top.mas_equalTo(self.top).with.offset(-10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self).with.offset(0);
        make.height.mas_equalTo( selfwidth/Image_Width_height_Ratio );
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerImageView.bottom).with.offset(0);
        make.left.right.mas_equalTo(self).with.offset(0);
        make.height.mas_equalTo(contentHeight);
    }];
    
    [self.iknowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.bottom).with.offset(0);
        make.left.mas_equalTo(self).with.offset(0);
        make.width.mas_equalTo(self.hideRightButton? selfwidth : selfwidth/2.0);
        make.height.mas_equalTo(44.0);
    }];
    
    [self.checkMoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.bottom).with.offset(0);
        make.left.mas_equalTo(self).with.offset(selfwidth/2.0);
        make.width.mas_equalTo(selfwidth/2.0);
        make.height.mas_equalTo(44.0);
    }];
    
    [self.viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.bottom).with.offset(0);
        make.left.right.mas_equalTo(self).with.offset(0);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.buttonLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.contentView.bottom).with.offset(12);
        make.left.mas_equalTo(self.iknowButton.right).with.offset(0);
    }];
    
    if(self.hideRightButton){
        self.checkMoreButton.hidden = YES;
        self.buttonLine.hidden = YES;
    }
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(self.contentView).with.offset(0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollContentView).with.offset(22);
        make.left.right.mas_equalTo(self.scrollContentView).with.offset(0);
        make.height.mas_equalTo(18);
    }];
    
    [self.scrollContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.scrollView).with.offset(0);
        make.width.height.mas_equalTo(self.scrollView);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(view).with.offset(0);
    }];
    
}

#pragma mark - event response 
- (void)didPressButtonAction:(UIButton *)button {
    if (self.buttonClickBlock) {
        self.buttonClickBlock(button.tag - 0x90 , button.titleLabel.text);
    }
    [self removeFromSuperview];
    [self.bgView removeFromSuperview];
    [self.closeButton removeFromSuperview];
}




#pragma mark - getter & setter
- (void)setShowCloseButton:(BOOL)showCloseButton {
    _showCloseButton = showCloseButton;
    if (showCloseButton) {
        self.closeButton.hidden = NO;
    }
    else {
        self.closeButton.hidden = YES;
    }
}

- (UIButton *)closeButton {
    if (_closeButton) return _closeButton;
    _closeButton = [[UIButton alloc] init];
    _closeButton.tag = 0x92;
    [_closeButton addTarget:self action:@selector(didPressButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_closeButton setImage:[UIImage imageNamed:@"sign_tip_popup_close"] forState:UIControlStateNormal];
    [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(-10, -10, 10, 10)];
    _closeButton.hidden = YES;
    return _closeButton;
}

- (void)setHeaderImage:(UIImage *)headerImage {
    _headerImage = headerImage;
    if (_headerImage && [_headerImage isKindOfClass:[UIImage class]]) {
        self.headerImageView.image = _headerImage;
    }
}

- (void)setLeftButtonString:(NSString *)leftButtonString {
    _leftButtonString = leftButtonString;
    if (_leftButtonString && _leftButtonString.length > 0) {
        [self.iknowButton setTitle:_leftButtonString forState:UIControlStateNormal];
    }
}

- (void)setRightButtonString:(NSString *)rightButtonString {
    _rightButtonString = rightButtonString;
    if (_rightButtonString && _rightButtonString.length > 0) {
        [self.checkMoreButton setTitle:_rightButtonString forState:UIControlStateNormal];
    }
}

- (void)setLeftButtonTextColor:(UIColor *)leftButtonTextColor {
    _leftButtonTextColor = leftButtonTextColor;
    if (_leftButtonTextColor && [_leftButtonTextColor isKindOfClass:[UIColor class]]) {
        [self.iknowButton setTitleColor:_leftButtonTextColor forState:UIControlStateNormal];
    }
}

- (void)setRightButtonTextColor:(UIColor *)rightButtonTextColor {
    _rightButtonTextColor = rightButtonTextColor;
    if (_rightButtonTextColor && [_rightButtonTextColor isKindOfClass:[UIColor class]]) {
        [self.checkMoreButton setTitleColor:_rightButtonTextColor forState:UIControlStateNormal];
    }
}

- (UIButton *)iknowButton {
    if (_iknowButton) return _iknowButton;
    _iknowButton = [[UIButton alloc] init];
    [_iknowButton setTag:0x90];
    [_iknowButton addTarget:self action:@selector(didPressButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_iknowButton setTitle:ASLocalizedString(@"知道啦") forState:UIControlStateNormal];
    _iknowButton.titleLabel.font = FS4;
    [_iknowButton setTitleColor:FC1 forState:UIControlStateNormal];
    [_iknowButton setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdSubtitleColor]] forState:UIControlStateHighlighted];
    return _iknowButton;
}

- (UIButton *)checkMoreButton {
    if (_checkMoreButton) return _checkMoreButton;
    _checkMoreButton = [[UIButton alloc] init];
    _checkMoreButton.tag = 0x91;
    [_checkMoreButton addTarget:self action:@selector(didPressButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_checkMoreButton setTitle:ASLocalizedString(@"了解更多") forState:UIControlStateNormal];
    _checkMoreButton.titleLabel.font = FS4;
    [_checkMoreButton setTitleColor:FC5 forState:UIControlStateNormal];
    [_checkMoreButton setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdSubtitleColor]] forState:UIControlStateHighlighted];
    return _checkMoreButton;
}

- (UIImageView *)headerImageView {
    if (_headerImageView) return _headerImageView;
    _headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_img_backgroud"]];
    return _headerImageView;
}

- (UIView *)buttonLine {
    if (_buttonLine) return _buttonLine;
    _buttonLine = [[UIView alloc] init];
    _buttonLine.backgroundColor = [UIColor kdDividingLineColor];
    return _buttonLine;
}

- (UIView *)viewLine {
    if (_viewLine) return _viewLine;
    _viewLine = [[UIView alloc] init];
    _viewLine.backgroundColor = [UIColor kdDividingLineColor];
    return _viewLine;
}

- (UIView *)contentView {
    if (_contentView) return  _contentView;
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    return _contentView;
}

- (UILabel *)titleLabel {
    if (_titleLabel) return _titleLabel;
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = FS2;
    _titleLabel.textColor = FC1;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (_contentLabel) return _contentLabel;
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = FS5;
    _contentLabel.textColor = FC2;
    _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _contentLabel.numberOfLines = 0;
    return _contentLabel;
}

- (UIScrollView *)scrollView {
    if (_scrollView) return _scrollView;
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor clearColor];
    return _scrollView;
}

- (UIView *)scrollContentView {
    if (_scrollContentView) return _scrollContentView;
    _scrollContentView = [[UIView alloc] init];
    return _scrollContentView;
}

- (UIView *)bgView {
    if (_bgView) return _bgView;
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor kdPopupBackgroundColor];
    return _bgView;
}

@end
