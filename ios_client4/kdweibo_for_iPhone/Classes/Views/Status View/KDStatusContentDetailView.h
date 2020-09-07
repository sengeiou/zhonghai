//
//  KDStatusContentDetailView.h
//  kdweibo
//
//  Created by shen kuikui on 13-2-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTCoreText.h"
#import "KDStatusCoreTextDelegate.h"

typedef enum {
    KDStatusContentDetailViewCompleteMode = 0,
    KDStatusContentDetailViewExpressionOnlyMode
}KDStatusContentDetailViewMode;

typedef enum{
    KDStatusContentDetailViewTypeNormal = 0,
    KDStatusContentDetailViewTypeForwarding,
    KDStatusContentDetailViewTypeReply
}KDStatusContentDetailViewType;

@class KDStatus;

@interface KDStatusContentDetailView : UIView<DTAttributedTextContentViewDelegate> {
    KDStatusContentDetailViewMode mode_;
    KDStatusContentDetailViewType type_;
    KDStatus *status_;
    NSString *markString_;
}

@property (nonatomic, assign) id<KDStatusCoreTextDelegate> delegate;
@property (nonatomic, assign) KDStatusContentDetailViewMode mode;
@property (nonatomic, assign) KDStatusContentDetailViewType type;

//config text
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, assign) UITextAlignment alignment;

- (id)initWithFrame:(CGRect)frame andMode:(KDStatusContentDetailViewMode)mode;

- (id)initWithFrame:(CGRect)frame andMode:(KDStatusContentDetailViewMode)mode andType:(KDStatusContentDetailViewType)type;

- (void)setStatus:(KDStatus *)status;
- (void)setMarkString:(NSString *)string;
@end
