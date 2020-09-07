//
//  KDPersonHeaderBar.m
//  kdweibo
//
//  Created by Gil on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPersonHeaderBar.h"

@interface KDPersonHeaderBar ()
@property (strong, nonatomic) NSString *backBtnTitle;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *backButtonInWhite;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *backgroundView;
@end

@implementation KDPersonHeaderBar

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame backBtnTitle:ASLocalizedString(@"Global_GoBack")];
}

- (id)initWithFrame:(CGRect)frame backBtnTitle:(NSString *)backBtnTitle {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backBtnTitle = backBtnTitle;
        
        [self addSubview:self.backButton];
        
        [self.backgroundView addSubview:self.nameLabel];
        [self.backgroundView addSubview:self.backButtonInWhite];
        [self addSubview:self.backgroundView];
        
        [self setupVFL];
    }
    return self;
}

- (UIImageView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"nav_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 21)]];
        _backgroundView.frame = self.bounds;
        _backgroundView.userInteractionEnabled = YES;
        _backgroundView.alpha = .0;
    }
    return _backgroundView;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton backBtnInWhiteNavWithTitle:self.backBtnTitle inNav:NO];
        [_backButton setImage:[[UIImage imageNamed:@"nav_btn_back_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _backButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _backButton;
}

- (UIButton *)backButtonInWhite {
    if (_backButtonInWhite == nil) {
        _backButtonInWhite = [UIButton backBtnInWhiteNavWithTitle:self.backBtnTitle inNav:NO];
        [_backButtonInWhite addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _backButtonInWhite.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _backButtonInWhite;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(.0, .0, .0, 25.0)];
        _nameLabel.font = FS1;
        _nameLabel.textColor = FC1;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _nameLabel;
}

- (void)setupVFL {
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-kSpace-[backButton]"
                                                                 options:nil
                                                                 metrics:@{@"kSpace": @([NSNumber kdDistance1])}
                                                                   views:@{@"backButton" : self.backButton}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backButton(27)]-kSpace-|"
                                                                 options:nil
                                                                 metrics:@{@"kSpace": @((44-27)/2)}
                                                                   views:@{@"backButton" : self.backButton}]];
    
    autolayoutSetCenterX(self.nameLabel);
    [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameLabel(25)]-kSpace-|"
                                                                                options:nil
                                                                                metrics:@{@"kSpace": @((44-25)/2)}
                                                                                  views:@{@"nameLabel" : self.nameLabel}]];
    [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-kSpace-[backButtonInWhite]"
                                                                                options:nil
                                                                                metrics:@{@"kSpace": @([NSNumber kdDistance1])}
                                                                                  views:@{@"backButtonInWhite" : self.backButtonInWhite}]];
    [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backButtonInWhite(27)]-kSpace-|"
                                                                                options:nil
                                                                                metrics:@{@"kSpace": @((44-27)/2)}
                                                                                  views:@{@"backButtonInWhite" : self.backButtonInWhite}]];
}

#pragma mark - button pressed

- (void)backBtnPressed:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(personHeaderBarBackButtonPressed:)]) {
        [self.delegate personHeaderBarBackButtonPressed:self];
    }
}

@end
