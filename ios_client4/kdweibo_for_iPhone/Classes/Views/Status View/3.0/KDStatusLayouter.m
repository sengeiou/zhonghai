//
//  KDStatusLayouter.m
//  kdweibo
//
//  Created by Tan yingqi on 13-11-26.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDStatusLayouter.h"

#pragma - mark KDQuotedLayoutere
@implementation KDStatusLayouter

+ (KDStatusLayouter *)newStatusLayouter:(KDStatus *)status constrainedWidth:(CGFloat)width {
    KDStatusLayouter *layouter = [status propertyForKey:@"layouter"];
    NSInteger likeCount = status.liked?(status.likeUserInfos.count+1):status.likeUserInfos.count;
    if (!layouter && status.commentsCount==status.microBlogComments.count && status.likedCount==likeCount) {
        layouter = [[KDStatusLayouter alloc] init];// autorelease];
        layouter.data = status;
        [status setProperty:layouter forKey:@"layouter"];
        layouter.constrainedWidth = width;
        //[layouter configredLayouter:status];
        KDStatusHeaderLayouter *headLayouter = [[KDStatusHeaderLayouter alloc] init];// autorelease];
        [layouter addSubLayouter:headLayouter];
        headLayouter.data = status;
        if (status.isGroup && ![status isKindOfClass:[KDGroupStatus class]]) { //主页timeline 显示小组标志
            KDGroupFlagLayouter *flagLayouer = [[KDGroupFlagLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:flagLayouer];
            flagLayouer.data = status;
        }
        
        KDStatusCoreTextLayouter *coreTextLayouter = [[KDStatusCoreTextLayouter alloc] init];// autorelease];
        [layouter addSubLayouter:coreTextLayouter];
        coreTextLayouter.data = status;
        
        if (status.extraMessage && [status.extraMessage isVote]) {
            KDVoteLayouter *voteLayouter = [[KDVoteLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:voteLayouter];
            voteLayouter.data = status;
            
        }
        if (status.extendStatus) {
            KDExtendStatusLayouter *extendStatusLayouter = [[KDExtendStatusLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:extendStatusLayouter];
            extendStatusLayouter.data = status;
            if (status.extendStatus.content) {
                KDExtendStatusCoreTextLayouter *extendStatusCoreTextLayouter = [[KDExtendStatusCoreTextLayouter alloc] init] ;///autorelease];
                [extendStatusLayouter addSubLayouter:extendStatusCoreTextLayouter];
                extendStatusCoreTextLayouter.data = status;
            }
            if (status.extendStatus.forwardedContent) {
                KDExtendStatusForwardedStatusCoreTextLayouter *extendStatusForwardedStatusCoreTextLayouter = [[KDExtendStatusForwardedStatusCoreTextLayouter alloc] init];// autorelease];
                [extendStatusLayouter addSubLayouter:extendStatusForwardedStatusCoreTextLayouter];
                extendStatusForwardedStatusCoreTextLayouter.data = status;
            }
            if (status.extendStatus.compositeImageSource) {
                // KDThumbnailsLayouter *
                KDExtendStatusThumbnailsLayouter *extendStatusThumbnialsLayouter = [[KDExtendStatusThumbnailsLayouter alloc] init];// autorelease];
                [extendStatusLayouter addSubLayouter:extendStatusThumbnialsLayouter];
                extendStatusThumbnialsLayouter.data = status;
            }
            
        }
        
        if (status.compositeImageSource) {
            KDStatusThumbnailsLayouter *thumbnailsLayouter = [[KDStatusThumbnailsLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:thumbnailsLayouter];
            thumbnailsLayouter.data = status;
        }
        
        if ([status hasAttachments]) {
            KDStatusDocumentLayouter *docListLayouter = [[KDStatusDocumentLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:docListLayouter];
            docListLayouter.data = status;
        }
        if ([status hasAddress]) {
            KDLocationLayouter *locationLayouter = [[KDLocationLayouter alloc] init] ;//autorelease];
            [layouter addSubLayouter:locationLayouter];
            locationLayouter.data = status;
        }
        
        if (status.forwardedStatus) { //转发
            KDSubStatusLayouter *subStatusLayouter = [[KDSubStatusLayouter alloc] init] ;//autorelease];
            [layouter addSubLayouter:subStatusLayouter];
            subStatusLayouter.data = status.forwardedStatus;
            
            
            KDSubStatusCoreTextLayouter *subcoreTextLayouter = [[KDSubStatusCoreTextLayouter alloc] init];// autorelease];
            [subStatusLayouter addSubLayouter:subcoreTextLayouter];
            subcoreTextLayouter.data = status.forwardedStatus;
            
            if (status.forwardedStatus.extraMessage && [status.forwardedStatus.extraMessage isVote]) {
                KDVoteLayouter *subVoteLayouter = [[KDVoteLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subVoteLayouter];
                subVoteLayouter.data = status.forwardedStatus;
                
            }
            if (status.forwardedStatus.extendStatus) { //转发又转发新浪微博
                KDExtendStatusLayouter *subExtendStatusLayouter = [[KDExtendStatusLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subExtendStatusLayouter];
                subExtendStatusLayouter.data = status.forwardedStatus;
                
                if (status.forwardedStatus.extendStatus.content) {
                    KDExtendStatusCoreTextLayouter *subExtendStatusCoreTextLayouter = [[KDExtendStatusCoreTextLayouter alloc] init] ;//autorelease];
                    [subExtendStatusLayouter addSubLayouter:subExtendStatusCoreTextLayouter];
                    subExtendStatusCoreTextLayouter.data =  status.forwardedStatus;
                }
                if (status.forwardedStatus.extendStatus.forwardedContent) {
                    KDExtendStatusForwardedStatusCoreTextLayouter *subExtendStatusForwardedStatusCoreTextLayouter = [[KDExtendStatusForwardedStatusCoreTextLayouter alloc] init] ;//autorelease];
                    [subExtendStatusLayouter addSubLayouter:subExtendStatusForwardedStatusCoreTextLayouter];
                    subExtendStatusForwardedStatusCoreTextLayouter.data = status.forwardedStatus;
                }
                if (status.forwardedStatus.extendStatus.compositeImageSource) {
                    // KDThumbnailsLayouter *
                    KDExtendStatusThumbnailsLayouter *subExtendStatusThumbnialsLayouter = [[KDExtendStatusThumbnailsLayouter alloc] init];// autorelease];
                    [subExtendStatusLayouter addSubLayouter:subExtendStatusThumbnialsLayouter];
                    subExtendStatusThumbnialsLayouter.data = status.forwardedStatus;
                }
                
            }
            
            if (status.forwardedStatus.compositeImageSource) {
                KDStatusThumbnailsLayouter *subThumbnailsLayouter = [[KDStatusThumbnailsLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subThumbnailsLayouter];
                subThumbnailsLayouter.data = status.forwardedStatus;
            }
            
            if ([status.forwardedStatus hasAttachments]) {
                KDSubStatusDocumentLayouter *subDocListLayouter = [[KDSubStatusDocumentLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subDocListLayouter];
                subDocListLayouter.data = status.forwardedStatus;
            }
            if ([status.forwardedStatus hasAddress]) {
                KDLocationLayouter *subLocationLayouter = [[KDLocationLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subLocationLayouter];
                subLocationLayouter.data = status.forwardedStatus;
            }
            
        }
        KDFooterLayoutr *footerLayouter = [[KDFooterLayoutr alloc] init];// autorelease];
        [layouter addSubLayouter:footerLayouter];
        footerLayouter.data = status;
        
        if (status.likeUserInfos.count > 0 || status.liked) {
            KDLikedStatusCoreTextLayouter *coreTextLayouter = [[KDLikedStatusCoreTextLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:coreTextLayouter];
            coreTextLayouter.data = status;
        }
        if (status.microBlogComments.count > 0) {
            KDTopEmptyStatusCoreTextLayouter *emptyTextLayouter = [[KDTopEmptyStatusCoreTextLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:emptyTextLayouter];
            emptyTextLayouter.data = status;
        }
        if (status.microBlogComments.count > 0 && status.microBlogComments.count <= 5) {
            for (int i = 0; i < status.microBlogComments.count; i++) {
                KDMicroCommentsStatusCoreTextLayouter *coreTextLayouter = [[KDMicroCommentsStatusCoreTextLayouter alloc] init];// autorelease];
                [layouter addSubLayouter:coreTextLayouter];
                coreTextLayouter.data = [status.microBlogComments objectAtIndex:i];
            }
        }else if (status.microBlogComments.count > 5) {
            for (int i = 0; i < 5; i++) {
                KDMicroCommentsStatusCoreTextLayouter *coreTextLayouter = [[KDMicroCommentsStatusCoreTextLayouter alloc] init];// autorelease];
                [layouter addSubLayouter:coreTextLayouter];
                coreTextLayouter.data = [status.microBlogComments objectAtIndex:i];
            }
            KDMoreStatusCoreTextLayouter *moreTextLayouter = [[KDMoreStatusCoreTextLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:moreTextLayouter];
            moreTextLayouter.data = status;
        }
        if (status.likeUserInfos.count > 0 || status.liked || status.microBlogComments.count > 0) {
            KDEmptyStatusCoreTextLayouter *emptyTextLayouter = [[KDEmptyStatusCoreTextLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:emptyTextLayouter];
            emptyTextLayouter.data = status;
        }
        [layouter frame];
    }
    return layouter;
}

+ (KDStatusLayouter *)statusLayouter:(KDStatus *)status constrainedWidth:(CGFloat)width {
    KDStatusLayouter *layouter = [status propertyForKey:@"layouter"];
    if (!layouter) {
        layouter = [[KDStatusLayouter alloc] init];// autorelease];
        layouter.data = status;
        [status setProperty:layouter forKey:@"layouter"];
        layouter.constrainedWidth = width;
        //[layouter configredLayouter:status];
        KDStatusHeaderLayouter *headLayouter = [[KDStatusHeaderLayouter alloc] init];// autorelease];
        [layouter addSubLayouter:headLayouter];
        headLayouter.data = status;
        if (status.isGroup && ![status isKindOfClass:[KDGroupStatus class]]) { //主页timeline 显示小组标志
            KDGroupFlagLayouter *flagLayouer = [[KDGroupFlagLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:flagLayouer];
            flagLayouer.data = status;
        }
        
        KDStatusCoreTextLayouter *coreTextLayouter = [[KDStatusCoreTextLayouter alloc] init];// autorelease];
        [layouter addSubLayouter:coreTextLayouter];
        coreTextLayouter.data = status;
        
        if (status.extraMessage && [status.extraMessage isVote]) {
            KDVoteLayouter *voteLayouter = [[KDVoteLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:voteLayouter];
            voteLayouter.data = status;
            
        }
        if (status.extendStatus) {
            KDExtendStatusLayouter *extendStatusLayouter = [[KDExtendStatusLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:extendStatusLayouter];
            extendStatusLayouter.data = status;
            if (status.extendStatus.content) {
                KDExtendStatusCoreTextLayouter *extendStatusCoreTextLayouter = [[KDExtendStatusCoreTextLayouter alloc] init] ;///autorelease];
                [extendStatusLayouter addSubLayouter:extendStatusCoreTextLayouter];
                extendStatusCoreTextLayouter.data = status;
            }
            if (status.extendStatus.forwardedContent) {
                KDExtendStatusForwardedStatusCoreTextLayouter *extendStatusForwardedStatusCoreTextLayouter = [[KDExtendStatusForwardedStatusCoreTextLayouter alloc] init];// autorelease];
                [extendStatusLayouter addSubLayouter:extendStatusForwardedStatusCoreTextLayouter];
                extendStatusForwardedStatusCoreTextLayouter.data = status;
            }
            if (status.extendStatus.compositeImageSource) {
                // KDThumbnailsLayouter *
                KDExtendStatusThumbnailsLayouter *extendStatusThumbnialsLayouter = [[KDExtendStatusThumbnailsLayouter alloc] init];// autorelease];
                [extendStatusLayouter addSubLayouter:extendStatusThumbnialsLayouter];
                extendStatusThumbnialsLayouter.data = status;
            }
            
        }
        
        if (status.compositeImageSource) {
            KDStatusThumbnailsLayouter *thumbnailsLayouter = [[KDStatusThumbnailsLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:thumbnailsLayouter];
            thumbnailsLayouter.data = status;
        }
        
        if ([status hasAttachments]) {
            KDStatusDocumentLayouter *docListLayouter = [[KDStatusDocumentLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:docListLayouter];
            docListLayouter.data = status;
        }
        if ([status hasAddress]) {
            KDLocationLayouter *locationLayouter = [[KDLocationLayouter alloc] init] ;//autorelease];
            [layouter addSubLayouter:locationLayouter];
            locationLayouter.data = status;
        }
        
        if (status.forwardedStatus) { //转发
            KDSubStatusLayouter *subStatusLayouter = [[KDSubStatusLayouter alloc] init] ;//autorelease];
            [layouter addSubLayouter:subStatusLayouter];
            subStatusLayouter.data = status.forwardedStatus;
            
            
            KDSubStatusCoreTextLayouter *subcoreTextLayouter = [[KDSubStatusCoreTextLayouter alloc] init];// autorelease];
            [subStatusLayouter addSubLayouter:subcoreTextLayouter];
            subcoreTextLayouter.data = status.forwardedStatus;
            
            if (status.forwardedStatus.extraMessage && [status.forwardedStatus.extraMessage isVote]) {
                KDVoteLayouter *subVoteLayouter = [[KDVoteLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subVoteLayouter];
                subVoteLayouter.data = status.forwardedStatus;
                
            }
            if (status.forwardedStatus.extendStatus) { //转发又转发新浪微博
                KDExtendStatusLayouter *subExtendStatusLayouter = [[KDExtendStatusLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subExtendStatusLayouter];
                subExtendStatusLayouter.data = status.forwardedStatus;
                
                if (status.forwardedStatus.extendStatus.content) {
                    KDExtendStatusCoreTextLayouter *subExtendStatusCoreTextLayouter = [[KDExtendStatusCoreTextLayouter alloc] init] ;//autorelease];
                    [subExtendStatusLayouter addSubLayouter:subExtendStatusCoreTextLayouter];
                    subExtendStatusCoreTextLayouter.data =  status.forwardedStatus;
                }
                if (status.forwardedStatus.extendStatus.forwardedContent) {
                    KDExtendStatusForwardedStatusCoreTextLayouter *subExtendStatusForwardedStatusCoreTextLayouter = [[KDExtendStatusForwardedStatusCoreTextLayouter alloc] init] ;//autorelease];
                    [subExtendStatusLayouter addSubLayouter:subExtendStatusForwardedStatusCoreTextLayouter];
                    subExtendStatusForwardedStatusCoreTextLayouter.data = status.forwardedStatus;
                }
                if (status.forwardedStatus.extendStatus.compositeImageSource) {
                    // KDThumbnailsLayouter *
                    KDExtendStatusThumbnailsLayouter *subExtendStatusThumbnialsLayouter = [[KDExtendStatusThumbnailsLayouter alloc] init];// autorelease];
                    [subExtendStatusLayouter addSubLayouter:subExtendStatusThumbnialsLayouter];
                    subExtendStatusThumbnialsLayouter.data = status.forwardedStatus;
                }
                
            }
            
            if (status.forwardedStatus.compositeImageSource) {
                KDStatusThumbnailsLayouter *subThumbnailsLayouter = [[KDStatusThumbnailsLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subThumbnailsLayouter];
                subThumbnailsLayouter.data = status.forwardedStatus;
            }
            
            if ([status.forwardedStatus hasAttachments]) {
                KDSubStatusDocumentLayouter *subDocListLayouter = [[KDSubStatusDocumentLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subDocListLayouter];
                subDocListLayouter.data = status.forwardedStatus;
            }
            if ([status.forwardedStatus hasAddress]) {
                KDLocationLayouter *subLocationLayouter = [[KDLocationLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subLocationLayouter];
                subLocationLayouter.data = status.forwardedStatus;
            }
            
        }
        KDFooterLayoutr *footerLayouter = [[KDFooterLayoutr alloc] init];// autorelease];
        [layouter addSubLayouter:footerLayouter];
        footerLayouter.data = status;
        
        if (status.likeUserInfos.count > 0 || status.liked) {
            KDLikedStatusCoreTextLayouter *coreTextLayouter = [[KDLikedStatusCoreTextLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:coreTextLayouter];
            coreTextLayouter.data = status;
        }
        if (status.microBlogComments.count > 0) {
            KDTopEmptyStatusCoreTextLayouter *emptyTextLayouter = [[KDTopEmptyStatusCoreTextLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:emptyTextLayouter];
            emptyTextLayouter.data = status;
        }
        if (status.microBlogComments.count > 0 && status.microBlogComments.count <= 5) {
            for (int i = 0; i < status.microBlogComments.count; i++) {
                KDMicroCommentsStatusCoreTextLayouter *coreTextLayouter = [[KDMicroCommentsStatusCoreTextLayouter alloc] init];// autorelease];
                [layouter addSubLayouter:coreTextLayouter];
                coreTextLayouter.data = [status.microBlogComments objectAtIndex:i];
            }
        }else if (status.microBlogComments.count > 5) {
            for (int i = 0; i < 5; i++) {
                KDMicroCommentsStatusCoreTextLayouter *coreTextLayouter = [[KDMicroCommentsStatusCoreTextLayouter alloc] init];// autorelease];
                [layouter addSubLayouter:coreTextLayouter];
                coreTextLayouter.data = [status.microBlogComments objectAtIndex:i];
            }
            KDMoreStatusCoreTextLayouter *moreTextLayouter = [[KDMoreStatusCoreTextLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:moreTextLayouter];
            moreTextLayouter.data = status;
        }
        if (status.likeUserInfos.count > 0 || status.liked || status.microBlogComments.count > 0) {
            KDEmptyStatusCoreTextLayouter *emptyTextLayouter = [[KDEmptyStatusCoreTextLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:emptyTextLayouter];
            emptyTextLayouter.data = status;
        }
        [layouter frame];
    }
    return layouter;
}


+ (KDStatusLayouter *)groupStatusLayouter:(KDStatus *)status constrainedWidth:(CGFloat)width {
    KDStatusLayouter *layouter = [status propertyForKey:@"layouter"];
    if (!layouter) {
        layouter = [[KDStatusLayouter alloc] init];// autorelease];
        layouter.data = status;
        [status setProperty:layouter forKey:@"layouter"];
        layouter.constrainedWidth = width;
        //[layouter configredLayouter:status];
        KDStatusHeaderLayouter *headLayouter = [[KDStatusHeaderLayouter alloc] init] ;//autorelease];
        [layouter addSubLayouter:headLayouter];
        headLayouter.data = status;
        
        KDStatusCoreTextLayouter *coreTextLayouter = [[KDStatusCoreTextLayouter alloc] init] ;//autorelease];
        [layouter addSubLayouter:coreTextLayouter];
        coreTextLayouter.data = status;
        
        if (status.extraMessage && [status.extraMessage isVote]) {
            KDVoteLayouter *voteLayouter = [[KDVoteLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:voteLayouter];
            voteLayouter.data = status;
            
        }
        if (status.extendStatus) {
            KDExtendStatusLayouter *extendStatusLayouter = [[KDExtendStatusLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:extendStatusLayouter];
            extendStatusLayouter.data = status;
            if (status.extendStatus.content) {
                KDExtendStatusCoreTextLayouter *extendStatusCoreTextLayouter = [[KDExtendStatusCoreTextLayouter alloc] init] ;//autorelease];
                [extendStatusLayouter addSubLayouter:extendStatusCoreTextLayouter];
                extendStatusCoreTextLayouter.data = status;
            }
            if (status.extendStatus.forwardedContent) {
                KDExtendStatusForwardedStatusCoreTextLayouter *extendStatusForwardedStatusCoreTextLayouter = [[KDExtendStatusForwardedStatusCoreTextLayouter alloc] init];// autorelease];
                [extendStatusLayouter addSubLayouter:extendStatusForwardedStatusCoreTextLayouter];
                extendStatusForwardedStatusCoreTextLayouter.data = status;
            }
            if (status.extendStatus.compositeImageSource) {
                // KDThumbnailsLayouter *
                KDExtendStatusThumbnailsLayouter *extendStatusThumbnialsLayouter = [[KDExtendStatusThumbnailsLayouter alloc] init] ;//autorelease];
                [extendStatusLayouter addSubLayouter:extendStatusThumbnialsLayouter];
                extendStatusThumbnialsLayouter.data = status;
            }
            
        }
        if (status.compositeImageSource) {
            KDStatusThumbnailsLayouter *thumbnailsLayouter = [[KDStatusThumbnailsLayouter alloc] init] ;//autorelease];
            [layouter addSubLayouter:thumbnailsLayouter];
            thumbnailsLayouter.data = status;
        }
        
        if ([status hasAttachments]) {
            KDStatusDocumentLayouter *docListLayouter = [[KDStatusDocumentLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:docListLayouter];
            docListLayouter.data = status;
        }
        if ([status hasAddress]) {
            KDLocationLayouter *locationLayouter = [[KDLocationLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:locationLayouter];
            locationLayouter.data = status;
        }
        
        if (status.forwardedStatus) {
            KDSubStatusLayouter *subStatusLayouter = [[KDSubStatusLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:subStatusLayouter];
            subStatusLayouter.data = status.forwardedStatus;
            
            
            KDSubStatusCoreTextLayouter *subcoreTextLayouter = [[KDSubStatusCoreTextLayouter alloc] init];// autorelease];
            [subStatusLayouter addSubLayouter:subcoreTextLayouter];
            subcoreTextLayouter.data = status.forwardedStatus;
            
            if (status.forwardedStatus.extraMessage && [status.forwardedStatus.extraMessage isVote]) {
                KDVoteLayouter *subVoteLayouter = [[KDVoteLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subVoteLayouter];
                subVoteLayouter.data = status.forwardedStatus;
            }
            
            if (status.forwardedStatus.extendStatus) { //转发又转发新浪微博
                KDExtendStatusLayouter *subExtendStatusLayouter = [[KDExtendStatusLayouter alloc] init] ;//autorelease];
                [subStatusLayouter addSubLayouter:subExtendStatusLayouter];
                subExtendStatusLayouter.data = status.forwardedStatus;
                
                if (status.forwardedStatus.extendStatus.content) {
                    KDExtendStatusCoreTextLayouter *subExtendStatusCoreTextLayouter = [[KDExtendStatusCoreTextLayouter alloc] init];// autorelease];
                    [subExtendStatusLayouter addSubLayouter:subExtendStatusCoreTextLayouter];
                    subExtendStatusCoreTextLayouter.data =  status.forwardedStatus;
                }
                if (status.forwardedStatus.extendStatus.forwardedContent) {
                    KDExtendStatusForwardedStatusCoreTextLayouter *subExtendStatusForwardedStatusCoreTextLayouter = [[KDExtendStatusForwardedStatusCoreTextLayouter alloc] init];// autorelease];
                    [subExtendStatusLayouter addSubLayouter:subExtendStatusForwardedStatusCoreTextLayouter];
                    subExtendStatusForwardedStatusCoreTextLayouter.data = status.forwardedStatus;
                }
                if (status.forwardedStatus.extendStatus.compositeImageSource) {
                    // KDThumbnailsLayouter *
                    KDExtendStatusThumbnailsLayouter *subExtendStatusThumbnialsLayouter = [[KDExtendStatusThumbnailsLayouter alloc] init] ;//autorelease];
                    [subExtendStatusLayouter addSubLayouter:subExtendStatusThumbnialsLayouter];
                    subExtendStatusThumbnialsLayouter.data = status.forwardedStatus;
                }
                
            }
            
            if (status.forwardedStatus.compositeImageSource) {
                KDStatusThumbnailsLayouter *subThumbnailsLayouter = [[KDStatusThumbnailsLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subThumbnailsLayouter];
                subThumbnailsLayouter.data = status.forwardedStatus;
            }
            
            if ([status.forwardedStatus hasAttachments]) {
                KDSubStatusDocumentLayouter *subDocListLayouter = [[KDSubStatusDocumentLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subDocListLayouter];
                subDocListLayouter.data = status.forwardedStatus;
            }
            if ([status.forwardedStatus hasAddress]) {
                KDLocationLayouter *subLocationLayouter = [[KDLocationLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subLocationLayouter];
                subLocationLayouter.data = status.forwardedStatus;
            }
            
            
            
        }
        KDFooterLayoutr *footerLayouter = [[KDFooterLayoutr alloc] init];// autorelease];
        [layouter addSubLayouter:footerLayouter];
        footerLayouter.data = status;
        [layouter frame];
    }
    return layouter;
}

+ (KDStatusLayouter *)statusDetailLayouter:(KDStatus *)status constrainedWidth:(CGFloat)width {
    KDStatusLayouter *layouter = [status propertyForKey:@"layouter"];
    if (!layouter) {
        layouter = [[KDStatusLayouter alloc] init];// autorelease];
        layouter.data = status;
        [status setProperty:layouter forKey:@"layouter"];
        layouter.constrainedWidth = width;
        //[layouter configredLayouter:status];
        KDStatusHeaderLayouter *headLayouter = [[KDStatusHeaderLayouter alloc] init] ;//autorelease];
        [layouter addSubLayouter:headLayouter];
        headLayouter.data = status;
        if (status.isGroup) {
            KDGroupFlagLayouter *flagLayouer = [[KDGroupFlagLayouter alloc] init] ;//autorelease];
            [layouter addSubLayouter:flagLayouer];
            flagLayouer.data = status;
        }
        
        KDStatusCoreTextLayouter *coreTextLayouter = [[KDStatusCoreTextLayouter alloc] init];// autorelease];
        [layouter addSubLayouter:coreTextLayouter];
        coreTextLayouter.data = status;
        
        if (status.extraMessage && [status.extraMessage isVote]) {
            KDVoteLayouter *voteLayouter = [[KDVoteLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:voteLayouter];
            voteLayouter.data = status;
            
        }
        if (status.compositeImageSource) {
            KDStatusThumbnailsLayouter *thumbnailsLayouter = [[KDStatusThumbnailsLayouter alloc] init] ;//autorelease];
            [layouter addSubLayouter:thumbnailsLayouter];
            thumbnailsLayouter.data = status;
        }
        
        if ([status hasAttachments]) {
            KDStatusDocumentLayouter *docListLayouter = [[KDStatusDocumentLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:docListLayouter];
            docListLayouter.data = status;
        }
        if ([status hasAddress]) {
            KDLocationLayouter *locationLayouter = [[KDLocationLayouter alloc] init];// autorelease];
            [layouter addSubLayouter:locationLayouter];
            locationLayouter.data = status;
        }
        
        if (status.forwardedStatus) {
            KDSubStatusLayouter *subStatusLayouter = [[KDSubStatusLayouter alloc] init] ;//autorelease];
            [layouter addSubLayouter:subStatusLayouter];
            subStatusLayouter.data = status.forwardedStatus;
            
            
            KDSubStatusCoreTextLayouter *subcoreTextLayouter = [[KDSubStatusCoreTextLayouter alloc] init] ;//autorelease];
            [subStatusLayouter addSubLayouter:subcoreTextLayouter];
            subcoreTextLayouter.data = status.forwardedStatus;
            
            if (status.forwardedStatus.extraMessage && [status.forwardedStatus.extraMessage isVote]) {
                KDVoteLayouter *subVoteLayouter = [[KDVoteLayouter alloc] init] ;//autorelease];
                [subStatusLayouter addSubLayouter:subVoteLayouter];
                subVoteLayouter.data = status.forwardedStatus;
                
            }
            if (status.forwardedStatus.compositeImageSource) {
                KDStatusThumbnailsLayouter *subThumbnailsLayouter = [[KDStatusThumbnailsLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subThumbnailsLayouter];
                subThumbnailsLayouter.data = status.forwardedStatus;
            }
            
            if ([status.forwardedStatus hasAttachments]) {
                KDSubStatusDocumentLayouter *subDocListLayouter = [[KDSubStatusDocumentLayouter alloc] init] ;//autorelease];
                [subStatusLayouter addSubLayouter:subDocListLayouter];
                subDocListLayouter.data = status.forwardedStatus;
            }
            if ([status.forwardedStatus hasAddress]) {
                KDLocationLayouter *subLocationLayouter = [[KDLocationLayouter alloc] init];// autorelease];
                [subStatusLayouter addSubLayouter:subLocationLayouter];
                subLocationLayouter.data = status.forwardedStatus;
            }
            
        }
        
        
    }
    return layouter;
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(10, 8, 0, 8);
}

- (Class)viewClass {
    return [KDStatusView class];
}

@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDQuotedLayoutere
@implementation KDSubStatusLayouter
- (Class)viewClass {
    return [KDSubStatusView class];
}
- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 10, 10, 10);
}
@end

#pragma - mark KDStatusCoreTextLayouter
@implementation KDStatusCoreTextLayouter
- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        self.text = status.text;
        self.fontSize = 16.0f;
        self.type = KDExpressionLabelType_Expression;
    }
}

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    BOOL moreThanLimit = NO;
    rect.size = [KDStatusExpressionLabel sizeWithString:self.text constrainedToSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) withType:self.type textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:self.fontSize] limitLineNumber:6 moreThanLimit:&moreThanLimit];
    rect.size.width = self.constrainedWidth;
    return rect;
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (Class)viewClass {
    return [KDStatusCoreTextView class];
}
@end

@implementation KDSubStatusCoreTextLayouter
- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        NSString *string = FORMATE_FORWARD_STATUS_TEXT(status.author.screenName,status.text);
        self.text = string;
        self.fontSize = 15.0f;
        self.type = KDExpressionLabelType_Expression;
    }
}

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    BOOL moreThanLimit = NO;
    rect.size = [KDStatusExpressionLabel sizeWithString:self.text constrainedToSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) withType:self.type textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:self.fontSize] limitLineNumber:6 moreThanLimit:&moreThanLimit];
    rect.size.width = self.constrainedWidth;
    return rect;
}

- (Class)viewClass {
    return [KDSubStatusCoreTextView class];
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

@end

@implementation KDCommentStatusCoreTextLayouter
- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        if (status.replyScreenName &&[status isKindOfClass:[KDCommentStatus class]] ) {
            self.text = [NSString stringWithFormat:ASLocalizedString(@"KDStatusLayouter_Reply"),status.replyScreenName,status.text];
        }else {
            self.text = status.text;
        }
        self.fontSize = 16.0f;
        self.type = KDExpressionLabelType_Expression|KDExpressionLabelType_USERNAME|KDExpressionLabelType_URL;
    }
}


- (Class)viewClass {
    return [KDCommentStatusCoreTextView class];
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 10, 7, 8);
}

@end

@implementation KDLikedStatusCoreTextLayouter
- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        NSMutableString *nameStr = [[NSMutableString alloc] init];;//所有点赞人（不包括"我"）
        if (status.liked) {
            [nameStr appendString:@"我"];
        }
        for (NSDictionary *dic in status.likeUserInfos) {
            if (nameStr.length != 0) {
                [nameStr appendString:@"、"];
            }
            [nameStr appendString:[dic objectForKey:@"name"]];
        }
        [nameStr appendString:@"觉得很赞。"];
        self.text = nameStr;
        self.fontSize = 14.0f;
        self.type = KDExpressionLabelType_Expression;
    }
}

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    BOOL moreThanLimit = NO;
    //    rect.size = [KDStatusExpressionLabel sizeWithString:self.text constrainedToSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) withType:self.type textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:self.fontSize] limitLineNumber:6 moreThanLimit:&moreThanLimit];
    
    NSString *imgWithText = [NSString stringWithFormat:@"%@%@",@"图片",self.text];
    rect.size = [imgWithText boundingRectWithSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontSize]} context:nil].size;
    rect.size.height = rect.size.height + 5;
    
    rect.size.width = self.constrainedWidth;
    return rect;
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (Class)viewClass {
    return [KDLikedStatusCoreTextView class];
}

@end

@implementation KDMicroCommentsStatusCoreTextLayouter
- (void)update {
    if (self.data) {
        self.text = @"view会自己到数据源取数据";
        self.fontSize = 14.0f;
        self.type = KDExpressionLabelType_Expression;
        self.commentDic = self.data;
    }
}

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    //    BOOL moreThanLimit = NO;
    //    rect.size = [KDStatusExpressionLabel sizeWithString:self.text constrainedToSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) withType:self.type textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:self.fontSize] limitLineNumber:6 moreThanLimit:&moreThanLimit];
    
    
    NSDictionary *commentDic = self.data;
    
    NSMutableAttributedString *allAttrStr = [[NSMutableAttributedString alloc] init];
    NSDictionary *colorDic = @{NSForegroundColorAttributeName:UIColorFromRGB(0x586c94)};
    
    NSAttributedString *nameAttr = [[NSAttributedString alloc] initWithString:[[commentDic objectForKey:@"user"] objectForKey:@"name"] attributes:colorDic];
    
    NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] init];
    NSMutableArray *contentArray = [NSMutableArray array];
    [self getMessageRange:[NSString stringWithFormat:@": %@", [commentDic objectForKey:@"text"]] array:contentArray];
    for (NSString *obj in contentArray) {
        if ([obj hasSuffix:@"]"] && [obj hasPrefix:@"["]) {
            if ([[KDExpressionCode allCodeString] containsObject:obj]) {
                //如果是表情
                NSTextAttachment *imageStr = [[NSTextAttachment alloc] init];
                imageStr.image = [UIImage imageNamed:[KDExpressionCode  codeStringToImageName:obj]];
                CGFloat height = [UIFont systemFontOfSize:self.fontSize].lineHeight;
                imageStr.bounds = CGRectMake(0, -3, height, height);
                NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:imageStr];
                [textAttr appendAttributedString:imageAttr];
            } else {
                [textAttr appendAttributedString:[[NSAttributedString alloc] initWithString:obj]];
            }
        } else {
            [textAttr appendAttributedString:[[NSAttributedString alloc] initWithString:obj]];
        }
    }
    
    
    if ([[commentDic objectForKey:@"in_reply_to_screen_name"] isEqual:[NSNull null]]) {
        [allAttrStr appendAttributedString:nameAttr];
        [allAttrStr appendAttributedString:textAttr];
    }else {
        NSAttributedString *replyAttr = [[NSAttributedString alloc] initWithString:@" 回复 "];
        NSAttributedString *replyNameAttr = [[NSAttributedString alloc] initWithString:[commentDic objectForKey:@"in_reply_to_screen_name"] attributes:colorDic];
        [allAttrStr appendAttributedString:nameAttr];
        [allAttrStr appendAttributedString:replyAttr];
        [allAttrStr appendAttributedString:replyNameAttr];
        [allAttrStr appendAttributedString:textAttr];
    }
    
    [allAttrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.fontSize] range:NSMakeRange(0, allAttrStr.length)];
    
    rect.size = [allAttrStr boundingRectWithSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    rect.size.height = rect.size.height + 5;
    
    rect.size.width = self.constrainedWidth;
    return rect;
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (Class)viewClass {
    return [KDMicroCommentStatusCoreTextView class];
}

//分析一个字符串中哪些是文字，哪些是表情然后加入一个数组中待用
- (void)getMessageRange:(NSString *)message array:(NSMutableArray *)array {
    NSRange range = [message rangeOfString:@"["];
    NSRange range1 = [message rangeOfString:@"]"];
    if (range.length>0 && range1.length>0) {
        if (range.location>0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str = [message substringFromIndex:range1.location+1];
            [self getMessageRange:str array:array];
        } else {
            NSString *nextstr = [message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str = [message substringFromIndex:range1.location+1];
                [self getMessageRange:str array:array];
            } else {
                return;
            }
        }
    } else if (message != nil){
        [array addObject:message];
    }
}

@end


@implementation KDMoreStatusCoreTextLayouter
- (void)update {
    self.text = @"查看全部回复";
    self.fontSize = 14.0f;
    self.type = KDExpressionLabelType_Expression;
}

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    BOOL moreThanLimit = NO;
    rect.size = [KDStatusExpressionLabel sizeWithString:self.text constrainedToSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) withType:self.type textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:self.fontSize] limitLineNumber:6 moreThanLimit:&moreThanLimit];
    rect.size.width = self.constrainedWidth;
    return rect;
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (Class)viewClass {
    return [KDMoreStatusCoreTextView class];
}

@end


@implementation KDEmptyStatusCoreTextLayouter
- (void)update {
    self.text = @"";
    self.fontSize = 14.0f;
    self.type = KDExpressionLabelType_Expression;
}

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    return rect;
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(10, 15, 0, 15);
}

- (Class)viewClass {
    return [KDEmptyStatusCoreTextView class];
}

@end


@implementation KDTopEmptyStatusCoreTextLayouter
- (void)update {
    self.text = @"";
    self.fontSize = 14.0f;
    self.type = KDExpressionLabelType_Expression;
}

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    return rect;
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(5, 15, 0, 15);
}

- (Class)viewClass {
    return [KDEmptyStatusCoreTextView class];
}

@end



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#pragma - mark KDHeaderLayouter
@implementation KDStatusHeaderLayouter
@synthesize user = user_;
@synthesize time = time_;
@synthesize from = from_;

- (id)init {
    self = [super init];
    if (self) {
        //
        
    }
    return self;
}

- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        self.user = status.author;
        self.time = status.createdAtDateAsString;
        self.from = status.source;
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(user_);
    //KD_RELEASE_SAFELY(time_);
    //KD_RELEASE_SAFELY(from_);
    //[super dealloc];
}

- (Class)viewClass {
    return [KDLayouterHeaderView class];
}

- (CGRect)calculatedBounds {
    return CGRectMake(0, 0, self.constrainedWidth, 44);
    
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 4, 0);
}
@end

@implementation KDGroupFlagLayouter
@synthesize groupName = groupName_;

- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        groupName_ = [status.groupName copy];
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(groupName_);
    //[super dealloc];
}

- (Class)viewClass {
    return [KDGroupFlagLayouterView class];
}

- (CGRect)calculatedBounds {
    CGSize size = [KDStatusFromGroupTipView sizeWithText:groupName_ constrainedWidth:self.constrainedWidth];
    return CGRectMake(0, 0, size.width, size.height);
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 10, 10, 10);
}
@end


#pragma - mark KDImageLayouter
@implementation KDStatusThumbnailsLayouter
- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        imageSource_ = [status compositeImageSource ];// retain];
        if ([status hasVideo]) {
            NSArray *attachments = status.attachments;
            [imageSource_ setProperty:attachments forKey:@"attachments"];
            [imageSource_ setProperty:status.statusId forKey:@"dataId"];
        }
    }
}

@end


@implementation KDStatusDocumentLayouter
- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        docs_ = [status attachments];//retain];
    }
}

- (Class)viewClass {
    return [KDStatusDocumentLayouterView class];
}
@end


@implementation KDSubStatusDocumentLayouter
- (Class)viewClass {
    return [KDSubStatusDocumentLayouterView class];
}
@end


@implementation KDVoteLayouter
@synthesize voteId = voteId_;

- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        voteId_ = [status.extraMessage.referenceId copy];
        // vote_ = status.extendStatus;
    }
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(voteId_);
    //[super dealloc];
}

- (Class)viewClass {
    return [KDVoteLayouterView class];
}

- (CGRect)calculatedBounds {
    return CGRectMake(0, 0, self.constrainedWidth, 50);
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 10, 50);
}
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDFooterLayoutr


@implementation KDFooterLayoutr

- (Class)viewClass {
    return [KDLayouterFooterView class];
}
- (CGRect)calculatedBounds {
    return CGRectMake(0, 0, self.constrainedWidth, 37);
}

@end

@implementation KDCommentFooterLayouter

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDExtraStatusLayouter

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDCommentCellLayouter

@implementation KDCommentCellLayouter
- (Class)viewClass {
    return [KDCommentCellLayouterView class];
}


+ (KDCommentCellLayouter *)layouter:(KDStatus *)status constrainedWidth:(CGFloat)width {
    KDCommentCellLayouter *layouter = [status propertyForKey:@"layouter"];
    if (!layouter) {
        layouter = [[KDCommentCellLayouter alloc] init];// autorelease];
        layouter.data = status;
        [status setProperty:layouter forKey:@"layouter"];
        layouter.constrainedWidth = width;
        
        KDCommentHeadLayouter *headLayouter = [[KDCommentHeadLayouter alloc] init] ;//autorelease];
        
        [layouter addSubLayouter:headLayouter];
        headLayouter.data = status;
        
        KDCommentStatusCoreTextLayouter *coreTextLayouter = [[KDCommentStatusCoreTextLayouter alloc] init] ;//autorelease];
        
        [layouter addSubLayouter:coreTextLayouter];
        coreTextLayouter.data = status;
        
        if (status.compositeImageSource) {
            KDStatusThumbnailsLayouter *thumbnailsLayouter = [[KDStatusThumbnailsLayouter alloc] init] ;//autorelease];
            [layouter addSubLayouter:thumbnailsLayouter];
            thumbnailsLayouter.data = status;
        }
        
        if ([status hasAttachments]) {
            KDStatusDocumentLayouter *docListLayouter = [[KDStatusDocumentLayouter alloc] init] ;//autorelease];
            
            [layouter addSubLayouter:docListLayouter];
            docListLayouter.data = status;
        }
        // [layouter frame];
        
    }
    return layouter;
}

@end

@implementation KDCommentHeadLayouter
- (Class)viewClass {
    return [KDCommentHeadLayouterView class];
}
- (CGRect)calculatedBounds {
    return CGRectMake(0, 0, self.constrainedWidth, 20);
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(10, 10, 10, 8);
}
@end


@implementation KDExtendStatusLayouter
- (Class)viewClass {
    return [KDExtendStatusLayouterView class];
}
- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 10, 10, 10);
}
@end

@implementation KDExtendStatusCoreTextLayouter
- (Class)viewClass {
    return [KDExtendStatusCoreTextLayouterView class];
}
- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        KDExtendStatus *extendStatus = status.extendStatus;
        if (extendStatus && extendStatus.content) {
            NSString *content = extendStatus.content;
            if (extendStatus.senderName) {
                content = [NSString stringWithFormat:@"%@:%@",extendStatus.senderName,content];
            }
            self.text = content;
        }
        self.fontSize = 15.0f;
        self.type = KDExpressionLabelType_Expression;
    }
}
- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(8, 10, 8, 10);
}
@end

@implementation KDExtendStatusForwardedStatusCoreTextLayouter
- (Class)viewClass {
    return [KDExtendStatusForwardedStatusCoreTextLayouterView class];
}
- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        KDExtendStatus *extendStatus = status.extendStatus;
        if (extendStatus && extendStatus.forwardedContent) {
            NSString *content = extendStatus.forwardedContent;
            if (extendStatus.forwardedSenderName) {
                content = [NSString stringWithFormat:@"%@:%@",extendStatus.forwardedSenderName,content];
            }
            self.text = content;
        }
        self.fontSize = 15.0f;
        self.type = KDExpressionLabelType_Expression;
    }
}
- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(-5, 10, 10, 10);
}
@end

@implementation KDExtendStatusThumbnailsLayouter
- (void)update {
    if (self.data) {
        KDStatus *status = self.data;
        imageSource_ = [status.extendStatus compositeImageSource];// retain];
    }
}

- (Class)viewClass {
    return [KDExtendStatusThumbnailsView class];
}
@end

