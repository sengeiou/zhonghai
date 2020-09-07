//
//  KDGuideVC.h
//  kdweibo
//
//  Created by DarrenZheng on 14/12/2.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class KDGuideVC
//@protocol KDGuideVCDelegate <NSObject>
//
//- (void)animateGuidView:(KDGuideVC *)animateGuidView scrollToLast:(BOOL)flag;
//
//@end

@interface KDGuideVC : UIViewController

@property (nonatomic, copy) void (^blockDidPressEnterButton)(KDGuideVC *guideVC);
//@property (nonatomic, retain) id<KDGuideVCDelegate> delegate;

+ (BOOL)shouldShowGuideView;
@end

