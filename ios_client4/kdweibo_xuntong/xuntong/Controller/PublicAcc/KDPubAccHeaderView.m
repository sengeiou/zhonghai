//
//  KDPubAccHeaderView.m
//  kdweibo
//
//  Created by wenbin_su on 15/9/15.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPubAccHeaderView.h"

@interface KDPubAccHeaderView ()
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *distributionLabel;
@property (nonatomic, strong) UILabel *noteLabel;
//@property (nonatomic, strong) UIButton *attentionButton;
@property (nonatomic, strong) UILabel *dividingLine;
@end

@implementation KDPubAccHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor kdBackgroundColor2];
        
        [self addSubview:self.photoView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.dividingLine];
        [self addSubview:self.distributionLabel];
        [self addSubview:self.noteLabel];
//        [self addSubview:self.attentionButton];
        [self setupVFL];
    }
    return self;
}

- (UIImageView *)photoView {
    if (_photoView == nil) {
        _photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoView.layer.cornerRadius = 6.0;
        _photoView.layer.masksToBounds = YES;
        _photoView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _photoView;
}

- (UILabel *)dividingLine {
    if (_dividingLine == nil) {
        _dividingLine = [[UILabel alloc] initWithFrame:CGRectZero];
        _dividingLine.backgroundColor = [UIColor kdDividingLineColor];
        _dividingLine.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _dividingLine;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = FS1;
        _nameLabel.textColor = FC1;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.backgroundColor = self.backgroundColor;
    }
    return _nameLabel;
}

- (UILabel *)distributionLabel {
    if (_distributionLabel == nil) {
        _distributionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _distributionLabel.font = FS7;
        _distributionLabel.textColor = FC1;
        _distributionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _distributionLabel.backgroundColor = self.backgroundColor;
        _distributionLabel.text = ASLocalizedString(@"KDSignInSettingViewController_functionCell_leftLabel_text");
    }
    return _distributionLabel;
}

- (UILabel *)noteLabel {
    if (_noteLabel == nil) {
        _noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _noteLabel.font = FS4;
        _noteLabel.textColor = FC1;
        _noteLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noteLabel.backgroundColor = self.backgroundColor;
        _noteLabel.numberOfLines = 0;
    }
    return _noteLabel;
}

//- (UIButton *)attentionButton {
//    if (_attentionButton == nil) {
//        _attentionButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"添加")];
//        [_attentionButton.titleLabel setFont:FS2];
//        [_attentionButton addTarget:self action:@selector(attentionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        _attentionButton.translatesAutoresizingMaskIntoConstraints = NO;
//    }
//    return _attentionButton;
//}

- (void)setupVFL {
    NSDictionary *views = @{ @"photoView":self.photoView,
                             @"nameLabel":self.nameLabel,
                             @"dividingLine":self.dividingLine,
                             @"distributionLabel":self.distributionLabel,
                             @"noteLabel":self.noteLabel };
    
    NSDictionary *metrics = @{@"kSpace" : @([NSNumber kdDistance1])};
    NSArray *vfls = @[@"|-kSpace-[photoView(70)]-kSpace-[nameLabel]-kSpace-|",
                      @"|-kSpace-[distributionLabel]-kSpace-|",
                      @"|-kSpace-[noteLabel]-kSpace-|",
                      @"|-kSpace-[dividingLine]-kSpace-|",
                      @"V:|-kSpace-[photoView(70)]-kSpace-[dividingLine(0.5)]-kSpace-[distributionLabel(14)]-kSpace-[noteLabel]",];
//                      @"V:[attentionButton(44)]-kSpace-|"];
    for (NSString *vfl in vfls) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl
                                                                     options:nil
                                                                     metrics:metrics
                                                                       views:views]];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.photoView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.f constant:0.f]];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.photoView.layer.cornerRadius = (ImageViewCornerRadius==-1?(CGRectGetHeight(self.photoView.frame)/2):ImageViewCornerRadius);
    self.photoView.layer.masksToBounds = YES;
    self.photoView.layer.shouldRasterize = YES;
    self.photoView.layer.rasterizationScale = [UIScreen mainScreen].scale;
}



#pragma mark - button pressed
//
//- (void)attentionButtonPressed:(UIButton *)btn {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(pubAccHeaderViewAttentionButtonPressed:)]) {
//        [self.delegate pubAccHeaderViewAttentionButtonPressed:self];
//    }
//}

@end