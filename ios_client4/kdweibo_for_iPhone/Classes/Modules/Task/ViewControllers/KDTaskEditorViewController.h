//
//  KDTaskEditorViewController.h
//  kdweibo
//
//  Created by bird on 13-11-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDTaskEditorView.h"
#import "KDFrequentContactsPickViewController.h"

@protocol KDTaskEditorViewControllerDelegate <NSObject>

- (void)taskHasUpdated:(KDTask *)newTask;
@end

@interface KDTaskEditorViewController : UIViewController<TaskEditorViewAction>
{
    KDTaskEditorView *editorView_;
    KDTask          *task_;
    
    KDFrequentContactsPickViewController *executorsPickerVC_;
    KDFrequentContactsPickViewController *atSomeOneVC_;
}
@property (nonatomic, weak) id<KDTaskEditorViewControllerDelegate> delegate;
@property (nonatomic, assign) KDTaskPageInfoType type;
@property (nonatomic, retain) KDStatus *status;
- (id)initWithTask:(KDTask *)task;
@end
