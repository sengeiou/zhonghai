//
//  KDDocumentIndicatorView.h
//  kdweibo_common
//
//  Created by shen kuikui on 13-7-15.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDDocumentIndicatorView;
@class KDAttachment;

@protocol KDDocumentIndicatorViewDelegate <NSObject>

- (void)documentIndicatorView:(KDDocumentIndicatorView *)div didClickedAtAttachment:(KDAttachment *)attachment;
- (void)didClickMoreInDocumentIndicatorView:(KDDocumentIndicatorView *)div;

@end

@interface KDDocumentIndicatorView : UIView
{
    
}

@property (nonatomic, assign) id<KDDocumentIndicatorViewDelegate> delegate;
@property (nonatomic, retain) NSArray *documents;
@property (nonatomic, retain) UIColor *textColor; // 2013.12.3 By Tan yingqi 新增cell 的textColor 属性

+ (CGFloat)heightForDocumentsCount:(NSUInteger)count;

@end
