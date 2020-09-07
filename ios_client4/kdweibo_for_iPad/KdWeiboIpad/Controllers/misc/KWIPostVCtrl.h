//
//  KWIPostVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/10/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDStatus, KDCommentStatus, KDUser, KDGroup;

@interface KWIPostVCtrl : UIViewController 

+ (KWIPostVCtrl *)vctrl;

- (void)newStatus;
- (void)newStatusWithGroup:(KDGroup *)group;
- (void)newMention:(KDUser *)user;
- (void)replyStatus:(KDStatus *)status;
//- (void)replyComment:(KWComment *)comment;
- (void)replyComment:(KDCommentStatus *)comment status:(KDStatus *)status;
- (void)repostStatus:(KDStatus *)status;
- (void)dismiss;

@end
