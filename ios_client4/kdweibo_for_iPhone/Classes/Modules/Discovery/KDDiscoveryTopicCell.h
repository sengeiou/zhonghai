//
//  KDDiscoveryTopicCell.h
//  kdweibo
//
//  Created by weihao_xu on 14-4-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KDTopicSelectedIndex) {
    KDTopicSelectedIndexMainTopic = 0,
    KDTopicSelectedIndexFirst,
    KDTopicSelectedIndexSecond,
    KDTopicSelectedIndexThird,
    KDTopicSelectedIndexForth
};
@protocol KDDiscoveryTopicCellDelegate;

@interface KDDiscoveryTopicCell : UITableViewCell
@property (nonatomic, retain) UIImageView *avatarImageView;
@property (nonatomic, retain) UILabel *discoveryLabel;
@property (nonatomic, retain) UIImageView *accessoryImageView;
@property (nonatomic, assign) id<KDDiscoveryTopicCellDelegate> delegate;

- (void)setTopicsItemsWithTopicArray : (NSArray *)topicArray;
@end

@protocol KDDiscoveryTopicCellDelegate <NSObject>
@optional
- (void)kdDiscoveryDidSelectedItemAtIndexPath : (KDTopicSelectedIndex)index;
@end