//
//  KDStatus.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-4.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDObject.h"

#import "KDUser.h"
#import "KDCompositeImageSource.h"
#import "KDExtendStatus.h"
#import "KDStatusExtraMessage.h"

typedef enum : NSUInteger {
    KDTLStatusTypeUndefined = 0,
    
    KDTLStatusTypePublic = 1, // company public or community public statuses
    KDTLStatusTypeFriends, // company friend's or community friend's statuses
    KDTLStatusTypeHotComment, // company hot or community hot statuses with comments
    KDTLStatusTypeBulletin,
    KDTLStatusTypeShareSignin, //签到 王松 2013-10-21
    
    KDTLStatusTypeMentionMe = 10,
    KDTLStatusTypeCommentMe,
    
    KDTLStatusTypeGroupStatus = 20,
    
    KDTLStatusTypeComment = 30, // comment on status
    
    KDTLStatusTypeForwarded = 1 << 10, // the forwarded status
    KDTLStatusTypeFavorited = 1 << 11, // the favorited status
    
}KDTLStatusType;


typedef enum : NSUInteger {
    KDStatusSendingStateNone = 0,   //默认状态
    KDStatusSendingStateFailed,   //发送失败
    KDStatusSendingStateProcessing, //正在发送
    KDStatusSendingStateSuccess   //发送成功
}KDStatusSendingState;

extern NSString * const kKDHasBeenDeletedStatusId; // mark as that status has been deleted


@interface KDStatus : KDObject

@property(nonatomic, retain) NSString *statusId;
@property(nonatomic, retain) NSString *text; // the content of this status
@property(nonatomic, retain) KDUser *author; // the author of this status

@property(nonatomic, retain) NSString *groupId;
@property(nonatomic, retain) NSString *groupName;

@property(nonatomic, retain) NSDate *createdAt;
@property(nonatomic, retain) NSDate *updatedAt;

@property(nonatomic, retain) NSString *source; // like: from iPhone, Web etc.

@property(nonatomic, assign) float latitude;
@property(nonatomic, assign) float longitude;
@property(nonatomic, retain) NSString *address;

@property(nonatomic, assign) BOOL favorited; //
@property(nonatomic, assign) BOOL truncated; // YES means the content of status did truncated. otherwise is not
@property(nonatomic, assign) BOOL isPrivate;
@property(nonatomic, assign) BOOL liked;   //

@property(nonatomic, assign) NSInteger commentsCount; // a amount the comments number for this status
@property(nonatomic, assign) NSInteger forwardsCount; // a amount of the forwards number for this status
@property(nonatomic, assign) NSInteger likedCount;
@property(nonatomic, retain) KDStatus *forwardedStatus; //
@property(nonatomic, retain) KDExtendStatus *extendStatus; // for third part status, It just can be sina weibo at now

@property(nonatomic, retain) KDStatusExtraMessage *extraMessage; // the extra message like Bulletin, Freshman, Vote etc.

// the images for this status (it contains thumbnail, midddle, original for each image source object)
@property(nonatomic, retain) KDCompositeImageSource *compositeImageSource;
@property(nonatomic, retain) NSArray *attachments; // the documents of this status

@property(nonatomic, assign) KDTLStatusType type; // which status timeline type of this status (Public, Friend, Hot comments etc.)

// the extra source mask bits. It is point out which extra source (image source, attachments etc) belongs to this status.
// And use it to decrease the database query times.
@property(nonatomic, assign) KDExtraSourceMask extraSourceMask;

@property(nonatomic, retain) NSString *replyStatusId;//被回复的评论或者微博ID

@property(nonatomic, retain) NSString *replyUserId; //被回复的评论的作者得userId
@property(nonatomic, retain) NSString *replyScreenName; //被回复的评论的作者

@property (nonatomic, assign) CGFloat sendingProgress;

@property (nonatomic, assign) KDStatusSendingState  sendingState;   //发送状态

//@property (nonatomic,strong) NSArray *delData;

@property(nonatomic, retain) NSArray *microBlogComments; //回复内容
@property(nonatomic, retain) NSArray *likeUserInfos; //点赞内容


// traversal the status (also in forwarded status and extend status) and try to find out it is with image source
- (BOOL)hasExtraImageSource;

// retrieve the image source from status (also in forwarded status and extend status)
- (KDCompositeImageSource *)actuallyCompositeImageSourceAndType:(NSUInteger *)type;

// return YES it's means this status with an forwarded status, otherwise is NO.
- (BOOL)hasForwardedStatus;

// return YES it's means there are attachment(s) in this status, otherwise is NO.
- (BOOL)hasAttachments;

- (BOOL)hasVideo;

- (BOOL)hasBeenDeleted; //

- (BOOL)hasAddress;

- (BOOL)isGroup;

- (BOOL)hasTask;

- (NSString *)taskFormatContet;

- (NSString *)createdAtDateAsString;


//用于ipad viewController的动画和uploadtask 的删除
- (NSString *)id_;
@end

