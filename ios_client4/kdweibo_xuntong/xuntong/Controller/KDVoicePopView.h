//
//  KDVoicePopView.h
//  kdweibo
//
//  Created by tangzeng on 2017/3/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol KDVoicePopViewDelegate<NSObject>
- (void)invitePersonJoinMeeting;
- (void)sharePPTForMeeting;
//- (void)joinMeetingByPhone;

@end


@interface KDVoicePopView : UIView
@property (nonatomic, weak) id<KDVoicePopViewDelegate> delegate;
@property (nonatomic, assign) BOOL enableSharePPT;
- (void)hiddenPopView;
- (void)showPopView;
@end
