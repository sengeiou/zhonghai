//
//  KDInboxRenderView.h
//  kdweibo
//
//  Created by bird on 13-7-12.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDInbox.h"
#import "KDExpressionLabel.h"
#import "KDStatusExpressionLabel.h"


//收件箱只有提及，回复内容
enum {
    KDInboxInteractiveTypeMetion = 0x01,
    KDInboxInteractiveTypeComment ,
    KDInboxInteractiveTypeUnknown
};

typedef NSInteger KDInboxInteractiveType;


@interface KDInboxRenderView : UIView<KDExpressionLabelDelegate>
{
    KDInbox *inbox_;
    
    KDStatusExpressionLabel *replyLabel_;
    KDStatusExpressionLabel *contentLabel_;
    
    KDInboxInteractiveType type_;
    
    BOOL   replyNeedHiden_;
    
    UIImageView           *backgroundView_;
}
@property(nonatomic, retain) KDInbox *inbox;
@property(nonatomic, assign, readonly) KDInboxInteractiveType type;

+ (CGFloat)calculateInboxDisplaySize:(KDInbox *)inbox constrainedToSize:(CGSize)size;
@end
