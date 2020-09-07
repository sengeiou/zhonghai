//
//  KDVoiceHostModeTipsView.h
//  kdweibo
//
//  Created by 张培增 on 2016/10/7.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^KDVoiceHostModeTipsViewClickedBlock)(void);
typedef void(^KDVoiceHostModeTipsViewCloseBlock)(void);

@interface KDVoiceHostModeTipsView : UIView

@property (nonatomic, copy) KDVoiceHostModeTipsViewClickedBlock clickedBlock;
@property (nonatomic, copy) KDVoiceHostModeTipsViewCloseBlock closeBlock;

@end
