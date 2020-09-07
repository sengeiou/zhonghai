//
//  KDSheetRecommend.m
//  kdweibo
//
//  Created by janon on 15/2/9.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSheetRecommend.h"

@implementation KDSheetRecommend

- (void)buttonPressed:(UIButton *)button {
    [self recommendEventWithShareType:button.tag];
    [super shareWithShareType:super.shareType shareWay:button.tag];
    [super hideSheet];
}


#pragma mark - 推荐埋点

- (void)recommendEventWithShareType:(KDSheetShareWay)way {
//    if (way == KDSheetShareWaySMS) {
//        [KDEventAnalysis event:event_recommend_thirdpart
//                    attributes:@{event_recommend_thirdpart_type : event_recommend_thirdpart_type_sms}];
//    }
//    else if (way == KDSheetShareWayQzone) {
//        [KDEventAnalysis event:event_recommend_thirdpart
//                    attributes:@{event_recommend_thirdpart_type : event_recommend_thirdpart_type_qzone}];
//    }
//    else if (way == KDSheetShareWayWechat) {
//        [KDEventAnalysis event:event_recommend_thirdpart
//                    attributes:@{event_recommend_thirdpart_type : event_recommend_thirdpart_type_wechat}];
//    }
//    else if (way == KDSheetShareWayWeibo) {
//        [KDEventAnalysis event:event_recommend_thirdpart
//                    attributes:@{event_recommend_thirdpart_type : event_recommend_thirdpart_type_weibo}];
//    }
//    else if (way == KDSheetShareWayMoment) {
//        [KDEventAnalysis event:event_recommend_thirdpart
//                    attributes:@{event_recommend_thirdpart_type : event_recommend_thirdpart_type_moments}];
//    }
//    else if (way == KDSheetShareWayQQ) {
//        [KDEventAnalysis event:event_recommend_thirdpart
//                    attributes:@{event_recommend_thirdpart_type : event_recommend_thirdpart_type_qq}];
//    }
}
@end
