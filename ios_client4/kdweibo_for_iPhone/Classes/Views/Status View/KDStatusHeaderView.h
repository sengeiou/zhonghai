//
//  KDStatusHeaderView.h
//  kdweibo
//
//  Created by laijiandong on 12-9-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDStatus.h"

@interface KDHeaderViewIndicatorView : UIView
+(id)indicatorWithText:(NSString *)text imageName:(NSString*)imageName;
- (id)initWithText:(NSString *)text imageName:(NSString*)imageName;
@end



@interface KDStatusHeaderView : UIView {
 @private
    UILabel *screenNameLabel_;
    UILabel *sourceLabel_;
    UILabel *timeLabel_;
//    UIImageView *indicatorView_;
//    UIImageView *backgroundView_;
//    UILabel *textLabel_;

}

- (void)updateWithStatus:(KDStatus *)status;

+ (CGFloat)optimalStatusHeaderHeight;

@end
