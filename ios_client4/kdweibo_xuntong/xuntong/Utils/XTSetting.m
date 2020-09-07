//
//  XTSetting.m
//  XunTong
//
//  Created by Gil on 13-4-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSetting.h"
#import "BOSFileManager.h"

#define XTSETTING_FILENAME @"XTSetting_%@.archive"

#define P_XTSETTING_UPDATETIME @"updateTime"
#define P_XTSETTING_PUBACCOUNTS_UPDATETIME_DICT @"pubAccountsUpdateTimeDict"
#define P_XTSETTING_T9UPDATETIME @"t9UpdateTime"
#define P_XTSETTING_GRAMMARID @"grammarId"
#define P_XTSETTING_ORGTREE @"orgTree"
#define P_XTSETTING_DEFAULTSEARCHKEYBOARDTYPE @"defaultKeyboardType"
#define P_XTSETTING_DEFAULTCHATKEYBOARDTYPE @"defaultChatKeyboardType"
#define P_XTSETTING_NEWCOMPANY_FIRSTLOGIN @"firstLoginNewCompany"
#define P_XTSETTING_PARAMFETCHUPDATETIME @"paramFetchUpdateTime"
#define P_XTSETTING_PUBACCTUPDATETIME @"pubAcctUpdateTime"
#define P_XTSETTING_FOLDPUBLICACCOUNTPRESSED @"foldPublicAccountPressed"
#define P_XTSETTING_CLOUDPASSPORT @"cloudpassport"
#define P_XTSETTING_MSGLASTREADUPDATETIME    @"msgLastReadUpdateTime"
#define P_XTSETTING_MSGPRESSTIPSORNOT        @"msgPressTipsOrNot"
#define P_XTSETTING_GROUPEXITUPDATETIME @"groupExitUpdateTime"
#define P_XTSETTING_ISDONOTDISTURBMODEL       @"isDoNotDisturbModel"

#define P_XTSETTING_MSGLASTDELUPDATETIME    @"msgLastDelUpdateTime"
#define P_XTSETTING_APPLISTUPDATETIME    @"appListUpdateTime"
#define P_XTSETTING_CLEANUPDATETIME    @"lastClearDataUpdateTime"


@interface XTSetting ()
@property (strong, nonatomic) NSString *openId;
@property (strong, nonatomic) NSString *eId;
@property (strong, nonatomic) NSString *filePath;
@end

@implementation XTSetting

+ (XTSetting *)sharedSetting
{
    static dispatch_once_t pred;
    static XTSetting *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[XTSetting alloc] init];
    });
    return instance;
}

- (void)setOpenId:(NSString *)openId eId:(NSString *)eId
{
    NSParameterAssert(openId);
    NSParameterAssert(eId);
    
    //切换了账号
    if (![openId isEqualToString:self.openId]) {
        self.openId = openId;
        self.eId = eId;
        self.filePath = [[BOSFileManager currentUserPathWithOpenId:openId] stringByAppendingPathComponent:[NSString stringWithFormat:XTSETTING_FILENAME,eId]];
        [self readSetting];
        return;
    }
    
    //同一个账号，切换了企业
    if (![eId isEqualToString:self.eId]) {
        self.eId = eId;
        self.filePath = [[BOSFileManager currentUserPathWithOpenId:openId] stringByAppendingPathComponent:[NSString stringWithFormat:XTSETTING_FILENAME,eId]];
        [self readSetting];
    }
}

- (void)initProperties
{
    self.updateTime = [[NSString alloc] init];
    self.pubAccountsUpdateTimeDict = [[NSMutableDictionary alloc] init];
    self.t9UpdateTime = [[NSString alloc] init];
    self.grammarId = [[NSString alloc] init];
    self.orgTree = false;
    self.defaultSearchKeyboardType = XTSearchKeyboardSystem;
    self.defaultChatKeyboardType = XTChatKeyboardSpeech;
    self.isCreate = NO;
    self.paramFetchUpdateTime = [[NSString alloc] init];
    self.pubAcctUpdateTime = [[NSString alloc] init];
    self.foldPublicAccountPressed = NO;
    self.cloudpassport = [[NSString alloc]init];
    self.msgLastReadUpdateTime = [[NSString alloc] init];
    self.pressMsgUnreadTipsOrNot = NO;
    self.groupExitUpdateTime = [[NSString alloc] init];
    self.isDoNotDisturbMode = NO;
    self.msgLastDelUpdateTime = [[NSString alloc] init];
    self.appListUpdateTime = [[NSString alloc] init];
    self.lastClearDataUpdateTime = [[NSString alloc] init];
}

- (void)readSetting
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        NSDictionary *settingData = [NSDictionary dictionaryWithContentsOfFile:self.filePath];
        if (settingData != nil && [settingData isKindOfClass:[NSDictionary class]]) {
            self.updateTime = [self stringValueInSetting:settingData forKey:P_XTSETTING_UPDATETIME];
            self.t9UpdateTime = [self stringValueInSetting:settingData forKey:P_XTSETTING_T9UPDATETIME];
            self.pubAccountsUpdateTimeDict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryValueInSetting:settingData forKey:P_XTSETTING_PUBACCOUNTS_UPDATETIME_DICT]];
            self.grammarId = [self stringValueInSetting:settingData forKey:P_XTSETTING_GRAMMARID];
            self.orgTree = [self boolValueInSetting:settingData forKey:P_XTSETTING_ORGTREE];
            self.defaultSearchKeyboardType = [self intValueInSetting:settingData forKey:P_XTSETTING_DEFAULTSEARCHKEYBOARDTYPE];
            self.defaultChatKeyboardType = [self intValueInSetting:settingData forKey:P_XTSETTING_DEFAULTCHATKEYBOARDTYPE];
            self.isCreate = [self boolValueInSetting:settingData forKey:P_XTSETTING_NEWCOMPANY_FIRSTLOGIN];
            self.paramFetchUpdateTime = [self stringValueInSetting:settingData forKey:P_XTSETTING_PARAMFETCHUPDATETIME];
            self.pubAcctUpdateTime = [self stringValueInSetting:settingData forKey:P_XTSETTING_PUBACCTUPDATETIME];
            self.foldPublicAccountPressed = [self boolValueInSetting:settingData forKey:P_XTSETTING_FOLDPUBLICACCOUNTPRESSED];
            self.cloudpassport = [self stringValueInSetting:settingData forKey:P_XTSETTING_CLOUDPASSPORT];
            self.msgLastReadUpdateTime = [self stringValueInSetting:settingData forKey:P_XTSETTING_MSGLASTREADUPDATETIME];
            self.pressMsgUnreadTipsOrNot = [self boolValueInSetting:settingData forKey:P_XTSETTING_MSGPRESSTIPSORNOT];
            self.groupExitUpdateTime = [self stringValueInSetting:settingData forKey:P_XTSETTING_GROUPEXITUPDATETIME];
            self.isDoNotDisturbMode = [self boolValueInSetting:settingData forKey:P_XTSETTING_ISDONOTDISTURBMODEL];
            
            self.msgLastDelUpdateTime = [self stringValueInSetting:settingData forKey:P_XTSETTING_MSGLASTDELUPDATETIME];
            self.appListUpdateTime = [self stringValueInSetting:settingData forKey:P_XTSETTING_APPLISTUPDATETIME];
            self.lastClearDataUpdateTime = [self stringValueInSetting:settingData forKey:P_XTSETTING_CLEANUPDATETIME];
        } else {
            [self initProperties];
        }
    }else {
        [self initProperties];
    }
}
- (void)cleanSetting{
    
    self.updateTime = [[NSString alloc] init];
    self.pubAccountsUpdateTimeDict = [[NSMutableDictionary alloc] init];
    self.t9UpdateTime = [[NSString alloc] init];
    self.grammarId = [[NSString alloc] init];
    self.orgTree = false;
    self.defaultSearchKeyboardType = XTSearchKeyboardSystem;
    self.defaultChatKeyboardType = XTChatKeyboardSpeech;
    self.isCreate = NO;
    self.paramFetchUpdateTime = [[NSString alloc] init];
    self.pubAcctUpdateTime = [[NSString alloc] init];
    self.foldPublicAccountPressed = NO;
    self.cloudpassport = [[NSString alloc]init];
    self.msgLastReadUpdateTime = [[NSString alloc] init];
    self.pressMsgUnreadTipsOrNot = NO;
    self.isDoNotDisturbMode = NO;
    self.msgLastDelUpdateTime = [[NSString alloc] init];
    self.appListUpdateTime = [[NSString alloc] init];
    self.lastClearDataUpdateTime = [[NSString alloc] init];
    [self saveSetting];
}
#pragma mark - methods

-(BOOL)saveSetting
{
    NSMutableDictionary *settingData = [NSMutableDictionary dictionary];
    if (self.updateTime != nil) {
        [settingData setObject:self.updateTime forKey:P_XTSETTING_UPDATETIME];
    }
    if (self.t9UpdateTime != nil) {
        [settingData setObject:self.t9UpdateTime forKey:P_XTSETTING_T9UPDATETIME];
    }
    if (self.pubAccountsUpdateTimeDict != nil) {
        [settingData setObject:self.pubAccountsUpdateTimeDict forKey:P_XTSETTING_PUBACCOUNTS_UPDATETIME_DICT];
    }
    if (self.grammarId != nil) {
        [settingData setObject:self.grammarId forKey:P_XTSETTING_GRAMMARID];
    }
    if (self.cloudpassport != nil) {
        [settingData setObject:self.cloudpassport forKey:P_XTSETTING_CLOUDPASSPORT];
    }
    [settingData setObject:[NSNumber numberWithBool:self.isCreate] forKey:P_XTSETTING_NEWCOMPANY_FIRSTLOGIN];
    [settingData setObject:[NSNumber numberWithBool:self.orgTree] forKey:P_XTSETTING_ORGTREE];
    [settingData setObject:[NSNumber numberWithInt:self.defaultSearchKeyboardType] forKey:P_XTSETTING_DEFAULTSEARCHKEYBOARDTYPE];
    [settingData setObject:[NSNumber numberWithInt:self.defaultChatKeyboardType] forKey:P_XTSETTING_DEFAULTCHATKEYBOARDTYPE];
    if (self.paramFetchUpdateTime != nil) {
        [settingData setObject:self.paramFetchUpdateTime forKey:P_XTSETTING_PARAMFETCHUPDATETIME];
    }
    if (self.pubAcctUpdateTime != nil) {
        [settingData setObject:self.pubAcctUpdateTime forKey:P_XTSETTING_PUBACCTUPDATETIME];
    }
    if(self.msgLastReadUpdateTime != nil){
        [settingData setObject:self.msgLastReadUpdateTime forKey:P_XTSETTING_MSGLASTREADUPDATETIME];
    }
    if(self.msgLastDelUpdateTime != nil){
        [settingData setObject:self.msgLastDelUpdateTime forKey:P_XTSETTING_MSGLASTDELUPDATETIME];
    }
    [settingData setObject:[NSNumber numberWithBool:self.foldPublicAccountPressed] forKey:P_XTSETTING_FOLDPUBLICACCOUNTPRESSED];
    [settingData setObject:[NSNumber numberWithBool:self.pressMsgUnreadTipsOrNot] forKey:P_XTSETTING_MSGPRESSTIPSORNOT];
    [settingData setObject:[NSNumber numberWithBool:self.isDoNotDisturbMode] forKey:P_XTSETTING_ISDONOTDISTURBMODEL];
    if (self.groupExitUpdateTime != nil) {
        [settingData setObject:self.groupExitUpdateTime forKey:P_XTSETTING_GROUPEXITUPDATETIME];
    }
    if (self.appListUpdateTime != nil) {
        [settingData setObject:self.appListUpdateTime forKey:P_XTSETTING_APPLISTUPDATETIME];
    }
    
    if(self.lastClearDataUpdateTime != nil){
        [settingData setObject:self.lastClearDataUpdateTime forKey:P_XTSETTING_CLEANUPDATETIME];
    }
    
    return [settingData writeToFile:self.filePath atomically:YES];
}

#pragma mark - get value

- (int)intValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key
{
    id value = [settingData objectForKey:key];
    if (value == nil || ![value isKindOfClass:[NSNumber class]]) {
        return 0;
    }
    return [value intValue];
}

- (BOOL)boolValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key
{
    id value = [settingData objectForKey:key];
    if (value == nil || ![value isKindOfClass:[NSNumber class]]) {
        return NO;
    }
    return [value boolValue];
}

- (NSString *)stringValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key
{
    id value = [settingData objectForKey:key];
    if (value == nil || ![value isKindOfClass:[NSString class]]) {
        return [NSString string];
    }
    return value;
}

- (NSDictionary *)dictionaryValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key
{
    id value = [settingData objectForKey:key];
    if (value == nil || ![value isKindOfClass:[NSDictionary class]]) {
        return [NSDictionary dictionary];
    }
    return value;
}

- (NSArray *)arrayValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key
{
    id value = [settingData objectForKey:key];
    if (value == nil || ![value isKindOfClass:[NSArray class]]) {
        return [NSArray array];
    }
    return value;
}

@end
