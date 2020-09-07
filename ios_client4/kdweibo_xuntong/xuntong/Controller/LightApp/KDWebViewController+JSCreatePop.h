//
//  KDWebViewController+JSCreatePop.h
//  kdweibo
//
//  Created by shifking on 15/12/5.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//
#import "KDWebViewController.h"
#import "KDPlusMenuView.h"

@class KDJSBridgeTask;
//@class KDWebShareDataModel;
@interface KDWebViewController (JSCreatePop)
@property (strong , nonatomic) KDJSBridgeTask *createPopTask;
@property (assign , nonatomic) BOOL showingMenu;

/**
 *  初始化并显示可选菜单按钮
 *
 *  @param models 可选菜单item项，item为string类型。
 *  'forward'（转发）,'refresh'（刷新）,'share'（分享）,'openWithBrowser'（在浏览器中打开）。
 *  models = nil 则只显示系统菜单
 *  @param title 右上角标题。
 #  hiddenShare 调用JS桥showOptionMenu,隐藏分享、转发功能
 */
- (void)initialOptionMenuButtonWithMenuModels:(NSArray *)models withTitle:(NSString *)title hiddenShare:(BOOL)isHiddenShare;

/**
 *  可选按钮，默认系统菜单为（刷新、分享、转发、在浏览器打开）
 */
@property (nonatomic , strong , readonly) UIButton *optionMenuButton;

/**
 *  可选菜单，默认系统菜单为（刷新、分享、转发、在浏览器打开）
 */
@property (nonatomic, strong , readonly) KDPlusMenuView *optionMenuView;

/**
 *  js桥传过来的web分享数据
 */
@property (strong , nonatomic)  MessageNewsEachDataModel *jsShareData;

/**
 *  隐藏菜单面板
 */
- (void)hidePlusMenu;

/**
 *  显示菜单面板
 */
- (void)showPlusMenu;

/**
 *  创建右上角菜单
 */
- (void)createPop;
@end
