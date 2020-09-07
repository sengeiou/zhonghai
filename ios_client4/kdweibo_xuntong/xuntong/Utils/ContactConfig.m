//
//  ContactConfig.m
//  ContactsLite
//
//  Created by Gil on 12-11-30.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "ContactConfig.h"

#define kXTConfigPubAccount @"xtconfig_pubaccount"

@implementation ContactConfig

static ContactConfig *m_instance = nil;
+(ContactConfig *)sharedConfig
{
    @synchronized(self)
	{
		if(m_instance == nil)
		{
			m_instance=[[ContactConfig alloc] init];
		}
	}
	return m_instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        NSData *publicAccountList = [[NSUserDefaults standardUserDefaults] objectForKey:kXTConfigPubAccount];
        if (publicAccountList) {
            self.publicAccountList = [NSKeyedUnarchiver unarchiveObjectWithData:publicAccountList];
        }
        
        _needUpdateDataModel = nil;
    }
    return self;
}

- (void)clearConfig {
    self.publicAccountList = nil;
    [self saveConfig];
}

- (BOOL)saveConfig {
    if (self.publicAccountList != nil) {
        NSData *publicAccountList = [NSKeyedArchiver archivedDataWithRootObject:self.publicAccountList];
        [[NSUserDefaults standardUserDefaults] setObject:publicAccountList forKey:kXTConfigPubAccount];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXTConfigPubAccount];
    }
    BOOL result = [[NSUserDefaults standardUserDefaults] synchronize];
    return result;
}


@end
