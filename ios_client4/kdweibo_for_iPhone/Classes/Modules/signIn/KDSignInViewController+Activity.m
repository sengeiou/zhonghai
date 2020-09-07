//
//  KDSignInViewController+Activity.m
//  kdweibo
//
//  Created by shifking on 15/10/30.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController+Activity.h"
#import "KDCommonHintView.h"
#import "KDImageSourceConfig.h"
#import <objc/runtime.h>
#import "NSString+Operate.h"
#import "KDSignInRecord.h"
#import "BOSConfig.h"
#import "NSDate+Additions.h"
#import "KDSheetRecommend.h"
static NSString * ActivityHintViewKey;
static NSString * CancelActivityKey;

@interface KDSignInViewController()
@property (strong , nonatomic) KDSignInActivityHintView *activityHintView;
@property (nonatomic, strong) KDSheetRecommend *shareSheet;

@end

@implementation KDSignInViewController (Activity)
#pragma mark -setter  &  getter
- (void)setActivityHintView:(KDSignInActivityHintView *)activityHintView {
    objc_setAssociatedObject(self, &ActivityHintViewKey, activityHintView, OBJC_ASSOCIATION_RETAIN);
}

- (KDSignInActivityHintView *)activityHintView {
    return objc_getAssociatedObject(self, &ActivityHintViewKey);
}

- (void)setCancelActivity:(BOOL)cancelActivity {
    objc_setAssociatedObject(self, &CancelActivityKey, @(cancelActivity), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)cancelActivity {
    NSNumber *number = objc_getAssociatedObject(self, &CancelActivityKey);
    if (!number) return NO;
    return [number boolValue];
}

- (BOOL)showActivityWithRecord:(KDSignInRecord *)record {
    
    if (record.attendanceActivityDic != [NSNull null] && record.attendanceActivityDic.count > 0) {
        KDSignInActivityModel *model = [[KDSignInActivityModel alloc] init];
        model.model = record.attendanceActivityDic;
        if (model.activityId && model.picId) {
            self.activityHintView = [[KDSignInActivityHintView alloc] init];
            self.activityHintView.model = model;
            __weak __typeof(self) weakSelf = self;
            self.activityHintView.buttonDidClickedBlock = ^(NSInteger index) {
                if (index == 0) {
                    //签到迁移暂时屏蔽
//                    KDBlockActivityRequest *request = [[KDBlockActivityRequest alloc] initWithActivityId:model.activityId];
//                    [request start];
                }
                else if (index == 1) {
                    if (model.btnActionUrl && model.btnActionUrl.length > 0) {
                        [KDSchema openWithUrl:model.btnActionUrl appId:nil title:nil share:nil controller:weakSelf];
                    }
                }
            };
            [self.activityHintView show];
            return YES;
        }
    }
    
    return NO;
}

@end
