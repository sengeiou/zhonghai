//
//  T9.h
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

enum T9SearchTextType {
    T9SearchTextChinese,
    T9SearchTextNumber,
    T9SearchTextPinyinNumber,
    T9SearchTextOther
};

typedef enum T9SearchTextType T9SearchTextType;

@interface T9 : NSObject

@property(nonatomic)int personTotalCount;

+ (T9 *)sharedInstance;
- (NSArray *)search:(NSString *)word;
- (void)reloadData;
- (void)firstInitial:(void (^)(BOOL isInitial))isInitialingBlock
                        initFinished:(void (^)(void))initFinishedBlock;

//for test case
- (void)initTrieWithUsers:(NSArray*)users;

+ (T9SearchTextType)calcSearchType:(NSString*)word;

@end
