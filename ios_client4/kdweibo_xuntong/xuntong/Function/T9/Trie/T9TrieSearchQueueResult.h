//
//  T9TrieSearchQueueResult.h
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface T9TrieSearchQueueResult : NSObject

@property (nonatomic,retain) NSMutableDictionary * datas;  //<NSNumber(int),NSNumber(int)>
@property (nonatomic,retain) NSMutableDictionary * result;//<T9TrieSearchQueueResultData,NSNumber(int)>
- (id)initWithBool:(BOOL)flag;

+ (T9TrieSearchQueueResult*)EMPTY_SEARCH_RESULT;

- (BOOL) isEmpty;
- (T9TrieSearchQueueResult*) interSet: (NSMutableDictionary *)data;
- (void) adjustResult:(T9TrieSearchQueueResult *) rs match:(NSArray*) match;

@end
