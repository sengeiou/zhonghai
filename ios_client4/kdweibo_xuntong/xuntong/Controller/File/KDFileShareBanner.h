//
//  KDFileShareBanner.h
//  kdweibo
//
//  Created by lichao_liu on 10/28/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^KDFileShareBannerBlock)(void);

@interface KDFileShareBanner : UIView
@property (nonatomic, strong) UILabel *titleLabel;
- (instancetype)initWithFrame:(CGRect)frame Block:(KDFileShareBannerBlock)block title:(NSString *)title;
- (void)makeMasory;

@end
