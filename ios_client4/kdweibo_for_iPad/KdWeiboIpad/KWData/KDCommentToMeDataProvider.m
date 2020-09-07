//
//  KDCommentToMeDataProvider.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-3.
//
//

#import "KDCommentToMeDataProvider.h"

@implementation KDCommentToMeDataProvider
- (KDTLStatusType)type {
    return KDTLStatusTypeCommentMe;
}
//override
- (NSString *)actionPath {
    return @"/statuses/:commentsToMe";
}
//override
- (SEL)statuesSavingSelector {
    return @selector(saveCommentMeStatuses:database:rollback:);
}
//override
- (SEL)countingSavingSelector {
    return @selector(updateCommentMeStatusCounts:database:);
}
//override
- (BOOL)showAccurateGroupName {
    return NO;
}
//override
- (NSInteger)statueslimits {
    return 20;
}
//override
- (void)updateUnread {
    KDUnreadManager *unreadManager = [KDManagerContext globalManagerContext].unreadManager;
    [unreadManager didChangeMessageBadgeValue:NO resetComments:YES resetDM:NO];
}
- (void)cellSelected {
    NSLog(@"cell seleted...");
}

- (CGFloat)calculateStatusContentHeight:(KDStatus *)status {
    return 44;
}
- (KDQuery *)earlierStatusQuery {
    KDQuery *query = [KDQuery query];
    [query setParameter:@"include_group" stringValue:@"true"];
    [query queryByAddQuery:[super earlierStatusQuery]];
    return query;
}
- (KDQuery *)latestStatusQuery {
    KDQuery *query = [KDQuery query];
    [query setParameter:@"include_group" stringValue:@"true"];
    [query queryByAddQuery:[super latestStatusQuery]];
    return query;
}
@end
