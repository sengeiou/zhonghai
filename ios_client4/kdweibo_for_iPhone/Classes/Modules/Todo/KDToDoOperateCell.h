//
//  KDToDoOperateCell.h
//  kdweibo
//
//  Created by 陈彦安 on 15/4/8.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDToDoMessageDataModel;
@class KDToDoOperateCell;

@protocol KDToDoOperateCellDelegate <NSObject>
- (void)leftButtonWithcell:(KDToDoOperateCell *)cell Dic:(NSDictionary *)dic Model:(KDToDoMessageDataModel *)model;
- (void)middleButtonWithcell:(KDToDoOperateCell *)cell Dic:(NSDictionary *)dic Model:(KDToDoMessageDataModel *)model;
- (void)rightButtonWithcell:(KDToDoOperateCell *)cell Dic:(NSDictionary *)dic Model:(KDToDoMessageDataModel *)model;
@end

@interface KDToDoOperateCell : UITableViewCell
@property (nonatomic, weak) id<KDToDoOperateCellDelegate> delegate;
-(instancetype)initWithFrame:(CGRect)frame;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)anotherSetCellInformation:(KDToDoMessageDataModel *)model;
@end
