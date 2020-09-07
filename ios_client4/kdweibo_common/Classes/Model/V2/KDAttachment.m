//
//  KDAttachment.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-5.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDAttachment.h"
#import "NSData+Additions.h"
#import "KDUtility.h"

@implementation KDAttachment

@synthesize fileId=fileId_;
@synthesize filename=filename_;
@synthesize contentType=contentType_;
@synthesize url=url_;
@synthesize fileSize = fileSize_;

@synthesize objectId=objectId_;
@synthesize attachmentType=attachmentType_;

- (id) init {
    self = [super init];
    if(self){
        fileId_ = nil;
        filename_ = nil;
        contentType_ = nil;
        url_ = nil;
    }
    
    return self;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"{"];
    [string appendFormat:@"\"fileId\" : \"%@\",", fileId_];
    [string appendFormat:@"\"filename\" : \"%@\",", filename_];
    [string appendFormat:@"\"contentType\" : \"%@\",", contentType_];
    [string appendFormat:@"\"url\" : \"%@\",", url_];
    [string appendFormat:@"\"object_id\" : \"%@\"", objectId_];
    [string appendFormat:@"\"attachmetn_type\" : \"%lu\"", (unsigned long)attachmentType_];
    [string appendString:@"}"];
    
    return string;
}



+ (KDAttachment *)attachementByVideoPath:(NSString *)path  entityId:(NSString *)entityId {
    KDAttachment *attachemt = nil;
    if (path && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *theFileId = [data MD5String];
        if (theFileId) {
            attachemt = [[KDAttachment alloc] init];// autorelease];
            attachemt.fileSize = [data length];
            attachemt.fileId = theFileId;
            DLog(@"video id = %@",attachemt.fileId);
            attachemt.filename = [NSString stringWithFormat:@"%@.mp4",attachemt.fileId];
            attachemt.url = [NSString stringWithFormat:@"/filesvr/%@",attachemt.fileId];
            attachemt.objectId = entityId;
            NSString *newPath = [[[KDUtility defaultUtility] searchDirectory:KDVideosDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES] stringByAppendingPathComponent:attachemt.filename];
            
            DLog(@"new Path = %@",newPath);
            [[NSFileManager defaultManager] copyItemAtPath:path toPath:newPath error:NULL];
        }
    }
    return attachemt;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(fileId_);
    //KD_RELEASE_SAFELY(filename_);
    //KD_RELEASE_SAFELY(contentType_);
    //KD_RELEASE_SAFELY(url_);
    //KD_RELEASE_SAFELY(objectId_);
    //[super dealloc];
}

@end
