//
//  KDAttachmentParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDAttachmentParser.h"

#import "KDAttachment.h"

@implementation KDAttachmentParser

- (NSArray *)parse:(NSArray *)body objectId:(NSString *)objectId {
    NSUInteger count = 0;
    if (body == nil || (count = [body count]) == 0) return nil;
    
    NSMutableArray *attachments = [NSMutableArray arrayWithCapacity:count];
    KDAttachment *obj = nil;
    for(NSDictionary *item in body){
        obj = [[KDAttachment alloc] init];
        
        obj.objectId = objectId;
        
        obj.fileId = [item stringForKey:@"fileId"];
        obj.filename = [item stringForKey:@"fileName"];
        obj.contentType = [item stringForKey:@"contentType"];
        obj.url = [item stringForKey:@"url"];
        obj.fileSize = [item int64ForKey:@"fileSize"];
        
        [attachments addObject:obj];
//        [obj release];
    }
    
    return attachments;
}

@end
