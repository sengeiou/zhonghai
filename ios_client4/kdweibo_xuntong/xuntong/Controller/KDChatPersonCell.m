//
//  KDChatPersonCell.m
//  kdweibo
//
//  Created by lichao_liu on 7/22/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDChatPersonCell.h"
#import "BOSConfig.h"


@interface KDChatPersonCell()
@property (nonatomic, strong) UIImageView *deleteImageView;
@property (nonatomic, strong) UIImageView *isExternalImageView;
@end
@implementation KDChatPersonCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(54, 1, 15, 15)];
        self.deleteImageView.image = [UIImage imageNamed:@"badge_tip_delete"];
        [self addSubview:self.deleteImageView];
        
        self.isExternalImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.isExternalImageView];
        
        
        self.deleteImageView.hidden = YES;
    }
    return self;
}

- (void)setIsShowDelete:(BOOL)isShowDelete
{
    _isShowDelete = isShowDelete;
    self.deleteImageView.hidden = !isShowDelete;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.isExternalImageView.frame = CGRectMake(10, 71, 12, 12);
    self.isExternalImageView.image = [UIImage imageNamed:@"message_tip_shang_small"];
    self.isExternalImageView.hidden = YES;
    
    self.appNameLabel.textAlignment = NSTextAlignmentCenter;
    if (self.shouldSignExternalPerson)
    {
        CGSize size = CGSizeMake(40, 30);
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:FS7,NSFontAttributeName, nil];
        CGSize actualSize = [self.data.personName boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
        
        self.isExternalImageView.frame = CGRectMake((75- 3- CGRectGetWidth(self.isExternalImageView.frame) - actualSize.width)/2, 71, 12, 12);
        
        self.appNameLabel.textAlignment = NSTextAlignmentLeft;
        self.appNameLabel.frame = CGRectMake(CGRectGetMaxX(self.isExternalImageView.frame) + 3, 70,actualSize.width,actualSize.height);
        self.appNameLabel.backgroundColor = [UIColor clearColor];
        self.isExternalImageView.hidden = NO;
    }
}



@end
