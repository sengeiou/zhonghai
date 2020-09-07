//
//  KDServiceActionPathMapping.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-21.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDServiceActionPathMapping.h"

@interface KDServiceActionPathMapping ()

@property (nonatomic, retain) NSDictionary *pathsAndURLs;

@end


@implementation KDServiceActionPathMapping {
 @private
    
}

@synthesize pathsAndURLs=pathsAndURLs_;

- (id)init {
    self = [super init];
    if (self) {
        [self _setupActionPathsAndURLsMapping];
    }
    
    return self;
}

- (void)_setupActionPathsAndURLsMapping {
    
    /*
    NSDictionary *temp = @{@"account" : @{@"" : @"", @"" : @""}, };
    NSArray *temp2 = @[];
    
    NSDictionary *map = @{@"/account/:updateProfile" : @"/account/update_profile.json",
    @"/account/:updateProfileImage" : @"/account/updateProfileImage.json",};
    
	<key>/account/</key>
	<array>
    updateProfile
    updateProfileImage
    verifyCredentials
	</array>
	<key>/admin/</key>
	<array>
    registerAccount
	</array>
	<key>/auth/</key>
	<array>
    requestToken
    accessToken
	</array>
	<key>/client/</key>
	<array>
    uploadCrashReport
    shareUpdates
    checkUpdates
    storeDevice
    removeDevice
    userApplication
	</array>
	<key>/dm/</key>
	<array>
    dm
    newMessage
    more
    newMulti
    reply
    sent
    upload
    threadById
    threadByIdAddParticipant
    threadMessages
    threadByIdNewMessage
    threads
    threadParticipant
    threadsMore
    threadsNew
	</array>
	<key>/event/</key>
	<array>
    event
    message
    send
	</array>
	<key>/favorites/</key>
	<array>
    favorites
    create
    destoryById
    destoryBatch
	</array>
	<key>/friendships/</key>
	<array>
    create
    createById
    destroy
    destroyById
    exists
    show
	</array>
	<key>/group/</key>
	<array>
    details
    joined
    list
    members
	</array>
	<key>/group/statuses/</key>
	<array>
    comment
    counts
    destroyById
    periodTimeline
    periodTimelineByCursor
    repost
    showById
    timeline
    timelineByCursor
    update
    upload
    uploadComment
	</array>
	<key>/hot_blog/</key>
	<array>
    comment
    forward
	</array>
	<key>/like/</key>
	<array>
    like
    counts
    create
    destoryById
    destroyBatch
	</array>
	<key>/network/</key>
	<array>
    list
    selectByDomain
	</array>
	<key>/share/</key>
	<array>
    add
    count
    login
	</array>
	<key>/statuses/</key>
	<array>
    comment
    commentById
    comments
    commentsByCursor
    commentByMe
    commentDestory
    commentsTimeline
    commentsToMe
    counts
    destoryById
    followers
    followersById
    forwards
    friends
    friendsById
    friendsTimeline
    friendsTimelineByCursor
    mentions
    publicTimeline
    hotComments
    reply
    repost
    resetCount
    retweetById
    search
    showById
    unread
    update
    upload
    uploadComment
    userTimeline
    userTimelineByCursor
    timelineById
	</array>
	<key>/trends/</key>
	<array>
    trends
    listDefault
    all
    daily
    destroy
    detail
    follow
    fresh
    month
    recently
    statuses
    weekly
    search
	</array>
	<key>/users/</key>
	<array>
    feedback
    followedTopicNumber
    members
    search
    show
    showById
	</array>
	<key>/vote/</key>
	<array>
    resultById
    vote
    share
	</array>
    </dict>
     */
}

+ (KDServiceActionPathMapping *)globalActionPathMapping {
    static KDServiceActionPathMapping *globalMapping_ = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalMapping_ = [[KDServiceActionPathMapping alloc] init];
    });
    
    return globalMapping_;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(pathsAndURLs_);
    
    //[super dealloc];
}

@end
