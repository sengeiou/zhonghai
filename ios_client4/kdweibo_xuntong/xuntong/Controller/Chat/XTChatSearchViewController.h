//
//  XTChatSearchViewController.h
//  kdweibo
//
//  Created by bird on 14-7-29.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _SearchMode{
    SearchModeUnActive = 1,
    SearchModeActive = 2,
    SearchModeSearch = 3
}SearchMode;

@protocol XTChatSearchViewControllerDelegate <NSObject>

- (BOOL)isTopViewAnimation;
- (void)chatSearchViewWillPresent;
- (void)chatSearchViewWillDismiss;

- (UIView *)chatSearchViewPresentInMainView;
- (void)chatMessageDeleted:(NSString *)messageId group:(NSString *)groupId;
@end

@interface XTChatSearchViewController : UIViewController

@property (nonatomic, strong, readonly) UIView *topView;
@property (nonatomic, weak) UIViewController<XTChatSearchViewControllerDelegate> *controller;
@property (nonatomic, weak) GroupDataModel *group;
@property (nonatomic, assign) ChatMode  chatMode;
@property (nonatomic, assign) SearchMode mode;

- (void)dismissChatSearchView;
- (void)itemClick:(id)sender;
@end
