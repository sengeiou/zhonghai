//
//  KDWeiboServices.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDRequestWrapper.h"

@protocol KDAuthorization;

@class KDDownload;
@class KDImageSize;
@class KDServiceActionInvoker;

@protocol KDWeiboServices <NSObject>
@required

@property(nonatomic, copy) NSString *currentCommunityDomain;

- (void)updateWithBasicAuthorization:(NSString *)identifer passcode:(NSString *)passcode;
- (void)updateAuthorization:(id<KDAuthorization>)authorization;

- (NSString *)baseURLWithSuffix:(NSString *)suffix; // server base url
- (NSString *)communityURLWithSuffix:(NSString *)suffix; // the community base url

- (KDRequestWrapper *)toRequestWrapper:(KDServiceActionInvoker *)invoker isGet:(BOOL)isGet
                            usingBlock:(KDRequestWrapperDidCompleteBlock)block;

- (void)doRequest:(KDRequestWrapper *)requestWrapper transferType:(NSUInteger)type authNeed:(BOOL)authNeed communityNeed:(BOOL)communityNeed;

// load the avatar of user
- (void)accountAvatar:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url scaleToSize:(KDImageSize *)size;

// load the avatar of group
- (void)groupAvatar:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url scaleToSize:(KDImageSize *)size;

// load the images in statuses
- (void)statusesImageSource:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url
                  cacheType:(NSUInteger)cacheType scaleToSize:(KDImageSize *)size userInfo:(id)userInfo;

// download the attachments in status
- (void)startDownloadWithDownload:(KDDownload *)download delegate:(id<KDRequestWrapperDelegate>)delegate;
- (void)startDownloadWithDownload:(KDDownload *)download delegate:(id<KDRequestWrapperDelegate>)delegate completionBlock:(KDRequestWrapperDidCompleteBlock)block;
- (void)cancleAllDownloadWithDlegate:(id<KDRequestWrapperDelegate>)delegate;
- (void)cancleDownload:(KDDownload *)download;

@end
