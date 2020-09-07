//
//  KDAddingGridView.m
//  kdweibo
//
//  Created by Tan yingqi on 12-12-4.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDAddingGridView.h"

@implementation KDAddingGridView
@synthesize addBtn = addBtn_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [aBtn setImage :[UIImage imageNamed:@"dm_add_participant_btn.png"] forState:UIControlStateNormal];
        [aBtn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
       // aBtn.frame = CGRectMake(0, 0, 47, 47);
        [aBtn sizeToFit];
        [self addSubview:aBtn];
        self.addBtn = aBtn;
        
    }
    return self;
}

- (void)btnTapped:(id)sender {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDGridCellAddingViewTouched object:self userInfo:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
     self.addBtn.frame = CGRectOffset(self.addBtn.bounds, 6, 14);

}

- (void)dealloc {
    //KD_RELEASE_SAFELY(addBtn_);
    //[super dealloc];
}
@end
