//
//  KDAttachmentParser.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"

@interface KDAttachmentParser : KDBaseParser

- (NSArray *)parse:(NSArray *)body objectId:(NSString *)objectId;

@end
