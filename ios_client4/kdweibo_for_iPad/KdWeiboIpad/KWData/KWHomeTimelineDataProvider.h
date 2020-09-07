//
//  KWHomeTimelineDataProvider.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


/**
 @brief callbacks get called when data changes
 */
@protocol KWHomeTimelineDataDelegate

@optional
- (void)hometimelinePrepended:(NSArray *)statuses;
- (void)hometimelineAppended:(NSArray *)statuses;

- (void)loadingFailedWithError:(NSError *)err;

@end

/**
 @brief 
 */
@interface KWHomeTimelineDataProvider : KWDataProvider

@property (nonatomic, retain) NSObject<KWHomeTimelineDataDelegate> *delegate;

+ (KWHomeTimelineDataProvider *)provider;
+ (KWHomeTimelineDataProvider *)providerWithDelegate:(NSObject<KWHomeTimelineDataDelegate> *) delegate;

- (void)reload:(void (^)(NSArray *))onSuccess;
- (void)refresh;
- (void)loadmore;

- (void)remove:(KWStatus *)status;

@end
