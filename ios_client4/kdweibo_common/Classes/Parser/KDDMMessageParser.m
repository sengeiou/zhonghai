//
//  KDDMMessageParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDDMMessageParser.h"
#import "KDDMMessage.h"

#import "KDParserManager.h"

@implementation KDDMMessageParser

- (KDDMMessage *)parseAsDMMessage:(NSDictionary *)body {
    if (body == nil || ([body count]) == 0) return nil;
    
    KDDMMessage *m = [[KDDMMessage alloc] init];// autorelease];
    
    m.messageId = [body stringForKey:@"id"];
    
    m.isSystemMessage = [body boolForKey:@"system"];
    m.threadId = [body stringForKey:@"thread_id"];
    m.unread = [body boolForKey:@"unread"];
    m.latitude = [body floatForKey:@"latitude"];
    m.longitude = [body floatForKey:@"longitude"];
    m.address = [body stringForKey:@"address"];

    NSString *message = [body stringForKey:@"text"];
    
    if (m.isSystemMessage) {
        NSString *senderName = [body stringForKey:@"sender_screen_name"];
        message = [NSString stringWithFormat:NSLocalizedString(@"DM_SYSTEM_MESSAGE_%@_%@_JOINED_SESSION", nil), senderName, message];
    }
    
    m.message = message;
    m.messageState = KDDMMessageStateSended;
    m.createdAt = [[body ASCDatetimeForKey:@"created_at"] timeIntervalSince1970];
    
    KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
    
    NSDictionary *sender = [body objectNotNSNullForKey:@"sender"];
    if (sender != nil) {
        m.sender = [parser parseAsSimple:sender];
    }
    
    NSDictionary *recipient = [body objectNotNSNullForKey:@"recipient"];
    if (recipient != nil) {
        m.recipient = [parser parseAsSimple:recipient];
    }

    
    [self _parseExtraSource:body to:m];
    
    return m;
}

- (NSArray *)parseAsDMMessageList:(NSArray *)bodyList {
    NSUInteger count = 0;
    if (bodyList == nil || (count = [bodyList count]) == 0) return nil;
    
    KDDMMessage *m = nil;
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:count];
    
    for (NSDictionary *body in bodyList) {
        m = [self parseAsDMMessage:body];
        if (m != nil) {
            [messages addObject:m];
        }
    }
    
    return messages;
}

- (void)_parseExtraSource:(NSDictionary *)body to:(KDDMMessage *)message {
    // pictures
    NSArray *pictures = [body objectNotNSNullForKey:@"pictures"];
    KDCompositeImageSource *cis = [super parseAsCompositeImageSource:pictures];
    if (cis != nil && [cis hasImageSource]) {
        cis.entity = message;
        message.compositeImageSource = cis;
        
        // mark as images flag
        message.extraSourceMask |= KDExtraSourceMaskImages;
        for (KDImageSource *imageSource in cis.imageSources) {
            imageSource.entityId = message.messageId;
        }
    }
    
    // attachments
    NSArray *items = [body objectNotNSNullForKey:@"attachment"];
    NSArray *attachments = [super parseAsAttachments:items objectId:message.messageId];
    if (attachments != nil) {
        message.attachments = attachments;
        if (message.attachments != nil) {
            // mark as documents flag
            message.extraSourceMask |= KDExtraSourceMaskDocuments;
        }
    }
}

@end
