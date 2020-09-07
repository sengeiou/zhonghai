//
//  KDTableViewHeaderFooterView.h
//  kdweibo
//
//  Created by Gil on 2016/10/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KDTableViewHeaderFooterViewStyle) {
    KDTableViewHeaderFooterViewStyleGray = 0,
    KDTableViewHeaderFooterViewStyleGrayWhite,
    KDTableViewHeaderFooterViewStyleWhite
};

@interface KDTableViewHeaderFooterView : UITableViewHeaderFooterView

@property (strong, nonatomic) NSString *title;

- (instancetype)initWithStyle:(KDTableViewHeaderFooterViewStyle)style;

+ (CGFloat)heightWithStyle:(KDTableViewHeaderFooterViewStyle)style;

@end
