//
//  KDGroupStatusDataProvider.m
//  KdWeiboIpad
//
//  Created by Tan YingQi on 13-4-21.
//
//

#import "KDGroupStatusDataProvider.h"
#import "KDGroupStatus.h"
@implementation KDGroupStatusDataProvider
@synthesize group = group_;
- (KDTLStatusType)type {
    return KDTLStatusTypeGroupStatus;
}
//override
- (NSString *)actionPath {
    return @"/group/statuses/:periodTimeline";
}
//override
- (SEL)statuesSavingSelector {
    return @selector(saveGroupStatuses:database:rollback:);
}
//override
- (SEL)countingSavingSelector {
    return nil;
}
//override
- (BOOL)showAccurateGroupName {
    return YES;
}
//override
- (NSInteger)statueslimits {
    return 20;
}
//override
- (void)updateUnread {
    KDUnreadManager *unreadManager = [KDManagerContext globalManagerContext].unreadManager;
    [unreadManager didChangeGroupsBadgeValue:YES groupId:group_.groupId];
}
- (void)cellSelected {
    NSLog(@"cell seleted...");
}

- (CGFloat)calculateStatusContentHeight:(KDStatus *)status {
    return 44;
}

- (KDQuery *)latestStatusQuery {
    KDQuery *query = [KDQuery queryWithName:@"group_id" value:group_.groupId];
    NSInteger count = 50;
    KDGroupStatus *gs = nil;
    NSString *range = nil;
    if ([self.dataSet count] > 0) {
            gs = (KDGroupStatus *)[self.dataSet statusAtIndex:0];
            range = @"from";
    }
    [query setParameter:@"count" integerValue:count];
    
    if(range != nil){
        NSTimeInterval seconds = [gs.updatedAt timeIntervalSince1970];
        [query setParameter:range unsignedLongLongValue:(KDUInt64)secondsToMilliseconds(seconds)];
    }
    return query;

}

- (KDQuery *)earlierStatusQuery {
    KDQuery *query = [KDQuery queryWithName:@"group_id" value:group_.groupId];
    NSInteger count = 20;
    KDGroupStatus *gs = nil;
    NSString *range = nil;
    if ([self.dataSet count] > 0) {
        gs = (KDGroupStatus *)[self.dataSet lastStatus];
        range = @"to";
    }
    [query setParameter:@"count" integerValue:count];
    if(range != nil){
        NSTimeInterval seconds = [gs.updatedAt timeIntervalSince1970];
        [query setParameter:range unsignedLongLongValue:(KDUInt64)secondsToMilliseconds(seconds)];
    }
    return query;
}
- (void)dealloc {
    KD_RELEASE_SAFELY(group_);
    [super dealloc];
}
@end
