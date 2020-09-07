//
//  KDDraft.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-4.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDDraft.h"

#import "KDManagerContext.h"

#import "NSDate+Additions.h"
#import "UIImage+Additions.h"
#import "KDUtility.h"


NSString * const kKDDraftImageAttachmentPathPropertyKey = @"draftImageAttachment";
NSString * const kKDDraftBlockedPropertyKey = @"blocked";

@implementation KDDraft 

@synthesize draftId=draftId_;
@synthesize type=type_;
@synthesize saved=saved_;

@synthesize authorId=authorId_;
@synthesize creationDate=creationDate_;

@synthesize content=content_;
@synthesize originalStatusContent=originalStatusContent_;

@synthesize commentForStatusId=commentForStatusId_;
@synthesize commentForCommentId=commentForCommentId_;
@synthesize replyScreenName = replyScreenName_;
@synthesize forwardedStatusId = forwardedStatusId_;

@synthesize groupId=groupId_;

@synthesize groupName = groupName_;

@synthesize image=image_;
@synthesize mask=mask_;

@synthesize cellHeight=cellHeight_;

@synthesize address = address_;
@synthesize coordinate = coordinate_;
@synthesize assetURLs = assetURLs_;
@synthesize uploadIndex = uploadIndex_;
@synthesize uploadedImages = uploadedImages_;


- (id)init {
    self = [super init];
    if(self){
        draftId_ = 0;
        type_ = NSUIntegerMax;
        saved_ = NO;
        
        self.authorId = [KDManagerContext globalManagerContext].userManager.currentUserId;
        self.creationDate = [NSDate date];
        
        content_ = nil;
        originalStatusContent_ = nil;
        
        commentForStatusId_ = nil;
        commentForCommentId_ = nil;
        groupId_ = nil;
        
        groupName_ = nil;
        
        image_ = nil;
        mask_ = KDDraftMaskNone;
        
        cellHeight_ = 0.0;
        textBounds_[0] = CGRectZero;
        textBounds_[1] = CGRectZero;
        
        uploadIndex_ = -1;
    }
    
    return self;
}

- (id)initWithType:(KDDraftType)type {
    self = [self init];
    if(self){
        type_ = type;
    }
    
    return self;
}

+ (id)draftWithType:(KDDraftType)type {
    return [[KDDraft alloc] initWithType:type];// autorelease];
}

+ (NSInteger)nextDraftId {
    return (NSInteger)time(NULL);
}

- (NSData *)imageAttachmentAsJPEGData {
    return [image_ asJPEGDataWithQuality:kKDJPEGPreviewImageQuality];
}

- (NSString *)getCreationDateAsString {
    return [NSDate formatMonthOrDaySince1970:[creationDate_ timeIntervalSince1970]];
}

- (NSInteger)draftId {
    if (draftId_ == 0) {
        draftId_ = -(NSInteger)time(NULL);
    }
    
    return draftId_;
}


- (KDDraftMask)realMask {
    KDDraftMask mask = KDDraftMaskNone;
    if ([self.assetURLs count] > 0) {
        mask |= KDDraftMaskImages;
    }
    
    mask_ = mask;
    
    return mask;
}

- (BOOL)hasImages {
    return (mask_ & KDDraftMaskImages) != KDDraftMaskNone;
}

- (BOOL)hasVideo
{
    return _videoPath != nil;
}

- (BOOL)hasLoationInfo {
    return (address_  && address_.length >0);
}

- (CGFloat) getRowHeight {
    if(cellHeight_ < 0.01) {   
        UIFont *font = [UIFont systemFontOfSize:13];
        CGSize textSize = [content_ sizeWithFont:font constrainedToSize:CGSizeMake(300.0, 800.0)];
          
        textBounds_[0] = CGRectMake(18, 33, 292, textSize.height);
        cellHeight_ = textSize.height + 46;
        
        NSString *text = nil;
        
        if(originalStatusContent_.length <= 60)
            text = originalStatusContent_;
        else {
            text = [NSString stringWithFormat:@"%@...", [originalStatusContent_ substringToIndex:59]];
        }
        
        if(self.commentForStatusId != nil) {
            textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(292.0f, 800.0)];
            
            textBounds_[1] = CGRectMake(18, textBounds_[0].size.height+36+10, 292.0f, textSize.height + 20);
            cellHeight_ += textSize.height + 30;
        }
    }
    
    if(self.groupId && [self.groupId length] > 0)
        cellHeight_ += 20.0f;
    
    return cellHeight_;
}

- (CGRect) textBoundsByType:(int)type {
	return textBounds_[type];
}

- (NSMutableArray *)uploadedImages {
    if (!uploadedImages_) {
        uploadedImages_ = [[NSMutableArray alloc] init];
    }
    return uploadedImages_;
}

- (void)resetUploadFlag
{
    uploadIndex_ = -1;
    [uploadedImages_ removeAllObjects];
}

- (KDStatus *)sendingStatus:(NSArray *)imageSources videoPath:(NSString *)path {
    KDStatus *status = nil;
    if (!status) {
        //
        status = [[KDStatus alloc] init];// autorelease];
        status.type = KDTLStatusTypePublic;
        if (self.groupId) {
            status.type = KDTLStatusTypeGroupStatus;
        }
        if (self.type == KDDraftTypeCommentForComment || self.type == KDDraftTypeCommentForStatus) {
            status = [[KDCommentStatus alloc] init];// autorelease];
            status.type = KDTLStatusTypeComment;
            if (self.commentForCommentId && self.commentForStatusId) {
                status.replyStatusId = self.commentForCommentId;
                status.replyScreenName = self.replyScreenName;
                KDStatus *originStatus = [[KDStatus alloc] init];// autorelease];
                originStatus.statusId = self.commentForStatusId;
                [(KDCommentStatus *)status setStatus:originStatus];
                
            }else if(self.commentForStatusId && !self.commentForCommentId) {
                status.replyStatusId = self.commentForStatusId;
            }
            
        }
        else if(self.type == KDDraftTypeForwardStatus) {
            status.type = KDTLStatusTypeForwarded;
            KDStatus *forwardedStastus = [[KDStatus alloc] init];// autorelease];
            forwardedStastus.statusId = self.forwardedStatusId;
            status.forwardedStatus = forwardedStastus;
            
        }else if(self.type == KDDraftTypeShareSign) {
            status.type = KDTLStatusTypeShareSignin;
        }
        status.statusId = [NSString stringWithFormat:@"%ld",(long)self.draftId];
        status.text = self.content;
        status.latitude = self.coordinate.latitude;
        status.longitude = self.coordinate.longitude;
        status.address = self.address;
        status.author = [[[KDManagerContext globalManagerContext] userManager] currentUser];
        status.groupId = self.groupId;
        status.groupName = self.groupName;
        status.createdAt = [NSDate date];
        status.updatedAt = status.createdAt;
        status.source = !KD_IS_IPAD?ASLocalizedString(@"KDDraft_iPhone"):ASLocalizedString(@"KDDraft_iPad");
        KDCompositeImageSource *imageSource = [[KDUtility defaultUtility] compositeImageSourceByLocalImageSources:imageSources];
        
        if (imageSource) {
            status.compositeImageSource = imageSource;
            status.extraSourceMask|= KDExtraSourceMaskImages;
        }
        status.sendingState = KDStatusSendingStateProcessing;
        if (path) {
            KDAttachment *attachement = [KDAttachment attachementByVideoPath:path entityId:status.statusId];
            if (!attachement) {
                DLog(@"KDDraft_NoVideo")
            }else {
                status.attachments = @[attachement];
                status.extraSourceMask|=KDExtraSourceMaskDocuments;
                self.videoPath = [[[KDUtility defaultUtility] searchDirectory:KDVideosDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES] stringByAppendingPathComponent:attachement.filename];
            }
        }
        
    }
    return status;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(authorId_);
    //KD_RELEASE_SAFELY(creationDate_);
    
    //KD_RELEASE_SAFELY(content_);
    //KD_RELEASE_SAFELY(originalStatusContent_);
    
    //KD_RELEASE_SAFELY(commentForStatusId_);
    //KD_RELEASE_SAFELY(commentForCommentId_);
    //KD_RELEASE_SAFELY(replyScreenName_);
    //KD_RELEASE_SAFELY(forwardedStatusId_);
    
    //KD_RELEASE_SAFELY(groupId_);
    //KD_RELEASE_SAFELY(groupName_);
    
    //KD_RELEASE_SAFELY(image_);
    
    //KD_RELEASE_SAFELY(address_);
    
    //KD_RELEASE_SAFELY(assetURLs_);
    
    //KD_RELEASE_SAFELY(uploadedImages_);
    
    //KD_RELEASE_SAFELY(_videoPath);
    
    //[super dealloc];
}

@end
