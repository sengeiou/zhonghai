//
//  KDStatusView.h
//  kdweibo
//
//  Created by Tan yingqi on 10/26/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDStatus.h"
#import "KDLayouter.h"

@interface KDStatusView : UIView {
    @protected
   // KDLayouter *layouter_;
}
@property(nonatomic,retain)NSDictionary *userInfo;
- (void)update;
@end


//////////////////////////////////////////////////////////////////////////////////////
@interface KDLayouterTextView : KDStatusView
@property (nonatomic , retain)UILabel *textLabel;
@end

//////////////////////////////////////////////////////////////////////////////////////

@interface KDLayouterCoreTextView : KDStatusView
@property (nonatomic , retain)DTAttributedTextContentView *textView;
@end

//////////////////////////////////////////////////////////////////////////////////////
@interface KDLayouterImageView : KDStatusView
@property (nonatomic,retain)UIImageView *imageView;
@end


//////////////////////////////////////////////////////////////////////////////////////

@interface KDStatusFooterAttributeView : UIView {
@private
    UIImageView *typeImageView_;
    UILabel *textLabel_;
}
@property(nonatomic, retain) UIImageView *typeImageView;
@property(nonatomic, retain) UILabel *textLabel;

- (void)setTypeImage:(UIImage *)image;
- (void)setText:(NSString *)text;
- (CGSize)optimalDisplaySize;
@end


//////////////////////////////////////////////////////////////////////////////////////
@interface KDLayouterFooterView : KDStatusView
@property(nonatomic, assign) BOOL showAccurateGroupName;
@property(nonatomic, assign) BOOL isUsingNormalCommentsIcon;
@property(nonatomic, retain) UILabel *sourceLabel;
@property(nonatomic, retain) KDStatusFooterAttributeView *commentAttrView;
@property(nonatomic, retain) KDStatusFooterAttributeView *forwardAttrView;

@end


//////////////////////////////////////////////////////////////////////////////////////
@interface KDLayouterHeaderView : KDStatusView
@property (nonatomic ,  retain)UILabel *screenNameLabel;

@end

//////////////////////////////////////////////////////////////////////////////////////
@interface KDLayouterThumbnailsView : KDStatusView
@property (nonatomic ,retain)UIImageView *imageView;
@end


@interface KDLayouterExtraStatusView:KDStatusView
@property (nonatomic,retain)UIImageView *backgroudImageView;
@property (nonatomic,retain)UIImageView *accessoryImageView;
@property (nonatomic,retain)KDLayouterTextView *forwardedTextView;
@property (nonatomic,retain)KDLayouterTextView *contentTextView;
@property (nonatomic,retain)KDLayouterImageView *seperatorView;
@property (nonatomic,retain)KDLayouterThumbnailsView *thumnailView;

@end

//////////////////////////////////////////////////////////////////////////////////////
@interface KDLayouterFatherView : KDStatusView

@property (nonatomic,retain)UIImageView *backgroudImageView;
@property (nonatomic,retain)KDLayouterFatherView *fatherView;
@property (nonatomic,retain)KDLayouterHeaderView *headerView;
@property (nonatomic,retain)KDLayouterTextView   *textView;
@property (nonatomic,retain)KDLayouterFatherView *contentView;
@property (nonatomic,retain)KDLayouterThumbnailsView *thumnailsView;
@property (nonatomic,retain)KDLayouterFooterView *footerView;
@property (nonatomic,retain)KDLayouterExtraStatusView *extraStatusView;
@end


@interface KDQuotedStatusView : KDStatusView
@property (nonatomic,retain)UIImageView *backgroudImageView;
@end

@interface KDLayouterMessageView : KDStatusView
@property (nonatomic,retain)UIImageView *backgroudImageView;
@property (nonatomic,retain)KDLayouterTextView *textView;
@property (nonatomic,retain)KDLayouterThumbnailsView *thumbnailsView;

@end

@interface KDLayouterDocumentListView : KDStatusView
 @property (nonatomic,retain)UIImageView *backgroudImageView;
@end
