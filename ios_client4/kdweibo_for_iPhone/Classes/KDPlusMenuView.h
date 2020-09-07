//
//  KDPlusMenuView.h
//  kdweibo
//
//  Created by Darren on 15/5/20.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDPlusMenuView : UIView


// @[KDPlusMenuViewModel]
@property (nonatomic, strong) NSMutableArray *mArrayModels;
@property (nonatomic, strong) void (^backgroundPressed)();
- (void)shrinkTable;
- (void)restoreTable;
@end

//////////////////////////////////////////////////////////////////////////

@interface KDPlusMenuViewModel : NSObject

@property (nonatomic, strong) NSString *strImageName;
@property (nonatomic, strong) NSString *strTitle;
@property (nonatomic, strong) NSString *base64StrImage;
@property (nonatomic, strong) void (^selection)();

+ (KDPlusMenuViewModel *)modelWithTitle:(NSString *)strTitle
                              imageName:(NSString *)strImageName
                              selection:(void (^)())block;
+ (KDPlusMenuViewModel *)modelWithTitle:(NSString *)strTitle
                         base64StrImage:(NSString *)base64StrImage
                              selection:(void (^)())block;
@end
