//
//  KDTimelineManager.m
//  kdweibo
//
//  Created by AlanWong on 14-10-9.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDTimelineManager.h"
#import "BOSConfig.h"
#define kNumberOfPages @"kNumberOfPages"
#define kHasInitTimeLine @"kHasInitTimeLine"
@implementation KDTimelineManager
+(KDTimelineManager *)shareManager
{
    static KDTimelineManager * timeLineManager = nil;
    @synchronized(self)
    {
        if (timeLineManager == nil)
        {
            timeLineManager = [[self alloc] init];
        }
    }
    return timeLineManager;
}

-(void)deleteCompanyInfoForPageRequest{
    NSString * identifyKey1 = [NSString stringWithFormat:@"%@%@%@",kHasInitTimeLine,[self companyEid],[self userId]];
    NSString * identifyKey2 = [NSString stringWithFormat:@"%@%@%@",kHasInitTimeLine,[self companyEid],[self userId]];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:identifyKey1];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:identifyKey2];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}


-(BOOL)shouldStarPagingRequest{
    NSString * identifyKey = [NSString stringWithFormat:@"%@%@%@",kHasInitTimeLine,[self companyEid],[self userId]];
    BOOL hasInitTimeLine = [[NSUserDefaults standardUserDefaults]boolForKey:identifyKey];
    return !hasInitTimeLine;
}

-(void)setFinishPageRequest{
    NSString * identifyKey = [NSString stringWithFormat:@"%@%@%@",kHasInitTimeLine,[self companyEid],[self userId]];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:identifyKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

-(NSInteger)numberOfPages{
    NSString * identifyKey = [NSString stringWithFormat:@"%@%@%@",kNumberOfPages,[self companyEid],[self userId]];
    NSInteger numberOfPages = [[NSUserDefaults standardUserDefaults]integerForKey:identifyKey];
    return numberOfPages;
}

-(void)setNumberOfPages:(NSInteger)numberOfPages{
    NSString * identifyKey = [NSString stringWithFormat:@"%@%@%@",kNumberOfPages,[self companyEid],[self userId]];
    [[NSUserDefaults standardUserDefaults] setInteger:numberOfPages forKey:identifyKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSString * )companyEid{
    KDCommunityManager *communityManager = [[KDManagerContext globalManagerContext]communityManager];
    return communityManager.currentCompany.eid;
}
-(NSString * )userId{
//    KDCommunityManager *communityManager = [[KDManagerContext globalManagerContext]communityManager];
//    return communityManager.currentCompany.user.userId;
    
    // 一个工作圈的userId对应的是主账号的userId，切换团队账号后userId应随之改变，以确保identifyKey的唯一性
    NSString *userId = [BOSConfig sharedConfig].user.userId;
    return userId;
}
@end
