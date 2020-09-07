//
//  KDBaseParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"
#import "KDParserManager.h"

@implementation KDBaseParser

- (id)parserWithClass:(Class)clazz {
    return [[KDParserManager globalParserManager] parserWithClass:clazz];
}

- (KDCompositeImageSource *)parseAsCompositeImageSource:(NSArray *)body {
    if (body == nil) return nil;
    
    KDCompositeImageSourceParser *parser = [self parserWithClass:[KDCompositeImageSourceParser class]];
    return [parser parse:body];
}

- (NSArray *)parseAsAttachments:(NSArray *)body objectId:(NSString *)objectId {
    if (body == nil) return nil;
    
    KDAttachmentParser *parser = [self parserWithClass:[KDAttachmentParser class]];
    return [parser parse:body objectId:objectId];
}

@end
