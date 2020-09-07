//
//  KDLayouterView.h
//  kdweibo
//
//  Created by Tan yingqi on 13-11-26.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTAttributedTextContentView.h"
#import  "UIImage+Additions.h"
#import  "KDThumbnailView3.h"
#import  "KDDocumentIndicatorView.h"
#import  "KDLocationView.h"
#import "KDStatusExpressionLabel.h"
#import "KDDefaultViewControllerContext.h"

@class KDLayouter;

@interface KDLayouterView : UIView {
@protected
    KDLayouter *layouter_;
}

@property(nonatomic,retain)KDLayouter *layouter;
- (void)updateContent;
@end


@interface KDCoreTextLayouterView : KDLayouterView {
@protected
    KDExpressionLabel *textView_;
}
@property (nonatomic , retain)KDExpressionLabel *textView;
@end


@interface KDLikedCoreTextLayouterView : KDLayouterView {
@protected
    UILabel *likedLabel_;
}
@property(nonatomic,retain)UILabel *likedLabel;
@end


@interface KDMicroCommentCoreTextLayouterView : KDLayouterView {
@protected
    UILabel *microCommentLabel_;
}
@property(nonatomic,retain)UILabel *microCommentLabel;
@end


@interface KDMoreCoreTextLayouterView : KDLayouterView {
@protected
    UILabel *moreLabel_;
}
@property(nonatomic,retain)UILabel *moreLabel;
@end

@interface KDEmptyCoreTextLayouterView : KDLayouterView
@end


//////////////////////////////////////////////////////////////////////////////////////
@interface KDThumbnailsLayouterView : KDLayouterView
@property (nonatomic ,retain)KDThumbnailView3 *thumbnailView;
- (void)loadThumbailsImage;
@end

@interface KDDocumentListLayouterView:KDLayouterView {
@protected
    KDDocumentIndicatorView *docListView_;
}
@property(nonatomic,retain)KDDocumentIndicatorView *docListView;
@end


@interface KDLocationLayouterView : KDLayouterView
@property(nonatomic,retain)KDLocationView *locationView;
@end

