//
//  BOSConfig.m
//  EMPNativeContainer
//
//  Created by Gil on 12-11-9.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "BOSConfig.h"
#import "BOSFileManager.h"

@interface BOSConfig ()
- (NSArray*) parseInterfaceOrientations:(NSArray*)orientations;
@end


#define kConfigLoginToken @"loginToken"
#define kConfigSsoToken @"ssoToken"
#define kConfigHomePage @"homePage"
#define kConfigLoginUser @"loginUser"
#define kConfigAppId @"appId"
#define kConfigInstanceName @"instanceName"
#define kConfigUser @"config_user"
#define kConfigIsLoginWithOpenAccount @"isLoginWithOpenAccount"

#define kConfigFileName @"BOSConfig.archive"

@implementation BOSConfig

#pragma mark - init

static BOSConfig *m_instance = nil;

+(BOSConfig *)sharedConfig
{
    @synchronized(self)
	{
		if(m_instance == nil)
		{
			m_instance=[[BOSConfig alloc] init];
		}
	}
	return m_instance;
}

- (void)initProperties
{
    self.deviceToken = [NSString string];
    self.supportedOrientations = [self parseInterfaceOrientations:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"]];
    self.loginToken = [NSString string];
    self.ssoToken = [NSString string];
    self.homePage = @"/index.html";
    
    _bAutoLogin = YES;
    id autoLogin = [[BOSSetting sharedSetting].params objectForKey:@"autoLogin"];
    if (autoLogin) {
        _bAutoLogin = [autoLogin boolValue];
    }
    _bSecurity = NO;
    id security = [[BOSSetting sharedSetting].params objectForKey:@"security"];
    if (security) {
        _bSecurity = [security boolValue];
    }
    self.loginUser = [NSString string];
    self.secretKey = [NSString string];
    self.appId = 0;
    self.instanceName = [NSString string];
    self.bDemoLogin = NO;
    
    self.isLoginWithOpenAccount = YES;
    
}

-(id)init
{
    self = [super init];
    if (self) {
        [self initProperties];
        
        if ([BOSFileManager fileExistAtXuntongPath:kConfigFileName]) {
            NSDictionary *settingData = [NSDictionary dictionaryWithContentsOfFile:[[BOSFileManager xuntongPath] stringByAppendingPathComponent:kConfigFileName]];
            if (settingData != nil && [settingData isKindOfClass:[NSDictionary class]]) {
                self.loginToken = [self stringValueInSetting:settingData forKey:kConfigLoginToken];
                self.ssoToken = [self stringValueInSetting:settingData forKey:kConfigSsoToken];
                self.homePage = [self stringValueInSetting:settingData forKey:kConfigHomePage];
                self.loginUser = [self stringValueInSetting:settingData forKey:kConfigLoginUser];
                self.appId = [self intValueInSetting:settingData forKey:kConfigAppId];
                self.instanceName = [self stringValueInSetting:settingData forKey:kConfigInstanceName];
                self.isLoginWithOpenAccount = [self boolValueInSetting:settingData forKey:kConfigIsLoginWithOpenAccount];
            }
        }
        
        NSData *user = [[NSUserDefaults standardUserDefaults] objectForKey:kConfigUser];
        if (user) {
            self.user = [NSKeyedUnarchiver unarchiveObjectWithData:user];
        }
        
        // 主账号反归档操作
        NSData *mainUserData = [NSData dataWithContentsOfFile:[[BOSFileManager xuntongPath] stringByAppendingPathComponent:@"mainUser.archiver"]];
        NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc]initForReadingWithData:mainUserData];
        KDMainUserDataModel *mainUser = [unArch decodeObjectForKey:@"mainUser"];
        self.mainUser = mainUser;
    }
    return self;
}

#pragma mark - update

-(void)updateConfig4Param
{
    id autoLogin = [[BOSSetting sharedSetting].params objectForKey:@"autoLogin"];
    if (autoLogin) {
        _bAutoLogin = [autoLogin boolValue];
    }
    id security = [[BOSSetting sharedSetting].params objectForKey:@"security"];
    if (security) {
        _bSecurity = [security boolValue];
    }
}

#pragma mark -

-(void)clearConfig
{
    self.loginToken = [NSString string];
    self.ssoToken = [NSString string];
    self.homePage = @"/index.html";
    
    /*
     登录者的用户名不清空
    self.loginUser = [NSString string];
     */
    
    self.secretKey = [NSString string];
    self.appId = 0;
    self.instanceName = [NSString string];
    self.bDemoLogin = NO;
    
    /*
     只清空当前登录者的token信息
    self.user = nil;
     */
    self.user.token = @"";
    self.currentUser = nil;
    
    [self saveConfig];
}

- (BOOL)saveConfig {
    
    NSMutableDictionary *settingData = [NSMutableDictionary dictionary];
    if (self.loginToken != nil) {
        [settingData setObject:self.loginToken forKey:kConfigLoginToken];
    }
    if (self.ssoToken != nil) {
        [settingData setObject:self.ssoToken forKey:kConfigSsoToken];
    }
    if (self.homePage != nil) {
        [settingData setObject:self.homePage forKey:kConfigHomePage];
    }
    if (self.loginUser != nil) {
        [settingData setObject:self.loginUser forKey:kConfigLoginUser];
    }
    [settingData setObject:[NSNumber numberWithInt:self.appId] forKey:kConfigAppId];
    if (self.instanceName != nil) {
        [settingData setObject:self.instanceName forKey:kConfigInstanceName];
    }
    [settingData setObject:[NSNumber numberWithBool:self.isLoginWithOpenAccount] forKey:kConfigIsLoginWithOpenAccount];
    
    if (self.user != nil) {
        NSData *user = [NSKeyedArchiver archivedDataWithRootObject:self.user];
        [[NSUserDefaults standardUserDefaults] setObject:user forKey:kConfigUser];
        
        if([[KDManagerContext globalManagerContext] userManager].verifyCache
           && self.user.eid
           )
        {
                [[[KDManagerContext globalManagerContext] userManager].verifyCache setObject:self.user.eid forKey:@"eid"];
                [[KDManagerContext globalManagerContext].userManager storeUserData];
        }
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConfigUser];
    }
    
    // 主账号反归档操作
    NSData *mainUserData = [NSData dataWithContentsOfFile:[[BOSFileManager xuntongPath] stringByAppendingPathComponent:@"mainUser.archiver"]];
    NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:mainUserData];// autorelease];
    KDMainUserDataModel *mainUser = [unArch decodeObjectForKey:@"mainUser"];
    self.mainUser = mainUser;
    
    BOOL result = [[NSUserDefaults standardUserDefaults] synchronize];
    return result && [settingData writeToFile:[[BOSFileManager xuntongPath] stringByAppendingPathComponent:kConfigFileName] atomically:YES];
}

- (PersonSimpleDataModel *)currentUser
{
    if(_currentUser == nil || (![_currentUser.personId isEqualToString:_user.userId])) {
        _currentUser = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:_user.userId] ;//retain];
    }
    return _currentUser;
}

-(void)dealloc
{
}

- (NSArray*) parseInterfaceOrientations:(NSArray*)orientations
{
    NSMutableArray* result = [[NSMutableArray alloc] init];// autorelease];
	
    if (orientations != nil)
    {
        NSEnumerator* enumerator = [orientations objectEnumerator];
        NSString* orientationString;
        
        while (orientationString = [enumerator nextObject])
        {
            if ([orientationString isEqualToString:@"UIInterfaceOrientationPortrait"]) {
                [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationPortrait]];
            } else if ([orientationString isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]) {
                [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown]];
            } else if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
                [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft]];
            } else if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
                [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight]];
            }
        }
    }
    
    // default
    if ([result count] == 0) {
        [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationPortrait]];
    }
    
    return result;
}
    
#pragma mark - get value

- (int)intValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key {
	id value = [settingData objectForKey:key];
	if (value == nil || ![value isKindOfClass:[NSNumber class]]) {
		return 0;
	}
	return [value intValue];
}

- (BOOL)boolValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key {
	id value = [settingData objectForKey:key];
	if (value == nil || ![value isKindOfClass:[NSNumber class]]) {
		return NO;
	}
	return [value boolValue];
}

- (NSString *)stringValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key {
	id value = [settingData objectForKey:key];
	if (value == nil || ![value isKindOfClass:[NSString class]]) {
		return [NSString string];
	}
	return value;
}

- (NSDictionary *)dictionaryValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key {
	id value = [settingData objectForKey:key];
	if (value == nil || ![value isKindOfClass:[NSDictionary class]]) {
		return [NSDictionary dictionary];
	}
	return value;
}

- (NSArray *)arrayValueInSetting:(NSDictionary *)settingData forKey:(NSString *)key {
	id value = [settingData objectForKey:key];
	if (value == nil || ![value isKindOfClass:[NSArray class]]) {
		return [NSArray array];
	}
	return value;
}

@end
