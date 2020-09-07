//
//  KDPubAccFooterView.m
//  kdweibo
//
//  Created by wenbin_su on 16/1/21.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDPubAccFooterView.h"

@interface KDPubAccFooterView ()
@property (nonatomic, strong) UIButton *attentionButton;
@property (nonatomic, strong) UIView  *adminTipsView;
@property (nonatomic, strong) UILabel *adminTipsLabel;
@end

@implementation KDPubAccFooterView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor kdBackgroundColor2];
        
        [self addSubview:self.attentionButton];
        [self addSubview:self.adminTipsView];
        [self setupVFL];
    }
    return self;
}

- (UIButton *)attentionButton {
    if (_attentionButton == nil) {
        _attentionButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"添加")];
        [_attentionButton.titleLabel setFont:FS2];
        [_attentionButton addTarget:self action:@selector(attentionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _attentionButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_attentionButton setCircle];
    }
    return _attentionButton;
}

- (UIView *)adminTipsView {
    if (_adminTipsView == nil)
    {
        _adminTipsView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.attentionButton.frame)+15, CGRectGetMaxY(self.attentionButton.frame)+30, ScreenFullWidth - 30, 15)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reg_img_notice_normal"]];
        imageView.frame = CGRectMake(0, 0, 15, 15);
        [_adminTipsView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+5, CGRectGetMinY(imageView.frame), 100, CGRectGetHeight(imageView.frame))];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:14];
        label.text = ASLocalizedString(@"KDApplicationViewController_tips_warn");
        [_adminTipsView addSubview:label];
        
        
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+5, CGRectGetWidth(_adminTipsView.frame), 0)];
        tipsLabel.textAlignment = NSTextAlignmentLeft;
        tipsLabel.textColor = [UIColor lightGrayColor];
        tipsLabel.font = [UIFont systemFontOfSize:14];
        tipsLabel.numberOfLines = 0;
        [_adminTipsView addSubview:tipsLabel];
        self.adminTipsLabel = tipsLabel;
    }
    return _adminTipsView;
}


-(void)setTipsLabelText:(NSString *)tips
{
    self.adminTipsLabel.text = tips;
    CGRect frame = self.adminTipsLabel.frame;
    [self.adminTipsLabel sizeToFit];
    frame.size.height = self.adminTipsLabel.frame.size.height;
    self.adminTipsLabel.frame = frame;
}

-(void)setupVFL
{
     NSDictionary *viewsDictionary = @{@"attentionButton":self.attentionButton};
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[attentionButton]-12-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[attentionButton]-10-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    // 3.B ...and try to change the visual format string
    //NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[redView]-30-|" options:0 metrics:nil views:viewsDictionary];
    //NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[redView]" options:0 metrics:nil views:viewsDictionary];
    
    [self addConstraints:constraint_POS_H];
    [self addConstraints:constraint_POS_V];
}

-(void)attentionButtonPressed:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubAccFooterViewAttentionButtonPressed:)]) {
        [self.delegate pubAccFooterViewAttentionButtonPressed:self];
    }
}
@end
