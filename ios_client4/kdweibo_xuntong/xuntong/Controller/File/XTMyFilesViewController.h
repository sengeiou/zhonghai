//
//  XTMyFilesViewController.h
//  kdweibo
//
//  Created by bird on 14-10-15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDWebViewController.h"
@class DocumentFileModel;

@protocol XTMyFilesViewControllerDelegate <NSObject>
- (void)fileModelChanged;
- (void)fileDidSelected:(DocumentFileModel *)file;
- (void)fileDidReomved:(DocumentFileModel *)file;
- (BOOL)fileChecked:(DocumentFileModel *)file;
- (BOOL)isPreviewModel;
@end

@class XTMyFilesViewController;

@protocol XTMyFilesViewControllerJSBridgeDelegate <NSObject>
@optional
-(void)theSelectedFiles:(NSArray *)array;
@end

@interface XTMyFilesViewController : UIViewController <XTMyFilesViewControllerDelegate>
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) id <XTMyFilesViewControllerJSBridgeDelegate> JSBridgeDelegate;
@property (nonatomic, assign) int fromType;     //0:传输文件 1:应用 2:文件共享
@property (nonatomic, assign) BOOL fromJSBridge;      //V5.0之后从web唤醒
@property (nonatomic, strong) KDWebViewController *fromViewController;      //V5.0之后从web唤醒, 里层页面pop
@end

@protocol SendFileDelegate <NSObject>
- (void)sendShareFile:(NSDictionary *)dict;
@end