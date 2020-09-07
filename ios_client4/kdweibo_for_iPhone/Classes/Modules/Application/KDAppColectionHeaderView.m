//
//  KDAppColectionHeaderView.m
//  kdweibo
//
//  Created by Joyingx on 2016/10/18.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDAppColectionHeaderView.h"

@implementation KDAppColectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpViews];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpViews];
    }
    
    return self;
}

- (void)setUpViews {
    self.backgroundColor = [UIColor kdBackgroundColor1];
    
    [self addSubview:self.label];
    
    [self.label makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).with.offset(12);
        make.right.equalTo(self).with.offset(-12);
        make.height.equalTo(self);
    }];
}

#pragma mark - Setters and Getters

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = FS7;
        _label.textColor = FC2;
    }
    
    return _label;
}

@end
