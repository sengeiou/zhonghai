//
//  KDV8Cells.m
//  DZFoundation
//
//  Created by Darren Zheng on 16/9/6.
//  Copyright © 2016年 Darren Zheng. All rights reserved.
//

#import "KDV8Cell.h"

@implementation KDEmptyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _kd_contentView = [KDV8CellContentView new];
        [_kd_contentView install:self.contentView style:KDListStyleEmpty];
    }
    return self;
}

@end


@interface KDLS1Cell ()
@property (nonatomic, strong) XTUnreadImageView *unreadImageView; // 未读数
@end

@implementation KDLS1Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _kd_contentView = [KDV8CellContentView new];
        [_kd_contentView install:self.contentView style:KDListStyleLs1];
    }
    return self;
}
@end

@implementation KDLS2Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _kd_contentView = [KDV8CellContentView new];
        [_kd_contentView install:self.contentView style:KDListStyleLs2];
    }
    return self;
}

@end

@implementation KDLS3Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _kd_contentView = [KDV8CellContentView new];
        [_kd_contentView install:self.contentView style:KDListStyleLs3];
    }
    return self;
}

@end

@implementation KDLS4Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _kd_contentView = [KDV8CellContentView new];
        [_kd_contentView install:self.contentView style:KDListStyleLs4];
    }
    return self;
}

@end

@implementation KDLS5Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _kd_contentView = [KDV8CellContentView new];
        [_kd_contentView install:self.contentView style:KDListStyleLs5];
    }
    return self;
}

@end

@implementation KDLS6Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _kd_contentView = [KDV8CellContentView new];
        [_kd_contentView install:self.contentView style:KDListStyleLs6];
    }
    return self;
}

@end

@implementation KDLS7Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _kd_contentView = [KDV8CellContentView new];
        [_kd_contentView install:self.contentView style:KDListStyleLs7];
    }
    return self;
}

@end

@implementation KDLS8Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _kd_contentView = [KDV8CellContentView new];
        [_kd_contentView install:self.contentView style:KDListStyleLs8];
    }
    return self;
}

@end
