//
//  KDMessagePromptView.h
//  kdweibo_common
//
//  Created by Tan Yingqi on 13-12-17.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NEW_ICOMING_TAG  10211
#define SEND_ERROR_TAG   10212

@interface KDMessagePromptView : UIView {
    @protected
    NSDictionary *userInfo_;
}

@property(nonatomic,retain)NSDictionary *userInfo;
+ (void)showPromptViewInView:(UIView *)view tag:(NSInteger)tag userInfo:(NSDictionary *)info autoDismiss:(BOOL)autoDismiss;
- (void)dismiss:(BOOL)animation;
@end
