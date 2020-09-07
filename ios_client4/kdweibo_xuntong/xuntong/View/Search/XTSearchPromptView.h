//
//  XTContactSearchPromptView.h
//  XT
//
//  Created by Gil on 13-7-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTSearchPromptView : UIView

@property (nonatomic, copy) NSString *title;

//readonly
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UIImageView *leftArrowImageView;
@property (nonatomic, strong, readonly) UIImageView *rightArrowImageView;

@end
