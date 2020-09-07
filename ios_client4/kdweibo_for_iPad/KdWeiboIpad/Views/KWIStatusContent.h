//
//  KWIStatusContent.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDStatus;
@class KDCommentStatus;
@class KDCommentMeStatus;

@interface KWIStatusContent : UIView 

@property (retain, nonatomic) KDStatus *status;
@property (retain, nonatomic) KDCommentStatus *comment;
@property (retain, nonatomic) KDCommentMeStatus *commentMeStatus;

+ (KWIStatusContent *)viewForStatus:(KDStatus *)status 
                              frame:(CGRect)frame;

+ (KWIStatusContent *)viewForStatus:(KDStatus *)status 
                              frame:(CGRect)frame 
                    contentFontSize:(NSUInteger)contentFontSize;

+ (KWIStatusContent *)viewForStatus:(KDStatus *)status 
                              frame:(CGRect)frame 
                    contentFontSize:(NSUInteger)contentFontSize 
             textInteractionEnabled:(BOOL)textInteractionEnabled;

+ (KWIStatusContent *)viewForComment:(KDCommentStatus *)comment 
                               frame:(CGRect)frame;

+ (KWIStatusContent *)viewForComment:(KDCommentStatus *)comment 
                               frame:(CGRect)frame 
                     contentFontSize:(NSUInteger)contentFontSize;

+ (KWIStatusContent *)viewForComment:(KDCommentStatus *)comment 
                               frame:(CGRect)frame 
                     contentFontSize:(NSUInteger)contentFontSize 
              textInteractionEnabled:(BOOL)textInteractionEnabled;



+ (KWIStatusContent *)viewForCommentMeStatus:(KDCommentMeStatus *)commentMeStatus
                                       frame:(CGRect)frame;

+ (KWIStatusContent *)viewForCommentMeStatus:(KDCommentMeStatus *)commentMeStatus
                                       frame:(CGRect)frame
                             contentFontSize:(NSUInteger)contentFontSize;

+ (KWIStatusContent *)viewForCommentMeStatus:(KDCommentMeStatus *)commentMeStatus
                               frame:(CGRect)frame
                     contentFontSize:(NSUInteger)contentFontSize
              textInteractionEnabled:(BOOL)textInteractionEnabled ;
//+(CGFloat )optimalHeightByConstrainedWidth:(CGFloat)width commentStatus:(KDCommentStatus *)commnet;
//+(NSAttributedString *)_buildContentAttrStr:(KDStatus *)status textInteractionEnabled:(BOOL)enable;
//+(NSAttributedString *)_buildQuoteAttrStr:(NSString *)text;
@end
