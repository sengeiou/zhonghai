//
//  KDDistancePicker.m
//  kdweibo
//
//  Created by lichao_liu on 7/17/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDDistancePicker.h"

@interface KDDistancePicker()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation KDDistancePicker

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dataArray = @[@50,@100,@200,@300,@500];
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 216, CGRectGetWidth(frame), 216)];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        self.pickerView.backgroundColor = [UIColor whiteColor];
         [self addSubview:self.pickerView];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 44)];
        toolbar.backgroundColor = FC6;
        [toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny                      barMetrics:UIBarMetricsDefault];
        toolbar.clipsToBounds = YES;
        
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        [leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC5, NSFontAttributeName : FS3} forState:UIControlStateNormal];
        [leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC7, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        
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
    if (self.leftEventHandler) {
        self.leftEventHandler(0);
    }
}

- (void)done:(id)sender {
    __weak KDDistancePicker *weakSelf = self;
    if (self.rightEventHandler) {
        self.rightEventHandler([weakSelf distance]);
    }
}

-(NSInteger)distance
{
    NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
    return [self.dataArray[selectedRow] integerValue];
}

- (void)setDistance:(NSInteger)distance
{
    if ([self.dataArray containsObject:@(distance)]) {
        NSInteger selectedRow = [self.dataArray indexOfObject:@(distance)];
        [self.pickerView selectRow:selectedRow inComponent:0 animated:YES];
    }
}

#pragma mark - delegate & datasource
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.dataArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
    {
        return [NSString stringWithFormat:ASLocalizedString(@"%ld米"),(long)[self.dataArray[row] integerValue]];
    }
    return nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

@end
