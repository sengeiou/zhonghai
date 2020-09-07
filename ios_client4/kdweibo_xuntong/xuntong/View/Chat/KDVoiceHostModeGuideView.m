//
//  KDVoiceHostModeGuideView.m
//  kdweibo
//
//  Created by 张培增 on 16/9/26.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDVoiceHostModeGuideView.h"


#define bottomViewHeight 275
#define horizontalSpace ((ScreenFullWidth - 120) / 3)

@interface KDVoiceHostModeGuideView ()

@property (nonatomic, strong) UIView            *backgroundView;
@property (nonatomic, strong) UIView            *bottomView;
@property (nonatomic, strong) UILabel           *titleLabel;
@property (nonatomic, strong) UIButton          *closeButton;
@property (nonatomic, strong) UIView            *leftView;
@property (nonatomic, strong) UIImageView       *leftImageView;
@property (nonatomic, strong) UIView            *rightView;
@property (nonatomic, strong) UIImageView       *rightImageView;
@property (nonatomic, strong) UIImageView       *fingerImageView;
@property (nonatomic, strong) UIView            *tipsView;
@property (nonatomic, strong) UILabel           *tipsLabel;
@property (nonatomic, strong) CAShapeLayer      *leftGrayLayer;
@property (nonatomic, strong) CAShapeLayer      *leftBlueLayer;
@property (nonatomic, strong) CAShapeLayer      *rightGrayLayer;
@property (nonatomic, strong) CAShapeLayer      *rightBlueLayer;
@property (nonatomic, strong) UIButton          *againButton;
@property (nonatomic, strong) UIButton          *finishButton;

//记录用户引导进行到哪个步骤
@property (nonatomic, assign) NSInteger         currentStep;

@end

@implementation KDVoiceHostModeGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        //backgroundView
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.backgroundView.backgroundColor = [UIColor colorWithRGB:0x04142a];
        [self addSubview:self.backgroundView];
        self.backgroundView.alpha = 0.0;
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsZero);
        }];
        
        //bottomView
        self.bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bottomView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(self);
            make.height.mas_equalTo(bottomViewHeight);
            make.bottom.mas_equalTo(self).with.offset(bottomViewHeight);
        }];
        
        //titleLabel
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.text = @"主持人模式";
        self.titleLabel.textColor = FC1;
        self.titleLabel.font = FS1;
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.bottomView.mas_centerX);
            make.top.mas_equalTo(self.bottomView.top).with.offset(20);
        }];
        
        //closeButton
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:[UIImage imageNamed:@"phone_btn_close"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.closeButton];
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.bottomView).with.offset(-[NSNumber kdDistance1]);
            make.top.mas_equalTo(self.bottomView).with.offset([NSNumber kdDistance1]);
            make.height.mas_equalTo(16);
            make.width.mas_equalTo(16);
        }];
        
        //leftView
        self.leftView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addNameLabelToView:self.leftView name:@"韩梅梅"];
        [self.bottomView addSubview:self.leftView];
        [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bottomView.left).with.offset(horizontalSpace);
            make.height.mas_equalTo(84);
            make.width.mas_equalTo(60);
            make.bottom.mas_equalTo(self.bottomView).with.offset(-31);
        }];
        
        self.leftImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.leftImageView.layer.cornerRadius = 60 / 2;
        self.leftImageView.layer.masksToBounds = YES;
        self.leftImageView.userInteractionEnabled = YES;
        [self.leftView addSubview:self.leftImageView];
        [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.leftView.top).with.offset(0);
            make.centerX.mas_equalTo(self.leftView.mas_centerX);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(60);
        }];
        UITapGestureRecognizer *leftImageTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftImageViewDidClicked:)];
        [self.leftImageView addGestureRecognizer:leftImageTapGestureRecognizer];
        
        //rightView
        self.rightView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addNameLabelToView:self.rightView name:@"李雷"];
        [self.bottomView addSubview:self.rightView];
        [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.bottomView.right).with.offset(- horizontalSpace);
            make.height.mas_equalTo(84);
            make.width.mas_equalTo(60);
            make.bottom.mas_equalTo(self.bottomView).with.offset(-31);
        }];
        
        self.rightImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.rightImageView.layer.cornerRadius = 60 / 2;
        self.rightImageView.layer.masksToBounds = YES;
        self.rightImageView.userInteractionEnabled = YES;
        [self.rightView addSubview:self.rightImageView];
        [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.rightView.top).with.offset(0);
            make.centerX.mas_equalTo(self.rightView.mas_centerX);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(60);
        }];
        UITapGestureRecognizer *rightImageTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightImageViewDidClicked:)];
        [self.rightImageView addGestureRecognizer:rightImageTapGestureRecognizer];
        
        //fingerImageView
        self.fingerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 19)];
        [self.fingerImageView setImage:[UIImage imageNamed:@"phone_guide_finger"]];
        [self.bottomView addSubview:self.fingerImageView];
        
        //tipsView
        self.tipsView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tipsView.layer.borderColor = [UIColor kdBackgroundColor7].CGColor;
        self.tipsView.layer.borderWidth = 1.0;
        self.tipsView.layer.cornerRadius = 5.0;
        self.tipsView.layer.masksToBounds = YES;
        [self.bottomView addSubview:self.tipsView];
        [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.bottom).with.offset(31);
            make.width.mas_equalTo(148);
            make.height.mas_equalTo(52);
            make.left.mas_equalTo(self.bottomView.left).with.offset(horizontalSpace - 44);
        }];
        
        self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.tipsLabel.text = @"韩梅梅举手想要发言,\n点击她的头像试试看~";
        self.tipsLabel.font = FS6;
        self.tipsLabel.textColor = FC1;
        self.tipsLabel.numberOfLines = 0;
        [self.tipsView addSubview:self.tipsLabel];
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.tipsView.mas_centerX);
            make.centerY.mas_equalTo(self.tipsView.mas_centerY);
        }];
        
        //againButton
        self.againButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.againButton setTitle:@"再来一遍" forState:UIControlStateNormal];
        [self.againButton setTitleColor:FC2 forState:UIControlStateNormal];
        self.againButton.titleLabel.font = FS4;
        self.againButton.layer.cornerRadius = 22;
        self.againButton.layer.masksToBounds = YES;
        self.againButton.layer.borderWidth = 1;
        self.againButton.layer.borderColor = [UIColor colorWithRGB:0xDCE1E8].CGColor;
        [self.againButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.againButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor7]] forState:UIControlStateHighlighted];
        [self.againButton addTarget:self action:@selector(againButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.againButton];
        [self.againButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(118);
            make.height.mas_equalTo(44);
            make.bottom.mas_equalTo(self.bottomView.bottom).with.offset(-35);
            make.centerX.mas_equalTo(self.leftView.mas_centerX);
        }];
        
        //finishButton
        self.finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.finishButton setTitle:@"学会啦" forState:UIControlStateNormal];
        [self.finishButton setTitleColor:FC2 forState:UIControlStateNormal];
        self.finishButton.titleLabel.font = FS4;
        self.finishButton.layer.borderWidth = 1;
        self.finishButton.layer.borderColor = [UIColor colorWithRGB:0xDCE1E8].CGColor;
        self.finishButton.layer.cornerRadius = 22;
        self.finishButton.layer.masksToBounds = YES;
        [self.finishButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.finishButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor7]] forState:UIControlStateHighlighted];
        [self.finishButton addTarget:self action:@selector(finishButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.finishButton];
        [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(118);
            make.height.mas_equalTo(44);
            make.bottom.mas_equalTo(self.bottomView.bottom).with.offset(-35);
            make.centerX.mas_equalTo(self.rightView.mas_centerX);
        }];
    }
    
    return self;
}

- (void)addNameLabelToView:(UIView *)view name:(NSString *)name {
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.text = name;
    nameLabel.font = FS6;
    nameLabel.textColor = FC1;
    [view addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.bottom.mas_equalTo(view).with.offset(0);
    }];
}

- (void)addFingerAnimation {
    [UIView beginAnimations:@"position" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationRepeatCount:HUGE];
    [UIView setAnimationRepeatAutoreverses:YES];
    CGPoint center = self.fingerImageView.center;
    self.fingerImageView.center = CGPointMake(center.x, 145);
    [UIView commitAnimations];
}

- (CAShapeLayer *)setUpGrayLayerToView:(UIView *)view size:(CGSize)size tintColor:(UIColor *)tintColor {
    CAShapeLayer *circle = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(30, 30) radius:size.height/2 startAngle:M_PI/2 endAngle:5.0/2 * M_PI clockwise:YES];
    circle.path = path.CGPath;
    circle.fillColor = nil;
    circle.lineWidth = 2.5;
    circle.strokeColor = tintColor.CGColor;
    [view.layer addSublayer:circle];
    return circle;
}

- (CAShapeLayer *)setUpBlueLayerToView:(UIView *)view fromValue:(float)fromValue toValue:(float)toValue size:(CGSize)size tintColor:(UIColor *)tintColor {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @(fromValue);
    animation.toValue = @(toValue);
    animation.duration = 0.5;
    animation.repeatCount = HUGE;
    animation.autoreverses = YES;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(30, 30) radius:size.height/2 startAngle:M_PI/2 endAngle:5.0/2 * M_PI clockwise:YES];
    circle.path = path.CGPath;
    circle.fillColor = nil;
    circle.lineWidth = 2.5;
    circle.strokeColor = tintColor.CGColor;
    [circle addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    [view.layer addSublayer:circle];
    return circle;
}

- (void)leftImageViewDidClicked:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.currentStep == 1) {
        [self.fingerImageView.layer removeAllAnimations];
        self.fingerImageView.center = CGPointMake(2 * horizontalSpace + 90, 138);
        [self addFingerAnimation];
        
        [self.leftImageView setImage:[UIImage imageNamed:@"phone_guide_speak_female"]];
        
        //音量动画
        self.leftGrayLayer = [self setUpGrayLayerToView:self.leftView size:CGSizeMake(65.5, 65.5) tintColor:[UIColor kdBackgroundColor7]];
        self.leftBlueLayer = [self setUpBlueLayerToView:self.leftView fromValue:0.6 toValue:0.8 size:CGSizeMake(65.5, 65.5) tintColor:FC10];
        
        [self.tipsView updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bottomView.left).with.offset(ScreenFullWidth - (horizontalSpace + 148 - 44));
        }];
        self.tipsLabel.text = @"想让李雷发言,就点击他\n的头像吧~";
        
        self.currentStep++;
    }
    else if (self.currentStep == 3) {
        [self.leftImageView setImage:[UIImage imageNamed:@"phone_guide_mute_female"]];
        
        if (self.leftGrayLayer) {
            [self.leftGrayLayer removeFromSuperlayer];
            self.leftGrayLayer = nil;
        }
        if(self.leftBlueLayer) {
            [self.leftBlueLayer removeFromSuperlayer];
            self.leftBlueLayer = nil;
        }
        
        [self.fingerImageView.layer removeAllAnimations];
        self.fingerImageView.center = CGPointMake(horizontalSpace + 30, 138);
        self.fingerImageView.hidden = YES;
        
        self.tipsView.hidden = YES;
        [self.leftView updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bottomView.bottom).with.offset(-111);
        }];
        [self.leftView setNeedsUpdateConstraints];
        [self.leftView updateConstraintsIfNeeded];
        [self.rightView updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bottomView.bottom).with.offset(-111);
        }];
        [self.rightView setNeedsUpdateConstraints];
        [self.rightView updateConstraintsIfNeeded];
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.bottomView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.againButton.hidden = NO;
            self.finishButton.hidden = NO;
        }];
        
        self.currentStep++;
    }
}

- (void)rightImageViewDidClicked:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.currentStep == 2) {
        [self.fingerImageView.layer removeAllAnimations];
        self.fingerImageView.center = CGPointMake(horizontalSpace + 30, 138);
        [self addFingerAnimation];
        
        [self.rightImageView setImage:[UIImage imageNamed:@"phone_guide_speak_male"]];
        
        //音量动画
        self.rightGrayLayer = [self setUpGrayLayerToView:self.rightView size:CGSizeMake(65.5, 65.5) tintColor:[UIColor kdBackgroundColor7]];
        self.rightBlueLayer = [self setUpBlueLayerToView:self.rightView fromValue:0.1 toValue:0.3 size:CGSizeMake(65.5, 65.5) tintColor:FC10];
        
        [self.tipsView updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bottomView.left).with.offset(horizontalSpace  - 44);
        }];
        self.tipsLabel.text = @"觉得声音太嘈杂?点击\n头像让她静音~";
        
        self.currentStep++;
    }
}

- (void)closeButtonDidClicked:(UIButton *)sender {
    [self hide];
}

- (void)againButtonDidClicked:(UIButton *)sender {
    self.againButton.hidden = YES;
    self.finishButton.hidden = YES;
    if (self.rightGrayLayer) {
        [self.rightGrayLayer removeFromSuperlayer];
        self.rightGrayLayer = nil;
    }
    if(self.rightBlueLayer) {
        [self.rightBlueLayer removeFromSuperlayer];
        self.rightBlueLayer = nil;
    }
    
    [self.leftImageView setImage:[UIImage imageNamed:@"phone_guide_handsup_female"]];
    [self.rightImageView setImage:[UIImage imageNamed:@"phone_guide_mute_male"]];
    
    [self.leftView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomView.bottom).with.offset(-31);
    }];
    [self.leftView setNeedsUpdateConstraints];
    [self.leftView updateConstraintsIfNeeded];
    [self.rightView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomView.bottom).with.offset(-31);
    }];
    [self.rightView setNeedsUpdateConstraints];
    [self.rightView updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.bottomView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.tipsView.hidden = NO;
        self.tipsLabel.text = @"韩梅梅举手想要发言,\n点击她的头像试试看~";
        self.currentStep = 1;
        self.fingerImageView.hidden = NO;
        [self addFingerAnimation];
    }];
}

- (void)finishButtonDidClicked:(UIButton *)sender {
    [self hide];
}

- (void)show {
    [self initStatus];
    
    [AppWindow addSubview:self];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(AppWindow).with.insets(UIEdgeInsetsZero);
    }];
    
    [self layoutIfNeeded];
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).with.offset(0);
    }];
    [self.bottomView setNeedsUpdateConstraints];
    [self.bottomView updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
        self.backgroundView.alpha = 0.3;
    }];
}

- (void)initStatus {
    self.againButton.hidden = YES;
    self.finishButton.hidden = YES;
    [self.leftImageView setImage:[UIImage imageNamed:@"phone_guide_handsup_female"]];
    [self.rightImageView setImage:[UIImage imageNamed:@"phone_guide_mute_male"]];
    [self.leftView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomView.bottom).with.offset(-31);
    }];
    
    if (self.leftGrayLayer) {
        [self.leftGrayLayer removeFromSuperlayer];
        self.leftGrayLayer = nil;
    }
    if(self.leftBlueLayer) {
        [self.leftBlueLayer removeFromSuperlayer];
        self.leftBlueLayer = nil;
    }
    [self.rightView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomView.bottom).with.offset(-31);
    }];
    if (self.rightGrayLayer) {
        [self.rightGrayLayer removeFromSuperlayer];
        self.rightGrayLayer = nil;
    }
    if(self.rightBlueLayer) {
        [self.rightBlueLayer removeFromSuperlayer];
        self.rightBlueLayer = nil;
    }
    self.tipsView.hidden = NO;
    [self.tipsView updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bottomView.left).with.offset(horizontalSpace  - 44);
    }];
    self.tipsLabel.text = @"韩梅梅举手想要发言,\n点击她的头像试试看~";
    self.currentStep = 1;
    self.fingerImageView.center = CGPointMake(horizontalSpace + 30, 138);
    self.fingerImageView.hidden = NO;
    [self addFingerAnimation];
}

- (void)hide {
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).with.offset(bottomViewHeight);
    }];
    [self.bottomView setNeedsUpdateConstraints];
    [self.bottomView updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
