//
//  KDSignInShareSheetView.h
//  kdweibo
//
//  Created by lichao_liu on 9/2/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSignInRecord.h"
typedef NS_ENUM(NSInteger, KDSignInShareViewType) {
    KDSignInShareViewType_friend= 10,
    KDSignInShareViewType_buluo,
    KDSignInShareViewType_chat
};

typedef void(^KDSignInShareViewBlock)(KDSignInShareViewType type,KDSignInRecord *record);
@interface KDSignInShareSheetView : UIView
@property (nonatomic, copy) KDSignInShareViewBlock shareBlock;
@property (nonatomic, strong) KDSignInRecord *record;

- (void)showShareView;
- (void)hideShareView;

@end
