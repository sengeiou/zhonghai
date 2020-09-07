//
//  KDMessageRemoteSettingDatePickerView.m
//  kdweibo
//
//  Created by liwenbo on 15/12/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDMessageRemoteSettingDatePickerView.h"

#define completeButtonTag 60000
#define cancelButtonTag 60001


@interface KDMessageRemoteSettingDatePickerView()


@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) NSDate *currentDate;
//@property (nonatomic, strong) UIButton *completeButton;
//@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation KDMessageRemoteSettingDatePickerView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.buttonView];
        [_buttonView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top); 
            make.left.equalTo(self.left);
            make.right.equalTo(self.right);
            make.height.mas_equalTo(44);
        }];

        [self addSubview:self.datePicker];
        [self.datePicker makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left); 
            make.top.equalTo(self.top).with.offset(44);
            make.right.equalTo(self.right);
            make.height.mas_equalTo(216);
        }];
    }
    return self;
}

- (UIView *)buttonView
{
    if (!_buttonView)
    {
        _buttonView = [[UIView alloc] init];        
        _buttonView.backgroundColor = [UIColor kdBackgroundColor3];
        
        UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [completeButton setTitle:ASLocalizedString(@"Global_Done") forState:UIControlStateNormal];
        [completeButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [completeButton setTitleColor:FC5 forState:UIControlStateNormal];
        [completeButton.titleLabel setFont:FS3];
        completeButton.tag = completeButtonTag;
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setTitle:ASLocalizedString(@"Global_Cancel") forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:FC5 forState:UIControlStateNormal];
        
        [cancelButton.titleLabel setFont:FS3];
        cancelButton.frame = CGRectMake([NSNumber kdDistance1], 0, 40, 44);
        cancelButton.tag = cancelButtonTag;
        
        [_buttonView addSubview:completeButton];
        [completeButton makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_buttonView.right).with.offset(- [NSNumber kdDistance1]);
            make.top.equalTo(_buttonView.top);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(40);
        }];
        
        [_buttonView addSubview:cancelButton];
        [cancelButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_buttonView.left).with.offset([NSNumber kdDistance1]);
            make.top.equalTo(_buttonView.top);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(40);
        }];
        
    }

    return _buttonView;
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker)
    {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeTime;
        _datePicker.backgroundColor = [UIColor whiteColor];
        [_datePicker addTarget:self action:@selector(datePickerValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}


- (void)buttonClick:(UIButton *)sender
{
    if (sender.tag == completeButtonTag)//完成操作
    {
        self.completeSetup(self.currentDate);
    }
    else if (sender.tag == cancelButtonTag)
    {
        self.cancelSetup(self.currentDate);
    }
}

- (void)datePickerValueChange:(UIDatePicker *)sender
{
    self.currentDate = sender.date;
}


@end
