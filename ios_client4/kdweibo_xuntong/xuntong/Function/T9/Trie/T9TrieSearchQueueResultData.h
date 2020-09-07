//
//  T9TrieSearchQueueResultData.h
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface T9TrieSearchQueueResultData : NSObject<NSCopying>

@property (nonatomic) int weight;
@property (nonatomic,retain) NSArray * match;
@property (nonatomic) int personId;

- (id)initWithPerson:(int)personId andWeight:(int)weight;

@end
