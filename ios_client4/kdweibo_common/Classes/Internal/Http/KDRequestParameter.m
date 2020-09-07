//
//  KDRequestParameter.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDRequestParameter.h"

@implementation KDRequestParameter

@synthesize name=name_;
@synthesize value=value_;
@synthesize filePath=filePath_;
@synthesize fileData=fileData_;

- (id) init {
    self = [super init];
    if(self){
        name_ = nil;
        value_ = nil;
        
        filePath_ = nil;
        fileData_ = nil;
    }
    
    return self;
}

- (id) initWithName:(NSString *)name value:(NSString *)value {
    self = [self init];
    if(self){
        name_ = name;// retain];
        value_ = value;// retain];
    }
    
    return self;
}

- (id) initWithName:(NSString *)name filePath:(NSString *)filePath {
    self = [self init];
    if(self){
        name_ = name ;//retain];
        filePath_ = filePath;// retain];
    }
    
    return self;
}

- (id) initWithName:(NSString *)name fileData:(NSData *)fileData {
    self = [self init];
    if(self){
        name_ = name;// retain];
        fileData_ = fileData;// retain];
    }
    
    return self;
}

+ (id) parameterWithName:(NSString *)name value:(NSString *)value {
    return [[KDRequestParameter alloc] initWithName:name value:value];// autorelease];
}

+ (id) parameterWithName:(NSString *)name filePath:(NSString *)filePath {
    return [[KDRequestParameter alloc] initWithName:name filePath:filePath] ;//autorelease];
}

+ (id) parameterWithName:(NSString *)name fileData:(NSData *)fileData {
    return [[KDRequestParameter alloc] initWithName:name fileData:fileData];// autorelease];
}


// Generally speaking, the request parameter value can be value, file path or file data. 
// And only one of them can be set. If more than one value been setted, the order listed at below. 
- (id) getRealParameterValue {
    if(value_ != nil) return value_;
    if(filePath_ != nil) return filePath_;
    
    return fileData_;
}

- (BOOL) isFile {
    return filePath_ != nil;
}

- (BOOL) hasFileData {
    return fileData_ != nil;
}

- (BOOL) containsFile {
    return (filePath_ != nil || fileData_ != nil) ? YES : NO;
}


+ (BOOL) containsFile:(NSArray *)params {
    if(params == nil) return NO;
    
    BOOL containsFile = false;
    for (KDRequestParameter *param in params) {
        if ([param containsFile]) {
            containsFile = YES;
            break;
        }
    }
    
    return containsFile;
}

- (KDUInt64) postContentLength {
    KDUInt64 contentLength = 0;
    if(value_ != nil){
        contentLength += [value_ length];
    }
    
    if(fileData_ != nil){
        contentLength += [fileData_ length];
    }
    
    if(filePath_ != nil){
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath_ error:NULL];
		contentLength += [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
    }
    
    return contentLength;
}

+ (NSMutableArray *) toParameterArray:(NSString *)name value:(NSString *)value {
    return [NSMutableArray arrayWithObject:[[KDRequestParameter alloc] initWithName:name value:value]];// autorelease]];
}

+ (NSMutableArray *) toParameterArray:(NSString *)name integerValue:(NSInteger)value {
    return [KDRequestParameter toParameterArray:name value:[NSString stringWithFormat:@"%ld", (long)value]];
}

+ (NSMutableArray *) toParameterArray:(NSString *)name value:(NSString *)value name2:(NSString *)name2 value2:(NSString *)value2 {
    return [NSMutableArray arrayWithObjects:[[KDRequestParameter alloc] initWithName:name value:value],
            [[KDRequestParameter alloc] initWithName:name2 value:value2] , nil];
}


+ (NSMutableArray *) toParameterArray:(NSString *)name integerValue:(NSInteger)value name2:(NSString *)name2 integerValue2:(NSInteger)value2 {
    return [NSMutableArray arrayWithObjects:
            [[KDRequestParameter alloc] initWithName:name value:[NSString stringWithFormat:@"%ld", (long)value]],
            [[KDRequestParameter alloc] initWithName:name2 value:[NSString stringWithFormat:@"%ld", (long)value2]],
            nil];
}

- (NSInteger) compareTo:(id)object {
    KDRequestParameter *that = (KDRequestParameter *) object;
    
    NSComparisonResult compared = [name_ compare:that.name options:NSBackwardsSearch];
    if (NSOrderedSame == compared) {
        compared = [value_ compare:that.value options:NSBackwardsSearch];
    }
    
    return compared;
}

- (NSUInteger) hash {
    NSUInteger result = [name_ hash];
    result = 31 * result + (value_ != nil ? [value_ hash] : 0);
    result = 31 * result + (filePath_ != nil ? [filePath_ hash] : 0);
    result = 31 * result + (fileData_ != nil ? [filePath_ length] : 0);
    
    return result;
}

- (BOOL) isEqual:(id)object {
    if(self == object) return YES;
    if(!([object isMemberOfClass:[KDRequestParameter class]])) return NO;
    
    KDRequestParameter *that = (KDRequestParameter *)object;
    
    if (filePath_ != nil ? ![filePath_ isEqual:that.filePath] : that.filePath != nil)
        return NO;
    
    if (fileData_ != nil ? ![fileData_ isEqual:that.fileData] : that.fileData != nil)
        return NO;
    
    if (![name_ isEqual:that.name]) return NO;
    
    if (value_ != nil ? ![value_ isEqual:that.value] : that.value != nil)
        return NO;
    
    return YES;
}

- (NSString *) description {
    NSUInteger length = (fileData_ != nil) ? [fileData_ length] : 0;
    
    return [NSString stringWithFormat:@"KDRequestParameter{name='%@', value='%@', filePath='%@', fileData=[%lu bytes]}", 
            name_, value_, filePath_, (unsigned long)length];
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(name_);
    //KD_RELEASE_SAFELY(value_);
    
    //KD_RELEASE_SAFELY(filePath_);
    //KD_RELEASE_SAFELY(fileData_);
    
    //[super dealloc];
}


@end
