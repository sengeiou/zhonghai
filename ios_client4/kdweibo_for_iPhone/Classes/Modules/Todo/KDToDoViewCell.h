//
//  KDToDoViewCell.h
//  kdweibo
//
//  Created by janon on 15/4/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDToDoViewController.h"

@class KDToDoMessageDataModel;
@class KDToDoViewCell;

@protocol KDToDoViewCellDelegate <NSObject>
@optional
- (void)bubbleDidDeleteMsgWithModel:(KDToDoMessageDataModel *)model cell:(KDToDoViewCell *)cell;
- (void)changeUndoMsgWithModel:(KDToDoMessageDataModel *)model cell:(KDToDoViewCell *)cell;
@end
@interface KDToDoViewCell : UITableViewCell
@property(nonatomic, weak) id <KDToDoViewCellDelegate> delegate;
@property (nonatomic,weak) KDToDoViewController *todoVC;
@property (nonatomic,assign) BOOL searchType;
@property (nonatomic,strong) NSString *searchKeyWord;

-(instancetype)initWithFrame:(CGRect)frame;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)anotherSetCellInformation:(KDToDoMessageDataModel *)model;
@end
