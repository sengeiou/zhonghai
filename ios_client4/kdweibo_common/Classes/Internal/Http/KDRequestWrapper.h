//
//  KDRequestWrapper.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-9.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDAuthorization.h"
#import "KDRequestParameter.h"
#import "KDRequestMethod.h"

#import "ASIHTTPRequest.h"

#import "KDResponseWrapper.h"
#import "KDRequestProgressMonitor.h"

@protocol KDRequestWrapperDelegate;
@class KDRequestWrapper;


enum {
    KDAPIUndefined = 0,
    
    // auth api methods
    KDAPIAuthRequestToken = 1,
    KDAPIAuthAccessToken,
    
    // statuses api methods
    KDAPIStatusesComment = 50,
    KDAPIStatusesCommentById,
    KDAPIStatusesComments,
    KDAPIStatusesCommentsByCursor,
    KDAPIStatusesCommentsByMe,
    KDAPIStatusesCommentsDestroy,
    KDAPIStatusesCommentsTimeline,
    KDAPIStatusesCommentsToMe,
    KDAPIStatusesCounts,
    KDAPIStatusesDestroyById,
    KDAPIStatusesFollowers,
    KDAPIStatusesFollowersById,
    KDAPIStatusesForwards,
    KDAPIStatusesFriends,
    KDAPIStatusesFriendsById,
    KDAPIStatusesFriendsTimeline,
    KDAPIStatusesFriendsTimelineBycursor,
    KDAPIStatusesMentions,
    KDAPIStatusesPublicTimeline,
    KDAPIStatusesHotComments,
    KDAPIStatusesReply,
    KDAPIStatusesRepost,
    KDAPIStatusesResetCount,
    KDAPIStatusesRetweetById,
    KDAPIStatusesSearch,
    KDAPIStatusesShowById,
    KDAPIStatusesUnread,
    KDAPIStatusesUpdate,
    KDAPIStatusesUpload,
    KDAPIStatusesUploadComment,
    KDAPIStatusesUserTimeline,
    KDAPIStatusesUserTimelineByCursor,
    KDAPIStatusesUserTimelineById,
    
    
    // users api methods
    KDAPIUsersFeedback = 150,
    KDAPIUsersFollowedTopicNumber,
    KDAPIUsersMembers,
    KDAPIUsersSearch,
    KDAPIUsersShow,
    KDAPIUsersShowById,
    
    // admin api methods
    KDAPIAdminCreateUnverifiedUser = 200,
    KDAPIAdminCreateUser,
    KDAPIAdminDeleteUser,
    KDAPIAdminExists,
    KDAPIAdminGetUser,
    KDAPIAdminPostUserInfo,
    KDAPIAdminRegister,
    
    
    // network api methods
    KDAPINetworkList = 250,
    KDAPINetworkSelectByDomain,
    
    
    // account api methods
    KDAPIAccountUpdateProfile = 300,
    KDAPIAccountUpdateProfileImage,
    KDAPIAccountVerifyCredentials,
    
    
    // friendship api methods
    KDAPIFriendshipsCreate = 350,
    KDAPIFriendshipsCreateById,
    KDAPIFriendshipsDestroy,
    KDAPIFriendshipsDestroyById,
    KDAPIFriendshipsExists,
    KDAPIFriendshipsShow,
    
    
    // friendship api methods
    KDAPIFavorites = 400,
    KDAPIFavoritesCreate,
    KDAPIFavoritesDestoryById,
    KDAPIFavoritesDestoryBatch,
    
    
    // direct message api methods
    KDAPIDirectMessages = 450,
    KDAPIDirectMessagesNewMessage,
    KDAPIDirectMessagesMore,
    KDAPIDirectMessagesNewMulti,
    KDAPIDirectMessagesReply,
    KDAPIDirectMessagesSent,
    KDAPIDirectMessagesUpload,
    KDAPIDirectMessagesThreadById,
    KDAPIDirectMessagesThreadByIdAddParticipant,
    KDAPIDirectMessagesThreadMessages,
    KDAPIDirectMessagesThreadByIdNewMessage,
    KDAPIDirectMessagesThreads,
    KDAPIDirectMessagesThreadParticipant,
    KDAPIDirectMessagesThreadsMore,
    KDAPIDirectMessagesThreadsNew,
    KDAPIDirectMessagesThreadAddParticipant,
    KDAPIDirectMessagesThreadUpdateThreadSubject,
    
    
    // hot api methods
    KDAPIHotBlogComment = 500,
    KDAPIHotBlogForward,
    
    
    // tags api methods
    KDAPITags = 550,
    KDAPITagsCreate,
    KDAPITagsDestroy,
    KDAPITagsDestroyBatch,
    
    
    // like api methods
    KDAPILike = 600,
    KDAPILikeCounts,
    KDAPILikeCreate,
    KDAPILikeDestoryById,
    KDAPILikeDestroyBatch,
    
    
    // trends api methods
    KDAPITrends = 650,
    KDAPITrendsDefault,
    KDAPITrendsAll,
    KDAPITrendsDaily,
    KDAPITrendsDestroy,
    KDAPITrendsDetail,
    KDAPITrendsFollow,
    KDAPITrendsFresh,
    KDAPITrendsMonth,
    KDAPITrendsRecently,
    KDAPITrendsStatuses,
    KDAPITrendsWeekly,
    KDAPITrendsSearch,
    
    // share api methods
    KDAPIShareAdd = 700,
    KDAPIShareCount,
    KDAPIShareLogin,
    
    
    // event api methods
    KDAPIEvent = 750,
    KDAPIEventMessages,
    KDAPIEventSend,
    
    
    // group statuses api methods
    KDAPIGroupStatusesComment = 800,
    KDAPIGroupStatusesCounts,
    KDAPIGroupStatusesDestroyById,
    KDAPIGroupStatusesPeriodTimeline,
    KDAPIGroupStatusesPeriodTimelineByCursor,
    KDAPIGroupStatusesRepost,
    KDAPIGroupStatusesShowById,
    KDAPIGroupStatusesTimeline,
    KDAPIGroupStatusesTimelineByCursor,
    KDAPIGroupStatusesUpdate,
    KDAPIGroupStatusesUpload,
    KDAPIGroupStatusesUploadComment,
    
    
    // stream api methods
    KDAPIStreamCheckSubscribe = 850,
    KDAPIStreamCreate,
    KDAPIStreamExist,
    KDAPIStreamPostActivity,
    KDAPIStreamSubscribe,
    KDAPIStreamUnread,
    KDAPIStreamUnreadCount,
    KDAPIStreamUnsubscribe,
    KDAPIStreamUpdate,
    
    
    // group api methods
    KDAPIGroupDetail = 900,
    KDAPIGroupJoined,
    KDAPIGroupList,
    KDAPIGroupMembers,
    
    
    // megagame api methods
    KDAPIMegagameCountsByIds = 950,
    KDAPIMegagameLearningFeedbackDepartmentTopic,
    KDAPIMegagameShowById,
    KDAPIMegagameShowListByIds,
    KDAPIMegagameTopicsTopic,
    KDAPIMegagameTopicsAllTopics,
    
    
    // test api methods
    KDAPITest = 1000,
    
    
    // client api methods
    KDAPIClientUploadCrashReport = 1050,
    KDAPIClientShareUpdates,
    KDAPIClientCheckUpdates,
    KDAPIClientStoreDevice,
    KDAPIClientRemoveDevice,
    KDAPIClientUserApplications,
    
    // vote api methods
    KDAPIVoteResultById = 1100,
    KDAPIVoteVote,
    KDAPIVoteShare,
    
    // address book methods
    KDAPIABRecentlyContacts = 1150,
    KDAPIABMemberList,
    KDAPIABFavoriteList,
    KDAPIABSearch,
    KDAPIABFavorite,
    KDAPIABUnFavorite
};

typedef NSUInteger KDAPIIdentifer;


typedef enum {
	KDRequestPriorityVeryLow = -10,
	KDRequestPriorityLow = -5,
	KDRequestPriorityNormal = 0,
	KDRequestPriorityMedium = 3,
	KDRequestPriorityHigh = 5,
	KDRequestPriorityVeryHigh = 10
}KDRequestPriority;


extern NSString * const kKDImageScaleSizeKey;
extern NSString * const kKDIsRequestImageSourceKey;
extern NSString * const kKDRequestImageCropTypeKey;
extern NSString * const KKDDownloadFinished;

extern NSString * const kKDCustomUserInfoKey;

/////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark blocks for request status

typedef void (^KDRequestWrapperDidCompleteBlock)(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed);
typedef void (^KDRequestWrapperConfigBlock)(KDRequestWrapper *requestWrapper, ASIHTTPRequest *request);

@interface KDRequestWrapper : NSObject {
@private
//    id<KDRequestWrapperDelegate> delegate_;
    
    id<KDAuthorization> authorization_;
    
    NSString *url_;
    KDRequestMethod *method_;
    NSArray *parameters_;
    NSDictionary *requestHeaders_;
    
    KDAPIIdentifer APIIdentifier_;
    KDRequestPriority priority_;
    NSInteger tag_;
    
    ASIHTTPRequest *httpRequest_;
    
    KDRequestProgressMonitor *progressMonitor_;
    
    // for downloads
    BOOL isDownload_;
    // Generally speaking, It's not need set a temporary path for this value manually, 
    // This class will provide one for you when this value is nil. If you wanna to custom it,
    // Please set new path for it
    NSString *downloadTemporaryPath_;
    
    // The file will be move to destination path from temporary path when download did succeed.
    // If this value was nil, the downloaded file will be removed at final.
    NSString *downloadDestinationPath_;
    
    NSString *fingerprint_;
    NSMutableDictionary *userInfo_;
    
    KDRequestWrapperDidCompleteBlock didCompleteBlock_;
    KDRequestWrapperConfigBlock configBlock_;
}

@property (nonatomic, assign) id<KDRequestWrapperDelegate> delegate;

@property (nonatomic, retain) id<KDAuthorization> authorization;

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) KDRequestMethod *method;
@property (nonatomic, retain) NSArray *parameters;
@property (nonatomic, retain) NSDictionary *requestHeaders;

@property (nonatomic, assign) KDAPIIdentifer APIIdentifier;
@property (nonatomic, assign) KDRequestPriority priority;
@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, retain, readonly) KDRequestProgressMonitor *progressMonitor;

@property (nonatomic, assign) BOOL isDownload;
@property (nonatomic, retain) NSString *downloadTemporaryPath; 
@property (nonatomic, retain) NSString *downloadDestinationPath;

@property (nonatomic, copy) NSString *fingerprint;
@property (nonatomic, retain) NSDictionary *userInfo;

@property (nonatomic, copy) KDRequestWrapperDidCompleteBlock didCompleteBlock;
@property (nonatomic, copy) KDRequestWrapperConfigBlock configBlock;

- (id) initWithURL:(NSString *)url method:(KDRequestMethod *)method parameters:(NSArray *)parameters requestHeaders:(NSDictionary *)requestHeaders;
- (id) initWithDelegate:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url method:(KDRequestMethod *)method parameters:(NSArray *)parameters requestHeaders:(NSDictionary *)requestHeaders identifier:(KDAPIIdentifer)identifier;

- (void) addUserInfoWithObject:(id)obj forKey:(NSString *)aKey;
- (void) removeUserInfoForKey:(NSString *)aKey;
- (void) removeAllUserInfo;

- (ASIHTTPRequest *) getHttpRequest;

- (KDUInt64) postDataContentLength;

@end


@protocol KDRequestWrapperDelegate <NSObject>
@optional

// the request did not push to request queue, because this request is invalid, or exist duplicate requests in the queue,
// for instance, list new statuses more than one.
- (void) didDropRequestWrapper:(KDRequestWrapper *)requestWrapper error:(NSError *)error;

- (void) requestWrapper:(KDRequestWrapper *)requestWrapper requestDidStart:(ASIHTTPRequest *)request;
- (void) requestWrapper:(KDRequestWrapper *)requestWrapper request:(ASIHTTPRequest *)request didRecieveResponseHeaders:(NSDictionary *)responseHeaders;

- (void) requestWrapper:(KDRequestWrapper *)requestWrapper request:(ASIHTTPRequest *)request progressMonitor:(KDRequestProgressMonitor *)progressMonitor;

- (void) requestWrapper:(KDRequestWrapper *)requestWrapper responseWrapper:(KDResponseWrapper *)responseWrapper requestDidFinish:(ASIHTTPRequest *)request;

@end


