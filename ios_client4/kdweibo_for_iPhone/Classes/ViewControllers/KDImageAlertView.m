//
//  KDImageAlertView.m
//  kdweibo
//
//  Created by kingdee on 2017/8/29.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDImageAlertView.h"


@interface KDImageAlertView()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;

@end

@implementation KDImageAlertView

- (instancetype)initWithTitle:(NSString *)title Image:(UIImage *)image {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor kdPopupColor];
        self.title = title;
        self.image = image;
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat containerWidth = [UIScreen mainScreen].bounds.size.width/3*2;
    CGFloat containerHeight = [UIScreen mainScreen].bounds.size.height/2;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerWidth, containerHeight)];
    containerView.center = self.center;
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 8.0;
    containerView.layer.masksToBounds = YES;
    [self addSubview:containerView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.title;
    titleLabel.font = FS3;
    titleLabel.textColor = [UIColor blackColor];
    [containerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.superview).with.offset(12);
        make.top.equalTo(titleLabel.superview).with.offset(12);
        make.width.mas_equalTo(containerWidth-24);
        make.height.mas_equalTo(20);
    }];
    
    UIImageView *imageV = [[UIImageView alloc] initWithImage:self.image];
    imageV.userInteractionEnabled = YES;
    imageV.layer.cornerRadius = 5.0;
    imageV.layer.masksToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editImage)];
    [imageV addGestureRecognizer:tap];
    [containerView addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).with.offset(12);
        make.top.equalTo(titleLabel.bottom).with.offset(8);
        make.right.equalTo(containerView).with.offset(-12);
        make.bottom.equalTo(containerView).with.offset(-58);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = ASLocalizedString(@"KDImageAlertView_tip");
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = FS6;
    tipLabel.backgroundColor = [UIColor grayColor];
    tipLabel.layer.cornerRadius = 8;
    tipLabel.layer.masksToBounds = YES;
    [imageV addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imageV);
        make.centerY.equalTo(imageV.bottom).with.offset(-16);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(16);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor kdBackgroundColor1];
    [containerView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView);
        make.right.equalTo(containerView);
        make.top.equalTo(imageV.bottom).with.offset(8);
        make.height.mas_equalTo(0.5);
    }];
    
    UIView *lineUpright = [[UIView alloc] init];
    lineUpright.backgroundColor = [UIColor kdBackgroundColor1];
    [containerView addSubview:lineUpright];
    [lineUpright mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).with.offset(containerWidth/2);
        make.top.equalTo(line.bottom).with.offset(5);
        make.width.mas_equalTo(0.5);
        make.height.mas_equalTo(40);
    }];
    
    UIButton *cancelBtn = [UIButton normalBtnWithTile:ASLocalizedString(@"Global_Cancel")];
    [cancelBtn addTarget:self action:@selector(hideImageAlert) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.center = CGPointMake(containerWidth/4, containerHeight - 25);
    [containerView addSubview:cancelBtn];
//    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(imageV.bottom).with.offset(8);
//        make.left.equalTo(containerView).offset(20);
        
//    }];
    
    UIButton *confirmBtn = [UIButton normalBtnWithTile:ASLocalizedString(@"Global_Sure")];
    [confirmBtn addTarget:self action:@selector(clickConfirm) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.center = CGPointMake(containerWidth/4*3, containerHeight - 25);
    [containerView addSubview:confirmBtn];
//    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(imageV.bottom).with.offset(8);
//        make.right.equalTo(containerView).offset(-20);
//    }];
}

- (void)editImage {
    if (self.editImageBlock) {
        self.editImageBlock();
    }
    [self hideImageAlert];
}

- (void)clickConfirm {
    if (self.clickConfirmBlock) {
        self.clickConfirmBlock();
    }
    [self hideImageAlert];
}

- (void)showImageAlert {
    [[KDWeiboAppDelegate getAppDelegate].window addSubview:self];
}

- (void)hideImageAlert {
    [self removeFromSuperview];
}


@end
