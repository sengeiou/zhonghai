//
//  KDDMThreadParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDDMThreadParser.h"
#import "KDDMThread.h"

#import "KDManagerContext.h"
#import "KDParserManager.h"
#import "KDUtility.h"

@implementation KDDMThreadParser

- (NSArray *)_parseParticipantAvatarURLs:(NSArray *)avatarURLs isPublic:(BOOL)isPublic {
    NSMutableArray *items = nil;
    NSUInteger count = [avatarURLs count];
    if (count > 0) {
        if (count > 0x04) {
            count = 0x04;
            avatarURLs = [avatarURLs subarrayWithRange:NSMakeRange(0, 0x04)];
        }
        
        items = [NSMutableArray arrayWithCapacity:count];
        
        NSString *tinyAvatarSuffix = [[KDUtility defaultUtility] isHighResolutionDevice] ? @"&spec=50" : @"&spec=25";
        
        NSString *avatarURL = nil;
        NSString *suffix = isPublic ? tinyAvatarSuffix : @"&spec=180";
        for (NSString *item in avatarURLs) {
            avatarURL = [item stringByAppendingString:suffix];
            [items addObject:avatarURL];
        }
    }
    
    return items;
}

- (void)_formatThreadSubject:(KDDMThread *)t defaultSubject:(NSString *)defaultSubject
                   recipient:(NSDictionary *)recipient sender:(NSDictionary *)sender {
    
    NSString *subject = defaultSubject;
    
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    if (!t.isPublic) {
        NSDictionary *userInfo = nil;
        if (t.participantsCount > 1 && ![userManager isCurrentUserId:[recipient stringForKey:@"id"]]) {
            userInfo = recipient;
            
        } else {
            userInfo = sender;
        }
        
        t.subject = [userInfo stringForKey:@"screen_name"];
        
    } else {
        NSString *temp = (subject != nil) ? subject : NSLocalizedString(@"DM_MULTIPLE_SHORT_MAIL", @"");
        if (t.participantsCount > 0) {
            temp = [NSString stringWithFormat:NSLocalizedString(@"DM_THREAD_TITLE_%@_%d_PERSONS", @""), temp, t.participantsCount];
        }
        
        t.subject = temp;
    }
}

- (NSArray *)parseTop:(NSArray *)body
{
    NSArray *result = [self parse:body];
    for (KDDMThread *thread in result) {
        if ([thread isKindOfClass:[KDDMThread class]]) {
            thread.isTop = YES;
        }
    }
    return result;
}

- (NSArray *)parse:(NSArray *)body {
    NSUInteger count = 0;
    if (body == nil || (count = [body count]) == 0) return nil;
    
    NSMutableArray *threads = [NSMutableArray arrayWithCapacity:count];
    
    KDDMThread *t = nil;
    for(NSDictionary *item in body){
        t = [[KDDMThread alloc] init];
        
        t.threadId = [item stringForKey:@"id"];
        
        t.createdAt = [[item ASCDatetimeForKey:@"create_at"] timeIntervalSince1970];
        t.updatedAt = [[item ASCDatetimeWithMillionSecondsForKey:@"update_at"] timeIntervalSince1970];
        
        t.unreadCount = [item intForKey:@"unread" defaultValue:0];
        t.isPublic = [[item stringForKey:@"multi"] boolValue];
        t.participantsCount = [item integerForKey:@"participantCount" defaultValue:0];
        
        NSArray *photos = [item objectNotNSNullForKey:@"participants_photo"];
        t.participantAvatarURLs = [self _parseParticipantAvatarURLs:photos isPublic:t.isPublic];
        
        NSDictionary *dmBody = [item objectNotNSNullForKey:@"last"];
        t.latestDMId = [dmBody stringForKey:@"id"];
        t.latestDMText = [dmBody stringForKey:@"text"];
        t.latestDMSenderId = [dmBody stringForKey:@"sender_id"];
        t.avatarURL = [dmBody stringForKey:@"composite_avatar"];
        
        t.isTop = NO;

        // parse attchments
        NSArray *pictures = [dmBody objectNotNSNullForKey:@"pictures"];
        NSArray *attachments = [dmBody objectNotNSNullForKey:@"attachment"];
        
        NSUInteger picturesCount = (pictures != nil) ? [pictures count] : 0;
        NSUInteger attachmentsCount = (attachments != nil) ? [attachments count] : 0;
        
        BOOL shareAudio = NO;
        if(attachments.count == 1) {
            NSDictionary *aDic = [attachments objectAtIndex:0];
            NSString *fileName = [aDic objectNotNSNullForKey:@"fileName"];
            if([fileName hasSuffix:@".amr"]) {
                shareAudio = YES;
            }
        }
        
        if(picturesCount > 0 || attachmentsCount > 0){
            NSMutableString *extensions = [NSMutableString stringWithString:@" "];
            if(picturesCount > 0){
                [extensions appendFormat:NSLocalizedString(@"DM_%d_PHOTOS", @""), picturesCount];
            }
            
            if(shareAudio) {
                [extensions appendString:NSLocalizedString(@"DM_SHARE_AUDIO", @"")];
            }else if(attachmentsCount > 0){
                if(picturesCount > 0){
                    [extensions appendString:@" "];
                }
                
                [extensions appendFormat:NSLocalizedString(@"DM_%d_DOCUMENTS", @""), attachmentsCount];
            }
            
            t.latestDMText = [t.latestDMText stringByAppendingString:extensions];
        }
        
        NSDictionary *recipient = [dmBody objectNotNSNullForKey:@"recipient"];
        NSDictionary *sender = [dmBody objectNotNSNullForKey:@"sender"];
        if (sender) {
            KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
            t.latestSender = [parser parseAsSimple:sender];
        }
        
        NSString *subject = [item stringForKey:@"subject"];
        [self _formatThreadSubject:t defaultSubject:subject recipient:recipient sender:sender];
        
        [threads addObject:t];
       // [t release];
    }
    
    return threads;
}

- (KDDMThread *)parseSingle:(NSDictionary *)item {
    KDDMThread * t = [[KDDMThread alloc] init];
    
    t.threadId = [item stringForKey:@"id"];
    
    t.createdAt = [[item ASCDatetimeForKey:@"create_at"] timeIntervalSince1970];
    t.updatedAt = [[item ASCDatetimeWithMillionSecondsForKey:@"update_at"] timeIntervalSince1970];
    
    t.unreadCount = [item intForKey:@"unread" defaultValue:0];
    t.isPublic = [[item stringForKey:@"multi"] boolValue];
    t.participantsCount = [item integerForKey:@"participantCount" defaultValue:0];
    
    NSArray *photos = [item objectNotNSNullForKey:@"participants_photo"];
    t.participantAvatarURLs = [self _parseParticipantAvatarURLs:photos isPublic:t.isPublic];
    
    NSDictionary *dmBody = [item objectNotNSNullForKey:@"last"];
    t.latestDMId = [dmBody stringForKey:@"id"];
    t.latestDMText = [dmBody stringForKey:@"text"];
    t.latestDMSenderId = [dmBody stringForKey:@"sender_id"];
    t.avatarURL = [dmBody stringForKey:@"composite_avatar"];
    
    // parse attchments
    NSArray *pictures = [dmBody objectNotNSNullForKey:@"pictures"];
    NSArray *attachments = [dmBody objectNotNSNullForKey:@"attachment"];
    
    NSUInteger picturesCount = (pictures != nil) ? [pictures count] : 0;
    NSUInteger attachmentsCount = (attachments != nil) ? [attachments count] : 0;
    
    BOOL shareAudio = NO;
    if(attachments.count == 1) {
        NSDictionary *aDic = [attachments objectAtIndex:0];
        NSString *fileName = [aDic objectNotNSNullForKey:@"fileName"];
        if([fileName hasSuffix:@".amr"]) {
            shareAudio = YES;
        }
    }
    
    if(picturesCount > 0 || attachmentsCount > 0){
        NSMutableString *extensions = [NSMutableString stringWithString:@" "];
        if(picturesCount > 0){
            [extensions appendFormat:NSLocalizedString(@"DM_%d_PHOTOS", @""), picturesCount];
        }
        
        if(shareAudio) {
            [extensions appendString:NSLocalizedString(@"DM_SHARE_AUDIO", @"")];
        }else if(attachmentsCount > 0){
            if(picturesCount > 0){
                [extensions appendString:@" "];
            }
            
            [extensions appendFormat:NSLocalizedString(@"DM_%d_DOCUMENTS", @""), attachmentsCount];
        }
        
        t.latestDMText = [t.latestDMText stringByAppendingString:extensions];
    }
    
    NSDictionary *recipient = [dmBody objectNotNSNullForKey:@"recipient"];
    NSDictionary *sender = [dmBody objectNotNSNullForKey:@"sender"];
    if (sender) {
        KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
        t.latestSender = [parser parseAsSimple:sender];
    }
    
    NSString *subject = [item stringForKey:@"subject"];
    [self _formatThreadSubject:t defaultSubject:subject recipient:recipient sender:sender];

    return t;//;/ autorelease];
}

@end
