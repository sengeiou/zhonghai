//
//  KDFileShareBanner.m
//  kdweibo
//
//  Created by lichao_liu on 10/28/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import "KDFileShareBanner.h"
@interface KDFileShareBanner()
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, copy) KDFileShareBannerBlock block;

@end

@implementation KDFileShareBanner

- (instancetype)initWithFrame:(CGRect)frame Block:(KDFileShareBannerBlock)block title:(NSString *)title
{
    if(self = [super initWithFrame:frame])
    {
        self.block = block;
        
         self.icon = [[UIImageView alloc] init];
        self.icon.image = [UIImage imageNamed:@"phone_tip_share"];
        [self addSubview:self.icon];
        
        
        self.arrowImageView = [[UIImageView alloc] init];
        self.arrowImageView.image = [UIImage imageNamed:@"cell_arrow"];
        [self addSubview:self.arrowImageView];
       
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = FS5;
        self.titleLabel.textColor = FC1;
        self.titleLabel.text = title;
        [self addSubview:self.titleLabel];
        
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenBannerClicked:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)makeMasory
{
    [self.icon makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.mas_equalTo(self.left).with.offset(12);
         make.centerY.equalTo(self.centerY);
         make.height.mas_equalTo(20);
         make.width.mas_equalTo(20);
     }];
 
    [self.arrowImageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(7);
        make.height.mas_equalTo(13);
        make.right.equalTo(self.right).offset(-12);
        make.centerY.equalTo(self.centerY);
    }];
    
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.right).with.offset(8);
        make.centerY.equalTo(self.icon.centerY);
        make.right.equalTo(self.arrowImageView.left).offset(8);
    }];
}

- (void)whenBannerClicked:(id)sender
{
    if(self.block)
    {
        self.block();
    }
}
@end
