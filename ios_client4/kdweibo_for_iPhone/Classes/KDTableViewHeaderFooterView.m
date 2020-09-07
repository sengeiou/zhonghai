//
//  KDTableViewHeaderFooterView.m
//  kdweibo
//
//  Created by Gil on 2016/10/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewHeaderFooterView.h"

@interface KDTableViewHeaderFooterView ()
@property (strong, nonatomic) UIView *titleBackgroundView;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation KDTableViewHeaderFooterView

- (instancetype)initWithStyle:(KDTableViewHeaderFooterViewStyle)style {
    self = [super initWithReuseIdentifier:[NSString stringWithFormat:@"KDTableViewHeaderFooterViewStyle-%lu",(unsigned long)style]];
    if (self) {
        
        switch (style) {
            case KDTableViewHeaderFooterViewStyleGray:
            case KDTableViewHeaderFooterViewStyleWhite:
            {
                self.contentView.backgroundColor = (style == KDTableViewHeaderFooterViewStyleGray) ? [UIColor kdBackgroundColor6] : [UIColor kdBackgroundColor2];
                
                [self.contentView addSubview:self.titleLabel];

                self.titleLabel.backgroundColor = self.contentView.backgroundColor;
                self.titleLabel.font = FS7;
                self.titleLabel.textColor = (style == KDTableViewHeaderFooterViewStyleGray) ? FC1 : FC2;
                [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.contentView.left).with.offset([NSNumber kdDistance1]);
                    make.centerY.equalTo(self.contentView.centerY);
                }];
            }
                break;
            case KDTableViewHeaderFooterViewStyleGrayWhite:
            {
                self.contentView.backgroundColor = [UIColor kdBackgroundColor1];
                
                [self.contentView addSubview:self.titleBackgroundView];
                
                self.titleBackgroundView.backgroundColor = [UIColor kdBackgroundColor2];
                [self.titleBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.contentView.left).with.offset(0);
                    make.right.equalTo(self.contentView.right).with.offset(0);
                    make.top.equalTo(self.contentView.top).with.offset([NSNumber kdDistance2]);
                    make.bottom.equalTo(self.contentView.bottom).with.offset(0);
                }];
                
                [self.titleBackgroundView addSubview:self.titleLabel];
                
                self.titleLabel.backgroundColor = self.titleBackgroundView.backgroundColor;
                self.titleLabel.font = FS7;
                self.titleLabel.textColor = FC2;
                [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.titleBackgroundView.left).with.offset([NSNumber kdDistance1]);
                    make.centerY.equalTo(self.titleBackgroundView.centerY);
                }];
            }
                break;
            default:
                break;
        }
    }
    return self;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _titleLabel;
}

- (UIView *)titleBackgroundView {
    if (_titleBackgroundView == nil) {
        _titleBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _titleBackgroundView;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _titleLabel.text = nil;
}

+ (CGFloat)heightWithStyle:(KDTableViewHeaderFooterViewStyle)style {
    switch (style) {
        case KDTableViewHeaderFooterViewStyleGray:
        case KDTableViewHeaderFooterViewStyleWhite:
            return 22;
        case KDTableViewHeaderFooterViewStyleGrayWhite:
            return 30 + [NSNumber kdDistance2];
        default:
            break;
    }
}

@end
