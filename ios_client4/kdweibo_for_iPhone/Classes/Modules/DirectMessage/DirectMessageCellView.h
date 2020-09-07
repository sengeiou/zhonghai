//
//  DirectMessageCellView.h
//  kdweibo
//
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDDMThread;
@class KDInbox;
@interface DirectMessageCellView : UIView {
 @private
    UILabel *titleLabel_;
    UILabel *summaryLabel_;
    UILabel *lastDateLabel_;
    UIImageView *audioSendFailedImageView_;
}

- (void)updateWithDMThread:(KDDMThread *)thread;

@property (nonatomic, assign) BOOL highlighted;
@end
