//
//  KDAgoraCallView.h
//  kdweibo
//
//  Created by lichao_liu on 8/5/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupDataModel.h"
typedef NS_ENUM(NSInteger, agoraCallViewOperationType) {
    agoraCallViewOperationType_ignore,
    agoraCallViewOperationType_answer
};
typedef void(^agoraCallViewBlock)(agoraCallViewOperationType type);

static NSInteger const KDAgoraCallViewTag = 900001;
@interface KDAgoraCallView : UIView

@property (nonatomic, strong) GroupDataModel *groupDataModel;
@property (nonatomic, copy) agoraCallViewBlock agoraCallViewBlock;


- (void)removeView;
@end
