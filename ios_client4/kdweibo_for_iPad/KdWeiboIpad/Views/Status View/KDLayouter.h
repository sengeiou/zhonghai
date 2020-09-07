//
//  KDLayouter.h
//  kdweibo
//
//  Created by Tan yingqi on 12-10-31.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDCompositeImageSource.h"
//#import "KWStatus.h"
#import "KDStatus.h"

//#import "GroupStatus.h"
#import "KDDMMessage.h"
#import "KDCommentStatus.h"
#import "KDStatusView.h"

@class KDStatusView;
@interface KDLayouter : NSObject
@property (nonatomic,assign)CGRect frame;
@property (nonatomic,assign)CGFloat constrainedWidth;
@property (nonatomic,retain)NSMutableArray *subLayouters;
@property (nonatomic,assign)KDLayouter *superLayouter;
@property (nonatomic,assign)NSInteger tag;
@property (nonatomic,assign)CGRect bounds;
@property (nonatomic,retain)NSDictionary *propertyDic;
@property (nonatomic,assign)UIEdgeInsets defaultEdgeInsets;
@property (nonatomic,retain)KDStatusView *statusView;

//+(KDLayouter *)layouterByStatus:(KDStatus *)status frame:(CGRect)frame level:(NSInteger) level;
+(KDLayouter *)layouterWithPropertyDic:(NSDictionary *)dic;
- (void)addSubLayouter:(KDLayouter *)layout;
//- (void)updateFrame;

- (Class)statusViewClass;
//- (KDStatusView *)getView;
@end

@interface KDQuotedLayouter: KDLayouter

@end


@interface KDCoreTextLayouter : KDLayouter

//+(KDCoreTextLayouter *)layouterByText:(NSString *)text;

@end


@interface KDImageLayouter : KDLayouter

@end

@interface KDThumbnailsLayouter : KDLayouter
@end

@interface KDHeaderLayouter : KDLayouter
@end


@interface KDFooterLayoutr : KDHeaderLayouter

@end

@interface KDCommentFooterLayouter : KDLayouter

@end

@interface KDDocumentListLayouter : KDLayouter

@end

@interface KDCommentCellLayouter:KDLayouter
+ (KDLayouter *)layouter:(KDCommentStatus *)status constrainedWidth:(CGFloat) width;
@end

@interface KDRepostStatusLayouter:KDLayouter
+ (KDLayouter *)layouter:(KDStatus *)status constrainedWidth:(CGFloat) width;

@end

@interface KDDMMessageLayouter : KDLayouter
+ (KDLayouter *)layouter:(KDDMMessage *)message constrainedWidth:(CGFloat)width shouldDisplayTimeStamp:(BOOL)should;
@end