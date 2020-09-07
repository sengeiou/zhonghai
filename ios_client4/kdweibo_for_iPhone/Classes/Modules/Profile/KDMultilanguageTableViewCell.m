//
//  KDMultilanguageTableViewCell.m
//  kdweibo
//
//  Created by wenjie_lee on 16/3/30.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDMultilanguageTableViewCell.h"

@implementation KDMultilanguageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.separatorLineInset = UIEdgeInsetsMake(0, 12, 0, 0);
        
        [self.contentView addSubview:self.label];
        [self.label makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.contentView.mas_top).with.offset(5);
            make.left.equalTo(self.contentView.mas_left).with.offset(12);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(5);
            make.width.mas_equalTo(100);
        }];
        [self.contentView addSubview:self.accessoryImageView];
        [self.accessoryImageView makeConstraints:^(MASConstraintMaker *make){
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.right.equalTo(self.contentView.mas_right).with.offset(-20);
            make.width.mas_equalTo(30);
            make.height.mas_equalTo(20);
        }];
    
    }
    return self;
}

- (UILabel *)label
{
    if(!_label)
    {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.font = FS3;
        _label.textColor = FC1;
        _label.backgroundColor = [UIColor clearColor];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _label;
}
-(UIImageView *)accessoryImageView
{
    if(!_accessoryImageView)
    {
        _accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _accessoryImageView.image = [UIImage imageNamed:@"common_tip_check"];
        _accessoryImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _accessoryImageView;
}


@end
