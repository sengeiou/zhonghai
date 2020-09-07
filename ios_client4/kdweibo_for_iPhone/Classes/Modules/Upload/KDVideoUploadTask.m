//
//  KDVideoUploadTask.m
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-16.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDVideoUploadTask.h"
#import "KDUtility.h"

@implementation KDVideoUploadTask
@synthesize attachment = attachement_;

+ (KDVideoUploadTask *)videoUploadTaskWithAttachements:(NSArray *)attachements{
    if (!attachements || [attachements count] == 0) {
        return nil;
    }
    KDVideoUploadTask *task = [[KDVideoUploadTask alloc] init];// autorelease];
        KDVideoUploadTask *subTask = nil;
        for (KDAttachment * attachement in attachements) {
            subTask = [[KDVideoUploadTask alloc] init];// autorelease];
            subTask.attachment = attachement;
            [task addSubTask:subTask];
    }
    return task;
}

- (NSString *)uploadingDocPath {
    if (!self.attachment) {
        return nil;
    }
    if (!uploadingDocPath_) {
        uploadingDocPath_ = [[[[KDUtility defaultUtility] searchDirectory:KDVideosDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES] stringByAppendingPathComponent:self.attachment.filename] copy];
    }
    return uploadingDocPath_;
}

- (void)taskDidSuccess {
    if (!self.subTasks) {
       
        NSString *newFileName = [NSString stringWithFormat:@"%@.mp4",self.fetchedFileId];
        NSString *toPath = [[[KDUtility defaultUtility] searchDirectory:KDVideosDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES] stringByAppendingPathComponent:newFileName];
        
        [[NSFileManager defaultManager] moveItemAtPath:self.uploadingDocPath toPath:toPath error:NULL];
    }
    
    [super taskDidSuccess];
}

- (NSString *)documentType {
    return ASLocalizedString(@"KDVideoUploadTask_Video");
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(attachement_);
    //[super dealloc];
}
@end
