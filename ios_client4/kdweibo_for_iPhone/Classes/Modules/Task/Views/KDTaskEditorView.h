//
//  KDTaskEditorView.h
//  kdweibo
//
//  Created by bird on 13-11-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "KDPostActionMenuView.h"
#import "KDDatePickerViewController.h"
#import "KDUserPortraitGroupView.h"
#import "KDExpressionLabel.h"

typedef enum{
    KDTaskPageInfoUndefine =0,
    KDTaskPageDetailType,
    KDTaskPageEditorType
}KDTaskPageInfoType;


@class KDTask;
@class KDExpressionInputView;

@protocol TaskEditorViewAction <NSObject>

- (void)toAtViewController;
- (void)toTopicViewController;
@end
@protocol KDUserPortraitDelegate;
@interface KDTaskEditorView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView_;
    
    HPGrowingTextView *textView_;

    KDExpressionInputView *expressionInputView_;
    
    KDExpressionLabel   *taskContentView_;
    
    KDPostActionMenuView *actionMenuView_;
    
    UILabel *wordLimitLabel_;
    
    KDDatePickerViewController *datePicker_;
    
    NSMutableArray *executors_;
    
    NSDate *needFinishDate_;
    struct {
        unsigned int isExpressionViewShow:1;
        float textViewHeight;
        NSRange textRange;
        
    }flag_;
}
@property (nonatomic, retain) KDStatus *status;
@property (nonatomic, retain) KDTask *task;
@property (nonatomic, assign) KDTaskPageInfoType type;
@property (nonatomic, retain) id<TaskEditorViewAction,KDUserPortraitDelegate> delegate;
@property (nonatomic, retain, readonly) HPGrowingTextView *textView;
- (void)appendText:(NSString *)text;
- (void)updateExecutors:(NSArray *)executors;

- (BOOL)checkInfo;

- (NSString *)executorsIds;
- (NSString *)finishDate;
- (NSString *)content;
@end

#define USERPORTRAIT_TITLE_MARGIN 3.0f
@interface UserPortraitGroupCell : UITableViewCell
{
    UILabel *title_;
    KDUserPortraitGroupView *groupView_;
}
@property (nonatomic, retain, readonly) KDUserPortraitGroupView *groupView;
- (void)setUsers:(NSArray *)users;
@end
