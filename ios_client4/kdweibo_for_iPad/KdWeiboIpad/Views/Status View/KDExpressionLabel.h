//
//  KDExpressionLabel.h
//  kdweibo
//
//  Created by shen kuikui on 13-3-1.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DTCoreText.h"
#import "DTTiledLayerWithoutFade.h"
#import "DTCoreTextLayouter.h"

typedef enum {
    KDExpressionLabelType_NONE = 0x00,
    KDExpressionLabelType_Expression,
    KDExpressionLabelType_URL
}KDExpressionLabelType;

typedef void (*MyFunc)(NSString *url);

@interface KDExpressionLabel : UIView <DTAttributedTextContentViewDelegate>
{
    DTAttributedTextContentView *contentView_;
    KDExpressionLabelType type_;
    MyFunc f_;
}
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, assign) UITextAlignment textAlignment;

- (id)initWithFrame:(CGRect)frame andType:(KDExpressionLabelType)type urlRespondFucIfNeed:(MyFunc)func;

+ (CGSize)sizeWithString:(NSString *)content constrainedToSize:(CGSize)size withType:(KDExpressionLabelType)type textAlignment:(UITextAlignment)alignment textColor:(UIColor *)color textFont:(UIFont *)font;

@end
