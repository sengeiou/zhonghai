//
//  XTFilePreviewViewController.h
//  XT
//
//  Created by kingdee eas on 13-11-11.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTFilePreviewViewController : UIViewController

@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,copy) NSString *fileExt;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) FileModel *file;
@property (nonatomic,assign) BOOL isFromJSBridge;

@property (nonatomic, assign) BOOL isReadOnly;//是否只读文件,只读文件屏蔽右上角按钮

- (id)initWithFilePath:(NSString *)path andFileExt:(NSString *)ext;

@end
