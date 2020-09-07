//
//  KDAttachment.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-5.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDTypeDefination.h"
#import "KDCommon.h"

enum {
    KDAttachmentTypeStatus = KDDataTypeStatus,
    KDAttachmentTypeComment = KDDataTypeComment,
    KDAttachmentTypeDirectMessage = KDDataTypeDirectMessage,
};

typedef NSUInteger KDAttachmentType;


@interface KDAttachment : NSObject {
 @private
    NSString *fileId_;
    NSString *filename_;
    NSString *contentType_;
    NSString *url_;
    KDInt64 fileSize_;
    
    NSString *objectId_;
    KDAttachmentType attachmentType_;
}

@property(nonatomic, retain) NSString *fileId;
@property(nonatomic, retain) NSString *filename;
@property(nonatomic, retain) NSString *contentType;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, assign) KDInt64 fileSize;

@property(nonatomic, retain) NSString *objectId;
@property(nonatomic, assign) KDAttachmentType attachmentType;
+ (KDAttachment *)attachementByVideoPath:(NSString *)path entityId:(NSString *)entityId;

@end
