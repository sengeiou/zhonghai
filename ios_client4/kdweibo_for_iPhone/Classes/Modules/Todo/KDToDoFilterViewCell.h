//
//  KDToDoFilterViewCell.h
//  kdweibo
//
//  Created by janon on 15/4/5.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDToDoMessageDataModel.h"

@class KDToDoFilterViewCell;
@class KDPublicAccountDataModel;

@protocol KDToDoFilterViewCellDelegate <NSObject>
//-(void)clickedWithCell:(KDToDoFilterViewCell *)cell Model:(PersonSimpleDataModel *)mode status:(BOOL)status;
-(void)clickedWithCell:(KDToDoFilterViewCell *)cell;
@end

@interface KDToDoFilterViewCell : UICollectionViewCell

@property (nonatomic, weak) id<KDToDoFilterViewCellDelegate> delegate;

-(void)setCellInformation:(KDPublicAccountDataModel *)model checkWithArray:(NSMutableArray *)array;
-(void)setAtInformation:(KDPublicAccountDataModel *)model checkWithArray:(NSMutableArray *)array;
-(void)setUndoInformation:(KDPublicAccountDataModel *)model checkWithArray:(NSMutableArray *)array;
@end
