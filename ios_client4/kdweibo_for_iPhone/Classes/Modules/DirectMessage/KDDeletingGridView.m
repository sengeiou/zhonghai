//
//  KDDeletingGridView.m
//  kdweibo
//
//  Created by Tan Yingqi on 14-2-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDDeletingGridView.h"

@implementation KDDeletingGridView

@synthesize delBtn = delBtn_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [aBtn setImage :[UIImage imageNamed:@"dm_delete_participant_btn.png"] forState:UIControlStateNormal];
        [aBtn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
        // aBtn.frame = CGRectMake(0, 0, 47, 47);
        [aBtn sizeToFit];
        [self addSubview:aBtn];
        self.delBtn = aBtn;
        
    }
    return self;
}

- (void)btnTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:KDGridCellDeltingViewTouched object:self userInfo:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.delBtn.frame = CGRectOffset(self.delBtn.bounds, 6, 14);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(delBtn_);
    //[super dealloc];
}
@end
