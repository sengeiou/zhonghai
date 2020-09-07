//
//  KDChooseDepartmentBottomBarView.m
//  kdweibo
//
//  Created by DarrenZheng on 14-7-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDChooseDepartmentBottomBarView.h"
#import "KDSelectItemView.h"

@interface KDChooseDepartmentBottomBarView ()

@property(nonatomic, strong) UIImageView *imageViewBottomBG;
@property(nonatomic, strong) KDWideButton *buttonConfirm;
@property (nonatomic, strong) NSMutableArray *delegateArr;
@property (nonatomic, strong) NSMutableArray *departmentModels;
@property (strong , nonatomic) UIScrollView *contentScrollView;
@end

@implementation KDChooseDepartmentBottomBarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.departmentModels = [[NSMutableArray alloc] init];
        [self addSubview:self.imageViewBottomBG];
        [_imageViewBottomBG makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top);
            make.left.equalTo(self.left);
            make.right.equalTo(self.right);
            make.height.mas_equalTo(44.0);
        }];
        
        [self addSubview:self.labelDepartment];
        [self.labelDepartment makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).with.offset(10);
            make.top.equalTo(self.top).with.offset(16);
            make.width.mas_equalTo(228);
            make.height.mas_equalTo(21);
        }];
        
        [self addSubview:self.buttonConfirm];
        [_buttonConfirm makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.right).with.offset(-12);
            make.centerY.equalTo(self.centerY);
            make.width.mas_equalTo(52);
            make.height.mas_equalTo(30);
        }];
        
        [self addSubview:self.contentScrollView];
        [self.contentScrollView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left);
            make.right.equalTo(self.buttonConfirm.left).with.offset(-10);
            make.top.equalTo(self.top);
            make.height.mas_equalTo(44.0);
        }];
        
        self.labelDepartment.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        [self replaceSubViews];
    }
    return self;
}

- (void)replaceSubViews{
    for (UIView *view in self.contentScrollView.subviews) {
        if ([view isKindOfClass:[KDSelectItemView class]]) {
            [view removeFromSuperview];
        }
    }
    
    KDSelectItemView *lastView = nil;
    for (NSInteger indexmodel = 0;indexmodel<_departmentModels.count ; indexmodel++) {
        @autoreleasepool {
            KDChooseDepartmentModel *model = _departmentModels[indexmodel];
            KDSelectItemView *selectedView = [[KDSelectItemView alloc] initWithViewStyle:SelectItemViewStyleNormalFirst viewTitle:model.strName atIndex:indexmodel];
            //签到迁移，暂时屏蔽
//            [selectedView setItemTitleColor:[UIColor blackColor]];
//            [selectedView setItemEnale:NO];
            CGSize size = [selectedView getItemViewSize];
            [_contentScrollView addSubview:selectedView];
            if (lastView == nil) {
                [selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.contentScrollView).with.offset([NSNumber kdDistance1]);
                    make.centerY.mas_equalTo(self.contentScrollView);
                    make.width.mas_equalTo(size.width);
                    make.height.mas_equalTo(size.height);
                }];
            }
            else {
                [selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(lastView.right).with.offset(8);
                    make.centerY.mas_equalTo(self.contentScrollView);
                    make.width.mas_equalTo(size.width);
                    make.height.mas_equalTo(size.height);
                }];
            }
            
            if (indexmodel == _departmentModels.count - 1) {
                [selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(self.contentScrollView).with.offset(-[NSNumber kdDistance1]);
                }];
            }
            lastView = selectedView;
        }
    }
}


- (UIScrollView *)contentScrollView {
    if (_contentScrollView) return _contentScrollView;
    _contentScrollView = [[UIScrollView alloc] init];
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.backgroundColor = [UIColor clearColor];
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    return _contentScrollView;
}

- (UIImageView *)imageViewBottomBG {
    if (!_imageViewBottomBG) {
        _imageViewBottomBG = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"toolbar_other_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 21)]];
        _imageViewBottomBG.backgroundColor = [UIColor kdBackgroundColor2];
    }
    return _imageViewBottomBG;
}

- (UILabel *)labelDepartment {
    if (!_labelDepartment) {
        _labelDepartment = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelDepartment.font = FS3;
        _labelDepartment.textColor = FC1;
    }
    return _labelDepartment;
}

- (void)updateButtonColor {
    if (self.departmentModels && self.departmentModels.count > 0) {
        self.buttonConfirm.enabled = YES;
    }
    else {
        self.buttonConfirm.enabled = NO;
    }
}

- (void)updateButtonColorWithConfirm:(BOOL)confirm {
    if (confirm) {
        self.buttonConfirm.enabled = YES;
    }
    else {
        self.buttonConfirm.enabled = NO;
    }
}

- (KDWideButton *)buttonConfirm {
    if (!_buttonConfirm) {
        _buttonConfirm = [KDWideButton new];
        [_buttonConfirm setTitle:ASLocalizedString(@"确定") forState:UIControlStateNormal];
        [_buttonConfirm.titleLabel setFont:FS5];
        _buttonConfirm.enabled = NO;
        _buttonConfirm.layer.cornerRadius = 30.0/2;
        [_buttonConfirm setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdDividingLineColor]] forState:UIControlStateDisabled];
        [_buttonConfirm setBackgroundImage:[UIImage kd_imageWithColor:FC5] forState:UIControlStateNormal];
        [_buttonConfirm setBackgroundImage:[UIImage kd_imageWithColor:FC5] forState:UIControlStateHighlighted];
        [_buttonConfirm addTarget:self action:@selector(buttonConfirmPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonConfirm;
}



- (void)buttonConfirmPressed:(UIButton *)button {
    if (self.delegate) {
        [self.delegate buttonConfirmPressed];
    }
}

- (void)reloadDataWithDepartments:(NSArray *)departments {
    if (!departments) return;
    if(!_departmentModels){
        _departmentModels = [NSMutableArray new];
    }else if(_departmentModels.count >0){
        [_departmentModels  removeAllObjects];
    }
    [_departmentModels addObjectsFromArray:departments];
    [self updateButtonColor];
    [self replaceSubViews];
}

@end
