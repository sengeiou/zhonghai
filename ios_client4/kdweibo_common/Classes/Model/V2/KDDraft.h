//
//  KDDraft.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-4.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDObject.h"
#import <CoreLocation/CoreLocation.h>
//#import "Statement.h"
#import "KDCommentStatus.h"
#import "KDGroupStatus.h"
#import "KDAttachment.h"

enum {
    KDDraftTypeDirectMessage = 0,
    KDDraftTypeNewStatus,
    KDDraftTypeForwardStatus,
    KDDraftTypeCommentForStatus,
    KDDraftTypeCommentForComment,
    KDDraftTypeShareSign
};

typedef NSUInteger KDDraftType;


typedef enum : NSUInteger {
    KDDraftMaskNone = 0,
    KDDraftMaskImages = 1 // has images
}KDDraftMask;


extern NSString * const kKDDraftImageAttachmentPathPropertyKey;
extern NSString * const kKDDraftBlockedPropertyKey;

@interface KDDraft : KDObject {
@private
    NSInteger draftId_;
    KDDraftType type_;
    BOOL saved_;
    
    NSString *authorId_;
    NSDate *creationDate_;
    
    NSString *content_;
    NSString *originalStatusContent_; // the original conetnt of forward status
    
    NSString *commentForStatusId_;
    NSString *commentForCommentId_;
    NSString *groupId_;
    
    NSString *groupName_;
    
    UIImage *image_;
    KDDraftMask mask_;
    
    CGFloat cellHeight_;
    CGRect textBounds_[2];
	
    NSString *address_;
    
    CLLocationCoordinate2D coordinate_;
}

@property (nonatomic, assign) NSInteger draftId;
@property (nonatomic, assign) KDDraftType type;
@property (nonatomic, assign) BOOL saved;

@property (nonatomic, retain) NSString *authorId;
@property (nonatomic, retain) NSDate *creationDate;

@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *originalStatusContent; // the original conetnt of forward status

@property (nonatomic, retain) NSString *commentForStatusId;
@property (nonatomic, retain) NSString *commentForCommentId;
@property (nonatomic, retain) NSString *replyScreenName;    //被回复人得名字
@property (nonatomic, retain) NSString *forwardedStatusId; //转发的statusId
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, strong) UIImage *groupImage;
@property (nonatomic ,retain) NSString *groupName;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy)   NSArray *assetURLs; //存放当前Image的Asset路径
@property (nonatomic, assign) NSInteger uploadIndex; //已上传的图片在images中的索引
@property (nonatomic, retain) NSMutableArray *uploadedImages; //存放已上传的图片的服务端id
@property (nonatomic, retain) NSString *videoPath; 
@property (nonatomic, assign) KDDraftMask mask;
@property (nonatomic, assign, getter = isSending) BOOL sending;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BOOL doExtraCommentOrForward; //当转发的时候是否同时给予评论 或者 当回复的时候时候同时转发

@property (nonatomic, copy)NSString *address;

@property (nonatomic, assign)CLLocationCoordinate2D coordinate;

- (id)initWithType:(KDDraftType)type;
+ (id)draftWithType:(KDDraftType)type;

- (NSData *)imageAttachmentAsJPEGData;
- (NSString *)getCreationDateAsString;

- (KDDraftMask)realMask;
- (BOOL)hasImages;
- (BOOL)hasVideo;

- (CGFloat) getRowHeight;
- (CGRect) textBoundsByType:(int)type;

- (void)resetUploadFlag;

- (BOOL)hasLoationInfo;

//通过草稿创建的待上传的status
- (KDStatus *)sendingStatus:(NSArray *)imageSources videoPath:(NSString *)path;

@end
