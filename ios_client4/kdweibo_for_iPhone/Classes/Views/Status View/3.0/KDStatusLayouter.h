//
//  KDStatusLayouter.h
//  kdweibo
//
//  Created by Tan yingqi on 13-11-26.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDLayouter.h"
#import "KDCompositeImageSource.h"
//#import "KWStatus.h"
#import "KDStatus.h"

//#import "GroupStatus.h"
#import "KDDMMessage.h"
#import "KDCommentStatus.h"
#import "KDStatusView.h"

/////////////////////////////////////////////////////////////////////////////////////////////////
@interface KDStatusLayouter : KDLayouter {
    
}
+ (KDStatusLayouter *)newStatusLayouter:(KDStatus *)status constrainedWidth:(CGFloat)width;
+ (KDStatusLayouter *)statusLayouter:(KDStatus *)status constrainedWidth:(CGFloat)width;
+ (KDStatusLayouter *)statusDetailLayouter:(KDStatus *)status constrainedWidth:(CGFloat)width;
+ (KDStatusLayouter *)groupStatusLayouter:(KDStatus *)status constrainedWidth:(CGFloat)width;
@end

/////////////////////////////////////////////////////////////////////////////////////////////////
@interface KDSubStatusLayouter: KDStatusLayouter

@end

/////////////////////////////////////////////////////////////////////////////////////////////////
@interface KDStatusCoreTextLayouter:KDCoreTextLayouter

@end

@interface KDSubStatusCoreTextLayouter:KDCoreTextLayouter
@end

@interface KDCommentStatusCoreTextLayouter:KDCoreTextLayouter
@end

@interface KDLikedStatusCoreTextLayouter:KDLikedCoreTextLayouter
@end

@interface KDMicroCommentsStatusCoreTextLayouter:KDMicroCommentsCoreTextLayouter
@end

@interface KDMoreStatusCoreTextLayouter : KDMoreCoreTextLayouter
@end

@interface KDEmptyStatusCoreTextLayouter : KDEmptyCoreTextLayouter
@end

@interface KDTopEmptyStatusCoreTextLayouter : KDEmptyCoreTextLayouter
@end

/////////////////////////////////////////////////////////////////////////////////////////////////
@interface KDStatusThumbnailsLayouter : KDThumbnailsLayouter
@end

@interface KDStatusHeaderLayouter : KDLayouter
@property(nonatomic,retain)KDUser *user;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,copy)NSString *from;
@end


@interface KDGroupFlagLayouter : KDLayouter
@property(nonatomic,copy,readonly)NSString *groupName;
@end

@interface KDFooterLayoutr:KDLayouter

@end

@interface KDCommentFooterLayouter:KDLayouter

@end

@interface KDCommentHeadLayouter:KDLayouter

@end

@interface KDCommentCellLayouter:KDLayouter
+ (KDCommentCellLayouter *)layouter:(KDStatus *)status constrainedWidth:(CGFloat)width;

@end


@interface KDDMMessageLayouter : KDLayouter
+ (KDLayouter *)layouter:(KDDMMessage *)message constrainedWidth:(CGFloat)width shouldDisplayTimeStamp:(BOOL)should;
@end

@interface KDStatusDocumentLayouter:KDDocumentListLayouter

@end


@interface KDSubStatusDocumentLayouter:KDStatusDocumentLayouter

@end

@interface KDVoteLayouter:KDLayouter
@property(nonatomic,readonly,copy)NSString *voteId;
@end

//新浪微博
@interface KDExtendStatusLayouter:KDLayouter

@end

@interface KDExtendStatusCoreTextLayouter : KDCoreTextLayouter

@end

@interface KDExtendStatusForwardedStatusCoreTextLayouter : KDCoreTextLayouter

@end

@interface KDExtendStatusThumbnailsLayouter : KDThumbnailsLayouter

@end

