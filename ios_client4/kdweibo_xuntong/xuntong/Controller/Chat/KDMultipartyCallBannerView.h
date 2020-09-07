//
//  KDMultipartyCallBannerView.h
//  kdweibo
//
//  Created by Darren on 15/7/27.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDMultipartyCallBannerView : UIView

@property (nonatomic, copy) void (^blockButtonConfirmPressed)();
@property (nonatomic, strong) UILabel *labelTitle;

@end
