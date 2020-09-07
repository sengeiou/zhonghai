//
//  KDFriendStatusDataProvider.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-3.
//
//

#import "KDFriendStatusDataProvider.h"

@implementation KDFriendStatusDataProvider
//override
- (KDTLStatusType)type {
    return KDTLStatusTypeFriends;
}
//override
- (NSString *)actionPath {
    return @"/statuses/:friendsTimeline";
}
//override
- (SEL)statuesSavingSelector {
    return @selector(saveStatuses:database:rollback:);
}
//override
- (SEL)countingSavingSelector {
    return @selector(updateStatusCounts:database:);
}
//override
- (BOOL)showAccurateGroupName {
    return NO;
}
//override
- (NSInteger)statueslimits {
    return 50;
}
//override
- (void)updateUnread {
    KDUnreadManager *unreadManager = [KDManagerContext globalManagerContext].unreadManager;
    [unreadManager didChangeFriendTimelineBadge:YES];
}
- (void)cellSelected {
    NSLog(@"cell seleted...");
}

@end
