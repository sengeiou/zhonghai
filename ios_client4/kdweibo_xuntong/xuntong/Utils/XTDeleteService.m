//
//  XTDeleteService.m
//  XT
//
//  Created by Gil on 13-10-14.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTDeleteService.h"
#import "ContactClient.h"

@interface XTDeleteService ()
@property (strong, nonatomic) NSMutableDictionary *serviceClients;
@end

@implementation XTDeleteService

+ (XTDeleteService *)shareService
{
    static dispatch_once_t pred;
    static XTDeleteService *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[XTDeleteService alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.serviceClients = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)deleteGroupWithGroupId:(NSString *)groupId
{
    if (groupId.length == 0) {
        return;
    }
    
    ContactClient *deleteClient = [[ContactClient alloc] initWithTarget:self action:@selector(deleteDidReceived:result:)];
    deleteClient.clientKey = groupId;
    [self.serviceClients setObject:deleteClient forKey:deleteClient.clientKey];
    [deleteClient delGroupWithGroupId:groupId];
}

- (void)deleteMessageWithGroupId:(NSString *)groupId msgId:(NSString *)msgId
{
    if (groupId.length == 0 || msgId.length == 0) {
        return;
    }
    ContactClient *deleteClient = [[ContactClient alloc] initWithTarget:self action:@selector(deleteDidReceived:result:)];
    deleteClient.clientKey = msgId;
    [self.serviceClients setObject:deleteClient forKey:deleteClient.clientKey];
    [deleteClient delMessageWithGroupId:groupId msgId:msgId];
}

- (void)deleteMessageWithPublicId:(NSString *)publicId groupId:(NSString *)groupId msgId:(NSString *)msgId
{
    if (publicId.length == 0 || groupId.length == 0 || msgId.length == 0) {
        return;
    }
    ContactClient *deleteClient = [[ContactClient alloc] initWithTarget:self action:@selector(deleteDidReceived:result:)];
    deleteClient.clientKey = msgId;
    [self.serviceClients setObject:deleteClient forKey:deleteClient.clientKey];
    [deleteClient delMessageWithPublicId:publicId groupId:groupId msgId:msgId];
}

- (void)deleteDidReceived:(ContactClient *)client result:(id)result
{
    [self.serviceClients removeObjectForKey:client.clientKey];
    client = nil;
}
@end
