//
//  XTForwardDataModel.m
//  XT
//
//  Created by kingdee eas on 13-11-13.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTForwardDataModel.h"
#import "RecordDataModel.h"

@implementation XTForwardDataModel

- (id)init {
    self = [super init];
    if (self) {
        _message = [[NSString alloc] init];
        _forwardType = 0;
        _paramObject = nil;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    
    if (self) {
        
        id message = [dict objectForKey:@"message"];
        if (![message isKindOfClass:[NSNull class]] && message) {
            self.message = message;
        }
        
        id forwardType = [dict objectForKey:@"forwardType"];
        if (![forwardType isKindOfClass:[NSNull class]] && forwardType) {
            self.forwardType = [forwardType intValue];
        }
        
        switch (self.forwardType) {
            case ForwardMessageFile:
            {
                id fileModel = [dict objectForKey:@"messageFileDM"];
                if (![fileModel isKindOfClass:[NSNull class]] && fileModel) {
                    self.paramObject = (MessageFileDataModel *)fileModel;
                }
                break;
            }
            default:
                break;
        }
    }
    
    return self;
}


@end

