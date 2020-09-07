//
//  KDStatus.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-4.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatus.h"
#import "KDCache.h"
#import "KDAttachment.h"

#import "NSDate+Additions.h"
#import "KDUtility.h"

NSString * const kKDHasBeenDeletedStatusId = @"-1";

@implementation KDStatus

@synthesize statusId=statusId_;
@synthesize text=text_;
@synthesize author=author_;

@synthesize groupId=groupId_;
@synthesize groupName=groupName_;

@synthesize createdAt=createdAt_;
@synthesize updatedAt=updatedAt_;

@synthesize source=source_;

@synthesize latitude=latitude_;
@synthesize longitude=longitude_;
@synthesize address = address_;

@synthesize favorited=favorited_;
@synthesize truncated=truncated_;
@synthesize isPrivate=isPrivate_;

@synthesize commentsCount=commentsCount_;
@synthesize forwardsCount=forwardsCount_;
@synthesize likedCount = likedCount_;

@synthesize forwardedStatus=forwardedStatus_;
@synthesize extendStatus=extendStatus_;

@synthesize extraMessage=extraMessage_;

@synthesize compositeImageSource=compositeImageSource_;
@synthesize attachments=attachments_;

@synthesize type=type_;
@synthesize extraSourceMask=extraSourceMask_;

@synthesize replyStatusId=replyStatusId_;
@synthesize replyUserId=replyUserId_;
@synthesize replyScreenName=replyScreenName_;

//@synthesize delData = delData_;

- (id)init {
    self = [super init];
    if (self) {
        extraSourceMask_ = KDExtraSourceMaskNone;
    }
    
    return self;
}

- (BOOL)hasExtraImageSource {
    BOOL flag = NO;
    if (compositeImageSource_ != nil && [compositeImageSource_ hasImageSource]) {
        flag = YES;
        
    } else {
        KDExtendStatus *es = self.extendStatus;
        if (es != nil) {
            flag = es.compositeImageSource != nil && [es.compositeImageSource hasImageSource];
        }
    }
    if (flag) return flag;
    return (self.forwardedStatus != nil) ? [self.forwardedStatus hasExtraImageSource] : NO;
}

- (KDCompositeImageSource *)actuallyCompositeImageSourceAndType:(NSUInteger *)type {
    NSUInteger layer = 0x00;
    KDCompositeImageSource *target = nil;
    KDCompositeImageSource *temp = compositeImageSource_;
    if (temp != nil && [temp hasImageSource]) {
        layer = 0x01;
        target = temp;
        
    } else {
        KDStatus *fs = self.forwardedStatus;
        KDExtendStatus *es = self.extendStatus;
        if (fs != nil) {
            temp = fs.compositeImageSource;
            if (temp != nil && [temp hasImageSource]) {
                layer = 0x02;
                target = temp;
            }
            
            if (target == nil && fs.extendStatus != nil) {
                es = fs.extendStatus;
            }
        }
        
        if (es != nil) {
            temp = es.compositeImageSource;
            if (temp != nil && [temp hasImageSource]) {
                layer = (fs != nil) ? 0x03 : 0x02;
                target = temp;
            }
        }
    }
    
    if (target != nil && type != NULL) {
        *type = layer;
    }
    
    return target;
}

- (CGSize)middleImageSize {
    NSString *cacheKey = [self.compositeImageSource cacheKeyForImageSourceURL:[self.compositeImageSource middleImageURL]];
    UIImage *image = [[KDCache sharedCache] imageForCacheKey:cacheKey imageType:KDCacheImageTypeMiddle];
    
    BOOL useDefault = NO;
    if(image == nil) {
        useDefault = YES;
        // load default image as placeholder
        image = [UIImage imageNamed:@"image_placeholder.png"];
    }
    
    // for high resolution device, Just think the normal image also display like UIImage with @2x
    CGSize size = image.size;
    if(!useDefault && [UIScreen mainScreen].scale + 0.01 > 2.0){
        size.width *= 0.5;
        size.height *= 0.5;
    }
    
    return size;
}

- (BOOL)hasForwardedStatus {
    return forwardedStatus_ != nil;
}

//@modify-time:2013年11月11日10:20:44
//@modify-by:shenkuikui
//@modify-reason:逻辑错误
- (BOOL)hasAttachments {
    BOOL flag = (attachments_ != nil && [attachments_ count] > 0 && ![self hasVideo]);
    return flag;
}

- (BOOL)hasVideo {
    BOOL flag =  (attachments_ != nil && [attachments_ count] == 1 && [((KDAttachment *)[attachments_ objectAtIndex:0]).filename hasSuffix:@".mp4"] && [self.compositeImageSource.imageSources count] == 1);
    return flag;
}

- (BOOL)hasBeenDeleted {
    return [kKDHasBeenDeletedStatusId isEqualToString:statusId_];
}

- (BOOL)hasAddress {
    return (!KD_IS_BLANK_STR(address_));
}

- (BOOL)isGroup {
    return (!KD_IS_BLANK_STR(groupId_));
}

- (NSString *)id_ {
    return self.statusId;
}

- (NSString *)taskFormatContet{
    NSString *result = self.text ;
    if (self.extraMessage && [self.extraMessage isTask]) {
        KDStatusExtraMessage *extraMsg = self.extraMessage;
//        NSDate *needFinishDate = [NSDate dateWithTimeIntervalSince1970:extraMsg.needFinishDate];
//        NSString *dateStr = [needFinishDate formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER];
//        NSString *excutors = extraMsg.exctorName;
       
//        
//        NSMutableString *builder =[NSMutableString string];
//        if (content) {
//            [builder appendFormat:ASLocalizedString(@"KDStatus_title"),content,excutors,dateStr];
//        }
//         [builder insertString:[NSString stringWithFormat:@"%@",result] atIndex:0];
//         result = builder;
        result = result?result:@"";
        NSString *taskFormate = [super propertyForKey:@"taskFormate"];
        if (taskFormate == nil) {
           NSString *content = extraMsg.content;          
           if (content) {
               taskFormate = [result stringByAppendingFormat:@"\n\n %@",content];
               [super setProperty:taskFormate forKey:@"taskFormate"];
          }
        }
         result = taskFormate;
    }
    return result;
}

#define KD_STATUS_PROP_CREATED_AT_KEY   @"created_at_str"

- (NSString *)createdAtDateAsString {
    NSString *prop = [super propertyForKey:KD_STATUS_PROP_CREATED_AT_KEY];
    if (prop == nil) {
        prop = [NSDate formatMonthOrDaySince1970WithDate:self.createdAt];
        
        if (prop != nil) {
            [super setProperty:prop forKey:KD_STATUS_PROP_CREATED_AT_KEY];
        }
    }
    
    return prop;
}

- (void)updateSendingProgress:(NSNotification *)nofitifation
{
    NSDictionary *info = nofitifation.object;
    NSNumber *progress = [info objectForKey:@"progress"];
    NSString *statusId = [info objectForKey:@"statusId"];
    if ([self.statusId isEqualToString:statusId]) {
        self.sendingProgress = [progress floatValue];
    }
}

- (BOOL)hasTask {
    return  ([self.extraMessage shouldShowTaskDetail:[[KDUtility defaultUtility] currentUserId]]||([[KDUtility defaultUtility] isMyStatus:self] && [self.extraMessage isTask]));
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(statusId_);
    //KD_RELEASE_SAFELY(text_);
    //KD_RELEASE_SAFELY(author_);
    
    //KD_RELEASE_SAFELY(groupId_);
    //KD_RELEASE_SAFELY(groupName_);
    
    //KD_RELEASE_SAFELY(createdAt_);
    //KD_RELEASE_SAFELY(updatedAt_);
    
    //KD_RELEASE_SAFELY(source_);
    
    //KD_RELEASE_SAFELY(forwardedStatus_);
    //KD_RELEASE_SAFELY(extendStatus_);
    
    //KD_RELEASE_SAFELY(extraMessage_);
    //KD_RELEASE_SAFELY(compositeImageSource_);
    //KD_RELEASE_SAFELY(attachments_);
    
    //KD_RELEASE_SAFELY(address_);
    
    //KD_RELEASE_SAFELY(replyStatusId_);
    //KD_RELEASE_SAFELY(replyUserId_);
    //KD_RELEASE_SAFELY(replyScreenName_);
//    //KD_RELEASE_SAFELY(delData_)
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //[super dealloc];
}

@end
