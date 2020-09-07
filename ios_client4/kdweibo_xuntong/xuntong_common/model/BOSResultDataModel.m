//
//  BOSResultDataModel.m
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "BOSResultDataModel.h"

@implementation BOSResultDataModel
@synthesize success = _success_;
@synthesize error = _error_;
@synthesize errorCode = _errorCode_;
@synthesize data = _data_;

- (id)init {
    self = [super init];
    if (self) {
        _data_ = nil;
        _error_ = [[NSString alloc] initWithString:ASLocalizedString(@"BOSResultDataModel_Error")];
        _errorCode_ = 1;
        _success_ = NO;
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
        id data = [dict objectForKey:@"data"];
        id error = [dict objectForKey:@"error"];
        id errorCode = [dict objectForKey:@"errorCode"];
        id success = [dict objectForKey:@"success"];
        
        if (![data isKindOfClass:[NSNull class]] && data) {
            self.data = data;
        }
        if (![error isKindOfClass:[NSNull class]] && error) {
            self.error = error;
        }
        if (![errorCode isKindOfClass:[NSNull class]] && errorCode) {
            self.errorCode = [errorCode intValue];
        }
        if (![success isKindOfClass:[NSNull class]] && success) {
            self.success = [success boolValue];
        }
    }
    return self;
}

- (void)dealloc {
    //BOSRELEASE_data_);
    //BOSRELEASE_error_);
    
//    if(_dictJSON)
        //BOSRELEASE_dictJSON)
    //[super dealloc];
}

+(BOOL)isBOSResultDataModelClass:(id)dataModel
{
    if (dataModel == nil) {
        return NO;
    }
    if (![dataModel isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    NSDictionary *dataModelDictionary = (NSDictionary *)dataModel;
    NSArray *keys = dataModelDictionary.allKeys;
    if ([keys containsObject:@"success"] &&
        [keys containsObject:@"error"] &&
        [keys containsObject:@"errorCode"] &&
        [keys containsObject:@"data"]) {
        return YES;
    }
    return NO;
}


@end
