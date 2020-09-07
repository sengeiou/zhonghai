//
//  KDAppCollectionViewCell.h
//  kdweibo
//
//  Created by Joyingx on 16/9/8.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDAppCollectionViewCell;

@protocol KDAppCollectionViewCellDelegate <NSObject>

- (void)collectionViewCellDeleteButtonDidPressed:(KDAppCollectionViewCell *)cell;

@end

@interface KDAppCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *logoImageView;
@property (nonatomic, strong, readonly) UIView *redDot;
@property (nonatomic, strong, readonly) UILabel *nameLabel;

@property (nonatomic, assign) BOOL isDeleteStatus;
@property (nonatomic, assign) BOOL isUndeleteable;

@property (nonatomic, weak) id<KDAppCollectionViewCellDelegate> delegate;

+ (CGSize)size;

@end
