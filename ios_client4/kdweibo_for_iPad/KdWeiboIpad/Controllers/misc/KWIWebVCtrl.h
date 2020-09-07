//
//  KWIWebVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 6/7/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWIStatusVCtrl.h"
@interface KWIWebVCtrl : UIViewController

+ (KWIWebVCtrl *)vctrlWithUrl:(NSURL *)url;
@property(nonatomic,assign)KWIStatusVCtrl *statusVCtrl;
@end
