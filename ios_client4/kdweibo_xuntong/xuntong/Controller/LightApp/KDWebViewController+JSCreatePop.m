//
//  KDWebViewController+JSCreatePop.m
//  kdweibo
//
//  Created by shifking on 15/12/5.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDWebViewController+JSCreatePop.h"
#import <objc/runtime.h>
#import "KDJSBridgeTask.h"
#import "NSString+Operate.h"
#import "KDWebViewController+JSBridge.h"
#import "KDWebViewController+Share.h"
#import "XTForwardDataModel.h"
#import "KDPlusMenuView.h"
#import "BOSConfig.h"

//系统默认菜单
static KDPlusMenuViewModel *forward_menu;
static KDPlusMenuViewModel *refresh_menu;
static KDPlusMenuViewModel *shareStatus_menu;
static KDPlusMenuViewModel *share_menu;
static KDPlusMenuViewModel *openInBrowser_menu;

@interface KDWebViewController ()
@property (strong , nonatomic) NSString *popBackId;
@property (nonatomic , strong) UIButton *optionMenuButton;
@property (nonatomic, strong) KDPlusMenuView *optionMenuView;
/**
 *  默认系统菜单（刷新、分享、转发、在浏览器打开）
 */
@property (strong , nonatomic) NSMutableArray *baseMenuModels;
@end

@implementation KDWebViewController (JSCreatePop)


- (void)createPop {
    NSArray *items = self.createPopTask.args[@"items"];
    NSString *title = self.createPopTask.args[@"popTitle"];
    NSString *popTitleCallBackId = self.createPopTask.args[@"popTitleCallBackId"];
    NSArray *menuList = self.createPopTask.args[@"menuList"];
    NSDictionary *shareDataDictionary = self.createPopTask.args[@"shareData"];
    if(popTitleCallBackId && ![popTitleCallBackId isKindOfClass:[NSNull class]])
    {
        [self addCreatePopRightBarItemWithItemsArray:items andBtnTitle:title popBackId:popTitleCallBackId withMenuList:menuList];
        [self initialJSShareDataModelWithDictionary:shareDataDictionary];
    }
}


- (void)addCreatePopRightBarItemWithItemsArray:(NSArray *)items andBtnTitle:(NSString *)title popBackId:(NSString*)popBackId withMenuList:(NSArray *)menus
{
    self.popBackId = popBackId;
    NSArray *mArray = [self setupOptionMenuWithItems:items menus:menus];
    [self initialOptionMenuButtonWithMenuModels:mArray withTitle:title hiddenShare:NO];
}

//判断右上角title是否有效
- (BOOL)rightButtonTitleAvailable:(NSString *)title {
    if (!title || title.length > 4 || ![NSString isAllChineseChar:title]) return NO;
    
    return YES;
}

- (NSArray *)setupOptionMenuWithItems:(NSArray *)items menus:(NSArray *)menus{
    NSMutableArray *mArray = @[].mutableCopy;
    NSMutableArray *baseMenus = @[].mutableCopy;
    
    if (menus && menus.count > 0 && self.baseMenuModels) {
        for (NSString *title in menus) {
            if ([title isEqualToString:@"refresh"]) {
                [baseMenus addObject:refresh_menu];
            }
            // JS createPop桥 屏蔽转发
//            if ([title isEqualToString:@"forward"]) {
//                [baseMenus addObject:forward_menu];
//            }
            if ([title isEqualToString:@"shareStatus"]) {
                [baseMenus addObject:shareStatus_menu];
            }
            
            if ([title isEqualToString:@"share"]) {
                [baseMenus addObject:share_menu];
            }
            
            // baseMenuModels有可能少于4个，所以不能直接取第四个
            if ([title isEqualToString:@"openWithBrowser"]) {
                [baseMenus addObject:openInBrowser_menu];
            }
        }
        
    }
    NSInteger menuCount = (baseMenus) ? (baseMenus.count) : (0);
    
    if(items && items.count>0)
    {
        __weak KDWebViewController *weakSelf = self;
        
        for (NSInteger i = 0 ; i < items.count ; i++) {
            //最多允许7个菜单项
            if (i + menuCount >= 7 ) break;
            
            NSDictionary *dict = items[i];
            NSString *title = dict[@"text"];
            NSString *callBackId = dict[@"callBackId"];
            if(title && callBackId)
            {
                [mArray addObject:[KDPlusMenuViewModel modelWithTitle:title
                                                       base64StrImage:nil
                                                            selection:^
                                   {
                                       NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:callBackId, @"callBackId", nil];
                                       NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, data, Data, nil];
                                       [weakSelf returnResult:weakSelf.createPopTask.callbackId args:argDic];
                                       [self hidePlusMenu];
                                   }]];
            }
        }
    }
    
    if (baseMenus && baseMenus.count > 0) {
        [mArray addObjectsFromArray:baseMenus];
    }
    
    return mArray;
    
}



#pragma mark - event response
- (void)initialOptionMenuButtonWithMenuModels:(NSArray *)models withTitle:(NSString *)title hiddenShare:(BOOL)isHiddenShare {
    if (self.optionMenuView) {
        [self.optionMenuView removeFromSuperview];
        self.optionMenuView = nil;
    }
    self.optionMenuButton = nil;
    self.jsShareData = nil;
    
    //显示系统菜单
    if (models == nil) {
        self.optionMenuView.mArrayModels = isHiddenShare ? [self JSbaseMenuModels] : self.baseMenuModels;
        self.optionMenuButton = [self optionMenuButtonWithImage];
    }
    //显示可选菜单
    else {
        //title有效，替换掉三个点图片
        if ([self rightButtonTitleAvailable:title]){
            //设置title
            self.optionMenuButton = [self optionMenuButtonWithAvailableTitle:title];
        }
        else {
            self.optionMenuButton = [self optionMenuButtonWithImage];
        }
        if (models.count > 0) {
            self.optionMenuView.mArrayModels = [NSMutableArray arrayWithArray:models];
        }
    }

    UIBarButtonItem *barButton =  [[UIBarButtonItem alloc] initWithCustomView:self.optionMenuButton];
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = barButton;
    [AppWindow addSubview:self.optionMenuView];
}

//初始化分享数据
- (void)initialJSShareDataModelWithDictionary:(NSDictionary *)dictionary {
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]] && ![dictionary isKindOfClass:[NSNull class]]) {
        self.jsShareData = [[MessageNewsEachDataModel alloc] initWithDictionary:dictionary];
    }
}

- (void)clickPopOptionMenuAction:(UIButton *)button {
    if (self.showingMenu) {
        [self hidePlusMenu];
    }
    else {
        [self showPlusMenu];
        [self popBackItemClicked:nil];
    }
}

- (void)popBackItemClicked:(id)sender
{
    if(self.popBackId && self.popBackId.length>0)
    {
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:self.popBackId, @"callBackId", nil];
        NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, data, Data, nil];
        [self returnResult:self.createPopTask.callbackId args:argDic];
    }
}


- (void)showPlusMenu {
    if (!self.showingMenu && self.optionMenuView && self.optionMenuView.mArrayModels && self.optionMenuView.mArrayModels.count >0 ) {
        [self.optionMenuView restoreTable];
        [UIView animateWithDuration:.25 animations:^
         {
             self.optionMenuView.alpha = 1;
         }];
        self.showingMenu = YES;
    }
}

- (void)hidePlusMenu {
    if (self.showingMenu){
        [UIView animateWithDuration:.25 animations:^
         {
             self.optionMenuView.alpha = 0;
             [self.optionMenuView shrinkTable];
         }];
        self.showingMenu = NO;
    }
}

//转发
- (void)forwardMessage {
    [self shareActionWithTitle:ASLocalizedString(@"KDStatusDetailViewController_Forward")];
}

//刷新
- (void)refresh {
    [self.webView reload];
}


#pragma mark - setter & getter 

- (NSString *)popBackId {
    return objc_getAssociatedObject(self, @selector(popBackId));
}

- (void)setPopBackId:(NSString *)popBackId {
    objc_setAssociatedObject(self, @selector(popBackId), popBackId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCreatePopTask:(KDJSBridgeTask *)createPopTask {
    objc_setAssociatedObject(self, @selector(createPopTask), createPopTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KDJSBridgeTask *)createPopTask {
    return objc_getAssociatedObject(self, @selector(createPopTask));
}


- (UIButton *)optionMenuButtonWithAvailableTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = FS3;
    if (![self isWhileNav]) {
        [button setTitleColor:FC6 forState:UIControlStateNormal];
    }
    else {
        [button setTitleColor:FC5 forState:UIControlStateNormal];
    }
    [button setTitle:title forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(clickPopOptionMenuAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)optionMenuButtonWithImage {
    UIButton *button ;
    if (![self isWhileNav]) {
        button = [UIButton btnInNavWithImage:[UIImage imageNamed:@"nav_btn_more_white_normal"] highlightedImage:[UIImage imageNamed:@"nav_btn_more_press"]];
    }
    else {
        button = [UIButton btnInNavWithImage:[UIImage imageNamed:@"nav_btn_more_normal"] highlightedImage:[UIImage imageNamed:@"nav_btn_more_press"]];
    }
    [button addTarget:self action:@selector(clickPopOptionMenuAction:) forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (UIButton *)optionMenuButton {
    UIButton *button = objc_getAssociatedObject(self, @selector(optionMenuButton));
    return button;
}

- (void)setOptionMenuButton:(UIButton *)optionMenuButton {
    objc_setAssociatedObject(self, @selector(optionMenuButton), optionMenuButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)baseMenuModels {
    NSMutableArray *models = objc_getAssociatedObject(self, @selector(baseMenuModels));
    if (models) return models;
    models = [[NSMutableArray alloc] init];
    __weak KDWebViewController *weak_Self = self;
    
    forward_menu = [KDPlusMenuViewModel modelWithTitle:@"转发"
                                        base64StrImage:nil
                                             selection:^
                    {
                        [weak_Self forwardMessage];
                        [weak_Self hidePlusMenu];
                    }];
    
    refresh_menu = [KDPlusMenuViewModel modelWithTitle:@"刷新"
                                        base64StrImage:nil
                                             selection:^
                    {
                        [weak_Self refresh];
                        [weak_Self hidePlusMenu];
                    }];
    
    shareStatus_menu = [KDPlusMenuViewModel modelWithTitle:@"分享到动态"
                                            base64StrImage:nil
                                                 selection:^
                        {
                            [weak_Self shareToCommunity];
                            [weak_Self hidePlusMenu];
                        }];
    
    share_menu = [KDPlusMenuViewModel modelWithTitle:@"分享到其他"
                                      base64StrImage:nil
                                           selection:^
                  {
                      [weak_Self shareToSocial];
                      [weak_Self hidePlusMenu];
                  }];
    
    openInBrowser_menu = [KDPlusMenuViewModel modelWithTitle:@"在浏览器打开"
                                              base64StrImage:nil
                                                   selection:^
                          {
                              [weak_Self geturltoweb];
                              [weak_Self hidePlusMenu];
                          }];
    NSString *token = [BOSConfig sharedConfig].user.token;
    MessageNewsEachDataModel *shareData = [self getCurrentPageShareData];
    KDPublicAccountDataModel *pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:shareData.appId];
    if(!pubacc && [self.personDataModel isPublicAccount])
        pubacc = (KDPublicAccountDataModel *)(self.personDataModel);
    
    BOOL canInnerShare = NO;
    BOOL canOuterShare = NO;
    if(pubacc)
    {
        canInnerShare = [pubacc allowInnerShare];
        canOuterShare = [pubacc allowOuterShare];
    }
    else
    {
        canInnerShare = [BOSSetting sharedSetting].allowMsgInnerMobileShare;
        canOuterShare = [BOSSetting sharedSetting].allowMsgOuterMobileShare;
    }
    
    
    //未登陆
    if (!token || token.length <= 0) {
        [models addObject:refresh_menu];
        if(canInnerShare)
        {
            [models addObject:shareStatus_menu];
        }
        //zgbin:屏蔽“分享到其他”和“在浏览器打开”
//        if(canOuterShare)
//        {
//            [models addObject:share_menu];
//            [models addObject:openInBrowser_menu];
//        }
        //zgbin:end
    }
    else {
        [models addObject:refresh_menu];
        if(canInnerShare)
        {
            [models addObject:forward_menu];
            
            if ([BOSConfig sharedConfig].user.partnerType != 1)
                [models addObject:shareStatus_menu];
        }
        //zgbin:屏蔽“分享到其他”和“在浏览器打开”
//        if(canOuterShare)
//        {
//            [models addObject:share_menu];
//            [models addObject:openInBrowser_menu];
//        }
        //zgbin:end
    }
    
    if (self.isOnlyOpenInBrowser) {
        [models removeAllObjects];
        //zgbin:屏蔽“分享到其他”和“在浏览器打开”
//        [models addObjectsFromArray:@[openInBrowser_menu]];
        //end
    }
    [self setBaseMenuModels:models];
    return models;
}

- (NSMutableArray *)JSbaseMenuModels {
    NSMutableArray *models  = [[NSMutableArray alloc] init];
    __weak KDWebViewController *weak_Self = self;
    
    refresh_menu = [KDPlusMenuViewModel modelWithTitle:@"刷新"
                                        base64StrImage:nil
                                             selection:^
                    {
                        [weak_Self refresh];
                        [weak_Self hidePlusMenu];
                    }];
    
    openInBrowser_menu = [KDPlusMenuViewModel modelWithTitle:@"在浏览器打开"
                                              base64StrImage:nil
                                                   selection:^
                          {
                              [weak_Self geturltoweb];
                              [weak_Self hidePlusMenu];
                          }];
    
    MessageNewsEachDataModel *shareData = [self getCurrentPageShareData];
    KDPublicAccountDataModel *pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:shareData.appId];
    if(!pubacc && [self.personDataModel isPublicAccount])
        pubacc = (KDPublicAccountDataModel *)(self.personDataModel);
    
    BOOL canOuterShare = NO;
    if(pubacc)
    {
        canOuterShare = [pubacc allowOuterShare];
    }
    else
    {
        canOuterShare = [BOSSetting sharedSetting].allowMsgOuterMobileShare;
    }
    
    
    [models addObject:refresh_menu];
    
    if (canOuterShare) {
        [models addObject:openInBrowser_menu];
    }
    
    if (self.isOnlyOpenInBrowser) {
        [models removeAllObjects];
        [models addObjectsFromArray:@[openInBrowser_menu]];
    }
    return models;
}

- (void)setBaseMenuModels:(NSMutableArray *)baseMenuModels {
    objc_setAssociatedObject(self, @selector(baseMenuModels), baseMenuModels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setBasePlusMenuView:(KDPlusMenuView *)basePlusMenuView {
    objc_setAssociatedObject(self, @selector(basePlusMenuView), basePlusMenuView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KDPlusMenuView *)optionMenuView {
    KDPlusMenuView *menuView = objc_getAssociatedObject(self, @selector(optionMenuView));

    if (menuView) return menuView;
    
    __weak KDWebViewController *weakSelf = self;
    menuView.mArrayModels = @[].mutableCopy;
    menuView = [[KDPlusMenuView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, ScreenFullHeight)];
    menuView.backgroundPressed = ^
    {
        [weakSelf hidePlusMenu];
    };
    menuView.alpha = 0;
    [self setOptionMenuView:menuView];
    return menuView;
}

- (void)setOptionMenuView:(KDPlusMenuView *)optionMenuView {
    objc_setAssociatedObject(self, @selector(optionMenuView), optionMenuView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setShowingMenu:(BOOL)showingMenu {
    objc_setAssociatedObject(self, @selector(showingMenu), @(showingMenu), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)showingMenu {
    NSNumber *temp = objc_getAssociatedObject(self, @selector(showingMenu));
    if (!temp) return NO;
    return [temp boolValue];
}

- (void)setJsShareData:(MessageNewsEachDataModel *)jsShareData {
    objc_setAssociatedObject(self, @selector(jsShareData), jsShareData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MessageNewsEachDataModel *)jsShareData {
    return objc_getAssociatedObject(self, @selector(jsShareData));
}
@end
