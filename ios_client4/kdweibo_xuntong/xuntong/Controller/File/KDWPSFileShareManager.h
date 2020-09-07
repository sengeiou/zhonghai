//
//  KDWPSFileShareManager.h
//  kdweibo
//
//  Created by lichao_liu on 10/22/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ShareManagerBlock)(void);
@interface KDWPSFileShareManager : NSObject
@property (nonatomic, copy) NSString *accessCode;
@property (nonatomic, copy) NSString *serverHost;
@property (nonatomic, copy) NSString *originatorPersonId;

+ (instancetype)sharedInstance;

- (void)startSharePlay:(NSData *)data
          withFileName:(NSString *)fileName;

- (void)joinWpsSharePlay;

- (void)setAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost;

- (void)joinWpsSharePlayFailured;

- (BOOL)isExitFileShareWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost;
@end
