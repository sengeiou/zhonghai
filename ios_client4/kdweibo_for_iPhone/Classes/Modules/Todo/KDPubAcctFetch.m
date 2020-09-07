//
//  KDPubAcctFetchManager.m
//  kdweibo
//
//  Created by Gil on 14-10-15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDPubAcctFetch.h"
#import "AppsClient.h"
#import "KDPublicAccountDataModel.h"
#import "KDPublicAccountCache.h"

@interface KDPubAcctFetch ()
@property (nonatomic, strong) KDPubAcctFetchCompletionBlock completionBlock;
@property (nonatomic, strong) AppsClient *client;
@property (nonatomic, assign) BOOL isFetchAll;
@end

@implementation KDPubAcctFetch

- (void)fetchWithPubAcctIds:(NSArray *)pubAcctIds
            completionBlock:(KDPubAcctFetchCompletionBlock)completionBlock {
	if ([pubAcctIds count] == 0) {
		if (completionBlock) {
			completionBlock(false, nil);
		}
	}

	self.completionBlock = completionBlock;
	[self getPubAcctsWithIds:pubAcctIds];
}

- (void)fetchAllPubAcctsCompletionBlock:(KDPubAcctFetchCompletionBlock)completionBlock {
	self.completionBlock = completionBlock;
	[self getAllPubAccts];
}

- (void)getPubAcctsWithIds:(NSArray *)pubAcctIds {
	self.isFetchAll = false;
	[self.client getPublicListWithPublicIds:pubAcctIds];
}

- (void)getAllPubAccts {
	self.isFetchAll = true;
	[self.client getPublicList];
}

- (AppsClient *)client {
	if (_client == nil) {
		_client = [[AppsClient alloc] initWithTarget:self action:@selector(getPublicListDidReceived:result:)];
	}
	return _client;
}

- (void)getPublicListDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result {
	if (result && [result isKindOfClass:[BOSResultDataModel class]] && result.success && result.data) {
		id list = nil;
		if (self.isFetchAll) {
			list = result.data;
		}
		else {
			list = result.data[@"list"];
		}

		if (list && [list isKindOfClass:[NSArray class]] && [(NSArray *)list count] > 0) {
			NSMutableArray *pubAccts = [NSMutableArray array];

			for (id each in list) {
				KDPublicAccountDataModel *pubacc = [[KDPublicAccountDataModel alloc] initWithDictionary:each];
				//如果存在中文，则先编码
				if ([KDCommon hasChinese:pubacc.photoUrl]) {
					pubacc.photoUrl = [pubacc.photoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				}
				[pubAccts addObject:pubacc];
                
                [[KDPublicAccountCache sharedPublicAccountCache] removePubAcctForKey:pubacc.personId];
			}

			if (self.isFetchAll) {
				[[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllPublicAccounts];
			}
			[[XTDataBaseDao sharedDatabaseDaoInstance] insertPublicAccounts:pubAccts];

            if (self.completionBlock) {
                self.completionBlock(true, pubAccts);
            }
			
			return;
		}
	}

    if (self.completionBlock) {
        self.completionBlock(false, nil);
    }
}

@end
