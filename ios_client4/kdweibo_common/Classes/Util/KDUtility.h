//
//  KDUtility.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "KDCommon.h"
#import "KDCompositeImageSource.h"
#import "KDUser.h"
#import "KDStatus.h"
#import "KDManagerContext.h"
enum {
    KDDocumentDirectory = 1,
    
    KDPicturesDirectory = 10,
    KDPicturesAvatarDirectory,
    KDPicturesPreviewDirectory,
    KDPicturesUnsendDirectory,
    KDPicturesEmailDirectory,
    
    KDDownloadDirectory = 20,
    KDDownloadDocument,
    KDDownloadDocumentTemp,
    KDDownloadAudio,
    KDDownloadAudioTemp,
    KDDownloadAudioUnsend,
    
    KDUserDirectory = 50,
    KDUserDatabaseDirectory,
    KDUserDocumentDirectory,
    KDUserPreviewDirectory,
    KDUserThumbnailDirectory,
    KDUserLogsDirectory,
    
    KDApplicationTemporaryDirectory = 110,
    
    KDUserUploadsDirectory = 120,
    KDUserDownloadsDirectory,
    
    KDVideosDirectory = 140,
    KDDownloadVideosTempDirectory,
    
};

typedef NSUInteger KDSearchPathDirectory;


enum {
    KDPersitentDomainMask = 1,
    KDTemporaryDomainMask = 2
};

typedef NSUInteger KDSearchPathDomainMask;



@interface KDUtility : NSObject {
@private
    NSString *uniqueUserToken_;
    NSMutableDictionary *cachedPaths_;
}

+ (KDUtility *) defaultUtility;
+ (void) setDefaultUtility:(KDUtility *)defaultUtility;
// device and application status
- (BOOL)isActiveApplication;
- (BOOL)isHighResolutionDevice;

// file system
- (NSString *)searchDirectory:(KDSearchPathDirectory)directory inDomainMask:(KDSearchPathDomainMask)domainMask needCreate:(BOOL)needCreate;

// this method should work for user logout action
- (void)removeAllCachedDataForCurrentUser;

- (KDUInt64)fileSizeForPath:(NSString*)path;

- (BOOL)isAppDocumentWithPath:(NSString *)path;
- (NSString *)pathByDeletingAppDocumentFromPath:(NSString *)path;
- (NSString *)pathByDeletingAppDocumentFromPath:(NSString *)path isDir:(BOOL)isDir;

- (NSString *)duplicateFileAtPath:(NSString *)srcPath toPath:(NSString *)toPath succeed:(BOOL *)succeed;
- (NSString *)uniqueNameAtPath:(NSString *)path;

//about status
//是否为本人的status
- (BOOL)isMyStatus:(KDStatus *)status;
- (NSString *)currentUserId;
- (KDUser *)currentUser;
- (NSString *)userNamesByUsers:(NSArray *)users;
- (NSString *)currentCompanyId;
- (KDCompositeImageSource *)compositeImageSourceByLocalImageSources:(NSArray *)sources;

- (NSString *)companySpecifickey:(NSString *)key;
@end


// utility methods

NSTimeInterval millisecondsToSeconds(NSTimeInterval milliseconds);
NSTimeInterval secondsToMilliseconds(NSTimeInterval seconds);

