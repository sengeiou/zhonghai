//
//  KDFileInMessageTableViewCell.h
//  kdweibo
//
//  Created by janon on 15/3/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDFileInMessageTableViewCell;
@class KDFileInMessageDataModel;

@protocol KDFileInMessageTableViewCellDelegate <NSObject>
@optional
- (void)cell:(KDFileInMessageTableViewCell *)cell openOrDownloadFileWithModel:(KDFileInMessageDataModel *)model;

- (void)cell:(KDFileInMessageTableViewCell *)cell personNameButtonPressedWithModel:(KDFileInMessageDataModel *)model;
@end

@interface KDFileInMessageTableViewCell : KDTableViewCell
@property(nonatomic, weak) id <KDFileInMessageTableViewCellDelegate> delegate;
@property(nonatomic, strong) UIImageView *loadbuttonImageView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setCellInformation:(KDFileInMessageDataModel *)model IndexPath:(NSIndexPath *)indexPath;

@end
