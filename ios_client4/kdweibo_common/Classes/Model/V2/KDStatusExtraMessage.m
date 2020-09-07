//
//  KDStatusExtraMessage.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-4.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusExtraMessage.h"

#import "NSDictionary+Additions.h"
#import "NSDate+Additions.h"

NSString * const kKDStatusExtraMessageConnector = @"connector";
NSString * const kKDStatusExtraMessageVote = @"vote";
NSString * const kKDStatusExtraMessagePraise = @"praise";
NSString * const kKDStatusExtraMessageBulletin = @"bulletin";
NSString * const kKDStatusExtraMessageFreshman = @"freshman";
NSString * const kKDStatusExtraMessageTask = @"TaskNew";

NSString * const kKDStatusExtraMessageProperties = @"properties";
NSString * const kKDStatusExtraMessageTemporaryProperties = @"temporaryProperties";


@implementation KDStatusExtraMessage

@synthesize extraId=extraId_;
@synthesize applicationURL=applicationURL_;
@synthesize type=type_;
@synthesize referenceId=referenceId_;
@synthesize tenantId=tenantId_;
@synthesize exectorId = exectorId_;
@synthesize exctorName = exctorName_;
@synthesize content = content_;


- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (BOOL)isConnector {
    return [type_ isEqualToString:kKDStatusExtraMessageConnector];
}

- (BOOL)isVote {
    return [type_ isEqualToString:kKDStatusExtraMessageVote];
}

- (BOOL)isPraise {
    return [type_ isEqualToString:kKDStatusExtraMessagePraise];
}

- (BOOL)isFreshman {
    return [type_ isEqualToString:kKDStatusExtraMessageFreshman];
}

- (BOOL)isBulletin {
    return [type_ isEqualToString:kKDStatusExtraMessageBulletin];
}
- (BOOL)isTask {
     return [type_ isEqualToString:kKDStatusExtraMessageTask];
}
- (BOOL)isExectorUser:(NSString*)userId {
    BOOL is = NO;
    NSLog(@"exetorId_ = %@",exectorId_);
    NSLog(@"userId = %@",userId);
    if (exectorId_) {
        NSArray *userIds = [exectorId_ componentsSeparatedByString:@","];
        for (NSString *item in userIds) {
            if ([userId isEqual:item]) {
                is = YES;
                break;
            }
        }
    }
    return is;
    
}

- (BOOL)shouldShowTaskDetail:(NSString*)userId {
    return [self isTask] && [self isExectorUser:userId];
}
//////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Utlity methods

// TODO: please change it in the future
// 仅简单格式化要显示的内容, 以后再重构这些内容。
+ (NSString *)formatPraiseContent:(NSString *)content message:(KDStatusExtraMessage *)message {
    NSMutableString *builder = [NSMutableString string];
    [builder appendString:NSLocalizedString(@"PRAISE_TO", @"")];
    
    NSDictionary *props = [message propertyForKey:kKDStatusExtraMessageProperties];
    if (props) {
        NSString *usernames = [props stringForKey:@"userNames"];
        usernames = [usernames stringByReplacingOccurrencesOfString:@";" withString:@" "];
        
        // 由于 userNames 属性是后期加入的，所以前期建立的表扬数据，不存在该属性。
        if (usernames != nil) {
            [builder appendString:usernames];
            [builder appendString:@"\n"];
        }
    }
    
    [builder appendString:content];
    
    return builder;
}

+ (NSString *)formatFreshmanContent:(NSString *)content message:(KDStatusExtraMessage *)message {
    NSMutableString *builder = [NSMutableString string];
    [builder appendString:content];
    
    NSDictionary *props = [message propertyForKey:kKDStatusExtraMessageProperties];
    if (props) {
        NSString *usernames = [props stringForKey:@"userNames"];
        if(usernames) {
            [builder appendString:usernames];
        }
    }
    
    return builder;
}

+ (NSString *)formatBulletinContent:(NSString *)content message:(KDStatusExtraMessage *)message {
    NSMutableString *builder = [NSMutableString string];
    NSDictionary *props = [message propertyForKey:kKDStatusExtraMessageProperties];
    if (props) {
        NSString *title = [props stringForKey:@"title"];
        [builder appendFormat:@"【%@】", title];
    }
    
    [builder appendString:content];
    
    return builder;
}

+(NSString *)formateTask:(NSString *)content message:(KDStatusExtraMessage *)message {
    NSMutableString *builder =[NSMutableString string];
    NSDictionary *props = [message propertyForKey:kKDStatusExtraMessageProperties];
    if (props) {
        NSString *date = nil;
        NSString *content = nil;
        NSString *excutor = nil;
        NSDate *excuteDate = [props ASCDatetimeWithMillionSecondsForKey:@"needFinishDate" ];
        if (excuteDate) {
            date = [excuteDate formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER];
        }
        content = [props stringForKey:@"content"];
        excutor = [props stringForKey:@"userName"];
        
        if (date &&content&&excutor) {
            [builder appendFormat:ASLocalizedString(@"KDStatus_title"),content,excutor,date];
        }
        
    }
    [builder insertString:[NSString stringWithFormat:@"%@",content] atIndex:0];
    return builder;
}
+ (NSString *)formatExtraMessage:(KDStatusExtraMessage *)message appendToContent:(NSString *)content {
    NSString *body = nil;
    if ([message isPraise]) {
        body = [KDStatusExtraMessage formatPraiseContent:content message:message];
        
    } else if ([message isBulletin]) {
        body = [KDStatusExtraMessage formatBulletinContent:content message:message];
        
    } else if([message isFreshman]) {
        body = [KDStatusExtraMessage formatFreshmanContent:content message:message];
    }
    
    return body;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(extraId_);
    //KD_RELEASE_SAFELY(applicationURL_);
    //KD_RELEASE_SAFELY(type_);
    //KD_RELEASE_SAFELY(referenceId_);
    //KD_RELEASE_SAFELY(tenantId_);
    //KD_RELEASE_SAFELY(exectorId_);
    //KD_RELEASE_SAFELY(exctorName_);
    //KD_RELEASE_SAFELY(content_);
    //[super dealloc];
}

@end
