//
//  KDBaseParser.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDictionary+Additions.h"

#import "NSNull+Dictionary.h"

@class KDCompositeImageSource;


// convert million seconds to seconds
#define KD_PARSER_MILLISECOND_TO_SECONDS(millisecond) ((millisecond) / 1000.0)


@interface KDBaseParser : NSObject

- (id)parserWithClass:(Class)clazz;

// try to parse composite image source from JSON body
- (KDCompositeImageSource *)parseAsCompositeImageSource:(NSArray *)body;

// try to parse attachments from JSON body
- (NSArray *)parseAsAttachments:(NSArray *)body objectId:(NSString *)objectId;

@end
