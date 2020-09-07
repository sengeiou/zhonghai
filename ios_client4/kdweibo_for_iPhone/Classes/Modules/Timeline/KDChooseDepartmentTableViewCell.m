//
//  KDChooseDepartmentTableViewCell.m
//  kdweibo
//
//  Created by DarrenZheng on 14-7-10.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDChooseDepartmentTableViewCell.h"

@interface KDChooseDepartmentTableViewCell ()

@property(nonatomic, strong) UIButton *buttonCheckbox;
@property(nonatomic, strong) UIImageView *imageViewCheckbox;
@end

@implementation KDChooseDepartmentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.imageViewCheckbox];
        [self.contentView addSubview:self.buttonCheckbox];
        [self.contentView addSubview:self.labelDepartment];
        [self.contentView addSubview:self.labelPersonCount];
        [self masMake];
    }
    return self;
}

- (void)masMake {
    [self.imageViewCheckbox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).with.offset([NSNumber kdDistance1]);
        make.width.mas_equalTo(Width(_imageViewCheckbox.frame));
        make.height.mas_equalTo(Height(_imageViewCheckbox.frame));
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.buttonCheckbox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).with.offset([NSNumber kdDistance1]);
        make.width.mas_equalTo(Width(_imageViewCheckbox.frame) + 10);
        make.height.mas_equalTo(Height(_imageViewCheckbox.frame) + 10);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.labelDepartment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.imageViewCheckbox.right).with.offset([NSNumber kdDistance1]);
        make.right.mas_equalTo(self.contentView.right).with.offset(-50);
    }];
    
    [self.labelPersonCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).with.offset(-2 * [NSNumber kdDistance1] - 3);
    }];
}

- (void)setModel:(KDChooseDepartmentModel *)model {
    _model = model;
    if (!model) return;
    NSArray *cons = [MASViewConstraint installedConstraintsForView:self.labelPersonCount];
    for (MASConstraint *con in cons) {
        [con uninstall];
    }
    if (!model.bIsLeaf) {
        [self.labelPersonCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.contentView).with.offset(-2 * [NSNumber kdDistance1] - 3);
        }];
    }
    else {
        [self.labelPersonCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.contentView).with.offset(-[NSNumber kdDistance1]);
        }];
    }
}

- (UIButton *)buttonCheckbox {
    if (!_buttonCheckbox) {
        _buttonCheckbox = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonCheckbox addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _buttonCheckbox;
}

- (UIImageView *)imageViewCheckbox {
    if (!_imageViewCheckbox) {
        _imageViewCheckbox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"task_editor_select"]];
    }
    return _imageViewCheckbox;
}

- (UILabel *)labelDepartment {
    if (!_labelDepartment) {
        _labelDepartment = [[UILabel alloc] init];
        _labelDepartment.font = FS3;
        _labelDepartment.backgroundColor = [UIColor clearColor];
    }
    return _labelDepartment;
}

- (UILabel *)labelPersonCount {
    if (!_labelPersonCount) {
        _labelPersonCount = [[UILabel alloc] init];
        _labelPersonCount.font = FS3;
        _labelPersonCount.textColor = FC2;
        _labelPersonCount.backgroundColor = [UIColor clearColor];
    }
    return _labelPersonCount;
}


- (void)setChecked:(BOOL)checked {
    _checked = checked;
    _imageViewCheckbox.image = checked ? [UIImage imageNamed:@"task_editor_finish"] : [UIImage imageNamed:@"task_editor_select"];
}

#pragma mark - Actions

- (void)buttonClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonCheckboxPressed:index:title:)])
    {
        [self.delegate buttonCheckboxPressed:self.model index:_index title:_labelDepartment.text];
    }
}

@end
