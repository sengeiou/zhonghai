//
//  KDVoiceHostModeTipsView.m
//  kdweibo
//
//  Created by 张培增 on 2016/10/7.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDVoiceHostModeTipsView.h"


@interface KDVoiceHostModeTipsView ()

@property (nonatomic, strong) UIView        *topView;
@property (nonatomic, strong) UIImageView   *circleView;
@property (nonatomic, strong) UIImageView   *lineView;
@property (nonatomic, strong) UIImageView   *closeView;
@property (nonatomic, strong) UILabel       *contentLabel;
@property (nonatomic, strong) UILabel       *attributedContentLabel;

@end

@implementation KDVoiceHostModeTipsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self addSubview:self.topView];
//        [self addSubview:self.lineView];
        [self addSubview:self.circleView];
        [self.topView addSubview:self.contentLabel];
        [self.topView addSubview:self.attributedContentLabel];
        [self.topView addSubview:self.closeView];
        
        [self.topView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).with.offset(0);
            make.left.equalTo(self.left).with.offset(0);
            make.right.equalTo(self.right).with.offset(0);
            make.height.mas_equalTo(65);
        }];
        
        [self.closeView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView.centerY);
            make.right.equalTo(self.topView.right).with.offset(-12);
        }];
        
        [self.contentLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.top).with.offset(14);
            make.left.equalTo(self.topView.left).with.offset(12);
            make.right.equalTo(self.topView.right).with.offset(-38);
        }];
        
        [self.attributedContentLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLabel.bottom).with.offset(6);
            make.left.equalTo(self.topView.left).with.offset(12);
            make.right.equalTo(self.topView.right).with.offset(-54);
        }];
        
        [self.circleView makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bottom).with.offset(0);
            make.right.equalTo(self.right).with.offset(-30);
        }];
        
//        [self.lineView makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.topView.bottom).with.offset(0);
//            make.bottom.equalTo(self.circleView.top).with.offset(0);
//            make.width.mas_equalTo(2);
//            make.left.equalTo(self.circleView.centerX).with.offset(-1);
//        }];
        
        UITapGestureRecognizer *close = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        [self.closeView addGestureRecognizer:close];
        
        UITapGestureRecognizer *show = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(show)];
        [self.attributedContentLabel addGestureRecognizer:show];
    }
    
    return self;
}

- (UIImageView *)circleView
{
    if (!_circleView)
    {
        _circleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _circleView.image = [UIImage imageNamed:@"admin_tip_checkbackground_circle"];
    }
    return _circleView;
}

- (UIImageView *)closeView
{
    if (!_closeView)
    {
        _closeView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _closeView.image = [UIImage imageNamed:@"phone_tip_close"];
        _closeView.userInteractionEnabled = YES;
    }
    return _closeView;
}

//- (UIImageView *)lineView
//{
//    if (!_lineView)
//    {
//        _lineView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        _lineView.backgroundColor = [UIColor kdPopupColor];
//    }
//    return _lineView;
//}

- (UILabel *)contentLabel
{
    if (!_contentLabel)
    {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.textColor = FC6;
        _contentLabel.font = FS6;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.text = @"超炫酷的新功能上线啦~";
        
    }
    return _contentLabel;
}

- (UILabel *)attributedContentLabel
{
    if (!_attributedContentLabel)
    {
        _attributedContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _attributedContentLabel.textColor = FC6;
        _attributedContentLabel.font = FS6;
        _attributedContentLabel.textAlignment = NSTextAlignmentLeft;
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"9秒学习新功能"];
        [str addAttribute:NSFontAttributeName value:FS6 range:NSMakeRange(0, str.length)];
        [str addAttribute:NSForegroundColorAttributeName value:FC10 range:NSMakeRange(0, str.length)];
        [str addAttribute:NSUnderlineStyleAttributeName value:@(1) range:NSMakeRange(0, str.length)];
        _attributedContentLabel.attributedText = str;
        _attributedContentLabel.userInteractionEnabled = YES;
    }
    return _attributedContentLabel;
}

- (UIView *)topView
{
    if (!_topView)
    {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = [UIColor kdPopupColor];
        _topView.layer.masksToBounds = YES;
        _topView.layer.cornerRadius = 6.0f;
    }
    return _topView;
}

- (void)close
{
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)show
{
    if (self.clickedBlock) {
        self.clickedBlock();
        [self close];
    }
}

@end
