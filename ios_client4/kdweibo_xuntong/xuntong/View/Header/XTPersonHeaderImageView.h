//
//  XTPersonHeaderImageView.h
//  XT
//
//  Created by Gil on 13-7-5.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@class PersonSimpleDataModel;
@interface XTPersonHeaderImageView : UIImageView

@property (nonatomic, assign) BOOL bSouldCompress;
@property (nonatomic, strong) PersonSimpleDataModel *person;
//@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, strong) UILabel *unActivatedLabel;

@property (nonatomic, assign) BOOL checkStatus;
//@property (nonatomic, strong) UIImageView *accountAvailableImageView;
@property (nonatomic, strong) UIImageView *xtAvailableImageView;
//@property (nonatomic, strong) UILabel *unActivatedLabel;

- (id)initWithFrame:(CGRect)frame checkStatus:(BOOL)checkStatus;
//- (id)initWithFrame:(CGRect)frame checkStatus:(BOOL)checkStatus withPublic:(BOOL)pub;

@end
