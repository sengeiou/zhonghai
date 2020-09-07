//
//  KDMentionMeStatusDataProvider.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-3.
//
//

#import "KDMentionMeStatusDataProvider.h"

@implementation KDMentionMeStatusDataProvider
//override
- (KDTLStatusType)type {
    return KDTLStatusTypeMentionMe;
}
//override
- (NSString *)actionPath {
    return @"/statuses/:mentions";
}
//override
- (SEL)statuesSavingSelector {
    return @selector(saveMentionMeStatuses:database:rollback:);
}
//override
- (SEL)countingSavingSelector {
    return @selector(updateMentionMeStatusCounts:database:);
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
    [unreadManager didChangeMessageBadgeValue:YES resetComments:NO resetDM:NO];
}
- (void)cellSelected {
    NSLog(@"cell seleted...");
}

- (CGFloat)calculateStatusContentHeight:(KDStatus *)status {
    return 44;
}
- (KDQuery *)latestStatusQuery {
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"includ_group" stringValue:@"true"];
    [query queryByAddQuery:[super latestStatusQuery]];
    return query;
}
@end
