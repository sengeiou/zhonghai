//
//  KDActionPathsConfigurator.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDActionPathsConfigurator.h"

@interface KDActionPathsConfigurator ()

@property(nonatomic, retain) NSDictionary *customizeServiceNames;

@end


@implementation KDActionPathsConfigurator

@synthesize customizeServiceNames=customizeServiceNames_;

- (id)init {
    self = [super init];
    if (self) {
        [self _loadActionPaths];
    }
    
    return self;
}

// load the customized service names and action path from property file
- (void)_loadActionPaths {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Common" ofType:@"bundle"]];
    NSURL *url = [NSURL fileURLWithPath:[bundle pathForResource:@"/Conf/action_paths" ofType:@"plist"]];
   
    NSAssert(url, ASLocalizedString(@"KDActionPathsConfigurator_Err"));
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfURL:url];
    customizeServiceNames_ = data;// retain];
}

// check specificed action path is valid or not
- (BOOL)isValidActionPath:(NSString *)actionPath {
    NSArray *items = [self serviceNamesForActionPath:actionPath];
    return items != nil;
}

// check specificed service name in action path is valid or not
- (BOOL)isValidServiceName:(NSString *)serviceName forActionPath:(NSString *)actionPath {
    BOOL isValid = NO;
    NSArray *items = [self serviceNamesForActionPath:actionPath];
    if (items != nil) {
        if (NSNotFound != [items indexOfObject:serviceName]) {
            isValid = YES;
        }
    }
    
    return isValid;
}

// return all allowed action paths
- (NSArray *)allAllowedActionPaths {
    return [customizeServiceNames_ allKeys];
}

// return all customized service name in specified action path
- (NSArray *)serviceNamesForActionPath:(NSString *)actionPath {
    if (actionPath != nil && customizeServiceNames_ != nil) {
        return [customizeServiceNames_ objectForKey:actionPath];
    }
    
    return nil;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(customizeServiceNames_);
    
    //[super dealloc];
}

@end
