//
//  KDStatusBodyView.h
//  kdweibo
//
//  Created by laijiandong on 12-9-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDStatus.h"
#import "KDThumbnailView2.h"
#import "KDExpressionLabel.h"
#import "KDLocationView.h"
#import "KDDocumentIndicatorView.h"
#import "KDStatusFromGroupTipView.h"
enum {
    KDStatusBodyViewDisplayStyleNone = 0,
    KDStatusBodyViewDisplayStyleThumbnail = 1 << 0,
};

typedef NSUInteger KDStatusBodyViewDisplayStyle;

typedef enum {
    KDStatusBodyViewDisplayPositionNormal = 0,
    KDStatusBodyViewDisplayPositionGroup
}KDStatusBodyViewDisplayPosition;


@interface KDStatusBodyView : UIView<KDDocumentIndicatorViewDelegate> {
 @private
    KDStatus *status_;
//    id<KDThumbnailViewDelegate2> thumbnailDelegate_;
    KDStatusBodyViewDisplayStyle style_;
    KDStatusBodyViewDisplayPosition position_;

    UIImageView *backgroundView_;
    
    KDExpressionLabel *textLabel_;
    KDExpressionLabel *forwardTextLabel_;
    UIImageView *dividerView_;
    
    KDStatusBodyView *extraContentView_;
    KDThumbnailView2 *thumbnailView_;
    UIView *extraMessageTypeView_;
    KDLocationView *loactionView_;
    
    KDDocumentIndicatorView *documentIndicatorView_;
    
    UIEdgeInsets contentEdgeInsets_;
    
    UIView *groupTipView;
}

@property(nonatomic, retain) KDStatus *status;
@property(nonatomic, assign) id<KDThumbnailViewDelegate2> thumbnailDelegate;
@property(nonatomic, assign) KDStatusBodyViewDisplayStyle style;
@property(nonatomic, assign) KDStatusBodyViewDisplayPosition position;

- (void)reload;
- (KDThumbnailView2 *)currentVisibleThumbnailView;

+ (CGFloat)calculateStatusBodyHeight:(KDStatus *)status bodyViewPosition:(KDStatusBodyViewDisplayPosition)p;
+ (CGFloat)calculateStatusBodyHeight:(KDStatus *)status;
+ (CGFloat)calculateStatusBodyThumbnailHeight:(KDStatus *)status;

@end

