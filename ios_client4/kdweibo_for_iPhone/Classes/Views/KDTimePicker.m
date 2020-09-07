//
//  DatePickerView.h
//  NetworkEducation
//
//  Created by Joey Zeng on 12-2-3.
//  Copyright (c) 2012年 achievo. All rights reserved.
//

#import "KDTimePicker.h"

@interface KDTimePicker ()
@property(nonatomic, strong) UIDatePicker *datePicker;
@end


@implementation KDTimePicker
@synthesize datePicker = datePicker_;
@synthesize leftEventHandler = leftEventHander_;
@synthesize rightEventHandler = rightEventHandler_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        datePicker_ = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 216, CGRectGetWidth(frame), 216)];
        datePicker_.backgroundColor = [UIColor whiteColor];
        datePicker_.datePickerMode = UIDatePickerModeTime;
        [self addSubview:datePicker_];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 44)];
        toolbar.backgroundColor = FC6;
        [toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny                      barMetrics:UIBarMetricsDefault];
        toolbar.clipsToBounds = YES;
        
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        [leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC5, NSFontAttributeName : FS3} forState:UIControlStateNormal];
        [leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC7, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC5, NSFontAttributeName : FS3} forState:UIControlStateNormal];
        [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC7, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        toolbar.items = @[leftItem, flexibleSpaceItem, rightItem];
        [self addSubview:toolbar];
        
        UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, CGRectGetWidth(frame), 1)];
        separatorLine.backgroundColor = [UIColor kdDividingLineColor];
        [self addSubview:separatorLine];
        
    }
    
    return self;
}

- (void)cancel:(id)sender {
    if (leftEventHander_) {
        leftEventHander_();
    }
}

- (void)done:(id)sender {
    if (rightEventHandler_) {
        rightEventHandler_();
    }
}

- (NSDate *)date {
    return self.datePicker.date;
}

- (void)setDate:(NSDate *)date {
    self.datePicker.date = date;
}
@end
