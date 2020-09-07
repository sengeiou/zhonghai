//
//  KDTopicGridView.h
//  kdweibo
//
//  Created by Tan Yingqi on 14-4-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDTopic.h"

#define TOPIC_GRID_CELL_HEIGHT   50.0f
@protocol KDTopicGridViewDelete <NSObject>

- (void)didSeletedGridAtIndex:(NSInteger) index;

@end

@interface KDTopicGridView : UIView

@property(nonatomic,retain)NSArray *topics;
@property(nonatomic,assign)id<KDTopicGridViewDelete> delegate;

+(NSInteger)numberOfRow:(NSInteger)topicsCout;


@end
