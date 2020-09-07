//
//  KDRequestParameter.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDCommon.h"
#import "KDComparable.h"

@interface KDRequestParameter : NSObject <KDComparable> {
@private
    NSString *name_;
    NSString *value_;
    
    NSString *filePath_;
    NSData *fileData_;
}

@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) NSString *value;

@property (nonatomic, retain, readonly) NSString *filePath;
@property (nonatomic, retain, readonly) NSData *fileData;

- (id) initWithName:(NSString *)name value:(NSString *)value;
- (id) initWithName:(NSString *)name filePath:(NSString *)filePath;
- (id) initWithName:(NSString *)name fileData:(NSData *)fileData;

+ (id) parameterWithName:(NSString *)name value:(NSString *)value;
+ (id) parameterWithName:(NSString *)name filePath:(NSString *)filePath;
+ (id) parameterWithName:(NSString *)name fileData:(NSData *)fileData;

- (id) getRealParameterValue;

- (BOOL) isFile;
- (BOOL) hasFileData;
- (BOOL) containsFile;

+ (BOOL) containsFile:(NSArray *)params;

- (KDUInt64) postContentLength;

+ (NSMutableArray *) toParameterArray:(NSString *)name value:(NSString *)value;
+ (NSMutableArray *) toParameterArray:(NSString *)name integerValue:(NSInteger)value;

+ (NSMutableArray *) toParameterArray:(NSString *)name value:(NSString *)value name2:(NSString *)name2 value2:(NSString *)value2;
+ (NSMutableArray *) toParameterArray:(NSString *)name integerValue:(NSInteger)value name2:(NSString *)name2 integerValue2:(NSInteger)value2;


@end

