//
//  XTFileListViewController.h
//  XT
//
//  Created by kingdee eas on 13-11-1.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <objc/runtime.h>

@protocol XTMyFilesViewControllerDelegate;

@interface XTFileListViewController : UIViewController

@property (nonatomic,weak) id<XTMyFilesViewControllerDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *backTitleArr;
@property (nonatomic,strong) NSMutableArray *backFolderIDArr;
@property (nonatomic,strong) NSString *parentID;

@property (nonatomic, assign) int fromType;     //0:传输文件 1:应用 2:文件共享

- (id)initWithFolderId:(NSString *)folderID;


@end

