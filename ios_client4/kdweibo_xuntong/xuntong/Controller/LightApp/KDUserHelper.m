//
//  KDUserHelper.m
//  kdweibo
//
//  Created by Gil on 14-7-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDUserHelper.h"
#import "XTOpenSystemClient.h"
#import "BOSConfig.h"
#import "XTDataBaseDao.h"
#import "ContactClient.h"
#import "KDServiceActionInvoker.h"

@interface KDUserHelper ()

@property (strong, nonatomic) XTOpenSystemClient *openSystemClient;
@property (strong, nonatomic) ContactClient *getCloudPassportClient;
@property (strong, nonatomic) ContactClient *getRelatedPersonClient;
@property (strong, nonatomic) ContactClient *getGroupUserClient;
@property (strong, nonatomic) ContactClient *personInfoClient;

@property (strong, nonatomic) KDUserHelperCompletionBlock completionBlock;
@property (strong, nonatomic) KDUserHelperCloudCompletionBlock cloudCompletionBlock;
@property (strong, nonatomic) KDUserHelperRelatedPersonCompletionBlock relatePersonCompletionBlock;
@property (assign, nonatomic) BOOL batch;

@end

@implementation KDUserHelper

- (void)exchangePersonWithOid:(NSString *)oid
                   completion:(KDUserHelperCompletionBlock)completionBlock
{
    self.batch = NO;
    
    [self getPersonsWithOids:oid completion:completionBlock];
}

- (void)getPersonInfoWithPersonId:(NSString *)personId
                       completion:(KDUserHelperCompletionBlock)completionBlock
{
    if (personId.length == 0) {
        completionBlock(NO, nil, ASLocalizedString(@"参数错误"));
        return;
    }
    
    self.completionBlock = completionBlock;
    [self.personInfoClient getPersonInfoWithPersonID:personId type:nil];
}
- (void)exchangePersonsWithOids:(NSString *)oids
                     completion:(KDUserHelperCompletionBlock)completionBlock
{
    self.batch = YES;
    
    [self getPersonsWithOids:oids completion:completionBlock];
}

- (void)getPersonsWithOids:(NSString *)oids
                     completion:(KDUserHelperCompletionBlock)completionBlock
{
    if (oids.length == 0) {
		completionBlock(NO, nil, ASLocalizedString(@"参数错误"));
        return;
    }
    
    self.completionBlock = completionBlock;
    [self.openSystemClient getPersonsByOids:[self fetchOids:oids batch:self.batch] token:[BOSConfig sharedConfig].user.token];
}

- (NSString *)fetchOids:(NSString *)oids batch:(BOOL)batch
{
    if (batch) {
        return oids;
    }
    
    //如果不是批量，则只取第一个
    NSRange range = [oids rangeOfString:@","];
    if (range.location != NSNotFound) {
        return [oids substringToIndex:range.location];
    }
    return oids;
}

- (void)getRelatePersonWithScore:(NSString *)score
                      completion:(KDUserHelperRelatedPersonCompletionBlock)completionBlock
{
//    if (score.length == 0) {
//        completionBlock(NO, nil, ASLocalizedString(@"参数错误"));
//        return;
//    }
    
    self.relatePersonCompletionBlock = completionBlock;
    [self.getRelatedPersonClient getRelatePersonsWithLastPersonScore:score];
}
//获取新增相关人员信息
- (void)getGroupUsersWithGroupId:(NSString *)groupId
                           Score:(NSString*)score
                      completion:(KDUserHelperRelatedPersonCompletionBlock)completionBlock
{
    self.relatePersonCompletionBlock = completionBlock;
    [self.getGroupUserClient getGroupUsersWithGroupId:groupId LastPersonScore:score];
}

#pragma mark - get

- (XTOpenSystemClient *)openSystemClient
{
    if (_openSystemClient == nil) {
        _openSystemClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getPersonDidRecieve:result:)];
    }
    return _openSystemClient;
}
- (ContactClient *)personInfoClient
{
    if (_personInfoClient == nil) {
        _personInfoClient = [[ContactClient alloc] initWithTarget:self action:@selector(personInfoDidReceived:result:)];
    }
    return _personInfoClient;
}
- (ContactClient *)getCloudPassportClient
{
    if (_getCloudPassportClient == nil) {
        _getCloudPassportClient = [[ContactClient alloc] initWithTarget:self action:@selector(getCloudPassportDidReceived:result:)];
    }
    return _getCloudPassportClient;
}
- (ContactClient *)getRelatedPersonClient
{
    if (_getRelatedPersonClient == nil) {
        _getRelatedPersonClient = [[ContactClient alloc] initWithTarget:self action:@selector(getRelatedPersonDidReceived:result:)];
    }
    return _getRelatedPersonClient;
}

- (ContactClient *)getGroupUserClient
{
    if (_getGroupUserClient == nil) {
        _getGroupUserClient = [[ContactClient alloc] initWithTarget:self action:@selector(getGroupUserDidReceived:result:)];
    }
    return _getGroupUserClient;
}

- (void)getGroupUserDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError) {
        self.relatePersonCompletionBlock(NO, NO, nil, client.errorMessage);
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        self.relatePersonCompletionBlock(NO, NO, nil, ASLocalizedString(@"返回值格式错误"));
        return;
    }
    if (!result.success) {
        self.relatePersonCompletionBlock(NO, nil, nil, result.error);
        return;
    }
    
    //    if (![result.data isKindOfClass:[NSArray class]] || [(NSArray *)result.data count] == 0) {
    //        self.relatePersonCompletionBlock(NO, nil, @"返回值格式错误");
    //        return;
    //    }
    
    self.relatePersonCompletionBlock(YES, nil, result.data, nil);
    
}
- (void)getRelatedPersonDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError) {
        self.relatePersonCompletionBlock(NO, NO, nil, client.errorMessage);
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        self.relatePersonCompletionBlock(NO, NO, nil, ASLocalizedString(@"返回值格式错误"));
        return;
    }
    if (!result.success) {
        self.relatePersonCompletionBlock(NO, nil, nil, result.error);
        return;
    }
    
//    if (![result.data isKindOfClass:[NSArray class]] || [(NSArray *)result.data count] == 0) {
//        self.relatePersonCompletionBlock(NO, nil, @"返回值格式错误");
//        return;
//    }
    
    self.relatePersonCompletionBlock(YES, nil, result.data, nil);

}

- (void)getPersonDidRecieve:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
	if (client.hasError) {
		self.completionBlock(NO, nil, client.errorMessage);
		return;
	}
	if (![result isKindOfClass:[BOSResultDataModel class]]) {
		self.completionBlock(NO, nil, ASLocalizedString(@"返回值格式错误"));
		return;
	}
	if (!result.success) {
		self.completionBlock(NO, nil, result.error);
		return;
	}

    if (![result.data isKindOfClass:[NSArray class]] || [(NSArray *)result.data count] == 0) {
        self.completionBlock(NO, nil, @"返回值格式错误");
		return;
    }

	NSArray *data = (NSArray *)result.data;
    NSArray *persons = nil;
    if (self.batch) {
        __block NSMutableArray *personIds = [NSMutableArray array];
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSString *personId = obj[@"id"];
                if (personId.length > 0) {
                    [personIds addObject:personId];
                }
            }
        }];
        persons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryValidPersonWithPersonIds:personIds];
    }
    else {
        if ([[data firstObject] isKindOfClass:[NSDictionary class]]) {
            NSString *personId = [data firstObject][@"id"];
            if (personId.length > 0) {
//                PersonSimpleDataModel *personSimple = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:personId];
//                if (personSimple != nil && [personSimple accountAvailable]) {
//                    persons = @[personSimple];
//                }
                PersonDataModel *person = [[PersonDataModel alloc] initWithOpenDictionary:[data firstObject]];
                if(person)
                {
                    persons = @[person];
                }
                else
                {
                    PersonSimpleDataModel *personSimple = [[PersonSimpleDataModel alloc] init];
                    personSimple.personId = personId;
                    PersonDataModel *personDM = nil;
                    personDM = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonDetailWithPerson:personSimple];
                    persons = @[personSimple];
                }
            }
        }
    }

	if ([persons count] == 0) {
		self.completionBlock(NO, nil, ASLocalizedString(@"无法找到员工"));
		return;
	}
	self.completionBlock(YES, persons, nil);
}

- (void)personInfoDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError) {
        self.completionBlock(NO, nil, client.errorMessage);
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        self.completionBlock(NO, nil, ASLocalizedString(@"返回值格式错误"));
        return;
    }
    if (!result.success) {
        self.completionBlock(NO, nil, result.error);
        return;
    }

    if (result.success) {
        PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:result.data];
        [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:person];
    }
    self.completionBlock(YES, nil, nil);
}
- (void)getCloudPassportWith:(NSString*)userId
                  completion:(KDUserHelperCloudCompletionBlock)completionBlock
{
    self.batch = NO;
    
    if (userId.length == 0) {
        completionBlock(NO, nil, ASLocalizedString(@"参数错误"));
        return;
    }
    
    self.cloudCompletionBlock = completionBlock;
    KDQuery *query = [KDQuery query];
    [query setParameter:@"userId" stringValue:userId];
    

    KDServiceActionDidCompleteBlock completionBlock1 = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
       self.cloudCompletionBlock(YES, results, nil);
        
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/account/:cloudPassport" query:query
                                 configBlock:nil completionBlock:completionBlock1];

}




@end
