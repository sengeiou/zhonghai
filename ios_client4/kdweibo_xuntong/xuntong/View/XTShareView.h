//
//  XTShareView.h
//  XT
//
//  Created by Gil on 13-9-26.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTShareDataModel.h"

#define ShareViewSize CGSizeMake(ScreenFullWidth - 52.0, 222.0)

@protocol XTShareViewDelegate;
@interface XTShareView : UIView

- (id)initWithShareData:(XTShareDataModel *)shareData;

@property (nonatomic, strong, readonly) XTShareDataModel *shareData;
@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, strong) PersonSimpleDataModel *person;

@property (nonatomic, weak) id<XTShareViewDelegate> delegate;
@property (nonatomic, assign, readonly) int cancelButtonIndex;
@property (nonatomic, strong, readonly) UITextField *shareTextField;

@end

@interface XTShareStartView : XTShareView<UITextFieldDelegate>
@end

@interface XTShareFinishView : XTShareView

@end

@protocol XTShareViewDelegate <NSObject>

@optional
- (void)shareView:(XTShareView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end