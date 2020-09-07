//
//  KDLetfMenuButton.h
//  KDLeftMenu
//
//  Created by 王 松 on 14-4-16.
//  Copyright (c) 2014年 Song.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDLeftMenuButtonModel : NSObject

@property (nonatomic, retain) NSString *title;

@property (nonatomic, assign) NSUInteger type;

@property (nonatomic, retain) UIImage *normalImage;

@property (nonatomic, retain) UIImage *highlightedImage;

+ (instancetype)model;

@end

@interface KDLeftMenuButton : UIButton

@property (nonatomic, retain) KDLeftMenuButtonModel *model;

+ (instancetype)buttonWithModel:(KDLeftMenuButtonModel *)model;

+ (instancetype)buttonWithTitle:(NSString *)title image:(UIImage *)image;

+ (instancetype)buttonWithTitle:(NSString *)title image:(UIImage *)image highlightedImage:(UIImage *)hImage;

@end


