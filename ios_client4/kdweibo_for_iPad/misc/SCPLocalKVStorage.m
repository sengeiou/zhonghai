//
//  SCPLocalKVStorage.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 8/9/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "SCPLocalKVStorage.h"

static SCPLocalKVStorage *_inst;

@implementation SCPLocalKVStorage

+ (id)inst
{
    if (!_inst) {
        _inst = [super dictionaryWithContentsOfFile:[self _storageFilePath]];
        if (_inst) {
            [_inst retain];
        } else {
            _inst = [[NSMutableDictionary dictionary] retain];
        }
    }
    
    return _inst;
}

+ (id)objectForKey:(id)aKey
{
    return [[self inst] objectForKey:aKey];
}

+ (void)setObject:(id)anObject forKey:(id)aKey
{
    if (anObject) {
        [[self inst] setObject:anObject forKey:aKey];
    }
    
    [self _persistDict];
}

+ (void)removeObjectForKey:(id)key
{
    [[self inst] removeObjectForKey:key];
    [self _persistDict];
}

+ (void)reset
{
    [[self inst] removeAllObjects];
    [self _persistDict];
}

+ (NSString *)_storageFilePath
{
    static NSString *path;
    if (!path) {
        //path = [[[NSBundle mainBundle] pathForResource:@"SCPKVLocalStorage" ofType:@"plist"] retain];
        //path = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"SCPKVLocalStorage.plist"] retain];
        
        NSString *docRoot = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [[docRoot stringByAppendingPathComponent:@"SCPKVLocalStorage.plist"] retain];
    }
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        NSLog(@"got file at %@", path);
//        NSLog(@"file content %@", [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]);
//    } else {
//        NSLog(@"no file at %@", path);
//    }
    
    return path;
}

+ (void)_persistDict
{
    NSString *parseErr = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:[self inst]
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&parseErr];
    if (parseErr) {
        return;
    }
    
    NSError *writeErr = nil;
    //[plistData writeToFile:[self _storageFilePath] atomically:YES];
    [plistData writeToFile:[self _storageFilePath]
                   options:NSDataWritingAtomic
                     error:&writeErr];    
    if (writeErr) {
    }
}

@end
