//
//  KDLayouter.h
//  kdweibo
//
//  Created by Tan yingqi on 12-10-31.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDLayouterView.h"
//UIKIT_EXTERN  CGRect boundsByContrainedWidth(CGFloat width ,UIFont *font ,NSString *text);
UIKIT_EXTERN  NSAttributedString * buildAttriString(NSString *text, BOOL enable, CGFloat fontSize);
UIKIT_EXTERN  NSAttributedString * buildQuoteAttrStr(NSString * text,CGFloat fontSize);

//@class KDStatusView;
@interface KDLayouter : NSObject {
@protected
    //     id data_;
}
@property (nonatomic,assign)CGRect frame;
@property (nonatomic,assign)CGFloat constrainedWidth;
@property (nonatomic,retain)NSMutableArray *subLayouters;
@property (nonatomic,assign)KDLayouter *superLayouter;
@property (nonatomic,assign)CGRect bounds;
@property (nonatomic,assign)UIEdgeInsets edgeInsets;
@property (nonatomic,assign)id data;

- (CGRect)calculatedBounds;
- (void)addSubLayouter:(KDLayouter *)layout;
- (UIEdgeInsets)defaultEdgeInsets;
- (Class)viewClass;
- (void)update;
- (KDLayouterView *)view;
@end
/**
 *  KDCoreTextLayouter
 */
@interface KDCoreTextLayouter : KDLayouter {
@protected
    NSString *text_;
    CGFloat fontSize_;
    KDExpressionLabelType type_;
    
}

@property(nonatomic,copy)NSString *text;
@property(nonatomic,assign)CGFloat fontSize;
@property(nonatomic,assign)KDExpressionLabelType type;
@end


/**zgbin:
 *  KDLikedCoreTextLayouter
 */
@interface KDLikedCoreTextLayouter : KDLayouter {
@protected
    NSString *text_;
    CGFloat fontSize_;
    KDExpressionLabelType type_;
    
}

@property(nonatomic,copy)NSString *text;
@property(nonatomic,assign)CGFloat fontSize;
@property(nonatomic,assign)KDExpressionLabelType type;
@end


/**
 *  KDMicroCommentsCoreTextLayouter
 */
@interface KDMicroCommentsCoreTextLayouter : KDLayouter {
@protected
    NSString *text_;
    CGFloat fontSize_;
    KDExpressionLabelType type_;
    NSDictionary *commentDic_;
    
}

@property(nonatomic,copy)NSString *text;
@property(nonatomic,assign)CGFloat fontSize;
@property(nonatomic,assign)KDExpressionLabelType type;
@property(nonatomic,copy)NSDictionary *commentDic;
@end


/**
 *  KDMoreCoreTextLayouter
 */
@interface KDMoreCoreTextLayouter : KDLayouter {
@protected
    NSString *text_;
    CGFloat fontSize_;
    KDExpressionLabelType type_;
    
}

@property(nonatomic,copy)NSString *text;
@property(nonatomic,assign)CGFloat fontSize;
@property(nonatomic,assign)KDExpressionLabelType type;
@end


/**
 *  KDEmptyCoreTextLayouter
 */
@interface KDEmptyCoreTextLayouter : KDLayouter {
@protected
    NSString *text_;
    CGFloat fontSize_;
    KDExpressionLabelType type_;
    
}

@property(nonatomic,copy)NSString *text;
@property(nonatomic,assign)CGFloat fontSize;
@property(nonatomic,assign)KDExpressionLabelType type;
@end
//end
/**
 *  KDThumbnailsLayouter
 */
@interface KDThumbnailsLayouter : KDLayouter {
@protected KDCompositeImageSource *imageSource_;
}
@property(nonatomic,readonly,retain)KDCompositeImageSource *imageSource;
@end

@interface KDDocumentListLayouter : KDLayouter {
@protected
    NSArray *docs_;
}
@property(nonatomic,readonly,retain)NSArray *docs;
@end

@interface KDLocationLayouter : KDLayouter {
@protected
    NSString *address_;
    CGFloat latitude_;
    CGFloat longitude_;
}
@property(nonatomic,readonly,copy)NSString *address;
@property(nonatomic,readonly,assign)CGFloat latitude;
@property(nonatomic,readonly,assign)CGFloat longitude;

@end

