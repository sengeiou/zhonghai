//
//  KDQuery.h
//  kdweibo_common
//
//  Created by laijiandong on 12-8-27.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDObject.h"

@interface KDQuery : KDObject {
 @private
    NSMutableDictionary *genericParameters_;
    NSMutableDictionary *fileDataParameters_;
}

+ (KDQuery *)query;
+ (KDQuery *)queryWithName:(NSString *)name value:(NSString *)value;
- (KDQuery *)queryByAddQuery:(KDQuery *)query;

/////////////////////////////////////////////////////////////////////////////////////

- (KDQuery *)setParameter:(NSString *)name booleanValue:(BOOL)value;
- (KDQuery *)setParameter:(NSString *)name charValue:(char)value;
- (KDQuery *)setParameter:(NSString *)name intValue:(int)value;
- (KDQuery *)setParameter:(NSString *)name integerValue:(NSInteger)value;
- (KDQuery *)setParameter:(NSString *)name longLongValue:(KDInt64)value;
- (KDQuery *)setParameter:(NSString *)name unsignedLongLongValue:(KDUInt64)value;
- (KDQuery *)setParameter:(NSString *)name floatValue:(float)value;
- (KDQuery *)setParameter:(NSString *)name doubleValue:(double)value;

- (KDQuery *)setParameter:(NSString *)name stringValue:(NSString *)value;


/////////////////////////////////////////////////////////////////////////////////////

- (NSString *)genericParameterForName:(NSString *)name;


/////////////////////////////////////////////////////////////////////////////////////

- (KDQuery *)setParameter:(NSString *)name filePath:(NSString *)filePath;
- (KDQuery *)setParameter:(NSString *)name fileData:(NSData *)fileData;

- (NSArray *)toRequestParameters;

@end
