//
//  KDExtendStatusParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDExtendStatusParser.h"
#import "KDExtendStatus.h"

#import "KDUtility.h"
#import "NSString+Additions.h"

@implementation KDExtendStatusParser

- (KDExtendStatus *)parse:(NSDictionary *)body {
    if (body == nil || [body count] == 0) return nil;
    
    KDExtendStatus *s = [[KDExtendStatus alloc] init];// autorelease];
    
    s.statusId = [body stringForKey:@"id"];
    
    NSDictionary *props = [body objectNotNSNullForKey:@"properties"];
    
    s.site = [props stringForKey:@"site"];
    s.content = [props stringForKey:@"content"];
    s.senderName = [props stringForKey:@"senderName"];
    
    NSString *thumbnail = [props stringForKey:@"thumbnail"];
    NSString *middle = [props stringForKey:@"middle"];
    NSString *original = [props stringForKey:@"original"];
    
    s.createdAt = KD_PARSER_MILLISECOND_TO_SECONDS([props uint64ForKey:@"sendTime"]);
    
    id forwardedSendTime = [props objectNotNSNullForKey:@"forwardedSendTime"];
    if(forwardedSendTime != nil) {
        s.forwardedAt = KD_PARSER_MILLISECOND_TO_SECONDS([props uint64ForKey:@"forwardedSendTime"]);
        s.forwardedSenderName = [props stringForKey:@"forwardedSenderName"];
        s.forwardedContent = [props stringForKey:@"forwardedContent"];
        
        thumbnail = [props stringForKey:@"forwardedThumbnail"];
        middle = [props stringForKey:@"forwardedMiddle"];
        original = [props stringForKey:@"forwardedOriginal"];
    }
    
    if (thumbnail != nil) {
        s.extraSourceMask |= KDExtraSourceMaskImages;
        
        KDImageSource *imageSource = [[KDImageSource alloc] init];
        imageSource.thumbnail = thumbnail;
        imageSource.middle = middle;
        imageSource.original = original;
        imageSource.fileId = [imageSource.thumbnail MD5DigestKey];
        
        NSArray *items = [NSArray arrayWithObject:imageSource];
//        [imageSource release];
        
        KDCompositeImageSource *cis = [[KDCompositeImageSource alloc] initWithImageSources:items];
        s.compositeImageSource = cis;
//        [cis release];
    }
    
    return s;
}

@end
