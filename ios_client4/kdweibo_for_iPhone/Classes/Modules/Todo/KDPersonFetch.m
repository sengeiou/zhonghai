//
//  KDPersonFetchManager.m
//  kdweibo
//
//  Created by Gil on 15/3/27.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPersonFetch.h"
#import "KDPersonCache.h"
#import "XTOpenSystemClient.h"

@interface KDPersonFetch ()
@property (strong, nonatomic) KDPersonFetchCompletionBlock completionBlock;
@property (strong, nonatomic) XTOpenSystemClient *personInfoClient;
@end

@implementation KDPersonFetch

- (void)fetchWithPersonIds:(NSArray *)personIds
           completionBlock:(KDPersonFetchCompletionBlock)completionBlock {
    if ([personIds count] == 0) {
        if (completionBlock) {
            completionBlock(false, nil, NO);
        }
    }
    
    self.completionBlock = completionBlock;
    [self personInfoWithPersonIds:personIds];
}
+ (instancetype)sharedPersonFetcher {
    static dispatch_once_t pred;
    static KDPersonFetch *instance = nil;
    
    dispatch_once(&pred, ^{
        instance = [[KDPersonFetch alloc] init];
    });
    return instance;
}

+ (void)fetchWithPersonIds:(NSArray *)personIds
           completionBlock:(KDPersonFetchCompletionBlock)completionBlock {
    [[[self class] sharedPersonFetcher] fetchWithPersonIds:personIds completionBlock:completionBlock];
}
#pragma mark - person info -

- (XTOpenSystemClient *)personInfoClient {
	if (_personInfoClient == nil) {
		_personInfoClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(personInfoDidReceived:result:)];
	}
	return _personInfoClient;
}

- (void)personInfoWithPersonIds:(NSArray *)personIds {
//	NSString *ids = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:personIds options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
	[self.personInfoClient getPersonsCasvirByIds:personIds];
}

- (void)personInfoDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result {
	if (result.success && [result.data isKindOfClass:[NSArray class]] && [(NSArray *)result.data count] > 0) {
		NSArray *datas = (NSArray *)result.data;
		__block NSMutableArray *persons = [NSMutableArray array];
		[datas enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
//		    PersonDataModel *person = [[PersonDataModel alloc] initWithOpenDictionary:obj];
            PersonSimpleDataModel *person =[[PersonSimpleDataModel alloc] initWithDictionary:obj] ;
		    [persons addObject:person];
		    [[KDPersonCache sharedPersonCache] removePersonForKey:person.personId];
            //更新数据库
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:person];
//          [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonContacts:person];
		}];
		
		if (self.completionBlock) {
			self.completionBlock(true, persons,NO);
		}
		return;
	}
	if (self.completionBlock) {
		self.completionBlock(false, nil,NO);
	}
}

@end
