//
//  KDVideoPickerViewController.h
//  kdweibo
//
//  Created by 王 松 on 13-7-11.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDVideoPickerViewDelegate;

@interface KDVideoPickerViewController : UIViewController

@property (nonatomic, assign) id<KDVideoPickerViewDelegate> delegate;

- (id)initWithVideoPath:(NSString *)videoPath;

@end

@protocol KDVideoPickerViewDelegate <NSObject>

- (void)videoCaptureFinished:(BOOL) finish filePath:(NSString *) filePath;

@end
