//
//  KDBubbleCellNewButton.h
//  kdweibo
//
//  Created by AlanWong on 14-7-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KDBubbleCellNewButton;
@class BubbleImageView;
@protocol KDBubbleCellNewButtonDelegate <NSObject>

- (void)forwardNew:(id)sender;
- (void)shareNewsToCommunity:(id)sender;
@end

@interface KDBubbleCellNewButton : UIButton
@property(nonatomic,weak)id<KDBubbleCellNewButtonDelegate> forwardDelegate;
@property(nonatomic,weak)id<BubbleImageViewDelegate> deleteDelegate;
@property(nonatomic,weak)BubbleImageView * bubbleImageView;
@property(nonatomic,weak)BubbleTableViewCell * cell;
@property(nonatomic,strong)RecordDataModel * record;

- (void)forwardNew:(id)sender;

- (void)deleteNews:(id)sender;

- (void)shareNewsToCommunity:(id)sender;

- (void)shareToOther:(id)sender;

@end
