//
//  KDExtendStatus.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-4.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDObject.h"
#import "KDCompositeImageSource.h"

// Third part weibo status. just support Sina weibo at now.

@interface KDExtendStatus : KDObject

@property(nonatomic, retain) NSString *statusId; // weibo id
@property(nonatomic, retain) NSString *site;
@property(nonatomic, retain) NSString *content; // the content of weibo
@property(nonatomic, retain) NSString *senderName; // the author name of original weibo
@property(nonatomic, retain) NSString *forwardedSenderName; // the author name of forwarded weibo
@property(nonatomic, retain) NSString *forwardedContent; // the content of forwarded weibo

@property(nonatomic, assign) NSUInteger createdAt; // the creation date time of this weibo
@property(nonatomic, assign) NSUInteger forwardedAt; // the forwarded date time about forwarded forwarded weibo

@property(nonatomic, retain) KDCompositeImageSource *compositeImageSource; // composite image source
@property(nonatomic, assign) KDExtraSourceMask extraSourceMask;

- (BOOL)hasForwarded; // check this status has forwarded status or not. return YES means has forwarded status, otherwise is NO.

@end
