//
//  KDMessageUploadTask.m
//  kdweibo
//
//  Created by Tan yingqi on 13-5-18.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//
#import "KDManagerContext.h"
#import "KDMessageUploadTask.h"
#import "KDDMThread.h"
#import "KDDMMessage.h"
#import "KDImageUploadTask.h"
#import "KDServiceActionInvoker.h"
#import "KDResponseWrapper.h"
#import "KDCache.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"
#import "KDAttachment.h"
#import "KDAudioController.h"

#import "UIImage+Additions.h"

@implementation KDMessageUploadTask {
    BOOL isSendEmail_;
}


- (id)initWithMessage:(KDDMMessage *)message sendEmail:(BOOL)send {
    self = [super init];
    if (self) {
        //
        self.entity = message;
        isSendEmail_ = send;
//        if (message.compositeImageSource) {
//            KDImageUploadTask *dependency = [KDImageUploadTask imageUploadTaskWithImageSourceArray:message.compositeImageSource.imageSources];
//            self.dependency = dependency;
//        }
//        
    }
    return self;
}

- (KDDMMessage *)message {
    return (KDDMMessage *)(self.entity);
}
+(KDMessageUploadTask *)taskWithMessage:(KDDMMessage *)message sendEmail:(BOOL)send {
    KDMessageUploadTask *task = [[KDMessageUploadTask alloc] initWithMessage:message sendEmail:send];
    return task;// autorelease];
}

- (void)main {
    KDDMMessageState state = KDDMMessageStateSending|KDDMMessageStateUnsend;
    self.message.messageState = state;
    
    KDQuery *query = [KDQuery query];
    NSString *actionPath = nil;
    [query setParameter:@"text" stringValue:self.message.message];
    [query  setParameter:@"send_email" booleanValue:isSendEmail_];
    
    NSString *threadId = self.message.threadId;
    
    if ([threadId hasPrefix:@"tempThreadId"]) {
        actionPath = @"/dm/:newMulti" ;
        NSMutableString *IDs = [NSMutableString string];
        
        NSMutableArray *recipients = [NSMutableArray arrayWithArray:[threadId componentsSeparatedByString:@"+"]];
        [recipients removeObjectAtIndex:0];
        NSUInteger count = [recipients count];
        NSUInteger idx = 0;
        for (NSString *userId in recipients) {
            [IDs appendString:userId];
            
            if(idx++ != count - 0x01){
                [IDs appendString:@","];
            }
        }
        
        [query setParameter:@"participants" stringValue:IDs];
    }else {
        actionPath = @"/dm/:threadByIdNewMessage";
        [query setProperty:threadId forKey:@"threadId"];
        [query setParameter:@"thread" stringValue:threadId];
    }
    
    NSString *fileUrl = nil;
    if([self.message hasAudio]) {
        fileUrl = [[self.message valueForKeyPath:@"attachments.url"] lastObject];
    }else {
        KDCompositeImageSource *cis = [self.message compositeImageSource];
        KDImageSource *imageSource = [[cis imageSources] lastObject];
        fileUrl = imageSource.thumbnail;
    }

    if(fileUrl) {
        [query setProperty:@(YES) forKey:@"hasAttachments"];
        [query setParameter:@"pic" filePath:fileUrl];
    }else {
        [query setProperty:@(NO) forKey:@"hasAttachments"];
    }

    if([self.message hasLocationInfo]) {
        [query setParameter:@"long" floatValue:self.message.longitude];
        [query setParameter:@"lat" floatValue:self.message.latitude];
        [query setParameter:@"address" stringValue:self.message.address];
    }
    
    __block KDMessageUploadTask *task = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
       if([response isValidResponse]){
           NSLog(ASLocalizedString(@"发送成功..."));
           KDDMMessage *dm = (KDDMMessage *)results;

           NSArray *attachments = dm.attachments;
           if (dm) {
               KDAttachment *att = [attachments lastObject];
               KDAttachment *attOrigin = [task.message.attachments lastObject];
               KDImageSource *imageSource = [[[task.message compositeImageSource] imageSources] lastObject];
               if([self.message hasAudio]) {//音频
                   [[KDAudioController sharedInstance] didSendAudioWithPath:attOrigin.url asAttachment:att.fileId];

               }else if(imageSource){ //图片
                   UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageSource.thumbnail]];
                   
                   //移除之前存进去的
                   NSFileManager *fileManager = [NSFileManager defaultManager];
                   NSString *cacheKey = [KDCache cacheKeyForURL:imageSource.thumbnail];
                   [fileManager removeItemAtPath:[KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:KDCacheImageTypePreview] error:NULL];
                   [fileManager removeItemAtPath:[KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:KDCacheImageTypeOrigin] error:NULL];
                   [fileManager removeItemAtPath:[KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:KDCacheImageTypePreviewBlur] error:NULL];
                   [fileManager removeItemAtPath:[KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:KDCacheImageTypeMiddle] error:NULL];
                   [fileManager removeItemAtPath:[KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:KDCacheImageTypeThumbnail] error:NULL];
                   
                   NSData *data = [image asJPEGDataWithQuality:kKDJPEGPreviewImageQuality];
                   [[KDCache sharedCache] storeImageData:data forURL:dm.compositeImageSource.bigImageURL imageType:KDCacheImageTypePreview];
                   [[KDCache sharedCache] storeImageData:data forURL:dm.compositeImageSource.bigImageURL imageType:KDCacheImageTypeOrigin];
                   
                   data = [image asJPEGDataWithQuality:kKDJPEGBlurPreviewImageQuality];
                   [[KDCache sharedCache] storeImageData:data forURL:dm.compositeImageSource.bigImageURL imageType:KDCacheImageTypePreviewBlur];
                   
                   data = [image asJPEGDataWithQuality:kKDJPEGThumbnailQuality];
                   [[KDCache sharedCache] storeImageData:data forURL:dm.compositeImageSource.middleImageURL imageType:KDCacheImageTypeMiddle];
                   [[KDCache sharedCache] storeImageData:data forURL:dm.compositeImageSource.thumbnailImageURL imageType:KDCacheImageTypeThumbnail];
                   
                   [fileManager removeItemAtPath:imageSource.thumbnail error:NULL];
               }
           }
           
           __block NSString *oldMessageId = [task.message.messageId copy];
           [KDDatabaseHelper inDatabase:^id(FMDatabase *fmdb) {
               id<KDDMMessageDAO> messageDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
//               [messageDAO saveDMMessages:@[dm] threadId:dm.threadId database:fmdb rollback:NULL];
               if([messageDAO removeUnsendDMMessageWithId:oldMessageId database:fmdb]) {
                   NSLog(ASLocalizedString(@"删除未发送的短邮%@成功"),oldMessageId);
               };
//               [oldMessageId release];
               return nil;
           }completionBlock:NULL];
           [task.message poulatedByMessage:dm];
           [task taskDidSuccess];
           
       }
       else {
           if (![response isCancelled]) {
               id result = [response responseAsJSONObject];
               NSString *errorMessage = NSLocalizedString(@"DM_SEND_DIRECT_MESSAGE_DID_FAIL", @"");
               
               if (result) {
                   NSInteger code = [result integerForKey:@"code"];
                 
                   if (code == 40006 ) {
                       errorMessage = NSLocalizedString(@"NO_IDENTICAL_DM_IN_TRHEE_MIN", @"");
                   }
                   else{
                       NSString *message = [(NSDictionary *)result objectForKey:@"message"];
                       NSRange range = [message rangeOfString:ASLocalizedString(@"KDMessageUploadTask_sms_unavailable")];
                       if (range.location !=NSNotFound) {
                           errorMessage = ASLocalizedString(@"KDMessageUploadTask_sms_unavailable2");
                       } else {
                           errorMessage = message;
                       }

                   }
               }
               
               [task taskDisFailed:errorMessage];
           }
           else { //  被取消
               [self taskDidCanceled];
           }
           DLog(@"responseString = %@",[response responseDiagnosis]);
       }
//        [task release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];

}

- (void)startTask {
    [super startTask];
}

- (void)taskDisFailed:(NSString *)errorMessage {
    KDDMMessageState state = self.message.messageState;
    state|=KDDMMessageStateUnsend;
    state = state&~KDDMMessageStateSending;
    self.message.messageState = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskFailed" object:nil userInfo:@{@"entity": self.message, @"errorMsg" : errorMessage}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"messageTaskFinished" object:self userInfo:@{@"message":self.message,@"isSuccess":@(NO), @"errorMsg":errorMessage}];
    
    [[[KDManagerContext globalManagerContext] unreadManager] start:NO]; //为了更新左侧边栏的警告标记
    [super taskDisFailed];
}

- (void)taskDidSuccess {
    
    KDDMMessageState state = self.message.messageState;
    state|=KDDMMessageStateSended;
    state = state&~KDDMMessageStateSending;
    self.message.messageState = state;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskFinished" object:nil userInfo:@{@"entity": self.message}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"messageTaskFinished" object:self userInfo:@{@"message":self.message,@"isSuccess":@(YES)}];
    
    [[[KDManagerContext globalManagerContext] unreadManager] start:NO]; //为了更新左侧边栏的警告标记
    [super taskDidSuccess];
    
}

- (void)cancel{
    [KDServiceActionInvoker cancelInvokersWithSender:self];
    [super cancel];
}

- (void)dealloc {

    //[super dealloc];
}
@end
