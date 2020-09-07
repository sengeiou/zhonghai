//
//  KDHomeStatusDataProvider.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-1.
//
//

#import "KDCompanyStatusDataProvider.h"

@implementation KDCompanyStatusDataProvider
//override
- (KDTLStatusType)type {
    return KDTLStatusTypePublic;
}
//override
- (NSString *)actionPath {
   return @"/statuses/:publicTimeline";
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
    [unreadManager didChangePublicTimelineBadge:YES];
}
- (void)cellSelected {
    NSLog(@"cell seleted...");
}

@end
