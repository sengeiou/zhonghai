//
//  KDUserPickableCell.h
//  kdweibo
//
//  Created by laijiandong on 12-11-2.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDNetworkUserBaseCell.h"

@class KDUserPickableCell;

@protocol KDUserPickableCellDelegate <NSObject>

- (void)didTapUserCell:(KDUserPickableCell *)cell;

@end

@interface KDUserPickableCell : KDNetworkUserBaseCell

@property(nonatomic, assign) BOOL picked;

@property(nonatomic, assign) id<KDUserPickableCellDelegate> delegate;

@end
