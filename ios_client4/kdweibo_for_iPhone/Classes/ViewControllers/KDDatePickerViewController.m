//
//  KDDatePickerViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 13-7-22.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDDatePickerViewController.h"

@interface KDDatePickerViewController () {
    NSDate *date_;
    
    UIView *contentView_;
}
@property(nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation KDDatePickerViewController
@synthesize datePicker = datePicker_;
@synthesize leftbtnTappedEventHander = leftbtnTappedEventHander_;
@synthesize rightTappedEventHander = rightTappedEventHander_;
@synthesize datePickerMode = datePickerMode_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        datePickerMode_ = UIDatePickerModeDateAndTime;
    }
    return self;
}


- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    contentView_ = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:contentView_];
    [contentView_ setBackgroundColor:[UIColor clearColor]];
    
    datePicker_ = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 216, CGRectGetWidth(self.view.frame), 216)];
    datePicker_.backgroundColor = [UIColor whiteColor];
    if (!date_) {
        datePicker_.date = [NSDate date];
    } else {
        datePicker_.date = date_;
    }
    datePicker_.datePickerMode = datePickerMode_;
    datePicker_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [contentView_ addSubview:datePicker_];
    
    
    UIImage *image = [UIImage imageNamed:@"date_picker_btn_bg"];
    image = [image stretchableImageWithLeftCapWidth:image.size.width topCapHeight:0];
    
    UIButton *cancleBtn = [UIButton whiteBtnWithTitle:ASLocalizedString(@"Global_Cancel")];
    cancleBtn.layer.borderWidth = 0;
    cancleBtn.layer.cornerRadius = 0;
    cancleBtn.frame = CGRectMake(0, CGRectGetMinY(datePicker_.frame) - 44, CGRectGetWidth(self.view.frame) * 0.5, 44);
    cancleBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [cancleBtn addTarget:self action:@selector(cancleBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cancleBtn.frame)-1, (CGRectGetHeight(cancleBtn.frame) - 14)/2.0, 0.5, 14)];
    rightView.backgroundColor = [UIColor kdDividingLineColor];
    [cancleBtn addSubview:rightView];
    UIView *bottomView1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(cancleBtn.frame)-1, CGRectGetWidth(cancleBtn.frame), 0.5)];
    bottomView1.backgroundColor = [UIColor kdDividingLineColor];
    [cancleBtn addSubview:bottomView1];
    [contentView_ addSubview:cancleBtn];
    
    UIButton *confirmBtn = [UIButton whiteBtnWithTitle:ASLocalizedString(@"Global_Sure")];
    confirmBtn.layer.borderWidth = 0;
    confirmBtn.layer.cornerRadius = 0;
    confirmBtn.frame = CGRectMake(CGRectGetMaxX(cancleBtn.frame), CGRectGetMinY(cancleBtn.frame), CGRectGetWidth(cancleBtn.frame), CGRectGetHeight(cancleBtn.frame));
    confirmBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [confirmBtn addTarget:self action:@selector(confirmBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIView *bottomView2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(confirmBtn.frame)-1, CGRectGetWidth(confirmBtn.frame), 0.5)];
    bottomView2.backgroundColor = [UIColor kdDividingLineColor];
    [confirmBtn addSubview:bottomView2];
    [contentView_ addSubview:confirmBtn];
    
    //    UIImageView *separatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"date_picker_separator_bg"]];
    //    [separatorView sizeToFit];
    //    CGRect frame = separatorView.frame;
    //    frame.size.height = 60;
    //    frame.origin.x = CGRectGetMidX(datePicker_.frame);
    //    frame.origin.y = CGRectGetMinY(cancleBtn.frame);
    //    separatorView.frame = frame;
    //    [contentView_ addSubview:separatorView];
    
    CGRect frame = contentView_.frame;
    frame.origin.y += CGRectGetHeight(datePicker_.frame) + 60.f;
    contentView_.frame = frame;
    
    
}

- (void)confirmBtnTapped:(id)sender {
    if (rightTappedEventHander_) {
        rightTappedEventHander_();
    }
}

- (void)cancleBtnTapped:(id)sender {
    if (leftbtnTappedEventHander_) {
        leftbtnTappedEventHander_();
    }
}

- (NSDate *)date {
    return datePicker_.date;
}

- (void)setDate:(NSDate *)date {
    if (date != date_) {
        date_ = date;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showInView:(UIView *)view {
    [view addSubview:self.view];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        CGRect frame = contentView_.frame;
        frame.origin.y -= CGRectGetHeight(datePicker_.frame) + 60.f;
        contentView_.frame = frame;
        
        self.view.backgroundColor = [UIColor kdPopupBackgroundColor];
        
    }                completion:^(BOOL finished) {
        
    }];
    
}

- (void)hide {
    [UIView animateWithDuration:0.25f animations:^{
        
        CGRect frame = contentView_.frame;
        frame.origin.y += CGRectGetHeight(datePicker_.frame) + 60.f;
        contentView_.frame = frame;
        
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
        
    }                completion:^(BOOL finished) {
        
        [self.view removeFromSuperview];
    }];
}
@end
