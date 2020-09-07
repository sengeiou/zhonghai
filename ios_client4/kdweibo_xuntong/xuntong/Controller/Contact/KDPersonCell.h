//
//  KDPersonCell.h
//  kdweibo
//
//  Created by Gil on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"
typedef void(^CellButtonClickBlock)(NSInteger index, NSString *value);

//基类，不直接使用，因为未做排版
@interface KDPersonCell : KDTableViewCell
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *contentLabel;
@property (nonatomic, strong) NSArray *hvlfs;
@end


@interface KDPersonContactCell : KDPersonCell
@property (strong , nonatomic) CellButtonClickBlock buttonClickBlock;
@property (strong , nonatomic) NSString *contactType;
@end

@interface KDPersonCompanyCell : KDPersonCell
@property (nonatomic, strong, readonly) UILabel *leaderLabel;
@end

@interface KDPersonOtherCell : KDPersonCell
@end

@interface KDPersonDynamicCell : KDPersonCell
@end

@interface KDPersonFoldCell : KDTableViewCell
@property (nonatomic, strong, readonly) UIImageView *foldImageView;

- (void)setTitle:(NSString *)title;
@end