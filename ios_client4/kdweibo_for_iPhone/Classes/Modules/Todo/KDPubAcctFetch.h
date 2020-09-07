//
//  KDPubAcctFetchManager.h
//  kdweibo
//
//  Created by Gil on 14-10-15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KDPubAcctFetchCompletionBlock) (BOOL success, NSArray *pubAccts);

@interface KDPubAcctFetch : NSObject

//批量获取公共号信息，返回KDPublicAccountDataModel数组
- (void)fetchWithPubAcctIds:(NSArray *)pubAcctIds
           completionBlock:(KDPubAcctFetchCompletionBlock)completionBlock;

//获取当前企业所有公共号信息
- (void)fetchAllPubAcctsCompletionBlock:(KDPubAcctFetchCompletionBlock)completionBlock;

@end
