//
//  InstructionsDataModel.m
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "InstructionsDataModel.h"

@implementation InstructionsCodeDataModel
@synthesize code = _code_;
@synthesize desc = _desc_;
@synthesize extra = _extra_;

- (id)init {
    self = [super init];
    if (self) {
        _code_ = InstructionsNone;
        _desc_ = [[NSString alloc] init];
        _extra_ = [[NSDictionary alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id code = [dict objectForKey:@"code"];
        id desc = [dict objectForKey:@"desc"];
        id extra = [dict objectForKey:@"extra"];
        
        if (![code isKindOfClass:[NSNull class]] && code) {
            self.code = [code intValue];
        }
        if (![desc isKindOfClass:[NSNull class]] && desc) {
            self.desc = desc;
        }
        if (![extra isKindOfClass:[NSNull class]] && extra) {
            self.extra = extra;
        }
    }
    return self;
}

- (void)dealloc {

}

@end

@implementation InstructionsDataModel
@synthesize instructions = _instructions_;
@synthesize desc = _desc_;

- (id)init {
    self = [super init];
    if (self) {
        _instructions_ = [[NSArray alloc] init];
        _desc_ = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id instructions = [dict objectForKey:@"instructions"];
        id desc = [dict objectForKey:@"desc"];
        
        if (![instructions isKindOfClass:[NSNull class]] && instructions 
            && [instructions isKindOfClass:[NSArray class]] && [(NSArray *)instructions count] > 0) {
            NSMutableArray *instructionsArray = [NSMutableArray arrayWithCapacity:[(NSArray *)instructions count]];
            for (id each in instructions) {
                InstructionsCodeDataModel *icDataModel = [[InstructionsCodeDataModel alloc] initWithDictionary:each];
                [instructionsArray addObject:icDataModel];
//                [icDataModel release];
            }
            self.instructions = instructionsArray;
        }
        if (![desc isKindOfClass:[NSNull class]] && desc) {
            self.desc = desc;
        }
    }
    return self;
}

@end
