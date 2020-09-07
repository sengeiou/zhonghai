//
//  KDChangeTeamTableViewCell.m
//  kdweibo
//
//  Created by kingdee on 16/7/11.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDChangeTeamTableViewCell.h"

#define teamHeadViewH 44.0

@interface KDChangeTeamTableViewCell()

@property (nonatomic, strong)UIImageView *accessoryImageView;
@end

@implementation KDChangeTeamTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.separatorLineInset = UIEdgeInsetsMake(0, 64.0, 0, 0);
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryView = self.accessoryImageView;
        self.accessoryView.hidden = YES;
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews {
    
    [self.contentView addSubview:self.teamHeadView];
    [self.contentView addSubview:self.teamNameLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offset = 10.0f;
    self.teamHeadView.frame = CGRectMake(offset, offset, teamHeadViewH, teamHeadViewH);
    
    self.teamNameLabel.frame = CGRectMake(CGRectGetMaxX(self.teamHeadView.frame) + offset, 22, 200, 20);
    
}

+ (NSString *)reuseIdentifier{
    static NSString *reuseIdentifier = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reuseIdentifier = NSStringFromClass([self class]);
    });
    return reuseIdentifier;
}


+ (CGFloat)rowHeight{
    return 64.0;
}

#pragma mark - Lazy Loading

- (UIImageView *)teamHeadView {
    if (!_teamHeadView) {
        _teamHeadView = [[UIImageView alloc] init];
        _teamHeadView.image  = [UIImage imageNamed:@"common_team_account"];
        _teamHeadView.layer.cornerRadius = teamHeadViewH/2;
        _teamHeadView.layer.masksToBounds = YES;
        
    }
    return _teamHeadView;
}

- (UILabel *)teamNameLabel {
    if (!_teamNameLabel) {
        _teamNameLabel = [[UILabel alloc] init];
    }
    return _teamNameLabel;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_tip_check"]];
    }
    return _accessoryImageView;
}

@end
